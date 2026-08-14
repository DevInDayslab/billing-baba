import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

class ItemAlternativeLocalSource {
  ItemAlternativeLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows =
        await (_db.select(_db.itemAlternativesLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<int> countActiveForItem(String businessId, String itemId) async {
    final rows =
        await (_db.select(_db.itemAlternativesLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.itemId.equals(itemId) &
                  t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<ItemAlternativeTableData>> listActiveRowsForItem(
    String businessId,
    String itemId,
  ) {
    return (_db.select(_db.itemAlternativesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.itemId.equals(itemId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  Future<List<ItemAlternativeTableData>> listActive(String businessId) {
    return (_db.select(_db.itemAlternativesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.itemId),
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  Future<Map<String, List<String>>> groupedAlternativeItemIds(
    String businessId,
  ) async {
    final rows = await listActive(businessId);
    final grouped = <String, List<String>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.itemId, () => []).add(row.alternativeItemId);
    }
    return grouped;
  }

  Future<List<ItemAlternativeTableData>> listActiveRowsReferencingItem(
    String businessId,
    String alternativeItemId,
  ) {
    return (_db.select(_db.itemAlternativesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.alternativeItemId.equals(alternativeItemId) &
                t.isDeleted.equals(false),
          ))
        .get();
  }

  Future<ItemAlternativeTableData?> getById(String id) {
    return (_db.select(
      _db.itemAlternativesLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ItemAlternativeTableData?> findActivePair({
    required String businessId,
    required String itemId,
    required String alternativeItemId,
  }) {
    return (_db.select(_db.itemAlternativesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.itemId.equals(itemId) &
                t.alternativeItemId.equals(alternativeItemId) &
                t.isDeleted.equals(false),
          ))
        .getSingleOrNull();
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String itemId,
    required String alternativeItemId,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    int sortOrder = 0,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db
        .into(_db.itemAlternativesLocal)
        .insertOnConflictUpdate(
          ItemAlternativesLocalCompanion.insert(
            id: id,
            businessId: businessId,
            itemId: itemId,
            alternativeItemId: alternativeItemId,
            sortOrder: Value(sortOrder),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertFromRemoteRow({
    required String businessId,
    required String id,
    required String itemId,
    required String alternativeItemId,
    required int sortOrder,
    String? createdAt,
    String? updatedAt,
  }) {
    final created =
        DateTime.tryParse(createdAt ?? '')?.toUtc() ??
        DateTime.now().toUtc();
    final updated =
        DateTime.tryParse(updatedAt ?? '')?.toUtc() ?? created;
    return upsertRow(
      id: id,
      businessId: businessId,
      itemId: itemId,
      alternativeItemId: alternativeItemId,
      sortOrder: sortOrder,
      syncVersion: 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) async {
    await (_db.update(
      _db.itemAlternativesLocal,
    )..where((t) => t.id.equals(id))).write(
      ItemAlternativesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }
}
