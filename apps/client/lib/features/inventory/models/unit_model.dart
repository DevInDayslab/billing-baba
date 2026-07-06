class UnitConversion {
  const UnitConversion({
    required this.id,
    required this.label,
    required this.factor,
    this.fromUnitId,
    this.toUnitId,
    this.toUnitName,
  });

  final String id;
  final String label;
  final double factor;
  final String? fromUnitId;
  final String? toUnitId;
  final String? toUnitName;
}

class InventoryUnit {
  const InventoryUnit({
    required this.id,
    required this.fullName,
    required this.shortName,
    this.conversions = const [],
    this.symbol,
    this.decimalPlaces = 0,
    this.isSystem = false,
    this.isActive = true,
    this.conversionCount = 0,
  });

  final String id;
  final String fullName;
  final String shortName;
  final List<UnitConversion> conversions;
  final String? symbol;
  final int decimalPlaces;
  final bool isSystem;
  final bool isActive;
  final int conversionCount;

  InventoryUnit copyWith({
    String? id,
    String? fullName,
    String? shortName,
    List<UnitConversion>? conversions,
    String? symbol,
    int? decimalPlaces,
    bool? isSystem,
    bool? isActive,
    int? conversionCount,
  }) {
    return InventoryUnit(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      shortName: shortName ?? this.shortName,
      conversions: conversions ?? this.conversions,
      symbol: symbol ?? this.symbol,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      conversionCount: conversionCount ?? this.conversionCount,
    );
  }
}

/// Picks a sensible default unit for service items when the user cannot choose one.
InventoryUnit? resolveDefaultServiceUnit(List<InventoryUnit> units) {
  if (units.isEmpty) return null;

  final byShortName = {
    for (final unit in units) unit.shortName.toLowerCase(): unit,
  };

  for (final shortName in ['svc', 'pcs']) {
    final unit = byShortName[shortName];
    if (unit != null) return unit;
  }

  for (final unit in units) {
    final fullName = unit.fullName.toLowerCase();
    if (fullName.contains('service') || fullName == 'piece') {
      return unit;
    }
  }

  return units.first;
}
