import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/utils/min_wholesale_qty_units.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Unit label / dropdown suffix for quantity fields (stock, wholesale qty, etc.).
class ItemQtyUnitSuffix extends StatelessWidget {
  const ItemQtyUnitSuffix({
    required this.unitOptions,
    required this.selectedUnitId,
    required this.fallbackBaseUnitId,
    required this.onUnitSelected,
    this.compact = true,
    super.key,
  });

  final List<InventoryUnit> unitOptions;
  final String? selectedUnitId;
  final String? fallbackBaseUnitId;
  final ValueChanged<String> onUnitSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (unitOptions.isEmpty) return const SizedBox.shrink();

    final selectedShortName = minWholesaleQtyUnitShortName(
      options: unitOptions,
      selectedUnitId: selectedUnitId,
      fallbackBaseUnitId: fallbackBaseUnitId,
    );
    if (selectedShortName == null) return const SizedBox.shrink();

    if (unitOptions.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          selectedShortName,
          style: saleFieldTextStyle.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return SizedBox(
      width: compact ? 88 : 96,
      child: SaleGenericSelectDropdown(
        borderless: true,
        compact: compact,
        triggerHeight: saleFieldHeight - 20,
        value: selectedShortName,
        options: unitOptions.map((unit) => unit.shortName).toList(),
        onSelected: (shortName) {
          final unit = unitOptions.firstWhereOrNull(
            (entry) => entry.shortName == shortName,
          );
          if (unit != null) onUnitSelected(unit.id);
        },
      ),
    );
  }
}
