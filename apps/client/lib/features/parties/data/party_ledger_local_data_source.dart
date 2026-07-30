import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

/// Snapshot of a sales or purchase document row used for party projections.
class PartyDocumentSnapshot {
  const PartyDocumentSnapshot({
    required this.id,
    required this.source,
    required this.documentType,
    required this.status,
    required this.documentSeries,
    required this.documentNumber,
    required this.documentDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.createdAt,
    required this.updatedAt,
    this.partyId,
    this.dueDate,
    this.paymentMode,
  });

  final String id;
  final String source;
  final String documentType;
  final String status;
  final String documentSeries;
  final String? documentNumber;
  final String documentDate;
  final String? dueDate;
  final String totalAmount;
  final String paidAmount;
  final String? paymentMode;
  final String? partyId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class PartyLedgerLocalDataSource {
  PartyLedgerLocalDataSource(this._db);

  final AppDatabase _db;

  Future<PartyTableData?> getParty(String partyId) {
    return (_db.select(_db.partiesLocal)
          ..where((t) => t.id.equals(partyId) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<PartyDocumentSnapshot>> listSalesDocumentsForParty({
    required String businessId,
    required String partyId,
  }) async {
    final rows =
        await (_db.select(_db.salesDocumentsLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) &
                    t.partyId.equals(partyId) &
                    t.isDeleted.equals(false) &
                    t.status.isIn(['finalized', 'converted']),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return rows.map(_salesRowToSnapshot).toList();
  }

  Future<List<PartyDocumentSnapshot>> listAllSalesDocuments(
    String businessId,
  ) async {
    final rows = await (_db.select(_db.salesDocumentsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.isDeleted.equals(false) &
                t.status.isIn(['finalized', 'converted']) &
                t.partyId.isNotNull(),
          ))
        .get();
    return rows.map(_salesRowToSnapshot).toList();
  }

  Future<List<PartyDocumentSnapshot>> listPurchaseDocumentsForParty({
    required String businessId,
    required String partyId,
  }) async {
    final rows =
        await (_db.select(_db.purchaseDocumentsLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) &
                    t.partyId.equals(partyId) &
                    t.isDeleted.equals(false) &
                    t.status.isIn(['finalized', 'converted']),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return rows.map(_purchaseRowToSnapshot).toList();
  }

  Future<List<PartyDocumentSnapshot>> listAllPurchaseDocuments(
    String businessId,
  ) async {
    final rows = await (_db.select(_db.purchaseDocumentsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.isDeleted.equals(false) &
                t.status.isIn(['finalized', 'converted']) &
                t.partyId.isNotNull(),
          ))
        .get();
    return rows.map(_purchaseRowToSnapshot).toList();
  }

  PartyDocumentSnapshot _salesRowToSnapshot(SalesDocumentLocalData row) {
    return PartyDocumentSnapshot(
      id: row.id,
      source: 'sales_documents',
      documentType: row.documentType,
      status: row.status,
      documentSeries: row.documentSeries,
      documentNumber: row.documentNumber,
      documentDate: row.documentDate,
      totalAmount: row.totalAmount,
      paidAmount: row.paidAmount,
      paymentMode: row.paymentMode,
      partyId: row.partyId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  PartyDocumentSnapshot _purchaseRowToSnapshot(PurchaseDocumentLocalData row) {
    return PartyDocumentSnapshot(
      id: row.id,
      source: 'purchase_documents',
      documentType: row.documentType,
      status: row.status,
      documentSeries: row.documentSeries,
      documentNumber: row.documentNumber,
      documentDate: row.documentDate,
      dueDate: row.dueDate,
      totalAmount: row.totalAmount,
      paidAmount: row.paidAmount,
      paymentMode: row.paymentMode,
      partyId: row.partyId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
