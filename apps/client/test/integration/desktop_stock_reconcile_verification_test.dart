import 'dart:io';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/stock_level_sync.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Desktop-pattern verification against a copy of the developer SQLite file.
void main() {
  const businessId = '6a045480-38d0-4a89-8d0f-74e2670807b4';
  const defaultGodown = 'e9aaef60-1fc6-411a-99fb-c7d25806089e';
  final sourceDb = File(
    r'C:\Users\saksh\OneDrive\Documents\billing_baba.sqlite',
  );

  test(
    'desktop first stock_levels pull reconciles default godown rows',
    () async {
      if (!sourceDb.existsSync()) {
        return;
      }

      final copy = File(
        '${Directory.systemTemp.path}/billing_baba_verify_${DateTime.now().millisecondsSinceEpoch}.sqlite',
      );
      copy.writeAsBytesSync(sourceDb.readAsBytesSync());
      addTearDown(() {
        if (copy.existsSync()) copy.deleteSync();
      });

      SharedPreferences.setMockInitialValues({});
      final storage = StorageService(
        preferences: await SharedPreferences.getInstance(),
      );
      final metadata = SyncMetadataStore(storage);
      final db = AppDatabase(NativeDatabase(copy));
      addTearDown(db.close);

      final stockLocal = InventoryStockLocalDataSource(db);
      final sync = StockLevelSync(stockLocal, metadata);

      final serverRows = <Map<String, String>>[
        {
          'entityId': '11111111-1111-1111-1111-111111111111',
          'itemId': 'c49b0607-6cc5-4eb0-bc5e-fd0427b5aa5c',
          'quantity': '11998.0000',
        },
        {
          'entityId': '22222222-2222-2222-2222-222222222222',
          'itemId': '94bd8878-9c21-4117-ba01-387aa7eadd9a',
          'quantity': '4.0000',
        },
        {
          'entityId': '33333333-3333-3333-3333-333333333333',
          'itemId': '88d23c7f-4694-40ae-a9f4-972dc3beffa2',
          'quantity': '-10.0000',
        },
        {
          'entityId': '44444444-4444-4444-4444-444444444444',
          'itemId': 'd6aa03ed-0da0-44ab-adb1-efdf2557fd7e',
          'quantity': '5222000.0000',
        },
        {
          'entityId': '55555555-5555-5555-5555-555555555555',
          'itemId': '75f47224-1516-478c-958c-d17680f45185',
          'quantity': '91.0000',
        },
      ];

      for (final row in serverRows) {
        await sync.applyChange(
          businessId: businessId,
          entityId: row['entityId']!,
          syncVersion: 1,
          updatedAt: DateTime.utc(2026, 7, 31),
          isDeleted: false,
          payload: {
            'item_id': row['itemId'],
            'godown_id': defaultGodown,
            'quantity': row['quantity'],
            'average_cost': '0.0000',
          },
        );
      }

      final sqliteDb = sqlite.sqlite3.open(copy.path);

      final defaultRows = sqliteDb.select(
        "SELECT * FROM stock_levels_local WHERE business_id = '$businessId' AND godown_id = 'default'",
      );
      expect(defaultRows, isEmpty);

      final duplicates = sqliteDb.select(
        """
        SELECT item_id, godown_id, COUNT(*) AS c FROM stock_levels_local
        WHERE business_id = '$businessId' AND is_deleted = 0
        GROUP BY item_id, godown_id HAVING COUNT(*) > 1
        """,
      );
      expect(duplicates, isEmpty);

      final totals = {
        for (final row in sqliteDb.select(
          """
          SELECT i.name, SUM(CAST(sl.current_quantity AS REAL)) AS total
          FROM stock_levels_local sl JOIN items_local i ON i.id = sl.item_id
          WHERE sl.business_id = '$businessId' AND sl.is_deleted = 0
          GROUP BY i.name
          """,
        ))
          row['name'] as String: row['total'] as double,
      };

      expect(
        totals['Bosch All-in-One Metal Hand Tool Kit'],
        11998,
      );
      expect(totals['CASHEW'], 4);
      expect(totals['ALMOND'], -10);
      expect(totals['Rose Water'], 5222000);
      expect(totals['test'], 91);

      expect(metadata.stockLevelsReconciledAtFor(businessId), isNotNull);

      // Second pull must not re-clear or change totals.
      for (final row in serverRows) {
        await sync.applyChange(
          businessId: businessId,
          entityId: row['entityId']!,
          syncVersion: 1,
          updatedAt: DateTime.utc(2026, 7, 31),
          isDeleted: false,
          payload: {
            'item_id': row['itemId'],
            'godown_id': defaultGodown,
            'quantity': row['quantity'],
            'average_cost': '0.0000',
          },
        );
      }

      final totalsAfterSecondPull = {
        for (final row in sqliteDb.select(
          """
          SELECT i.name, SUM(CAST(sl.current_quantity AS REAL)) AS total
          FROM stock_levels_local sl JOIN items_local i ON i.id = sl.item_id
          WHERE sl.business_id = '$businessId' AND sl.is_deleted = 0
          GROUP BY i.name
          """,
        ))
          row['name'] as String: row['total'] as double,
      };
      expect(totalsAfterSecondPull, totals);
      sqliteDb.dispose();
    },
    skip:
        !File(
          r'C:\Users\saksh\OneDrive\Documents\billing_baba.sqlite',
        ).existsSync()
        ? 'Desktop DB not present on this machine'
        : false,
  );
}
