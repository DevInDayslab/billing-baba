import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/add_item_form_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Mobile manufacturing / BOM editor for Add Item.
class MobileItemManufacturingScreen extends ConsumerStatefulWidget {
  const MobileItemManufacturingScreen({super.key});

  @override
  ConsumerState<MobileItemManufacturingScreen> createState() =>
      _MobileItemManufacturingScreenState();
}

class _MobileItemManufacturingScreenState
    extends ConsumerState<MobileItemManufacturingScreen> {
  final Map<String, TextEditingController> _additionalCostControllers = {};

  @override
  void dispose() {
    for (final controller in _additionalCostControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addItemFormProvider);
    final notifier = ref.read(addItemFormProvider.notifier);
    final units =
        ref.watch(inventoryUnitsProvider).value ?? const <InventoryUnit>[];
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: 'Manufacturing',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          Text(
            'Raw materials',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...form.rawMaterials.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _RawMaterialCard(
                index: entry.key + 1,
                row: entry.value,
                units: units,
                canRemove: form.rawMaterials.length > 1,
                onChanged: notifier.updateRawMaterial,
                onItemSelected: notifier.selectRawMaterialItem,
                onRemove: () => notifier.removeRawMaterialRow(entry.value.id),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: notifier.addRawMaterialRow,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add raw material'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Raw material total',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                currency.format(form.rawMaterialTotal),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Additional costs',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (form.additionalCosts.isEmpty)
            Text(
              'No additional costs added.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ...form.additionalCosts.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: MobileCard(
                child: Column(
                  children: [
                    MobileAddItemField(
                      controller: _additionalCostControllers.putIfAbsent(
                        row.id,
                        () => TextEditingController(text: row.description),
                      ),
                      label: 'Description',
                      hint: 'Labour, packaging, etc.',
                      onChanged: (value) => notifier.updateAdditionalCost(
                        row.id,
                        description: value,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    MobileAddItemField(
                      controller: TextEditingController(
                        text: row.amount == 0 ? '' : row.amount.toString(),
                      ),
                      label: 'Amount',
                      hint: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      onChanged: (value) => notifier.updateAdditionalCost(
                        row.id,
                        amount: double.tryParse(value) ?? 0,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => notifier.removeAdditionalCost(row.id),
                        icon: const Icon(
                          LucideIcons.trash2,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: notifier.addAdditionalCost,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add additional cost'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileCard(
            backgroundColor: const Color(0xFFFFF8E1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total estimated cost',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currency.format(form.totalEstimatedCost),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Raw materials + additional costs',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RawMaterialCard extends StatelessWidget {
  const _RawMaterialCard({
    required this.index,
    required this.row,
    required this.units,
    required this.canRemove,
    required this.onChanged,
    required this.onItemSelected,
    required this.onRemove,
  });

  final int index;
  final RawMaterialRow row;
  final List<InventoryUnit> units;
  final bool canRemove;
  final void Function(
    String id, {
    String? rawItemId,
    bool clearRawItemId,
    String? itemName,
    double? qty,
    String? unitId,
    bool clearUnitId,
    String? unitLabel,
    double? purchasePrice,
  })
  onChanged;
  final void Function(String id, SaleItemOption item) onItemSelected;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final unitOptions = units.isEmpty
        ? const ['PCS', 'Kg', 'Ltr']
        : units.map((unit) => unit.shortName).toList();
    final selectedUnitLabel = row.unitId != null
        ? units.firstWhereOrNull((unit) => unit.id == row.unitId)?.shortName
        : row.unitLabel;

    return MobileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Material $index',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(LucideIcons.x, size: 20, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ItemNameAutocompleteField(
            value: row.itemName,
            onChanged: (value) => onChanged(
              row.id,
              itemName: value,
              clearRawItemId: value.trim().isEmpty,
            ),
            onItemSelected: (item) {
              onItemSelected(row.id, item);
              final unit = units.firstWhereOrNull(
                (u) =>
                    u.shortName.toLowerCase() ==
                    saleItemDefaultUnit(item).toLowerCase(),
              );
              if (unit != null) {
                onChanged(row.id, unitId: unit.id, unitLabel: unit.shortName);
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: MobileAddItemField(
                  controller: TextEditingController(
                    text: row.qty == 0 ? '' : row.qty.toString(),
                  ),
                  label: 'Qty',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) =>
                      onChanged(row.id, qty: double.tryParse(value) ?? 0),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: unitOptions.contains(selectedUnitLabel)
                      ? selectedUnitLabel
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: unitOptions
                      .map(
                        (label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    final unit = units.firstWhereOrNull(
                      (u) => u.shortName == value,
                    );
                    onChanged(
                      row.id,
                      unitLabel: value,
                      unitId: unit?.id,
                      clearUnitId: unit == null,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          MobileAddItemField(
            controller: TextEditingController(
              text: row.purchasePrice == 0 ? '' : row.purchasePrice.toString(),
            ),
            label: 'Purchase price / unit',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (value) => onChanged(
              row.id,
              purchasePrice: double.tryParse(value) ?? 0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Estimated cost: ${currency.format(row.estimatedCost)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
