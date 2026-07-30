import 'package:billing_baba/core/database/database.dart';

/// Purges local Drift rows for a single business.
class BusinessLocalDataCleanup {
  BusinessLocalDataCleanup(this._db);

  final AppDatabase _db;

  Future<void> clearBusiness(String businessId) async {
    if (businessId.isEmpty) return;

    await (_db.delete(_db.salesLineLocal)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
    await (_db.delete(_db.salesLocal)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
    await (_db.delete(_db.heldBillsLocal)
          ..where((row) => row.businessId.equals(businessId)))
        .go();

    await (_db.delete(_db.leadActivities)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
    await (_db.delete(_db.leads)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
    await (_db.delete(_db.contactActivities)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
    await (_db.delete(_db.contacts)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
    await (_db.delete(_db.deals)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
    await (_db.delete(_db.categoriesLocal)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
    await (_db.delete(_db.syncQueue)
          ..where((row) => row.businessId.equals(businessId)))
        .go();
  }
}
