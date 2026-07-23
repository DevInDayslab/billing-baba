import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/utils/item_tax_rate.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';

/// Builds inventory item payloads from parsed purchase bill lines.
class PurchaseDocumentItemFactory {
  const PurchaseDocumentItemFactory._();

  static String normalizeName(String name) => name.trim().toLowerCase();

  static Map<String, String> buildNameToIdMap(List<InventoryItem> items) {
    final map = <String, String>{};
    for (final item in items) {
      final key = normalizeName(item.name);
      if (key.isEmpty) continue;
      map.putIfAbsent(key, () => item.id);
    }
    return map;
  }

  static String? resolveExistingItemId({
    required String itemName,
    required Map<String, String> nameToId,
    String? itemId,
  }) {
    if (itemId != null && itemId.isNotEmpty) return itemId;
    final key = normalizeName(itemName);
    if (key.isEmpty) return null;
    return nameToId[key];
  }

  /// One representative line per unique item name that still needs inventory.
  static List<PurchaseLineItem> linesNeedingCreation(
    List<PurchaseLineItem> lines,
    Map<String, String> nameToId,
  ) {
    final seen = <String>{};
    final templates = <PurchaseLineItem>[];

    for (final line in lines) {
      if (line.itemId != null && line.itemId!.isNotEmpty) continue;
      final key = normalizeName(line.itemName);
      if (key.isEmpty || seen.contains(key) || nameToId.containsKey(key)) {
        continue;
      }
      seen.add(key);
      templates.add(line);
    }

    return templates;
  }

  static List<PurchaseLineItem> assignItemIds(
    List<PurchaseLineItem> lines,
    Map<String, String> nameToId,
  ) {
    return [
      for (final line in lines)
        line.copyWith(
          itemId: resolveExistingItemId(
            itemName: line.itemName,
            nameToId: nameToId,
            itemId: line.itemId,
          ),
        ),
    ];
  }

  static AddItemFormState? toAddItemFormState({
    required PurchaseLineItem line,
    required List<InventoryUnit> units,
  }) {
    final name = line.itemName.trim();
    if (name.isEmpty) return null;

    final defaultUnit = _defaultUnit(units);
    if (defaultUnit == null) return null;

    final unitLabel = _unitLabelForLine(line.unit);
    final resolvedUnit = _resolveUnit(unitLabel, units) ?? defaultUnit;

    return AddItemFormState(
      itemName: name,
      description: line.description.trim(),
      baseUnitId: resolvedUnit.id,
      atPrice: line.pricePerUnit > 0 ? line.pricePerUnit : 0,
      // Opening stock stays 0; qty from the bill is applied when the bill is saved.
      openingQty: 0,
      purchasePriceTaxMode: line.priceIsTaxInclusive
          ? PriceTaxMode.withTax
          : PriceTaxMode.withoutTax,
      taxRate: ItemTaxRate.labelForPercent(
        line.taxPercent > 0 ? line.taxPercent : null,
      ),
    );
  }

  static String _unitLabelForLine(String unit) {
    final trimmed = unit.trim();
    if (trimmed.isEmpty || trimmed.toUpperCase() == 'NONE') return '';
    return trimmed;
  }

  static InventoryUnit? _defaultUnit(List<InventoryUnit> units) {
    if (units.isEmpty) return null;
    for (final unit in units) {
      if (unit.shortName.toLowerCase() == 'pcs') return unit;
    }
    return units.first;
  }

  static InventoryUnit? _resolveUnit(
    String unitLabel,
    List<InventoryUnit> units,
  ) {
    if (unitLabel.trim().isEmpty) return null;
    final normalized = unitLabel.trim().toLowerCase();

    for (final unit in units) {
      if (unit.shortName.toLowerCase() == normalized ||
          unit.fullName.toLowerCase() == normalized ||
          (unit.symbol?.toLowerCase() == normalized)) {
        return unit;
      }
    }

    for (final alias in _aliasesFor(normalized)) {
      for (final unit in units) {
        final shortName = unit.shortName.toLowerCase();
        final fullName = unit.fullName.toLowerCase();
        if (shortName == alias ||
            fullName == alias ||
            shortName.contains(alias) ||
            fullName.contains(alias)) {
          return unit;
        }
      }
    }

    return null;
  }

  static Iterable<String> _aliasesFor(String normalized) {
    return switch (normalized) {
      'nos' ||
      'no' ||
      'number' ||
      'numbers' => const ['pcs', 'piece', 'pieces'],
      'bag' || 'bags' => const ['bag', 'pcs'],
      'kg' || 'kgs' || 'kilogram' || 'kilograms' => const ['kg', 'kgs'],
      'gm' || 'gms' || 'gram' || 'grams' => const ['gm', 'gms', 'gram'],
      'ltr' || 'ltrs' || 'liter' || 'litre' => const ['ltr', 'liter', 'litre'],
      'box' || 'boxes' => const ['box', 'pcs'],
      'pkt' || 'pack' || 'packet' => const ['pkt', 'pack', 'pcs'],
      _ => const [],
    };
  }
}
