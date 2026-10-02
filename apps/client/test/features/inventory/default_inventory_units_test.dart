import 'package:billing_baba/features/inventory/default_inventory_units.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mergeUnitsWithCatalogDefaults', () {
    test('returns full catalog when remote list is empty', () {
      final merged = mergeUnitsWithCatalogDefaults(const []);
      expect(merged.length, defaultInventoryUnitSeeds.length);
      expect(
        merged.map((u) => u.shortName.toLowerCase()).toSet(),
        contains('pcs'),
      );
    });

    test('adds missing predefined units by short name', () {
      const custom = InventoryUnit(
        id: 'uuid-custom',
        fullName: 'CUSTOM',
        shortName: 'Cus',
      );
      final merged = mergeUnitsWithCatalogDefaults([custom]);
      expect(merged.length, defaultInventoryUnitSeeds.length + 1);
      expect(merged.any((u) => u.shortName.toLowerCase() == 'pcs'), isTrue);
      expect(merged.any((u) => u.id == 'uuid-custom'), isTrue);
    });
  });
}
