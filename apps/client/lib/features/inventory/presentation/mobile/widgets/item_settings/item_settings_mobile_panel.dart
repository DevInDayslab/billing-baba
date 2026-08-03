import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_list_section.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_settings/item_settings_mobile_rows.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemSettingsMobilePanel extends ConsumerStatefulWidget {
  const ItemSettingsMobilePanel({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final ItemSettings settings;
  final ValueChanged<ItemSettingsUpdater> onUpdate;

  @override
  ConsumerState<ItemSettingsMobilePanel> createState() =>
      _ItemSettingsMobilePanelState();
}

class _ItemSettingsMobilePanelState
    extends ConsumerState<ItemSettingsMobilePanel> {
  void _update(ItemSettingsUpdater updater) {
    widget.onUpdate(updater);
  }

  Future<void> _pickItemType(ItemSettings settings) async {
    final selected = await showMobileOptionSheet<ItemTypeScope>(
      context: context,
      title: 'Item Type',
      selected: settings.itemTypeScope,
      options: [
        for (final scope in ItemTypeScope.values)
          MobileOption(value: scope, label: scope.label),
      ],
    );
    if (selected == null || !mounted) return;
    _update((s) => s.copyWith(itemTypeScope: selected));
  }

  Future<void> _editDescription(ItemSettings settings) async {
    final controller = TextEditingController(text: settings.descriptionText);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Default Description',
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(color: Color(0xFFE8EAED)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(color: Color(0xFFE8EAED)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () =>
                    Navigator.of(sheetContext).pop(controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (result == null || !mounted) return;
    _update((s) => s.copyWith(descriptionText: result));
  }

  Future<void> _pickDefaultUnit(
    ItemSettings settings,
    List<InventoryUnit> units,
  ) async {
    if (units.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add units before selecting a default')),
      );
      return;
    }

    final selected = await showMobileOptionSheet<String>(
      context: context,
      title: 'Select Default Unit',
      selected: settings.defaultUnitId,
      options: [
        for (final unit in units)
          MobileOption(
            value: unit.id,
            label: unit.fullName,
            subtitle: unit.shortName,
          ),
      ],
    );
    if (selected == null || !mounted) return;
    _update(
      (s) => s.copyWith(
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
        MobileListSection(
          title: 'General',
          children: [
            _SettingsCard(
              children: [
                ItemSettingsMobileSwitchTile(
                  label: 'Enable Item',
                  infoTooltip:
                      'Turn item management on or off for your business.',
                  value: settings.enableItem,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(enableItem: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileOptionTile(
                  label: 'Item Type',
                  infoTooltip:
                      'Choose whether to track products, services, or both.',
                  value: settings.itemTypeScope.label,
                  onTap: () => _pickItemType(settings),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileCheckboxTile(
                  label: 'Barcode Scan',
                  infoTooltip:
                      'Allow barcode scanning when adding or selling items.',
                  value: settings.barcodeScanningEnabled,
                  onChanged: (value) => _update(
                    (s) => s.copyWith(barcodeScanningEnabled: value ?? false),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ItemSettingsMobileRadioGroup<BarcodeScannerType>(
                        value: settings.barcodeScannerType,
                        options: BarcodeScannerType.values,
                        labelBuilder: (type) => type.label,
                        onChanged: (type) =>
                            _update((s) => s.copyWith(barcodeScannerType: type)),
                      ),
                      const ItemSettingsMobileDivider(),
                      ItemSettingsMobileCheckboxTile(
                        label: 'Make Mobile POS as my default billing type',
                        value: settings.mobilePosDefaultBilling,
                        onChanged: (value) => _update(
                          (s) =>
                              s.copyWith(mobilePosDefaultBilling: value ?? false),
                        ),
                      ),
                    ],
                  ),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileSwitchTile(
                  label: 'Stock maintenance',
                  infoTooltip: 'Track stock quantities for products.',
                  value: settings.stockMaintenance,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(stockMaintenance: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileSwitchTile(
                  label: 'Manufacturing',
                  infoTooltip: 'Enable manufacturing and bill of materials.',
                  isPremium: true,
                  value: settings.manufacturing,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(manufacturing: value)),
                ),
              ],
            ),
          ],
        ),
        MobileListSection(
          title: 'Units & Categories',
          children: [
            _SettingsCard(
              children: [
                ItemSettingsMobileSwitchTile(
                  label: 'Item Units',
                  infoTooltip: 'Allow multiple units and conversions per item.',
                  value: settings.itemUnits,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(itemUnits: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileSwitchTile(
                  label: 'Default Unit',
                  infoTooltip: 'Apply a default unit when creating new items.',
                  value: settings.defaultUnitEnabled,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(defaultUnitEnabled: value)),
                ),
                if (settings.defaultUnitEnabled) ...[
                  const ItemSettingsMobileDivider(),
                  ItemSettingsMobileNavTile(
                    label: 'Change Default Unit',
                    trailingValue: defaultUnitLabel ?? 'Not set',
                    onTap: () => _pickDefaultUnit(settings, units),
                  ),
                ],
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileCheckboxTile(
                  label: 'Item Category',
                  infoTooltip: 'Organize items into categories.',
                  value: settings.itemCategory,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(itemCategory: value ?? false)),
                ),
              ],
            ),
          ],
        ),
        MobileListSection(
          title: 'Pricing',
          children: [
            _SettingsCard(
              children: [
                ItemSettingsMobileSwitchTile(
                  label: 'Party wise item rate',
                  infoTooltip: 'Set different sale rates for each party.',
                  isPremium: true,
                  value: settings.partyWiseItemRate,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(partyWiseItemRate: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileCheckboxTile(
                  label: 'Wholesale Price',
                  infoTooltip: 'Track wholesale pricing tiers on items.',
                  isPremium: true,
                  value: settings.wholesalePrice,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(wholesalePrice: value ?? false)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileCounterTile(
                  label: 'Quantity (Upto Decimal places)',
                  infoTooltip:
                      'Number of decimal places shown for item quantities.',
                  value: settings.quantityDecimalPlaces,
                  min: 0,
                  max: 4,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(quantityDecimalPlaces: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileSwitchTile(
                  label: 'Item wise tax',
                  infoTooltip: 'Set tax rates individually on each item.',
                  value: settings.itemWiseTax,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(itemWiseTax: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileSwitchTile(
                  label: 'Calculate Tax based on MRP',
                  infoTooltip: 'Compute tax from MRP instead of sale price.',
                  value: settings.calculateTaxBasedOnMrp,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(calculateTaxBasedOnMrp: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileSwitchTile(
                  label: 'Item wise discount',
                  infoTooltip: 'Allow per-item discounts on transactions.',
                  value: settings.itemWiseDiscount,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(itemWiseDiscount: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileSwitchTile(
                  label: 'Update Sale Price from TXN',
                  infoTooltip:
                      'Update item sale price automatically from transactions.',
                  value: settings.updateSalePriceFromTxn,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(updateSalePriceFromTxn: value)),
                ),
              ],
            ),
          ],
        ),
        MobileListSection(
          title: 'Fields',
          children: [
            _SettingsCard(
              children: [
                ItemSettingsMobileNavTile(
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
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileNavTile(
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
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileCheckboxTile(
                  label: 'Description',
                  infoTooltip: 'Show description field when creating items.',
                  value: settings.descriptionEnabled,
                  onChanged: (value) => _update(
                    (s) => s.copyWith(descriptionEnabled: value ?? false),
                  ),
                  child: ItemSettingsMobileDescriptionFooter(
                    descriptionText: settings.descriptionText,
                    onEdit: () => _editDescription(settings),
                  ),
                ),
              ],
            ),
          ],
        ),
        MobileListSection(
          title: 'GST',
          children: [
            _SettingsCard(
              children: [
                ItemSettingsMobileSwitchTile(
                  label: 'HSN/SAC Code',
                  infoTooltip: 'Capture HSN or SAC codes on items.',
                  value: settings.hsnSacCode,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(hsnSacCode: value)),
                ),
                const ItemSettingsMobileDivider(),
                ItemSettingsMobileSwitchTile(
                  label: 'Additional CESS',
                  infoTooltip: 'Track additional cess on applicable items.',
                  value: settings.additionalCess,
                  onChanged: (value) =>
                      _update((s) => s.copyWith(additionalCess: value)),
                ),
              ],
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return MobileCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}
