import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/documents/data/local_document_number_service.dart';
import 'package:billing_baba/features/sales/data/sales_document_payload_builder.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _salesDocumentsEntity = 'sales_documents';
const _salesDocumentLinesEntity = 'sales_document_lines';

/// Local-first sales return (credit note) writes + SyncQueue enqueue.
class SalesReturnCommandRepository {
  SalesReturnCommandRepository({
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
      throw StateError('No business selected for sales return operations');
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
    final existingLineIds = existing == null
        ? <String>{}
        : existing.lines.map((line) => line.id).toSet();

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
      documentType: SalesDocumentType.salesReturn.apiValue,
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
      paidAmount: existing?.paidAmount ?? '0',
      paymentMode: existing?.paymentMode,
      syncVersion: existing == null
          ? 0
          : (await _local.getHeaderSyncVersion(documentId) ?? 0),
      createdAt: existing == null
          ? now
          : DateTime.parse(existing.createdAt).toUtc(),
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

    final newLineIds = lineRows.map((line) => line.id).toSet();
    final removedLineIds = existingLineIds.difference(newLineIds);
    for (final removedId in removedLineIds) {
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        entityType: _salesDocumentLinesEntity,
        entityId: removedId,
        operation: SyncQueueOperation.delete,
        payload: {},
        deviceId: _deviceIdReader?.call(),
        clientUpdatedAt: now,
      );
    }

    await _local.replaceLines(
      businessId: businessId,
      salesDocumentId: documentId,
      lines: lineRows,
    );

    final headerPayload = buildSalesDocumentRowPayload(
      documentType: SalesDocumentType.salesReturn.apiValue,
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
    FinalizeSalePaymentCommand? payment,
  }) async {
    final businessId = _requireBusinessId();
    final document = await _local.getDocument(documentId);
    if (document == null) {
      throw StateError('Sales return not found locally');
    }

    final localNumber =
        localDocumentNumber ?? document.documentNumber ?? 'LOCAL-000001';
    final now = DateTime.now().toUtc();
    final paidAmount = payment?.amount ?? '0';
    final paymentMode = payment?.paymentMode;

    await _local.upsertDocument(
      id: documentId,
      businessId: businessId,
      documentType: document.documentType,
      status: 'finalized',
      documentNumber: document.documentNumber,
      documentSeries: document.documentSeries,
      partyId: document.partyId,
      isGstFormal: document.isGstFormal,
      subtotal: document.subtotal,
      discountTotal: document.discountTotal,
      taxAmount: document.taxAmount,
      totalAmount: document.totalAmount,
      documentDate: document.documentDate,
      convertedFromId: document.convertedFromId,
      notes: document.notes,
      paidAmount: paidAmount,
      paymentMode: paymentMode,
      syncVersion: await _local.getHeaderSyncVersion(documentId) ?? 0,
      createdAt: DateTime.parse(document.createdAt).toUtc(),
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );

    final commandPayload = <String, dynamic>{
      'document_id': documentId,
      'local_document_number': localNumber,
      'godown_id': ?godownId,
    };

    if (payment != null &&
        double.tryParse(payment.amount) != null &&
        double.parse(payment.amount) > 0) {
      commandPayload['payment'] = {
        'amount': payment.amount,
        'payment_mode': payment.paymentMode,
      };
    }

    await _syncQueue.enqueueCommand(
      businessId: businessId,
      command: 'finalize_credit_note',
      commandId: _uuid.v4(),
      payload: commandPayload,
      deviceId: _deviceIdReader?.call(),
      entityType: _salesDocumentsEntity,
      entityId: documentId,
      priority: SyncQueuePriority.high,
    );
  }

  Future<void> deleteDraft(String documentId) async {
    final businessId = _requireBusinessId();
    final document = await _local.getDocument(documentId);
    if (document == null) {
      return;
    }

    final now = DateTime.now().toUtc();
    await _local.softDeleteDocument(documentId, now);

    final headerSyncVersion =
        await _local.getHeaderSyncVersion(documentId) ?? 0;

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      entityType: _salesDocumentsEntity,
      entityId: documentId,
      operation: SyncQueueOperation.delete,
      payload: {},
      deviceId: _deviceIdReader?.call(),
      baseSyncVersion: headerSyncVersion,
      clientUpdatedAt: now,
    );

    for (final line in document.lines) {
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        entityType: _salesDocumentLinesEntity,
        entityId: line.id,
        operation: SyncQueueOperation.delete,
        payload: {},
        deviceId: _deviceIdReader?.call(),
        clientUpdatedAt: now,
      );
    }
  }

  Future<List<SalesDocumentDto>> listSalesReturns() {
    return _local.listByType(
      businessId: _requireBusinessId(),
      documentType: SalesDocumentType.salesReturn.apiValue,
    );
  }

  Future<SalesDocumentDto?> getDocument(String id) => _local.getDocument(id);
}
