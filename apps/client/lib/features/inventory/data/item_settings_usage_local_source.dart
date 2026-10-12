import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

/// Reads local inventory / document data to decide if item settings can be disabled.
class ItemSettingsUsageLocalSource {
  ItemSettingsUsageLocalSource(this._db);

  final AppDatabase _db;

  Future<bool> hasActiveItems(String businessId) async {
    if (businessId.isEmpty) return false;

    final count = _db.itemsLocal.id.count();
    final query = _db.selectOnly(_db.itemsLocal)
      ..addColumns([count])
      ..where(
        _db.itemsLocal.businessId.equals(businessId) &
            _db.itemsLocal.isDeleted.equals(false),
      );

    final total = await query.map((row) => row.read(count) ?? 0).getSingle();
    return total > 0;
  }

  Future<bool> hasItemLinesInDocuments(String businessId) async {
    if (businessId.isEmpty) return false;
    if (await _hasSalesItemLines(businessId)) return true;
    return _hasPurchaseItemLines(businessId);
  }

  Future<bool> hasItemUnitUsageInTransactions(String businessId) async {
    if (businessId.isEmpty) return false;
    if (await _hasSalesItemLines(businessId, requireUnit: true)) return true;
    return _hasPurchaseItemLines(businessId, requireUnit: true);
  }

  Future<bool> _hasSalesItemLines(
    String businessId, {
    bool requireUnit = false,
  }) async {
    final count = _db.salesDocumentLinesLocal.id.count();
    final query = _db.selectOnly(_db.salesDocumentLinesLocal)
      ..addColumns([count]);

    var predicate =
        _db.salesDocumentLinesLocal.businessId.equals(businessId) &
        _db.salesDocumentLinesLocal.isDeleted.equals(false) &
        _db.salesDocumentLinesLocal.itemId.isNotValue('');

    if (requireUnit) {
      predicate &= _db.salesDocumentLinesLocal.unit.isNotValue('');
    }

    query.where(predicate);

    final total = await query.map((row) => row.read(count) ?? 0).getSingle();
    return total > 0;
  }

  Future<bool> _hasPurchaseItemLines(
    String businessId, {
    bool requireUnit = false,
  }) async {
    final count = _db.purchaseDocumentLinesLocal.id.count();
    final query = _db.selectOnly(_db.purchaseDocumentLinesLocal)
      ..addColumns([count]);

    var predicate =
        _db.purchaseDocumentLinesLocal.businessId.equals(businessId) &
        _db.purchaseDocumentLinesLocal.isDeleted.equals(false) &
        _db.purchaseDocumentLinesLocal.itemId.isNotValue('');

    if (requireUnit) {
      predicate &= _db.purchaseDocumentLinesLocal.unit.isNotValue('');
    }

    query.where(predicate);

    final total = await query.map((row) => row.read(count) ?? 0).getSingle();
    return total > 0;
  }
}
