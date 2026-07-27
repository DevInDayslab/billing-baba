import 'package:billing_baba/core/database/tables/business_settings_table.dart';
import 'package:billing_baba/core/database/tables/categories_table.dart';
import 'package:billing_baba/core/database/tables/contacts_tables.dart';
import 'package:billing_baba/core/database/tables/deals_tables.dart';
import 'package:billing_baba/core/database/tables/godowns_table.dart';
import 'package:billing_baba/core/database/tables/items_table.dart';
import 'package:billing_baba/core/database/tables/leads_tables.dart';
import 'package:billing_baba/core/database/tables/parties_table.dart';
import 'package:billing_baba/core/database/tables/pos_sales_tables.dart';
import 'package:billing_baba/core/database/tables/sync_queue_table.dart';
import 'package:billing_baba/core/database/tables/tax_rates_table.dart';
import 'package:billing_baba/core/database/tables/unit_definitions_table.dart';
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
    CategoriesLocal,
    PartiesLocal,
    ItemsLocal,
    UnitDefinitionsLocal,
    TaxRatesLocal,
    GodownsLocal,
    BusinessSettingsLocal,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
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
      if (from < 8) {
        await m.addColumn(salesLocal, salesLocal.businessId);
        await m.addColumn(salesLineLocal, salesLineLocal.businessId);
        await m.addColumn(heldBillsLocal, heldBillsLocal.businessId);
        // Legacy rows were not business-scoped; drop them to prevent cross-tenant leakage.
        await m.database.customStatement('DELETE FROM sales_line_local');
        await m.database.customStatement('DELETE FROM sales_local');
        await m.database.customStatement('DELETE FROM held_bills_local');
      }
      if (from < 9) {
        // Recreate sync_queue: PK becomes UUID; prior CRM queue was never flushed.
        await m.database.customStatement('DROP TABLE IF EXISTS sync_queue');
        await m.createTable(syncQueue);
      }
      if (from < 10) {
        await m.createTable(categoriesLocal);
      }
      if (from < 11) {
        await m.createTable(partiesLocal);
      }
      if (from < 12) {
        await m.createTable(itemsLocal);
      }
      if (from < 13) {
        await m.createTable(unitDefinitionsLocal);
        await m.createTable(taxRatesLocal);
        await m.createTable(godownsLocal);
        await m.createTable(businessSettingsLocal);
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
