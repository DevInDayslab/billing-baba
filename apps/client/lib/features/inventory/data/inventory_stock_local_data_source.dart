import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:billing_baba/features/inventory/models/dto/movement_dto.dart';
import 'package:billing_baba/features/inventory/models/requests/movement_requests.dart';
import 'package:drift/drift.dart';

String stockLevelLocalId({
  required String businessId,
  required String itemId,
  required String godownId,
}) => '$businessId:$itemId:$godownId';

/// Composite keys from local document movements; server pull uses UUID ids.
bool isCompositeStockLevelId(String id) => id.contains(':');

double _parseQty(String? value) => double.tryParse(value ?? '') ?? 0;

String _formatQty(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(4);
}

/// Drift-backed inventory movements and stock levels.
class InventoryStockLocalDataSource {
  InventoryStockLocalDataSource(this._db);

  final AppDatabase _db;

  Future<double> currentQuantity({
    required String businessId,
    required String itemId,
    required String godownId,
  }) async {
    final rows =
        await (_db.select(_db.stockLevelsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.itemId.equals(itemId) &
                  t.godownId.equals(godownId) &
                  t.isDeleted.equals(false),
            ))
            .get();
    return rows.fold<double>(
      0,
      (sum, row) => sum + _parseQty(row.currentQuantity),
    );
  }

  Future<double> totalQuantityForItem({
    required String businessId,
    required String itemId,
  }) async {
    final rows =
        await (_db.select(_db.stockLevelsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.itemId.equals(itemId) &
                  t.isDeleted.equals(false),
            ))
            .get();
    return rows.fold<double>(
      0,
      (sum, row) => sum + _parseQty(row.currentQuantity),
    );
  }

  /// Removes all cached stock levels for a business (one-time reconcile only).
  Future<void> clearAllForBusiness(String businessId) {
    return (_db.delete(
      _db.stockLevelsLocal,
    )..where((t) => t.businessId.equals(businessId))).go();
  }

  /// Emits whenever stock levels change for a business (pull or local writes).
  Stream<void> watchStockLevels({required String businessId}) {
    return (_db.select(
      _db.stockLevelsLocal,
    )..where((t) => t.businessId.equals(businessId))).watch().map((_) {});
  }

  /// Applies a pulled `stock_levels` row. Upserts on (business, item, godown).
  Future<void> applyPullChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? itemId,
    String? godownId,
    String? quantity,
    String? averageCost,
    String? deviceId,
  }) async {
    final existingByTriple = itemId != null && godownId != null
        ? await _findByTriple(
            businessId: businessId,
            itemId: itemId,
            godownId: godownId,
          )
        : null;
    final existingById = await (_db.select(
      _db.stockLevelsLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();
    final existing = existingByTriple ?? existingById;

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    if (isDeleted) {
      final rowId = existing?.id ?? entityId;
      if (existing == null) {
        return;
      }
      await (_db.update(
        _db.stockLevelsLocal,
      )..where((t) => t.id.equals(rowId))).write(
        StockLevelsLocalCompanion(
          isDeleted: const Value(true),
          syncVersion: Value(syncVersion),
          updatedAt: Value(updatedAt.toUtc()),
          deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
        ),
      );
      return;
    }

    if (itemId == null || godownId == null) {
      return;
    }

    final currentQty = quantity ?? existing?.currentQuantity ?? '0';
    final avgCost = averageCost ?? existing?.averageCost ?? '0';
    final reservedQty = existing?.reservedQuantity ?? '0';
    final availableQty = _formatQty(
      _parseQty(currentQty) - _parseQty(reservedQty),
    );

    if (existing != null && existing.id != entityId) {
      await (_db.delete(
        _db.stockLevelsLocal,
      )..where((t) => t.id.equals(existing.id))).go();
    }

    await _db
        .into(_db.stockLevelsLocal)
        .insertOnConflictUpdate(
          StockLevelsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            itemId: itemId,
            godownId: godownId,
            currentQuantity: Value(currentQty),
            reservedQuantity: Value(reservedQty),
            availableQuantity: Value(availableQty),
            averageCost: Value(avgCost),
            updatedAt: updatedAt.toUtc(),
            syncVersion: Value(syncVersion),
            isDeleted: const Value(false),
            deviceId: Value(deviceId),
          ),
        );

    await collapseDuplicateStockTriples(businessId: businessId);
  }

  Future<StockLevelLocalData?> _findByTriple({
    required String businessId,
    required String itemId,
    required String godownId,
  }) {
    return (_db.select(_db.stockLevelsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.itemId.equals(itemId) &
                t.godownId.equals(godownId),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  /// Removes stale rows keyed by the literal godown id `default` (not a UUID).
  Future<void> removeLiteralDefaultGodownRows({
    required String businessId,
  }) async {
    await (_db.delete(_db.stockLevelsLocal)..where(
          (t) => t.businessId.equals(businessId) & t.godownId.equals('default'),
        ))
        .go();
  }

  /// When server pull and local document stock both wrote the same triple,
  /// keep the authoritative server row (UUID id / higher sync_version).
  Future<void> collapseDuplicateStockTriples({
    required String businessId,
  }) async {
    final rows =
        await (_db.select(_db.stockLevelsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();

    final groups = <String, List<StockLevelLocalData>>{};
    for (final row in rows) {
      final key = '${row.itemId}:${row.godownId}';
      groups.putIfAbsent(key, () => []).add(row);
    }

    for (final group in groups.values) {
      if (group.length <= 1) continue;

      final sorted = [...group]
        ..sort((a, b) {
          final timeCompare = b.updatedAt.compareTo(a.updatedAt);
          if (timeCompare != 0) return timeCompare;
          final aComposite = isCompositeStockLevelId(a.id);
          final bComposite = isCompositeStockLevelId(b.id);
          if (aComposite != bComposite) {
            return aComposite ? 1 : -1;
          }
          return b.syncVersion.compareTo(a.syncVersion);
        });

      for (final loser in sorted.skip(1)) {
        await (_db.delete(
          _db.stockLevelsLocal,
        )..where((t) => t.id.equals(loser.id))).go();
      }
    }
  }

  /// Bulk item quantities for list views (sums all godowns per item).
  Future<Map<String, double>> quantitiesByItem({
    required String businessId,
  }) async {
    final rows =
        await (_db.select(_db.stockLevelsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();

    final totals = <String, double>{};
    for (final row in rows) {
      totals[row.itemId] =
          (totals[row.itemId] ?? 0) + _parseQty(row.currentQuantity);
    }
    return totals;
  }

  Future<List<StockLevelLocalData>> listStockLevelRowsForItem({
    required String businessId,
    required String itemId,
  }) {
    return (_db.select(_db.stockLevelsLocal)..where(
          (t) =>
              t.businessId.equals(businessId) &
              t.itemId.equals(itemId) &
              t.isDeleted.equals(false),
        ))
        .get();
  }

  /// Idempotent movement write for finalized sales/purchase documents.
  Future<void> recordDocumentMovement({
    required String movementId,
    required String businessId,
    required String itemId,
    required String godownId,
    required String movementType,
    required double quantityDelta,
    required String documentId,
    required String documentType,
    required String referenceType,
    required DateTime createdAt,
    String? referenceNumber,
    String? costPerUnit,
    String? unit,
    String? notes,
    String? deviceId,
  }) async {
    final existing = await (_db.select(
      _db.inventoryMovementsLocal,
    )..where((t) => t.id.equals(movementId))).getSingleOrNull();
    if (existing != null) return;

    final beforeQty = await currentQuantity(
      businessId: businessId,
      itemId: itemId,
      godownId: godownId,
    );
    final afterQty = beforeQty + quantityDelta;

    await _db
        .into(_db.inventoryMovementsLocal)
        .insert(
          InventoryMovementsLocalCompanion.insert(
            id: movementId,
            businessId: businessId,
            itemId: itemId,
            godownId: godownId,
            documentId: Value(documentId),
            documentType: Value(documentType),
            movementType: movementType,
            quantity: _formatQty(quantityDelta),
            beforeQuantity: Value(_formatQty(beforeQty)),
            afterQuantity: Value(_formatQty(afterQty)),
            unit: Value(unit),
            reason: Value(notes),
            referenceId: Value(documentId),
            referenceType: Value(referenceType),
            referenceNumber: Value(referenceNumber),
            costPerUnit: Value(costPerUnit),
            notes: Value(notes),
            createdAt: createdAt,
            updatedAt: createdAt,
            syncVersion: const Value(0),
            deviceId: Value(deviceId),
          ),
        );

    await _upsertStockLevel(
      businessId: businessId,
      itemId: itemId,
      godownId: godownId,
      quantity: afterQty,
      averageCost: _parseQty(costPerUnit),
      updatedAt: createdAt,
      deviceId: deviceId,
    );
  }

  Future<bool> hasAnyMovements({required String businessId}) async {
    final row =
        await (_db.select(_db.inventoryMovementsLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) & t.isDeleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<InventoryMovementLocalData> recordAdjustment({
    required String movementId,
    required String businessId,
    required CreateMovementRequest request,
    required DateTime now,
    String? deviceId,
  }) async {
    final delta = _parseQty(request.quantityDelta);
    final beforeQty = await currentQuantity(
      businessId: businessId,
      itemId: request.itemId,
      godownId: request.godownId,
    );
    final afterQty = beforeQty + delta;

    final movement = InventoryMovementLocalData(
      id: movementId,
      businessId: businessId,
      itemId: request.itemId,
      godownId: request.godownId,
      movementType: request.movementType,
      quantity: request.quantityDelta,
      beforeQuantity: _formatQty(beforeQty),
      afterQuantity: _formatQty(afterQty),
      reason: request.notes,
      referenceId: movementId,
      referenceType: 'stock_adjustment',
      costPerUnit: request.costPerUnit,
      notes: request.notes,
      createdAt: now,
      updatedAt: now,
      syncVersion: 0,
      isDeleted: false,
      deviceId: deviceId,
    );

    await _db
        .into(_db.inventoryMovementsLocal)
        .insertOnConflictUpdate(
          InventoryMovementsLocalCompanion.insert(
            id: movement.id,
            businessId: movement.businessId,
            itemId: movement.itemId,
            godownId: movement.godownId,
            documentId: Value(movement.documentId),
            documentType: Value(movement.documentType),
            movementType: movement.movementType,
            quantity: movement.quantity,
            beforeQuantity: Value(movement.beforeQuantity),
            afterQuantity: Value(movement.afterQuantity),
            unit: Value(movement.unit),
            reason: Value(movement.reason),
            referenceId: Value(movement.referenceId),
            referenceType: Value(movement.referenceType),
            referenceNumber: Value(movement.referenceNumber),
            partyName: Value(movement.partyName),
            costPerUnit: Value(movement.costPerUnit),
            notes: Value(movement.notes),
            createdBy: Value(movement.createdBy),
            createdByName: Value(movement.createdByName),
            createdAt: movement.createdAt,
            updatedAt: movement.updatedAt,
            syncVersion: Value(movement.syncVersion),
            deviceId: Value(movement.deviceId),
          ),
        );

    await _upsertStockLevel(
      businessId: businessId,
      itemId: request.itemId,
      godownId: request.godownId,
      quantity: afterQty,
      averageCost: _parseQty(request.costPerUnit),
      updatedAt: now,
      deviceId: deviceId,
    );

    return movement;
  }

  Future<void> upsertMovementFromDto({
    required String businessId,
    required MovementDto dto,
    required DateTime updatedAt,
    int syncVersion = 0,
    String? deviceId,
    bool isDeleted = false,
  }) async {
    await _db
        .into(_db.inventoryMovementsLocal)
        .insertOnConflictUpdate(
          InventoryMovementsLocalCompanion.insert(
            id: dto.id,
            businessId: businessId,
            itemId: dto.itemId,
            godownId: dto.godownId,
            movementType: dto.movementType,
            quantity: dto.quantityDelta,
            unit: Value(dto.unit),
            reason: Value(dto.notes),
            referenceId: Value(dto.referenceId),
            referenceType: Value(dto.referenceType),
            referenceNumber: Value(dto.referenceNumber),
            partyName: Value(dto.partyName),
            costPerUnit: Value(dto.costPerUnit),
            notes: Value(dto.notes),
            createdBy: Value(dto.createdBy),
            createdByName: Value(dto.createdByName),
            createdAt: DateTime.tryParse(dto.createdAt)?.toUtc() ?? updatedAt,
            updatedAt: updatedAt,
            syncVersion: Value(syncVersion),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<List<MovementDto>> listMovementsForItem({
    required String businessId,
    required String itemId,
  }) async {
    final rows =
        await (_db.select(_db.inventoryMovementsLocal).join([
                leftOuterJoin(
                  _db.godownsLocal,
                  _db.godownsLocal.id.equalsExp(
                        _db.inventoryMovementsLocal.godownId,
                      ) &
                      _db.godownsLocal.businessId.equalsExp(
                        _db.inventoryMovementsLocal.businessId,
                      ),
                ),
                leftOuterJoin(
                  _db.itemsLocal,
                  _db.itemsLocal.id.equalsExp(
                        _db.inventoryMovementsLocal.itemId,
                      ) &
                      _db.itemsLocal.businessId.equalsExp(
                        _db.inventoryMovementsLocal.businessId,
                      ),
                ),
              ])
              ..where(
                _db.inventoryMovementsLocal.businessId.equals(businessId) &
                    _db.inventoryMovementsLocal.itemId.equals(itemId) &
                    _db.inventoryMovementsLocal.isDeleted.equals(false),
              )
              ..orderBy([
                OrderingTerm.desc(_db.inventoryMovementsLocal.createdAt),
              ]))
            .get();

    return [
      for (final row in rows)
        _movementDtoFromRow(
          movement: row.readTable(_db.inventoryMovementsLocal),
          godownName: row.readTableOrNull(_db.godownsLocal)?.name,
          itemName: row.readTableOrNull(_db.itemsLocal)?.name,
        ),
    ];
  }

  /// Sets per-godown stock from ledger totals; zeroes godowns with no movements.
  Future<double> applyStockQuantitiesFromLedger({
    required String businessId,
    required String itemId,
    required Map<String, double> quantitiesByGodown,
  }) async {
    final existingRows = await listStockLevelRowsForItem(
      businessId: businessId,
      itemId: itemId,
    );
    final now = DateTime.now().toUtc();
    final resolvedGodowns = <String>{
      ...quantitiesByGodown.keys,
      ...existingRows.map((row) => row.godownId),
    };

    for (final godownId in resolvedGodowns) {
      if (godownId.isEmpty) continue;
      final quantity = quantitiesByGodown[godownId] ?? 0;
      await _upsertStockLevel(
        businessId: businessId,
        itemId: itemId,
        godownId: godownId,
        quantity: quantity,
        averageCost: 0,
        updatedAt: now,
      );
    }

    return quantitiesByGodown.values.fold<double>(0, (sum, qty) => sum + qty);
  }

  Future<void> reconcileItemStock({
    required String businessId,
    required String itemId,
  }) async {
    final movements =
        await (_db.select(_db.inventoryMovementsLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) &
                    t.itemId.equals(itemId) &
                    t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();

    final byGodown = <String, double>{};
    for (final movement in movements) {
      final godownId = movement.godownId;
      final delta = _parseQty(movement.quantity);
      byGodown[godownId] = (byGodown[godownId] ?? 0) + delta;
    }

    final now = DateTime.now().toUtc();
    for (final entry in byGodown.entries) {
      await _upsertStockLevel(
        businessId: businessId,
        itemId: itemId,
        godownId: entry.key,
        quantity: entry.value,
        averageCost: 0,
        updatedAt: now,
      );
    }
  }

  Future<void> applyStockAdjustmentAck({
    required String adjustmentId,
    required List<Map<String, dynamic>> movementIds,
    required DateTime updatedAt,
    required int syncVersion,
  }) async {
    final existing = await (_db.select(
      _db.inventoryMovementsLocal,
    )..where((t) => t.id.equals(adjustmentId))).getSingleOrNull();
    if (existing == null) return;

    await (_db.update(
      _db.inventoryMovementsLocal,
    )..where((t) => t.id.equals(adjustmentId))).write(
      InventoryMovementsLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt),
      ),
    );

    final itemIds = <String>{existing.itemId};
    for (final entry in movementIds) {
      final itemId = entry['item_id']?.toString();
      if (itemId != null && itemId.isNotEmpty) {
        itemIds.add(itemId);
      }
    }

    for (final itemId in itemIds) {
      await reconcileItemStock(
        businessId: existing.businessId,
        itemId: itemId,
      );
    }
  }

  Future<void> _upsertStockLevel({
    required String businessId,
    required String itemId,
    required String godownId,
    required double quantity,
    required double averageCost,
    required DateTime updatedAt,
    String? deviceId,
  }) async {
    final existing = await _findByTriple(
      businessId: businessId,
      itemId: itemId,
      godownId: godownId,
    );
    final id =
        existing?.id ??
        stockLevelLocalId(
          businessId: businessId,
          itemId: itemId,
          godownId: godownId,
        );
    final reservedQty = existing?.reservedQuantity ?? '0';
    final resolvedCost = averageCost != 0
        ? averageCost
        : _parseQty(existing?.averageCost);
    final availableQty = _formatQty(quantity - _parseQty(reservedQty));

    await _db
        .into(_db.stockLevelsLocal)
        .insertOnConflictUpdate(
          StockLevelsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            itemId: itemId,
            godownId: godownId,
            currentQuantity: Value(_formatQty(quantity)),
            reservedQuantity: Value(reservedQty),
            availableQuantity: Value(availableQty),
            averageCost: Value(_formatQty(resolvedCost)),
            updatedAt: updatedAt,
            syncVersion: Value(existing?.syncVersion ?? 0),
            isDeleted: const Value(false),
            deviceId: Value(deviceId),
          ),
        );
  }

  MovementDto _movementDtoFromRow({
    required InventoryMovementLocalData movement,
    String? godownName,
    String? itemName,
  }) {
    return MovementDto(
      id: movement.id,
      itemId: movement.itemId,
      itemName: itemName ?? movement.itemId,
      godownId: movement.godownId,
      godownName: godownName ?? movement.godownId,
      movementType: movement.movementType,
      quantityDelta: movement.quantity,
      createdAt: movement.createdAt.toUtc().toIso8601String(),
      costPerUnit: movement.costPerUnit,
      unit: movement.unit,
      referenceId: movement.referenceId,
      referenceType: movement.referenceType,
      referenceNumber: movement.referenceNumber,
      partyName: movement.partyName,
      createdBy: movement.createdBy,
      createdByName: movement.createdByName,
      notes: movement.notes ?? movement.reason,
    );
  }
}
