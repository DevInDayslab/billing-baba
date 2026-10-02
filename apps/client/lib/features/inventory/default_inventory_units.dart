import 'package:billing_baba/features/inventory/models/unit_model.dart';

/// Stable ids for Vyapar-style default units (offline seed + UI catalog).
class DefaultInventoryUnitSeed {
  const DefaultInventoryUnitSeed({
    required this.id,
    required this.fullName,
    required this.shortName,
  });

  final String id;
  final String fullName;
  final String shortName;
}

const defaultInventoryUnitSeeds = <DefaultInventoryUnitSeed>[
  DefaultInventoryUnitSeed(id: 'pcs', fullName: 'PIECES', shortName: 'PCS'),
  DefaultInventoryUnitSeed(id: 'bags', fullName: 'BAGS', shortName: 'Bag'),
  DefaultInventoryUnitSeed(id: 'bottles', fullName: 'BOTTLES', shortName: 'Btl'),
  DefaultInventoryUnitSeed(id: 'box', fullName: 'BOX', shortName: 'Box'),
  DefaultInventoryUnitSeed(id: 'bundles', fullName: 'BUNDLES', shortName: 'Bdl'),
  DefaultInventoryUnitSeed(id: 'cans', fullName: 'CANS', shortName: 'Cns'),
  DefaultInventoryUnitSeed(id: 'cartons', fullName: 'CARTONS', shortName: 'Ctn'),
  DefaultInventoryUnitSeed(id: 'dozens', fullName: 'DOZENS', shortName: 'Dzn'),
  DefaultInventoryUnitSeed(id: 'grammes', fullName: 'GRAMMES', shortName: 'Gm'),
  DefaultInventoryUnitSeed(
    id: 'kilograms',
    fullName: 'KILOGRAMS',
    shortName: 'Kg',
  ),
  DefaultInventoryUnitSeed(id: 'litre', fullName: 'LITRE', shortName: 'Ltr'),
  DefaultInventoryUnitSeed(id: 'meters', fullName: 'METERS', shortName: 'Mtr'),
  DefaultInventoryUnitSeed(
    id: 'mililitre',
    fullName: 'MILILITRE',
    shortName: 'Ml',
  ),
];

/// Demo catalog units (includes sample conversion metadata for UI mocks).
List<InventoryUnit> catalogInventoryUnits() {
  return [
    for (final seed in defaultInventoryUnitSeeds)
      if (seed.id == 'bags')
        InventoryUnit(
          id: seed.id,
          fullName: seed.fullName,
          shortName: seed.shortName,
          isSystem: true,
          conversions: const [
            UnitConversion(
              id: 'conv-bags-bottles',
              label: '1 BAGS = 10 BOTTLES',
              factor: 10,
            ),
          ],
        )
      else
        InventoryUnit(
          id: seed.id,
          fullName: seed.fullName,
          shortName: seed.shortName,
          isSystem: true,
        ),
  ];
}

/// Ensures predefined units appear even when the local/API catalog is partial.
List<InventoryUnit> mergeUnitsWithCatalogDefaults(List<InventoryUnit> units) {
  if (units.isEmpty) return catalogInventoryUnits();

  final seenShortNames = <String>{
    for (final unit in units) unit.shortName.toLowerCase(),
  };
  final merged = List<InventoryUnit>.from(units);
  for (final catalogUnit in catalogInventoryUnits()) {
    final key = catalogUnit.shortName.toLowerCase();
    if (seenShortNames.add(key)) {
      merged.add(catalogUnit);
    }
  }
  merged.sort(
    (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
  );
  return merged;
}
