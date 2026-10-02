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
  return orderedIds
      .map((id) => byId[id])
      .whereType<InventoryUnit>()
      .toList();
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
