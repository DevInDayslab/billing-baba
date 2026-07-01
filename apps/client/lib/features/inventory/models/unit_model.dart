class UnitConversion {
  const UnitConversion({
    required this.id,
    required this.label,
    required this.factor,
  });

  final String id;
  final String label;
  final double factor;
}

class InventoryUnit {
  const InventoryUnit({
    required this.id,
    required this.fullName,
    required this.shortName,
    this.conversions = const [],
  });

  final String id;
  final String fullName;
  final String shortName;
  final List<UnitConversion> conversions;
}
