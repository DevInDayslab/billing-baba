import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

/// Allocates monotonic `LOCAL-######` display numbers per business + series.
class LocalDocumentNumberService {
  LocalDocumentNumberService(this._db);

  final AppDatabase _db;

  Future<String> allocate({
    required String businessId,
    required String documentSeries,
  }) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.localDocumentCounters)..where(
                (t) =>
                    t.businessId.equals(businessId) &
                    t.documentSeries.equals(documentSeries),
              ))
              .getSingleOrNull();

      final next = existing?.nextNumber ?? 1;
      await _db
          .into(_db.localDocumentCounters)
          .insertOnConflictUpdate(
            LocalDocumentCountersCompanion.insert(
              businessId: businessId,
              documentSeries: documentSeries,
              nextNumber: Value(next + 1),
            ),
          );

      return 'LOCAL-${next.toString().padLeft(6, '0')}';
    });
  }
}
