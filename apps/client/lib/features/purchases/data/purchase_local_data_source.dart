import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for purchase documents. Does not enqueue SyncJobs.
class PurchaseLocalDataSource {
  PurchaseLocalDataSource(this._db);

  final AppDatabase _db;

  Future<PurchaseDocumentDto?> getDocument(String id) async {
    final header = await (_db.select(_db.purchaseDocumentsLocal)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
    if (header == null) return null;

    final lines = await (_db.select(_db.purchaseDocumentLinesLocal)
          ..where(
            (t) =>
                t.purchaseDocumentId.equals(id) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    return _toDto(header, lines);
  }

  Future<List<PurchaseDocumentDto>> listByType({
    required String businessId,
    required String documentType,
  }) async {
    final headers = await (_db.select(_db.purchaseDocumentsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.documentType.equals(documentType) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    final results = <PurchaseDocumentDto>[];
    for (final header in headers) {
      final lines = await (_db.select(_db.purchaseDocumentLinesLocal)
            ..where(
              (t) =>
                  t.purchaseDocumentId.equals(header.id) &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      results.add(_toDto(header, lines));
    }
    return results;
  }

  Future<void> upsertDocument({
    required String id,
    required String businessId,
    required String documentType,
    required String status,
    required String documentSeries, required String partyId, required bool isGstFormal, required String subtotal, required String discountTotal, required String taxAmount, required String totalAmount, required String documentDate, required int syncVersion, required DateTime createdAt, required DateTime updatedAt, String? documentNumber,
    String? partyStateCode,
    String? convertedFromId,
    String? supplierInvoiceNumber,
    String? dueDate,
    String? notes,
    String? godownId,
    String paidAmount = '0',
    String? paymentMode,
    String? deviceId,
  }) async {
    await _db.into(_db.purchaseDocumentsLocal).insertOnConflictUpdate(
          PurchaseDocumentsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            documentType: documentType,
            status: Value(status),
            documentNumber: Value(documentNumber),
            documentSeries: documentSeries,
            partyId: partyId,
            isGstFormal: Value(isGstFormal),
            partyStateCode: Value(partyStateCode),
            subtotal: Value(subtotal),
            discountTotal: Value(discountTotal),
            taxAmount: Value(taxAmount),
            totalAmount: Value(totalAmount),
            documentDate: documentDate,
            convertedFromId: Value(convertedFromId),
            supplierInvoiceNumber: Value(supplierInvoiceNumber),
            dueDate: Value(dueDate),
            notes: Value(notes),
            godownId: Value(godownId),
            paidAmount: Value(paidAmount),
            paymentMode: Value(paymentMode),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> replaceLines({
    required String businessId,
    required String purchaseDocumentId,
    required List<PurchaseDocumentLineLocalData> lines,
  }) async {
    await (_db.delete(_db.purchaseDocumentLinesLocal)
          ..where((t) => t.purchaseDocumentId.equals(purchaseDocumentId)))
        .go();

    for (final line in lines) {
      await _db.into(_db.purchaseDocumentLinesLocal).insertOnConflictUpdate(
            PurchaseDocumentLinesLocalCompanion.insert(
              id: line.id,
              businessId: businessId,
              purchaseDocumentId: purchaseDocumentId,
              itemId: line.itemId,
              quantity: line.quantity,
              unit: line.unit,
              unitPrice: line.unitPrice,
              discountAmount: Value(line.discountAmount),
              taxType: Value(line.taxType),
              taxRate: Value(line.taxRate),
              cgstAmount: Value(line.cgstAmount),
              sgstAmount: Value(line.sgstAmount),
              igstAmount: Value(line.igstAmount),
              lineTotal: line.lineTotal,
              sortOrder: Value(line.sortOrder),
              syncVersion: Value(line.syncVersion),
              createdAt: line.createdAt.toUtc(),
              updatedAt: line.updatedAt.toUtc(),
              deviceId: Value(line.deviceId),
            ),
          );
    }
  }

  Future<void> softDeleteDocument(String id, DateTime deletedAt) {
    return (_db.update(_db.purchaseDocumentsLocal)..where((t) => t.id.equals(id)))
        .write(
      PurchaseDocumentsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  Future<int?> getHeaderSyncVersion(String id) async {
    final row = await (_db.select(_db.purchaseDocumentsLocal)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row?.syncVersion;
  }

  Future<void> applyFinalizeAck({
    required String documentId,
    required String status,
    required String? documentNumber,
    required int syncVersion,
    required DateTime updatedAt,
    String? paidAmount,
    String? paymentMode,
  }) {
    return (_db.update(_db.purchaseDocumentsLocal)
          ..where((t) => t.id.equals(documentId)))
        .write(
      PurchaseDocumentsLocalCompanion(
        status: Value(status),
        documentNumber: Value(documentNumber),
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        paidAmount:
            paidAmount != null ? Value(paidAmount) : const Value.absent(),
        paymentMode:
            paymentMode != null ? Value(paymentMode) : const Value.absent(),
      ),
    );
  }

  PurchaseDocumentDto _toDto(
    PurchaseDocumentLocalData header,
    List<PurchaseDocumentLineLocalData> lines,
  ) {
    return PurchaseDocumentDto(
      id: header.id,
      documentType: header.documentType,
      status: header.status,
      documentNumber: header.documentNumber,
      documentSeries: header.documentSeries,
      partyId: header.partyId,
      isGstFormal: header.isGstFormal,
      partyStateCode: header.partyStateCode,
      subtotal: header.subtotal,
      discountTotal: header.discountTotal,
      taxAmount: header.taxAmount,
      totalAmount: header.totalAmount,
      documentDate: header.documentDate,
      convertedFromId: header.convertedFromId,
      supplierInvoiceNumber: header.supplierInvoiceNumber,
      dueDate: header.dueDate,
      notes: header.notes,
      paidAmount: header.paidAmount,
      paymentMode: header.paymentMode,
      createdAt: header.createdAt.toUtc().toIso8601String(),
      updatedAt: header.updatedAt.toUtc().toIso8601String(),
      lines: lines
          .map(
            (line) => PurchaseDocumentLineDto(
              id: line.id,
              itemId: line.itemId,
              quantity: line.quantity,
              unit: line.unit,
              unitPrice: line.unitPrice,
              discountAmount: line.discountAmount,
              taxType: line.taxType,
              taxRate: line.taxRate,
              cgstAmount: line.cgstAmount,
              sgstAmount: line.sgstAmount,
              igstAmount: line.igstAmount,
              lineTotal: line.lineTotal,
              sortOrder: line.sortOrder,
            ),
          )
          .toList(),
    );
  }
}
