import 'package:billing_baba/core/database/database_corruption_exception.dart';
import 'package:billing_baba/core/database/drift_database_paths.dart';
import 'package:billing_baba/core/database/tables/brands_table.dart';
import 'package:billing_baba/core/database/tables/business_settings_table.dart';
import 'package:billing_baba/core/database/tables/categories_table.dart';
import 'package:billing_baba/core/database/tables/contacts_tables.dart';
import 'package:billing_baba/core/database/tables/deals_tables.dart';
import 'package:billing_baba/core/database/tables/expenses_tables.dart';
import 'package:billing_baba/core/database/tables/gateway_payment_sessions_table.dart';
import 'package:billing_baba/core/database/tables/godowns_table.dart';
import 'package:billing_baba/core/database/tables/inventory_stock_tables.dart';
import 'package:billing_baba/core/database/tables/item_alternatives_table.dart';
import 'package:billing_baba/core/database/tables/item_bom_costs_table.dart';
import 'package:billing_baba/core/database/tables/item_bom_materials_table.dart';
import 'package:billing_baba/core/database/tables/item_suppliers_table.dart';
import 'package:billing_baba/core/database/tables/item_tier_prices_table.dart';
import 'package:billing_baba/core/database/tables/items_table.dart';
import 'package:billing_baba/core/database/tables/leads_tables.dart';
import 'package:billing_baba/core/database/tables/notifications_table.dart';
import 'package:billing_baba/core/database/tables/parties_table.dart';
import 'package:billing_baba/core/database/tables/pos_sales_tables.dart';
import 'package:billing_baba/core/database/tables/purchase_document_tables.dart';
import 'package:billing_baba/core/database/tables/sales_document_tables.dart';
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
    BrandsLocal,
    PartiesLocal,
    ItemsLocal,
    ItemAlternativesLocal,
    ItemSuppliersLocal,
    ItemBomMaterialsLocal,
    ItemBomCostsLocal,
    ItemTierPricesLocal,
    UnitDefinitionsLocal,
    TaxRatesLocal,
    GodownsLocal,
    BusinessSettingsLocal,
    SalesDocumentsLocal,
    SalesDocumentLinesLocal,
    PurchaseDocumentsLocal,
    PurchaseDocumentLinesLocal,
    LocalDocumentCounters,
    InventoryMovementsLocal,
    StockLevelsLocal,
    ExpenseCategoriesLocal,
    ExpensesLocal,
    GatewayPaymentSessionsLocal,
    NotificationsLocal,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Drift schema version — keep in sync with [schemaVersion].
  static const currentSchemaVersion = 26;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      final integrityRows = await customSelect('PRAGMA integrity_check').get();
      for (final row in integrityRows) {
        final result = row.read<String>('integrity_check');
        if (result != 'ok') {
          throw DatabaseCorruptionException(result);
        }
      }
    },
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
      if (from < 14) {
        await m.createTable(salesDocumentsLocal);
        await m.createTable(salesDocumentLinesLocal);
        await m.createTable(purchaseDocumentsLocal);
        await m.createTable(purchaseDocumentLinesLocal);
        await m.createTable(localDocumentCounters);
      }
      if (from < 15) {
        await _addColumnIfMissing(
          m,
          salesDocumentsLocal,
          salesDocumentsLocal.paidAmount,
        );
        await _addColumnIfMissing(
          m,
          salesDocumentsLocal,
          salesDocumentsLocal.paymentMode,
        );
      }
      if (from < 16) {
        await _addColumnIfMissing(
          m,
          purchaseDocumentsLocal,
          purchaseDocumentsLocal.paidAmount,
        );
        await _addColumnIfMissing(
          m,
          purchaseDocumentsLocal,
          purchaseDocumentsLocal.paymentMode,
        );
      }
      if (from < 17) {
        await m.createTable(inventoryMovementsLocal);
        await m.createTable(stockLevelsLocal);
      }
      if (from < 18) {
        await m.createTable(brandsLocal);
        await m.createTable(expenseCategoriesLocal);
        await m.createTable(expensesLocal);
      }
      if (from < 19) {
        await _createBusinessIdIndexes(m);
      }
      if (from < 20) {
        await _createSyncQueueIndexes(m);
      }
      if (from < 21) {
        await m.createTable(itemSuppliersLocal);
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_suppliers_local_business_id ON item_suppliers_local (business_id)',
        );
      }
      if (from < 22) {
        await m.createTable(itemAlternativesLocal);
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_alternatives_local_business_id ON item_alternatives_local (business_id)',
        );
      }
      if (from < 22) {
        await m.createTable(itemTierPricesLocal);
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_tier_prices_local_business_id ON item_tier_prices_local (business_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_tier_prices_local_item_id ON item_tier_prices_local (item_id)',
        );
      }
      if (from < 23) {
        await m.createTable(itemBomMaterialsLocal);
        await m.createTable(itemBomCostsLocal);
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_bom_materials_local_business_id ON item_bom_materials_local (business_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_bom_costs_local_business_id ON item_bom_costs_local (business_id)',
        );
      }
      if (from < 24) {
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_suppliers_local_item_id ON item_suppliers_local (item_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_alternatives_local_item_id ON item_alternatives_local (item_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_alternatives_local_alternative_item_id ON item_alternatives_local (alternative_item_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_bom_materials_local_item_id ON item_bom_materials_local (item_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_item_bom_costs_local_item_id ON item_bom_costs_local (item_id)',
        );
      }
      if (from < 25) {
        await m.createTable(gatewayPaymentSessionsLocal);
      }
      if (from < 26) {
        await m.createTable(notificationsLocal);
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_notifications_local_business_id ON notifications_local (business_id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_notifications_local_business_read ON notifications_local (business_id, read)',
        );
      }
    },
  );

  static Future<void> _createSyncQueueIndexes(Migrator m) async {
    const statements = [
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON sync_queue (status)',
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_business_id ON sync_queue (business_id)',
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_status_business_id ON sync_queue (status, business_id)',
    ];
    for (final statement in statements) {
      await m.database.customStatement(statement);
    }
  }

  static Future<void> _createBusinessIdIndexes(Migrator m) async {
    const tables = [
      'sync_queue',
      'parties_local',
      'items_local',
      'item_alternatives_local',
      'item_suppliers_local',
      'item_bom_materials_local',
      'item_bom_costs_local',
      'item_tier_prices_local',
      'categories_local',
      'brands_local',
      'sales_documents_local',
      'purchase_documents_local',
      'expenses_local',
      'expense_categories_local',
      'leads',
      'contacts',
      'deals',
    ];
    for (final table in tables) {
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_${table}_business_id ON $table (business_id)',
      );
    }
  }

  static Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo<Table, Object?> table,
    GeneratedColumn<Object> column,
  ) async {
    final existing = await m.database
        .customSelect(
          'PRAGMA table_info(${table.actualTableName})',
        )
        .get();
    final hasColumn = existing.any(
      (row) => row.data['name'] == column.name,
    );
    if (!hasColumn) {
      await m.addColumn(table, column);
    }
  }

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
    return driftDatabase(name: kDriftDatabaseName);
  }
}
