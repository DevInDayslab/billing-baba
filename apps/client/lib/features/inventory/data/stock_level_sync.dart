import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';

/// Applies pull updates for `entity_type: stock_levels` into Drift.
///
/// Pull-only — never queued for push.
class StockLevelSync {
  StockLevelSync(this._stockLocal, this._metadata);

  final InventoryStockLocalDataSource _stockLocal;
  final SyncMetadataStore _metadata;

  final _reconcileLocks = <String, Future<void>>{};

  Future<void> applyChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    await _ensureStockLevelsReconciled(businessId);
    return _stockLocal.applyPullChange(
      businessId: businessId,
      entityId: entityId,
      syncVersion: syncVersion,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      itemId: _str(payload, 'item_id'),
      godownId: _str(payload, 'godown_id'),
      quantity: _str(payload, 'quantity'),
      averageCost: _str(payload, 'average_cost'),
      deviceId: deviceId,
    );
  }

  /// On the first `stock_levels` pull for a business, wipe the derived cache
  /// so server rows replace stale client-only rows (e.g. godown_id `default`).
  Future<void> _ensureStockLevelsReconciled(String businessId) async {
    if (_metadata.stockLevelsReconciledAtFor(businessId) != null) {
      return;
    }

    final existing = _reconcileLocks[businessId];
    if (existing != null) {
      await existing;
      return;
    }

    final future = _runReconcile(businessId);
    _reconcileLocks[businessId] = future;
    try {
      await future;
    } finally {
      _reconcileLocks.remove(businessId);
    }
  }

  Future<void> _runReconcile(String businessId) async {
    if (_metadata.stockLevelsReconciledAtFor(businessId) != null) {
      return;
    }
    await _stockLocal.clearAllForBusiness(businessId);
    await _metadata.setStockLevelsReconciledAtFor(businessId, DateTime.now());
  }

  static String? _str(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value == null) return null;
    return value.toString();
  }
}
