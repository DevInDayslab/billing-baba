import 'package:billing_baba/core/database/tables/contacts_tables.dart';
import 'package:billing_baba/core/database/tables/deals_tables.dart';
import 'package:billing_baba/core/database/tables/leads_tables.dart';
import 'package:billing_baba/core/database/tables/pos_sales_tables.dart';
import 'package:billing_baba/core/database/tables/sync_queue_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Local SQLite database via Drift.
@DriftDatabase(
  tables: [
    SalesLocal,
    SalesLineLocal,
    HeldBillsLocal,
    Leads,
    LeadActivities,
    Contacts,
    ContactActivities,
    Deals,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(salesLocal);
        await m.createTable(salesLineLocal);
        await m.createTable(leads);
        await m.createTable(leadActivities);
        await m.createTable(syncQueue);
      }
      if (from < 3) {
        await m.createTable(heldBillsLocal);
        await m.createTable(contacts);
        await m.createTable(contactActivities);
      }
      if (from < 4) {
        await m.createTable(deals);
      }
      if (from < 5) {
        await _createTableIfMissing(m, syncQueue);
      }
      if (from < 6) {
        await _createTableIfMissing(m, leads);
        await _createTableIfMissing(m, leadActivities);
        await _createTableIfMissing(m, contacts);
        await _createTableIfMissing(m, contactActivities);
        await _createTableIfMissing(m, deals);
        await _createTableIfMissing(m, syncQueue);
      }
      if (from < 7) {
        await _createTableIfMissing(m, salesLocal);
        await _createTableIfMissing(m, salesLineLocal);
        await _createTableIfMissing(m, heldBillsLocal);
        await _createTableIfMissing(m, leads);
        await _createTableIfMissing(m, leadActivities);
        await _createTableIfMissing(m, contacts);
        await _createTableIfMissing(m, contactActivities);
        await _createTableIfMissing(m, deals);
        await _createTableIfMissing(m, syncQueue);
      }
    },
  );

  static Future<void> _createTableIfMissing(
    Migrator m,
    TableInfo<Table, Object?> table,
  ) async {
    final existing = await m.database
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          variables: [
            const Variable<String>('table'),
            Variable<String>(table.actualTableName),
          ],
        )
        .getSingleOrNull();
    if (existing == null) {
      await m.createTable(table);
    }
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'billing_baba');
  }
}
