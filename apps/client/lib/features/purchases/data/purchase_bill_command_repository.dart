import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/documents/data/local_document_number_service.dart';
import 'package:billing_baba/features/purchases/data/purchase_document_payload_builder.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_document_draft_input.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _purchaseDocumentsEntity = 'purchase_documents';
const _purchaseDocumentLinesEntity = 'purchase_document_lines';

/// Local-first purchase bill writes + SyncQueue enqueue (hybrid ADR-025).
class PurchaseBillCommandRepository {
  PurchaseBillCommandRepository({
    required this._local,
    required this._syncQueue,
    required this._numbering,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final PurchaseLocalDataSource _local;
  final SyncQueue _syncQueue;
  final LocalDocumentNumberService _numbering;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for purchase bill operations');
    }
    return id;
  }

  Future<PurchaseDocumentDto> saveDraft(
    PurchaseDocumentDraftInput input, {
    required Map<String, String> itemNameToId,
  }) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final documentId = input.documentId ?? _uuid.v4();
    final isCreate = input.documentId == null;
    final partyId = input.partyId;
    if (partyId == null || partyId.isEmpty) {
      throw StateError('Party is required for purchase bills');
    }

    final existing = isCreate ? null : await _local.getDocument(documentId);
    final documentNumber = existing?.documentNumber ??
        await _numbering.allocate(
          businessId: businessId,
          documentSeries: input.documentSeries,
        );

    final totals = computePurchaseTotals(input.items);
    final documentDate = purchaseApiDocumentDate(
      documentDate: input.documentDate,
      documentTime: input.documentTime,
    );

    await _local.upsertDocument(
      id: documentId,
      businessId: businessId,
      documentType: PurchaseDocumentType.purchaseBill.apiValue,
      status: 'draft',
      documentNumber: documentNumber,
      documentSeries: input.documentSeries,
      partyId: partyId,
      isGstFormal: input.isGstFormal,
      subtotal: totals.subtotal,
      discountTotal: totals.discountTotal,
      taxAmount: totals.taxAmount,
      totalAmount: totals.totalAmount,
      documentDate: documentDate,
      convertedFromId: input.convertedFromId,
      supplierInvoiceNumber: input.supplierInvoiceNumber,
      dueDate: input.dueDate?.toIso8601String().split('T').first,
      notes: input.notes,
      godownId: input.godownId,
      syncVersion:
          isCreate ? 0 : (await _local.getHeaderSyncVersion(documentId) ?? 0),
      createdAt: existing == null
          ? now
          : DateTime.parse(existing.createdAt).toUtc(),
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );

    final lineRows = <PurchaseDocumentLineLocalData>[];
    var sortOrder = 0;
    for (final item in input.items) {
      final itemId = item.itemId ?? itemNameToId[item.itemName];
      if (itemId == null || itemId.isEmpty) continue;
      final lineId = item.serverLineId ?? item.id;
      lineRows.add(
        PurchaseDocumentLineLocalData(
          id: lineId,
          businessId: businessId,
          purchaseDocumentId: documentId,
          itemId: itemId,
          quantity: purchaseMoney(item.qty),
          unit: item.unit,
          unitPrice: purchaseMoney(item.pricePerUnit),
          discountAmount: '0',
          taxType: item.taxPercent > 0 ? 'gst' : 'none',
          taxRate: purchaseMoney(item.taxPercent),
          cgstAmount: purchaseMoney(item.lineTax / 2),
          sgstAmount: purchaseMoney(item.lineTax / 2),
          igstAmount: '0',
          lineTotal: purchaseMoney(item.amount),
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
      purchaseDocumentId: documentId,
      lines: lineRows,
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      entityType: _purchaseDocumentsEntity,
      entityId: documentId,
      operation: isCreate
          ? SyncQueueOperation.create
          : SyncQueueOperation.update,
      payload: buildPurchaseDocumentRowPayload(
        documentType: PurchaseDocumentType.purchaseBill.apiValue,
        documentSeries: input.documentSeries,
        partyId: partyId,
        isGstFormal: input.isGstFormal,
        documentNumber: documentNumber,
        documentDate: documentDate,
        convertedFromId: input.convertedFromId,
        supplierInvoiceNumber: input.supplierInvoiceNumber,
        dueDate: input.dueDate?.toIso8601String().split('T').first,
        notes: input.notes,
        subtotal: totals.subtotal,
        discountTotal: totals.discountTotal,
        taxAmount: totals.taxAmount,
        totalAmount: totals.totalAmount,
      ),
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
        entityType: _purchaseDocumentLinesEntity,
        entityId: lineId,
        operation: item.serverLineId == null
            ? SyncQueueOperation.create
            : SyncQueueOperation.update,
        payload: buildPurchaseLineRowPayload(
          purchaseDocumentId: documentId,
          itemId: itemId,
          item: item,
          sortOrder: lineRows.indexWhere((l) => l.id == lineId),
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
      throw StateError('Purchase document not found locally');
    }

    final localNumber =
        localDocumentNumber ?? document.documentNumber ?? 'LOCAL-000001';

    await _syncQueue.enqueueCommand(
      businessId: businessId,
      command: 'finalize_purchase',
      commandId: _uuid.v4(),
      payload: {
        'document_id': documentId,
        'local_document_number': localNumber,
        'godown_id': ?godownId,
      },
      deviceId: _deviceIdReader?.call(),
      entityType: _purchaseDocumentsEntity,
      entityId: documentId,
      priority: SyncQueuePriority.high,
    );
  }

  Future<List<PurchaseDocumentDto>> listPurchaseBills() {
    return _local.listByType(
      businessId: _requireBusinessId(),
      documentType: PurchaseDocumentType.purchaseBill.apiValue,
    );
  }

  Future<PurchaseDocumentDto?> getDocument(String id) => _local.getDocument(id);
}
