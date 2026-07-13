import 'package:billing_baba/core/database/tables/pos_sales_tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Local SQLite database via Drift.
@DriftDatabase(tables: [SalesLocal, SalesLineLocal, HeldBillsLocal])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(salesLocal);
        await m.createTable(salesLineLocal);
      }
      if (from < 3) {
        await m.createTable(heldBillsLocal);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'billing_baba');
  }
}
