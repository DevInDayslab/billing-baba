import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/models/requests/movement_requests.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Local-first stock adjustment writes + SyncQueue enqueue.
class StockAdjustmentCommandRepository {
  StockAdjustmentCommandRepository({
    required this._syncQueue,
    required this._local,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final SyncQueue _syncQueue;
  final InventoryStockLocalDataSource _local;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  Future<void> applyAdjustment(CreateMovementRequest request) async {
    final businessId = _businessIdReader().trim();
    if (businessId.isEmpty) {
      throw StateError('No business selected for stock adjustment');
    }

    final adjustmentId = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _local.recordAdjustment(
      movementId: adjustmentId,
      businessId: businessId,
      request: request,
      now: now,
      deviceId: _deviceIdReader?.call(),
    );

    await _syncQueue.enqueueCommand(
      businessId: businessId,
      command: 'stock_adjustment',
      commandId: adjustmentId,
      payload: {
        'adjustment_id': adjustmentId,
        'godown_id': request.godownId,
        'lines': [
          {
            'item_id': request.itemId,
            'quantity_delta': request.quantityDelta,
            if (request.costPerUnit != null)
              'cost_per_unit': request.costPerUnit,
            if (request.notes != null && request.notes!.trim().isNotEmpty)
              'reason': request.notes!.trim(),
          },
        ],
      },
      deviceId: _deviceIdReader?.call(),
      entityType: 'inventory_movements',
      entityId: adjustmentId,
      priority: SyncQueuePriority.high,
    );
  }
}
