import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/shared/utils/debouncer.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/item_settings/item_settings_rows.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemSettingsPanel extends ConsumerStatefulWidget {
  const ItemSettingsPanel({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final ItemSettings settings;
  final ValueChanged<ItemSettingsUpdater> onUpdate;

  @override
  ConsumerState<ItemSettingsPanel> createState() => _ItemSettingsPanelState();
}

class _ItemSettingsPanelState extends ConsumerState<ItemSettingsPanel> {
  late final TextEditingController _descriptionController;
  final _descriptionDebouncer = Debouncer();

  static final _descriptionDecoration = InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.all(AppSpacing.sm),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: listPanelCardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: listPanelCardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    hintText: 'Default item description',
    hintStyle: AppTypography.inter(
      color: AppColors.textSecondary,
      fontSize: AppTypography.bodySmallSize,
    ),
    filled: true,
    fillColor: AppColors.background,
  );

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.settings.descriptionText,
    );
  }

  @override
  void didUpdateWidget(ItemSettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.descriptionText != widget.settings.descriptionText &&
        _descriptionController.text != widget.settings.descriptionText) {
      _descriptionController.text = widget.settings.descriptionText;
    }
  }

  @override
  void dispose() {
    _descriptionDebouncer.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _update(ItemSettingsUpdater updater) {
    widget.onUpdate(updater);
  }

  Future<void> _pickDefaultUnit(List<InventoryUnit> units) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _DefaultUnitDialog(
        units: units,
        selectedId: widget.settings.defaultUnitId,
      ),
    );
    if (selected == null || !mounted) return;
    _update(
      (settings) => settings.copyWith(
        defaultUnitId: selected,
        defaultUnitEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final unitsAsync = ref.watch(inventoryUnitsProvider);
    final units = unitsAsync.value ?? const <InventoryUnit>[];
    final defaultUnitLabel = _defaultUnitLabel(units, settings.defaultUnitId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemSettingsSectionCard(
          title: 'General',
          children: [
            ItemSettingsToggleRow(
              label: 'Enable Item',
              infoTooltip: 'Turn item management on or off for your business.',
              value: settings.enableItem,
              onChanged: (value) =>
                  _update((s) => s.copyWith(enableItem: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsDropdownRow(
              label: 'Item Type',
              infoTooltip:
                  'Choose whether to track products, services, or both.',
              value: settings.itemTypeScope.label,
              options: ItemTypeScope.values.map((scope) => scope.label).toList(),
              onSelected: (label) {
                final scope = ItemTypeScope.values.firstWhere(
                  (entry) => entry.label == label,
                );
                _update((s) => s.copyWith(itemTypeScope: scope));
              },
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Barcode scanning for items',
              infoTooltip: 'Allow barcode scanning when adding or selling items.',
              value: settings.barcodeScanningEnabled,
              onChanged: (value) =>
                  _update((s) => s.copyWith(barcodeScanningEnabled: value)),
            ),
            if (settings.barcodeScanningEnabled) ...[
              const ItemSettingsDivider(),
              ItemSettingsCheckboxRow(
                label: 'Make Mobile POS as my default billing type',
                value: settings.mobilePosDefaultBilling,
                onChanged: (value) => _update(
                  (s) => s.copyWith(mobilePosDefaultBilling: value ?? false),
                ),
              ),
              const ItemSettingsDivider(),
              ItemSettingsRadioRow<BarcodeScannerType>(
                label: 'Select barcode scanner type',
                value: settings.barcodeScannerType,
                options: BarcodeScannerType.values,
                labelBuilder: (option) => option.label,
                onChanged: (value) =>
                    _update((s) => s.copyWith(barcodeScannerType: value)),
              ),
            ],
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Stock maintenance',
              infoTooltip: 'Track stock quantities for products.',
              value: settings.stockMaintenance,
              onChanged: (value) =>
                  _update((s) => s.copyWith(stockMaintenance: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Manufacturing',
              infoTooltip: 'Enable manufacturing and bill of materials.',
              isPremium: true,
              value: settings.manufacturing,
              onChanged: (value) =>
                  _update((s) => s.copyWith(manufacturing: value)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ItemSettingsSectionCard(
          title: 'Units & Categories',
          children: [
            ItemSettingsToggleRow(
              label: 'Item Units',
              infoTooltip: 'Allow multiple units and conversions per item.',
              value: settings.itemUnits,
              onChanged: (value) =>
                  _update((s) => s.copyWith(itemUnits: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Default Unit',
              infoTooltip: 'Apply a default unit when creating new items.',
              value: settings.defaultUnitEnabled,
              onChanged: (value) =>
                  _update((s) => s.copyWith(defaultUnitEnabled: value)),
            ),
            if (settings.defaultUnitEnabled) ...[
              const ItemSettingsDivider(),
              ItemSettingsNavRow(
                label: 'Change Default Unit',
                subtitle: defaultUnitLabel ?? 'Not set',
                onTap: units.isEmpty
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Add units before selecting a default'),
                          ),
                        );
                      }
                    : () => _pickDefaultUnit(units),
              ),
            ],
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Item Category',
              infoTooltip: 'Organize items into categories.',
              value: settings.itemCategory,
              onChanged: (value) =>
                  _update((s) => s.copyWith(itemCategory: value)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ItemSettingsSectionCard(
          title: 'Pricing',
          children: [
            ItemSettingsToggleRow(
              label: 'Party wise item rate',
              infoTooltip: 'Set different sale rates for each party.',
              isPremium: true,
              value: settings.partyWiseItemRate,
              onChanged: (value) =>
                  _update((s) => s.copyWith(partyWiseItemRate: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Wholesale Price',
              infoTooltip: 'Track wholesale pricing tiers on items.',
              isPremium: true,
              value: settings.wholesalePrice,
              onChanged: (value) =>
                  _update((s) => s.copyWith(wholesalePrice: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsCounterRow(
              label: 'Quantity (Upto Decimal places)',
              infoTooltip: 'Number of decimal places shown for item quantities.',
              value: settings.quantityDecimalPlaces,
              min: 0,
              max: 4,
              onChanged: (value) =>
                  _update((s) => s.copyWith(quantityDecimalPlaces: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Item wise tax',
              infoTooltip: 'Set tax rates individually on each item.',
              value: settings.itemWiseTax,
              onChanged: (value) =>
                  _update((s) => s.copyWith(itemWiseTax: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Calculate Tax based on MRP',
              infoTooltip: 'Compute tax from MRP instead of sale price.',
              value: settings.calculateTaxBasedOnMrp,
              onChanged: (value) =>
                  _update((s) => s.copyWith(calculateTaxBasedOnMrp: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Item wise discount',
              infoTooltip: 'Allow per-item discounts on transactions.',
              value: settings.itemWiseDiscount,
              onChanged: (value) =>
                  _update((s) => s.copyWith(itemWiseDiscount: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Update Sale Price from TXN',
              infoTooltip:
                  'Update item sale price automatically from transactions.',
              value: settings.updateSalePriceFromTxn,
              onChanged: (value) =>
                  _update((s) => s.copyWith(updateSalePriceFromTxn: value)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ItemSettingsSectionCard(
          title: 'Fields',
          children: [
            ItemSettingsNavRow(
              label: 'Additional Item Fields',
              isPremium: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Additional item fields coming soon'),
                  ),
                );
              },
            ),
            const ItemSettingsDivider(),
            ItemSettingsNavRow(
              label: 'Item Custom Fields',
              infoTooltip: 'Create custom fields for items.',
              isPremium: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item custom fields coming soon'),
                  ),
                );
              },
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Description',
              infoTooltip: 'Show description field when creating items.',
              value: settings.descriptionEnabled,
              onChanged: (value) =>
                  _update((s) => s.copyWith(descriptionEnabled: value)),
            ),
            if (settings.descriptionEnabled) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySmallSize,
                  color: AppColors.textPrimary,
                ),
                decoration: _descriptionDecoration,
                onChanged: (value) {
                  _descriptionDebouncer.run(() {
                    _update((s) => s.copyWith(descriptionText: value));
                  });
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ItemSettingsSectionCard(
          title: 'GST',
          children: [
            ItemSettingsToggleRow(
              label: 'HSN/SAC Code',
              infoTooltip: 'Capture HSN or SAC codes on items.',
              value: settings.hsnSacCode,
              onChanged: (value) =>
                  _update((s) => s.copyWith(hsnSacCode: value)),
            ),
            const ItemSettingsDivider(),
            ItemSettingsToggleRow(
              label: 'Additional CESS',
              infoTooltip: 'Track additional cess on applicable items.',
              value: settings.additionalCess,
              onChanged: (value) =>
                  _update((s) => s.copyWith(additionalCess: value)),
            ),
          ],
        ),
      ],
    );
  }

  String? _defaultUnitLabel(List<InventoryUnit> units, String? unitId) {
    if (unitId == null) return null;
    final unit = units.where((entry) => entry.id == unitId).firstOrNull;
    return unit?.fullName;
  }
}

class _DefaultUnitDialog extends StatelessWidget {
  const _DefaultUnitDialog({
    required this.units,
    required this.selectedId,
  });

  final List<InventoryUnit> units;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Default Unit'),
      content: SizedBox(
        width: 360,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: units.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final unit = units[index];
            final selected = unit.id == selectedId;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(unit.fullName),
              subtitle: Text(unit.shortName),
              trailing: selected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, unit.id),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
