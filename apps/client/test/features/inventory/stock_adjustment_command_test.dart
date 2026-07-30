import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/stock_adjustment_command_repository.dart';
import 'package:billing_baba/features/inventory/models/requests/movement_requests.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('applyAdjustment writes Drift movement and enqueues command', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-inv-1',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final queue = SyncQueue(db);
    final local = InventoryStockLocalDataSource(db);
    final repo = StockAdjustmentCommandRepository(
      syncQueue: queue,
      local: local,
      businessIdReader: () =>
          storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
      deviceIdReader: () => 'device-inv-test',
    );

    await repo.applyAdjustment(
      const CreateMovementRequest(
        itemId: 'item-1',
        godownId: 'godown-1',
        movementType: 'adjustment',
        quantityDelta: '5',
        costPerUnit: '10',
        notes: 'Cycle count',
      ),
    );

    final movements = await local.listMovementsForItem(
      businessId: 'biz-inv-1',
      itemId: 'item-1',
    );
    expect(movements, hasLength(1));
    expect(movements.first.quantityDelta, '5');

    final stockQty = await local.currentQuantity(
      businessId: 'biz-inv-1',
      itemId: 'item-1',
      godownId: 'godown-1',
    );
    expect(stockQty, 5);

    final pending = await queue.listPending();
    expect(pending, hasLength(1));
    expect(pending.first.kind, SyncQueueKind.command);
    expect(pending.first.payload['command'], 'stock_adjustment');
    expect(pending.first.payload['godown_id'], 'godown-1');
    final lines = pending.first.payload['lines'] as List<dynamic>;
    expect(lines.first['item_id'], 'item-1');
    expect(lines.first['quantity_delta'], '5');
    expect(lines.first['cost_per_unit'], '10');
  });
}
