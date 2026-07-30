import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/settings/models/tax_rate_models.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for tax rates. Does not enqueue SyncJobs.
class TaxRateLocalSource {
  TaxRateLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows = await (_db.select(_db.taxRatesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          ))
        .get();
    return rows.length;
  }

  Future<List<TaxRateDto>> listActive(String businessId) async {
    final rows = await (_db.select(_db.taxRatesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_toDto).toList();
  }

  Future<TaxRateTableData?> getById(String id) {
    return (_db.select(_db.taxRatesLocal)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<TaxRateDto?> getActiveDto(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toDto(row);
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String name,
    required String rate,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDefault = false,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db.into(_db.taxRatesLocal).insertOnConflictUpdate(
          TaxRatesLocalCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            rate: rate,
            isDefault: Value(isDefault),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) async {
    await (_db.update(_db.taxRatesLocal)..where((t) => t.id.equals(id))).write(
      TaxRatesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  TaxRateDto _toDto(TaxRateTableData row) {
    return TaxRateDto(
      id: row.id,
      name: row.name,
      rate: row.rate,
      isDefault: row.isDefault,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }
}
