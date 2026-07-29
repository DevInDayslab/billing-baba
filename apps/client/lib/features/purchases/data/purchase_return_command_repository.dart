import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/documents/data/local_document_number_service.dart';
import 'package:billing_baba/features/inventory/data/inventory_document_stock_applier.dart';
import 'package:billing_baba/features/purchases/data/purchase_bill_command_repository.dart';
import 'package:billing_baba/features/purchases/data/purchase_document_payload_builder.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_document_draft_input.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/shared/documents/document_line_id.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _purchaseDocumentsEntity = 'purchase_documents';
const _purchaseDocumentLinesEntity = 'purchase_document_lines';

/// Local-first purchase return (debit note) writes + SyncQueue enqueue.
class PurchaseReturnCommandRepository {
  PurchaseReturnCommandRepository({
    required this._local,
    required this._syncQueue,
    required this._numbering,
    required this._businessIdReader,
    this._deviceIdReader,
    this._stockApplier,
  });

  final PurchaseLocalDataSource _local;
  final SyncQueue _syncQueue;
  final LocalDocumentNumberService _numbering;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;
  final InventoryDocumentStockApplier? _stockApplier;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for purchase return operations');
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
      throw StateError('Party is required for purchase returns');
    }

    final existing = isCreate ? null : await _local.getDocument(documentId);
    final existingLineIds = existing == null
        ? <String>{}
        : existing.lines.map((line) => line.id).toSet();

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
      documentType: PurchaseDocumentType.purchaseReturn.apiValue,
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
      paidAmount: existing?.paidAmount ?? '0',
      paymentMode: existing?.paymentMode,
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
      final lineId = ensureDocumentLineId(item.serverLineId ?? item.id);
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

    final newLineIds = lineRows.map((line) => line.id).toSet();
    final removedLineIds = existingLineIds.difference(newLineIds);
    for (final removedId in removedLineIds) {
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        entityType: _purchaseDocumentLinesEntity,
        entityId: removedId,
        operation: SyncQueueOperation.delete,
        payload: {},
        deviceId: _deviceIdReader?.call(),
        clientUpdatedAt: now,
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
        documentType: PurchaseDocumentType.purchaseReturn.apiValue,
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
      final lineId = ensureDocumentLineId(item.serverLineId ?? item.id);
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
    FinalizePurchasePaymentCommand? payment,
  }) async {
    final businessId = _requireBusinessId();
    final document = await _local.getDocument(documentId);
    if (document == null) {
      throw StateError('Purchase return not found locally');
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
      supplierInvoiceNumber: document.supplierInvoiceNumber,
      dueDate: document.dueDate,
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
      command: 'finalize_debit_note',
      commandId: _uuid.v4(),
      payload: commandPayload,
      deviceId: _deviceIdReader?.call(),
      entityType: _purchaseDocumentsEntity,
      entityId: documentId,
      priority: SyncQueuePriority.high,
    );

    await _stockApplier?.applyPurchaseDocument(
      businessId: businessId,
      documentId: documentId,
      godownId: godownId,
      deviceId: _deviceIdReader?.call(),
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
      entityType: _purchaseDocumentsEntity,
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
        entityType: _purchaseDocumentLinesEntity,
        entityId: line.id,
        operation: SyncQueueOperation.delete,
        payload: {},
        deviceId: _deviceIdReader?.call(),
        clientUpdatedAt: now,
      );
    }
  }

  Future<List<PurchaseDocumentDto>> listPurchaseReturns() {
    return _local.listByType(
      businessId: _requireBusinessId(),
      documentType: PurchaseDocumentType.purchaseReturn.apiValue,
    );
  }

  Future<PurchaseDocumentDto?> getDocument(String id) => _local.getDocument(id);
}
