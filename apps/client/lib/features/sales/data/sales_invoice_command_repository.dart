import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/documents/data/local_document_number_service.dart';
import 'package:billing_baba/features/sales/data/sales_document_payload_builder.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _salesDocumentsEntity = 'sales_documents';
const _salesDocumentLinesEntity = 'sales_document_lines';

/// Local-first tax invoice writes + SyncQueue enqueue (hybrid ADR-025).
class SalesInvoiceCommandRepository {
  SalesInvoiceCommandRepository({
    required this._local,
    required this._syncQueue,
    required this._numbering,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final SalesLocalDataSource _local;
  final SyncQueue _syncQueue;
  final LocalDocumentNumberService _numbering;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for sales invoice operations');
    }
    return id;
  }

  Future<SalesDocumentDto> saveDraft(
    SalesDocumentDraftInput input, {
    required Map<String, String> itemNameToId,
  }) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final documentId = input.documentId ?? _uuid.v4();
    final isCreate = input.documentId == null;

    final existing = isCreate ? null : await _local.getDocument(documentId);
    final documentNumber = existing?.documentNumber ??
        await _numbering.allocate(
          businessId: businessId,
          documentSeries: input.documentSeries,
        );

    final totals = computeSalesTotals(
      items: input.items,
      taxOption: input.taxOption,
    );
    final documentDate = apiDocumentDateFromInput(
      documentDate: input.documentDate,
      documentTime: input.documentTime,
    );

    await _local.upsertDocument(
      id: documentId,
      businessId: businessId,
      documentType: SalesDocumentType.taxInvoice.apiValue,
      status: 'draft',
      documentNumber: documentNumber,
      documentSeries: input.documentSeries,
      partyId: input.partyId,
      isGstFormal: input.isGstFormal,
      subtotal: totals.subtotal,
      discountTotal: totals.discountTotal,
      taxAmount: totals.taxAmount,
      totalAmount: totals.totalAmount,
      documentDate: documentDate,
      convertedFromId: input.convertedFromId,
      notes: input.notes,
      godownId: input.godownId,
      syncVersion: existing == null
          ? 0
          : (await _local.getHeaderSyncVersion(documentId) ?? 0),
      createdAt: existing == null ? now : DateTime.parse(existing.createdAt).toUtc(),
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );

    final lineRows = <SalesDocumentLineLocalData>[];
    var sortOrder = 0;
    for (final item in input.items) {
      final itemId = item.itemId ?? itemNameToId[item.itemName];
      if (itemId == null || itemId.isEmpty) continue;
      final lineId = item.serverLineId ?? item.id;
      lineRows.add(
        SalesDocumentLineLocalData(
          id: lineId,
          businessId: businessId,
          salesDocumentId: documentId,
          itemId: itemId,
          quantity: money(item.qty),
          unit: item.unit,
          unitPrice: money(item.pricePerUnit),
          marketPrice: item.mrp > 0 ? money(item.mrp) : null,
          discountAmount: money(
            item.qty * item.pricePerUnit * item.discountPercent / 100,
          ),
          taxType: item.taxPercent > 0 ? 'gst' : 'none',
          taxRate: money(item.taxPercent),
          cgstAmount: money(item.lineTax / 2),
          sgstAmount: money(item.lineTax / 2),
          igstAmount: '0',
          lineTotal: money(item.amount),
          sortOrder: sortOrder++,
          syncVersion: 0,
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
          deviceId: _deviceIdReader?.call(),
        ),
      );
    }
    await _local.replaceLines(
      businessId: businessId,
      salesDocumentId: documentId,
      lines: lineRows,
    );

    final headerPayload = buildSalesDocumentRowPayload(
      documentType: SalesDocumentType.taxInvoice.apiValue,
      documentSeries: input.documentSeries,
      partyId: input.partyId,
      isGstFormal: input.isGstFormal,
      documentNumber: documentNumber,
      documentDate: documentDate,
      convertedFromId: input.convertedFromId,
      notes: input.notes,
      subtotal: totals.subtotal,
      discountTotal: totals.discountTotal,
      taxAmount: totals.taxAmount,
      totalAmount: totals.totalAmount,
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      entityType: _salesDocumentsEntity,
      entityId: documentId,
      operation: isCreate
          ? SyncQueueOperation.create
          : SyncQueueOperation.update,
      payload: headerPayload,
      deviceId: _deviceIdReader?.call(),
      priority: SyncQueuePriority.high,
      baseSyncVersion: isCreate
          ? 0
          : (await _local.getHeaderSyncVersion(documentId) ?? 0),
      clientUpdatedAt: now,
    );

    for (final item in input.items) {
      final itemId = item.itemId ?? itemNameToId[item.itemName];
      if (itemId == null || itemId.isEmpty) continue;
      final lineId = item.serverLineId ?? item.id;
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        entityType: _salesDocumentLinesEntity,
        entityId: lineId,
        operation: item.serverLineId == null
            ? SyncQueueOperation.create
            : SyncQueueOperation.update,
        payload: buildSalesLineRowPayload(
          salesDocumentId: documentId,
          itemId: itemId,
          item: item,
          sortOrder: lineRows.indexWhere((l) => l.id == lineId),
          taxOption: input.taxOption,
        ),
        deviceId: _deviceIdReader?.call(),
        clientUpdatedAt: now,
      );
    }

    return (await _local.getDocument(documentId))!;
  }

  Future<void> finalize({
    required String documentId,
    String? localDocumentNumber,
    String? godownId,
  }) async {
    final businessId = _requireBusinessId();
    final document = await _local.getDocument(documentId);
    if (document == null) {
      throw StateError('Sales document not found locally');
    }

    final localNumber =
        localDocumentNumber ?? document.documentNumber ?? 'LOCAL-000001';
    final commandId = _uuid.v4();

    await _syncQueue.enqueueCommand(
      businessId: businessId,
      command: 'finalize_sale',
      commandId: commandId,
      payload: {
        'document_id': documentId,
        'local_document_number': localNumber,
        'godown_id': ?godownId,
      },
      deviceId: _deviceIdReader?.call(),
      entityType: _salesDocumentsEntity,
      entityId: documentId,
      priority: SyncQueuePriority.high,
    );
  }

  Future<List<SalesDocumentDto>> listTaxInvoices() {
    return _local.listByType(
      businessId: _requireBusinessId(),
      documentType: SalesDocumentType.taxInvoice.apiValue,
    );
  }

  Future<SalesDocumentDto?> getDocument(String id) => _local.getDocument(id);
}
