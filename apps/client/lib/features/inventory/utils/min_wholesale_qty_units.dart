import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:collection/collection.dart';

/// Units available for minimum wholesale quantity (base + alternate).
List<InventoryUnit> minWholesaleQtyUnitOptions({
  required List<InventoryUnit> allUnits,
  String? baseUnitId,
  String? secondaryUnitId,
}) {
  final orderedIds = <String>[
    ?baseUnitId,
    if (secondaryUnitId != null && secondaryUnitId != baseUnitId)
      secondaryUnitId,
  ];
  if (orderedIds.isEmpty) return const [];

  final byId = {for (final unit in allUnits) unit.id: unit};
  return orderedIds.map((id) => byId[id]).whereType<InventoryUnit>().toList();
}

String? minWholesaleQtyUnitShortName({
  required List<InventoryUnit> options,
  required String? selectedUnitId,
  String? fallbackBaseUnitId,
}) {
  final effectiveId = selectedUnitId ?? fallbackBaseUnitId;
  if (effectiveId == null) return null;
  return options
      .where((unit) => unit.id == effectiveId)
      .map((unit) => unit.shortName)
      .firstOrNull;
}

/// Resolves catalog unit id from a short name (case-insensitive).
String? resolveInventoryUnitIdByShortName(
  List<InventoryUnit> allUnits,
  String? shortName,
) {
  final trimmed = shortName?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final normalized = trimmed.toLowerCase();
  final byShortName = allUnits
      .where((unit) => unit.shortName.toLowerCase() == normalized)
      .map((unit) => unit.id)
      .firstOrNull;
  if (byShortName != null) return byShortName;

  final byFullName = allUnits
      .where((unit) => unit.fullName.toLowerCase() == normalized)
      .map((unit) => unit.id)
      .firstOrNull;
  if (byFullName != null) return byFullName;

  const pieceAliases = {'pcs', 'pc', 'piece', 'pieces'};
  if (pieceAliases.contains(normalized)) {
    return resolveDefaultPcsUnit(allUnits)?.id;
  }
  return null;
}

/// Alternate unit for qty fields when item has a single conversion pair in catalog.
String? inferItemSecondaryUnitId({
  required List<InventoryUnit> allUnits,
  required String baseUnitId,
}) {
  final baseUnit = allUnits.where((unit) => unit.id == baseUnitId).firstOrNull;
  if (baseUnit != null) {
    for (final conversion in baseUnit.conversions) {
      final toId = conversion.toUnitId;
      if (toId != null &&
          toId != baseUnitId &&
          allUnits.any((unit) => unit.id == toId)) {
        return toId;
      }
    }
  }

  for (final unit in allUnits) {
    if (unit.id == baseUnitId) continue;
    for (final conversion in unit.conversions) {
      if (conversion.toUnitId == baseUnitId) {
        return unit.id;
      }
    }
  }
  return null;
}

/// Unit ids linked to [baseUnitId] via conversion rows (excludes base).
List<String> linkedUnitIdsFromConversions({
  required String baseUnitId,
  required List<UnitConversion> conversions,
}) {
  final ids = <String>{};
  for (final conversion in conversions) {
    final toId = conversion.toUnitId;
    final fromId = conversion.fromUnitId;
    if (toId != null && toId != baseUnitId) {
      if (fromId == null || fromId == baseUnitId) ids.add(toId);
    }
    if (fromId != null && fromId != baseUnitId) {
      if (toId == null || toId == baseUnitId) ids.add(fromId);
    }
  }
  return ids.toList();
}

/// Base + alternate units for stock/qty inputs on an existing item.
List<InventoryUnit> itemStockQtyUnitOptions({
  required List<InventoryUnit> allUnits,
  String? baseUnitId,
  String? baseUnitShortName,
  String? secondaryUnitId,
  Iterable<String>? additionalUnitIds,
}) {
  final resolvedBaseId =
      baseUnitId ??
      resolveInventoryUnitIdByShortName(allUnits, baseUnitShortName);
  if (resolvedBaseId != null) {
    final resolvedSecondaryId =
        secondaryUnitId ??
        inferItemSecondaryUnitId(
          allUnits: allUnits,
          baseUnitId: resolvedBaseId,
        );

    final orderedIds = <String>[resolvedBaseId];
    void addId(String? id) {
      if (id == null || id == resolvedBaseId || orderedIds.contains(id)) {
        return;
      }
      orderedIds.add(id);
    }

    addId(resolvedSecondaryId);
    for (final id in additionalUnitIds ?? const <String>[]) {
      addId(id);
    }

    final byId = {for (final unit in allUnits) unit.id: unit};
    final options = orderedIds.map((id) => byId[id]).whereType<InventoryUnit>().toList();
    if (options.isNotEmpty) return options;

    final label = baseUnitShortName?.trim();
    if (label != null && label.isNotEmpty) {
      return [
        InventoryUnit(
          id: resolvedBaseId,
          fullName: label,
          shortName: label,
        ),
      ];
    }
  }

  final label = baseUnitShortName?.trim();
  if (label == null || label.isEmpty) return const [];
  return [
    InventoryUnit(
      id: resolvedBaseId ?? label,
      fullName: label,
      shortName: label,
    ),
  ];
}
