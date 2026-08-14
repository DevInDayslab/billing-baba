import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_bom_cost_local_source.dart';
import 'package:billing_baba/features/inventory/data/item_bom_material_local_source.dart';
import 'package:billing_baba/features/inventory/models/dto/item_bom_dto.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _materialsEntity = 'item_bom_materials';
const _costsEntity = 'item_bom_costs';

class ItemBomReplaceMaterialInput {
  const ItemBomReplaceMaterialInput({
    required this.rawItemId,
    required this.qty,
    required this.unitId,
    required this.purchasePrice,
    this.sortOrder = 0,
  });

  final String rawItemId;
  final double qty;
  final String unitId;
  final double purchasePrice;
  final int sortOrder;
}

class ItemBomReplaceCostInput {
  const ItemBomReplaceCostInput({
    this.id,
    required this.description,
    required this.amount,
    this.sortOrder = 0,
  });

  final String? id;
  final String description;
  final double amount;
  final int sortOrder;
}

class ItemBomMasterRepository {
  ItemBomMasterRepository({
    required ItemBomMaterialLocalSource materialsLocal,
    required ItemBomCostLocalSource costsLocal,
    required SyncQueue syncQueue,
    required InventoryRemoteDataSource remote,
    required String Function() businessIdReader,
    String? Function()? deviceIdReader,
  }) : _materialsLocal = materialsLocal,
       _costsLocal = costsLocal,
       _syncQueue = syncQueue,
       _remote = remote,
       _businessIdReader = businessIdReader,
       _deviceIdReader = deviceIdReader;

  final ItemBomMaterialLocalSource _materialsLocal;
  final ItemBomCostLocalSource _costsLocal;
  final SyncQueue _syncQueue;
  final InventoryRemoteDataSource _remote;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for item BOM operations');
    }
    return id;
  }

  Future<ItemBomDto> getForItem(String itemId) async {
    final businessId = _requireBusinessId();
    await _hydrateItemIfEmpty(businessId, itemId);
    final materials = await _materialsLocal.listActiveForItem(businessId, itemId);
    final costs = await _costsLocal.listActiveForItem(businessId, itemId);
    return ItemBomDto(materials: materials, costs: costs);
  }

  Future<void> replaceForItem(
    String itemId, {
    required List<ItemBomReplaceMaterialInput> materials,
    required List<ItemBomReplaceCostInput> costs,
  }) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();

    final cleanedMaterials = <ItemBomReplaceMaterialInput>[];
    final seenRawIds = <String>{};
    for (final material in materials) {
      final rawItemId = material.rawItemId.trim();
      if (rawItemId.isEmpty || seenRawIds.contains(rawItemId)) continue;
      seenRawIds.add(rawItemId);
      cleanedMaterials.add(material);
    }

    final cleanedCosts = costs
        .where((cost) => cost.description.trim().isNotEmpty)
        .toList();

    await _replaceMaterials(
      businessId: businessId,
      itemId: itemId,
      materials: cleanedMaterials,
      now: now,
    );
    await _replaceCosts(
      businessId: businessId,
      itemId: itemId,
      costs: cleanedCosts,
      now: now,
    );
  }

  Future<void> removeAllForItem(String itemId) async {
    await replaceForItem(itemId, materials: const [], costs: const []);
  }

  Future<void> _replaceMaterials({
    required String businessId,
    required String itemId,
    required List<ItemBomReplaceMaterialInput> materials,
    required DateTime now,
  }) async {
    final existing = await _materialsLocal.listActiveRowsForItem(
      businessId,
      itemId,
    );
    final existingByRawItemId = {
      for (final row in existing) row.rawItemId: row,
    };
    final incomingRawIds = materials.map((m) => m.rawItemId).toList();

    for (final row in existing) {
      if (incomingRawIds.contains(row.rawItemId)) continue;
      await _materialsLocal.softDelete(id: row.id, deletedAt: now);
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _materialsEntity,
        entityId: row.id,
        operation: SyncQueueOperation.delete,
        payload: const {},
        baseSyncVersion: row.syncVersion,
        clientUpdatedAt: now,
      );
    }

    for (var index = 0; index < materials.length; index++) {
      final material = materials[index];
      final sortOrder = material.sortOrder == 0 ? index : material.sortOrder;
      final existingRow = existingByRawItemId[material.rawItemId];
      if (existingRow != null) {
        final needsUpdate =
            existingRow.qty != material.qty ||
            existingRow.unitId != material.unitId ||
            existingRow.purchasePrice != material.purchasePrice ||
            existingRow.sortOrder != sortOrder;
        if (!needsUpdate) continue;
        await _materialsLocal.upsertRow(
          id: existingRow.id,
          businessId: businessId,
          itemId: itemId,
          rawItemId: material.rawItemId,
          qty: material.qty,
          unitId: material.unitId,
          purchasePrice: material.purchasePrice,
          sortOrder: sortOrder,
          syncVersion: existingRow.syncVersion,
          createdAt: existingRow.createdAt,
          updatedAt: now,
          deviceId: _deviceIdReader?.call() ?? existingRow.deviceId,
        );
        await _syncQueue.enqueueRowMutation(
          businessId: businessId,
          deviceId: _deviceIdReader?.call(),
          entityType: _materialsEntity,
          entityId: existingRow.id,
          operation: SyncQueueOperation.update,
          payload: {
            'item_id': itemId,
            'raw_item_id': material.rawItemId,
            'qty': _formatQty(material.qty),
            'unit_id': material.unitId,
            'purchase_price': _formatMoney(material.purchasePrice),
            'sort_order': sortOrder,
          },
          baseSyncVersion: existingRow.syncVersion,
          clientUpdatedAt: now,
        );
        continue;
      }

      final id = _uuid.v4();
      await _materialsLocal.upsertRow(
        id: id,
        businessId: businessId,
        itemId: itemId,
        rawItemId: material.rawItemId,
        qty: material.qty,
        unitId: material.unitId,
        purchasePrice: material.purchasePrice,
        sortOrder: sortOrder,
        syncVersion: 0,
        createdAt: now,
        updatedAt: now,
        deviceId: _deviceIdReader?.call(),
      );
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _materialsEntity,
        entityId: id,
        operation: SyncQueueOperation.create,
        payload: {
          'item_id': itemId,
          'raw_item_id': material.rawItemId,
          'qty': _formatQty(material.qty),
          'unit_id': material.unitId,
          'purchase_price': _formatMoney(material.purchasePrice),
          'sort_order': sortOrder,
        },
        clientUpdatedAt: now,
      );
    }
  }

  Future<void> _replaceCosts({
    required String businessId,
    required String itemId,
    required List<ItemBomReplaceCostInput> costs,
    required DateTime now,
  }) async {
    final existing = await _costsLocal.listActiveRowsForItem(businessId, itemId);
    final existingById = {for (final row in existing) row.id: row};
    final incomingIds = costs
        .map((cost) => cost.id?.trim())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();

    for (final row in existing) {
      if (incomingIds.contains(row.id)) continue;
      await _costsLocal.softDelete(id: row.id, deletedAt: now);
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _costsEntity,
        entityId: row.id,
        operation: SyncQueueOperation.delete,
        payload: const {},
        baseSyncVersion: row.syncVersion,
        clientUpdatedAt: now,
      );
    }

    for (var index = 0; index < costs.length; index++) {
      final cost = costs[index];
      final sortOrder = cost.sortOrder == 0 ? index : cost.sortOrder;
      final description = cost.description.trim();
      final existingId = cost.id?.trim();
      final existingRow = existingId != null && existingId.isNotEmpty
          ? existingById[existingId]
          : null;

      if (existingRow != null) {
        final needsUpdate =
            existingRow.description != description ||
            existingRow.amount != cost.amount ||
            existingRow.sortOrder != sortOrder;
        if (!needsUpdate) continue;
        await _costsLocal.upsertRow(
          id: existingRow.id,
          businessId: businessId,
          itemId: itemId,
          description: description,
          amount: cost.amount,
          sortOrder: sortOrder,
          syncVersion: existingRow.syncVersion,
          createdAt: existingRow.createdAt,
          updatedAt: now,
          deviceId: _deviceIdReader?.call() ?? existingRow.deviceId,
        );
        await _syncQueue.enqueueRowMutation(
          businessId: businessId,
          deviceId: _deviceIdReader?.call(),
          entityType: _costsEntity,
          entityId: existingRow.id,
          operation: SyncQueueOperation.update,
          payload: {
            'item_id': itemId,
            'description': description,
            'amount': _formatMoney(cost.amount),
            'sort_order': sortOrder,
          },
          baseSyncVersion: existingRow.syncVersion,
          clientUpdatedAt: now,
        );
        continue;
      }

      final id = existingId != null && existingId.isNotEmpty
          ? existingId
          : _uuid.v4();
      await _costsLocal.upsertRow(
        id: id,
        businessId: businessId,
        itemId: itemId,
        description: description,
        amount: cost.amount,
        sortOrder: sortOrder,
        syncVersion: 0,
        createdAt: now,
        updatedAt: now,
        deviceId: _deviceIdReader?.call(),
      );
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _costsEntity,
        entityId: id,
        operation: SyncQueueOperation.create,
        payload: {
          'item_id': itemId,
          'description': description,
          'amount': _formatMoney(cost.amount),
          'sort_order': sortOrder,
        },
        clientUpdatedAt: now,
      );
    }
  }

  Future<void> _hydrateItemIfEmpty(String businessId, String itemId) async {
    final materialCount = await _materialsLocal.countActiveForItem(
      businessId,
      itemId,
    );
    final costCount = await _costsLocal.countActiveForItem(businessId, itemId);
    if (materialCount > 0 || costCount > 0) return;
    try {
      final remote = await _remote.getItemBom(itemId);
      for (final dto in remote.materials) {
        await _materialsLocal.upsertFromDto(businessId, dto);
      }
      for (final dto in remote.costs) {
        await _costsLocal.upsertFromDto(businessId, dto);
      }
    } on Object {
      // Offline — leave empty.
    }
  }

  static String _formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  static String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(4);
  }
}
