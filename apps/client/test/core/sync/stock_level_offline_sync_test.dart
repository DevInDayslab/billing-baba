import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/stock_level_sync.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late InventoryStockLocalDataSource stockLocal;
  late SyncMetadataStore metadata;
  late StockLevelSync sync;

  const businessId = 'biz-1';
  const itemId = 'item-1';
  const godownA = 'godown-a';
  const godownB = 'godown-b';
  const serverIdA = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const serverIdB = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService(
      preferences: await SharedPreferences.getInstance(),
    );
    metadata = SyncMetadataStore(storage);

    db = AppDatabase(NativeDatabase.memory());
    stockLocal = InventoryStockLocalDataSource(db);
    sync = StockLevelSync(stockLocal, metadata);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedLocalCompositeRow({
    required String godownId,
    required String quantity,
    String reserved = '2',
  }) async {
    final compositeId = stockLevelLocalId(
      businessId: businessId,
      itemId: itemId,
      godownId: godownId,
    );
    await db.into(db.stockLevelsLocal).insert(
          StockLevelsLocalCompanion.insert(
            id: compositeId,
            businessId: businessId,
            itemId: itemId,
            godownId: godownId,
            currentQuantity: Value(quantity),
            reservedQuantity: Value(reserved),
            availableQuantity: Value('0'),
            averageCost: const Value('10'),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
  }

  Future<void> markReconciled() {
    return metadata.setStockLevelsReconciledAtFor(
      businessId,
      DateTime.utc(2026, 7, 31),
    );
  }

  test(
    'first pull clears stale local rows including default godown alias',
    () async {
      await seedLocalCompositeRow(godownId: 'default', quantity: '-2');
      await seedLocalCompositeRow(godownId: godownA, quantity: '12000');

      await sync.applyChange(
        businessId: businessId,
        entityId: serverIdA,
        syncVersion: 1,
        updatedAt: DateTime.utc(2026, 7, 31),
        isDeleted: false,
        payload: {
          'item_id': itemId,
          'godown_id': godownA,
          'quantity': '11998.0000',
          'average_cost': '50.0000',
        },
      );

      final rows = await (db.select(db.stockLevelsLocal)
            ..where((t) => t.businessId.equals(businessId)))
          .get();
      expect(rows, hasLength(1));
      expect(rows.single.godownId, godownA);
      expect(rows.single.currentQuantity, '11998.0000');
      expect(
        metadata.stockLevelsReconciledAtFor(businessId),
        isNotNull,
      );
    },
  );

  test('second pull does not re-clear reconciled stock cache', () async {
    await sync.applyChange(
      businessId: businessId,
      entityId: serverIdA,
      syncVersion: 1,
      updatedAt: DateTime.utc(2026, 7, 31),
      isDeleted: false,
      payload: {
        'item_id': itemId,
        'godown_id': godownA,
        'quantity': '10.0000',
        'average_cost': '5.0000',
      },
    );

    await sync.applyChange(
      businessId: businessId,
      entityId: serverIdB,
      syncVersion: 1,
      updatedAt: DateTime.utc(2026, 7, 31),
      isDeleted: false,
      payload: {
        'item_id': itemId,
        'godown_id': godownB,
        'quantity': '4.0000',
        'average_cost': '5.0000',
      },
    );

    await sync.applyChange(
      businessId: businessId,
      entityId: serverIdA,
      syncVersion: 2,
      updatedAt: DateTime.utc(2026, 8, 1),
      isDeleted: false,
      payload: {
        'item_id': itemId,
        'godown_id': godownA,
        'quantity': '15.0000',
        'average_cost': '5.0000',
      },
    );

    final rows = await (db.select(db.stockLevelsLocal)
          ..where((t) => t.businessId.equals(businessId)))
        .get();
    expect(rows, hasLength(2));
    expect(
      rows.firstWhere((r) => r.id == serverIdA).currentQuantity,
      '15.0000',
    );
    expect(metadata.stockLevelsReconciledAtFor(businessId), isNotNull);
  });

  test('pull upserts by business/item/godown and preserves reserved_quantity',
      () async {
    await markReconciled();
    await seedLocalCompositeRow(godownId: godownA, quantity: '5', reserved: '2');

    await sync.applyChange(
      businessId: businessId,
      entityId: serverIdA,
      syncVersion: 2,
      updatedAt: DateTime.utc(2026, 7, 31),
      isDeleted: false,
      payload: {
        'item_id': itemId,
        'godown_id': godownA,
        'quantity': '35.0000',
        'average_cost': '50.0000',
      },
    );

    final row = await (db.select(db.stockLevelsLocal)
          ..where((t) => t.id.equals(serverIdA)))
        .getSingle();
    expect(row.currentQuantity, '35.0000');
    expect(row.reservedQuantity, '2');
    expect(row.availableQuantity, '33');
    expect(row.averageCost, '50.0000');
    expect(
      await (db.select(db.stockLevelsLocal)
            ..where((t) => t.id.equals(
                  stockLevelLocalId(
                    businessId: businessId,
                    itemId: itemId,
                    godownId: godownA,
                  ),
                )))
          .getSingleOrNull(),
      isNull,
    );
  });

  test('multi-godown rows sum independently without overwriting', () async {
    await sync.applyChange(
      businessId: businessId,
      entityId: serverIdA,
      syncVersion: 1,
      updatedAt: DateTime.utc(2026, 7, 31),
      isDeleted: false,
      payload: {
        'item_id': itemId,
        'godown_id': godownA,
        'quantity': '10.0000',
        'average_cost': '5.0000',
      },
    );
    await sync.applyChange(
      businessId: businessId,
      entityId: serverIdB,
      syncVersion: 1,
      updatedAt: DateTime.utc(2026, 7, 31),
      isDeleted: false,
      payload: {
        'item_id': itemId,
        'godown_id': godownB,
        'quantity': '4.0000',
        'average_cost': '5.0000',
      },
    );

    final totals = await stockLocal.quantitiesByItem(businessId: businessId);
    expect(totals[itemId], 14);
    expect(
      await (db.select(db.stockLevelsLocal)
            ..where((t) => t.businessId.equals(businessId)))
          .get(),
      hasLength(2),
    );
  });

  test('stale pull is ignored by sync_version guard', () async {
    await sync.applyChange(
      businessId: businessId,
      entityId: serverIdA,
      syncVersion: 3,
      updatedAt: DateTime.utc(2026, 7, 31),
      isDeleted: false,
      payload: {
        'item_id': itemId,
        'godown_id': godownA,
        'quantity': '9.0000',
        'average_cost': '5.0000',
      },
    );

    await sync.applyChange(
      businessId: businessId,
      entityId: serverIdA,
      syncVersion: 2,
      updatedAt: DateTime.utc(2026, 7, 30),
      isDeleted: false,
      payload: {
        'item_id': itemId,
        'godown_id': godownA,
        'quantity': '1.0000',
        'average_cost': '5.0000',
      },
    );

    final row = await (db.select(db.stockLevelsLocal)
          ..where((t) => t.id.equals(serverIdA)))
        .getSingle();
    expect(row.currentQuantity, '9.0000');
    expect(row.syncVersion, 3);
  });
}
