import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/models/item_settings_info_catalog.dart';
import 'package:billing_baba/features/inventory/models/item_vyapar_settings.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/item_settings/item_settings_custom_fields_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/item_settings/item_settings_desktop_dialogs.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/item_settings/item_settings_vyapar_form_widgets.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/general_settings_form_widgets.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemSettingsVyaparPanel extends ConsumerWidget {
  const ItemSettingsVyaparPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(itemSettingsProvider);
    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load item settings: $e')),
      data: (settings) {
        Future<void> patch(ItemSettingsUpdater update) {
          return ref.read(itemSettingsProvider.notifier).patch(update);
        }

        final units = ref.watch(inventoryUnitsProvider).value ?? const <InventoryUnit>[];

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final three = constraints.maxWidth >= 1100;
                final c1 = _ItemSettingsColumn(
                  settings: settings,
                  onPatch: patch,
                  units: units,
                );
                final c2 = _AdditionalItemFieldsColumn(
                  settings: settings,
                  onPatch: patch,
                );
                final c3 = _CustomFieldsColumn(settings: settings, onPatch: patch);
                if (three) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: c1),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: c2),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: c3),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [c1, const SizedBox(height: AppSpacing.md), c2, const SizedBox(height: AppSpacing.md), c3],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ItemSettingsColumn extends StatelessWidget {
  const _ItemSettingsColumn({
    required this.settings,
    required this.onPatch,
    required this.units,
  });

  final ItemSettings settings;
  final Future<void> Function(ItemSettingsUpdater) onPatch;
  final List<InventoryUnit> units;

  @override
  Widget build(BuildContext context) {
    final v = settings.vyapar;
    return GeneralSettingsSectionCard(
      title: 'Item Settings',
      children: [
        ItemSettingsVyaparCheckboxRow(
          label: 'Enable Item',
          value: settings.enableItem,
          infoKey: ItemSettingsInfoKey.enableItem,
          onChanged: (val) => onPatch((s) => s.copyWith(enableItem: val ?? false)),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: ItemSettingsRowMetrics.checkboxLeadingWidth,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'What do you sell?',
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodyMediumSize,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SettingsInfoHoverIcon(
                heading: 'What do you sell?',
                sections: ItemSettingsInfoCatalog.sectionsFor(
                  ItemSettingsInfoKey.whatDoYouSell,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: ItemSettingsRowMetrics.checkboxLeadingWidth,
            bottom: AppSpacing.sm,
          ),
          child: DropdownButtonFormField<String>(
            value: settings.itemTypeScope.vyaparLabel,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: AppRadius.smBorder),
            ),
            items: [
              for (final scope in ItemTypeScope.values)
                DropdownMenuItem(
                  value: scope.vyaparLabel,
                  child: Text(scope.vyaparLabel),
                ),
            ],
            onChanged: settings.enableItem
                ? (label) {
                    if (label == null) return;
                    onPatch(
                      (s) => s.copyWith(
                        itemTypeScope: ItemTypeScopeX.fromVyaparLabel(label),
                      ),
                    );
                  }
                : null,
          ),
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Barcode Scan',
          value: settings.barcodeScanningEnabled,
          infoKey: ItemSettingsInfoKey.barcodeScan,
          onChanged: settings.enableItem
              ? (val) => onPatch(
                  (s) => s.copyWith(barcodeScanningEnabled: val ?? false),
                )
              : null,
        ),
        if (settings.barcodeScanningEnabled)
          ItemSettingsVyaparCheckboxRow(
            label: 'Direct Barcode Scan',
            value: v.directBarcodeScan,
            infoKey: ItemSettingsInfoKey.directBarcodeScan,
            onChanged: settings.enableItem
                ? (val) => onPatch(
                    (s) => s.copyWithVyapar(
                      (vy) => vy.copyWith(directBarcodeScan: val ?? false),
                    ).copyWith(mobilePosDefaultBilling: val ?? false),
                  )
                : null,
          ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Stock Maintenance',
          value: settings.stockMaintenance,
          infoKey: ItemSettingsInfoKey.stockMaintenance,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(stockMaintenance: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Manufacturing',
          value: settings.manufacturing,
          infoKey: ItemSettingsInfoKey.manufacturing,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(manufacturing: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Show Low Stock Dialog',
          value: v.showLowStockDialog,
          infoKey: ItemSettingsInfoKey.showLowStockDialog,
          onChanged: settings.enableItem
              ? (val) => onPatch(
                  (s) => s.copyWithVyapar(
                    (vy) => vy.copyWith(showLowStockDialog: val ?? false),
                  ),
                )
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Items Unit',
          value: settings.itemUnits,
          infoKey: ItemSettingsInfoKey.itemsUnit,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(itemUnits: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Default Unit',
          value: settings.defaultUnitEnabled,
          infoKey: ItemSettingsInfoKey.defaultUnit,
          trailing: settings.defaultUnitEnabled
              ? ItemSettingsVyaparLink(
                  label: 'Add Default Unit',
                  onTap: () => _pickDefaultUnits(context, units, settings, onPatch),
                )
              : null,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(defaultUnitEnabled: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Item Category',
          value: settings.itemCategory,
          infoKey: ItemSettingsInfoKey.itemCategory,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(itemCategory: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Party Wise Item Rate',
          value: settings.partyWiseItemRate,
          infoKey: ItemSettingsInfoKey.partyWiseItemRate,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(partyWiseItemRate: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: v.descriptionFieldLabel,
          value: settings.descriptionEnabled,
          infoKey: ItemSettingsInfoKey.description,
          trailing: settings.descriptionEnabled
              ? ItemSettingsVyaparLink(
                  label: 'Change Text',
                  onTap: () async {
                    final label = await showEditItemFieldLabelDialog(
                      context: context,
                      title: 'Edit Text',
                      initialValue: v.descriptionFieldLabel,
                    );
                    if (label == null || label.isEmpty) return;
                    await onPatch(
                      (s) => s.copyWithVyapar(
                        (vy) => vy.copyWith(descriptionFieldLabel: label),
                      ),
                    );
                  },
                )
              : null,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(descriptionEnabled: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Item wise Tax',
          value: settings.itemWiseTax,
          infoKey: ItemSettingsInfoKey.itemWiseTax,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(itemWiseTax: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Item wise Discount',
          value: settings.itemWiseDiscount,
          infoKey: ItemSettingsInfoKey.itemWiseDiscount,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(itemWiseDiscount: val ?? false))
              : null,
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Update Sale Price from Transaction',
          value: settings.updateSalePriceFromTxn,
          infoKey: ItemSettingsInfoKey.updateSalePriceFromTxn,
          onChanged: settings.enableItem
              ? (val) =>
                  onPatch((s) => s.copyWith(updateSalePriceFromTxn: val ?? false))
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: ItemSettingsRowMetrics.checkboxLeadingWidth),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodyMediumSize,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          '(upto Decimal Places)',
                          style: AppTypography.inter(
                            fontSize: AppTypography.captionSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        ItemSettingsQuantityStepper(
                          value: settings.quantityDecimalPlaces,
                          onChanged: settings.enableItem
                              ? (n) => onPatch(
                                  (s) => s.copyWith(quantityDecimalPlaces: n),
                                )
                              : (_) {},
                        ),
                        Text(
                          'e.g. 0.00',
                          style: AppTypography.inter(
                            fontSize: AppTypography.captionSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SettingsInfoHoverIcon(
                heading: 'Quantity (upto Decimal Places)',
                sections: ItemSettingsInfoCatalog.sectionsFor(
                  ItemSettingsInfoKey.quantityDecimalPlaces,
                ),
              ),
            ],
          ),
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Wholesale Price',
          value: settings.wholesalePrice,
          infoKey: ItemSettingsInfoKey.wholesalePrice,
          onChanged: settings.enableItem
              ? (val) => onPatch((s) => s.copyWith(wholesalePrice: val ?? false))
              : null,
        ),
      ],
    );
  }

  Future<void> _pickDefaultUnits(
    BuildContext context,
    List<InventoryUnit> units,
    ItemSettings settings,
    Future<void> Function(ItemSettingsUpdater) onPatch,
  ) async {
    if (units.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add units before selecting defaults')),
      );
      return;
    }
    final result = await showSelectDefaultUnitsDialog(
      context: context,
      units: units,
      baseUnitId: settings.defaultUnitId,
      secondaryUnitId: settings.vyapar.defaultSecondaryUnitId,
    );
    if (result == null) return;
    await onPatch(
      (s) => s
          .copyWith(
            defaultUnitId: result.baseUnitId,
            defaultUnitEnabled: true,
            clearDefaultUnitId: result.baseUnitId == null,
          )
          .copyWithVyapar(
            (vy) => vy.copyWith(
              defaultSecondaryUnitId: result.secondaryUnitId,
              clearDefaultSecondaryUnitId: result.secondaryUnitId == null,
            ),
          ),
    );
  }
}

class _AdditionalItemFieldsColumn extends StatelessWidget {
  const _AdditionalItemFieldsColumn({
    required this.settings,
    required this.onPatch,
  });

  final ItemSettings settings;
  final Future<void> Function(ItemSettingsUpdater) onPatch;

  @override
  Widget build(BuildContext context) {
    final v = settings.vyapar;
    return GeneralSettingsSectionCard(
      title: 'Additional Item Fields',
      children: [
        Text(
          'MRP/Price',
          style: AppTypography.inter(
            fontSize: AppTypography.bodySmallSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _LabeledFieldRow(
          enabled: v.mrpEnabled,
          label: v.mrpLabel,
          hint: v.mrpLabel,
          infoKey: ItemSettingsInfoKey.mrp,
          onEnabled: (e) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(mrpEnabled: e)),
          ),
          onLabel: (t) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(mrpLabel: t)),
          ),
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Calculate Sale Price From MRP & Disc.',
          value: v.calculateSalePriceFromMrpDisc,
          infoKey: ItemSettingsInfoKey.calculateSalePriceFromMrpDisc,
          onChanged: (val) => onPatch(
            (s) => s.copyWithVyapar(
              (vy) => vy.copyWith(calculateSalePriceFromMrpDisc: val ?? false),
            ),
          ),
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Use MRP for Batch Tracking',
          value: v.useMrpForBatchTracking,
          onChanged: (val) => onPatch(
            (s) => s.copyWithVyapar(
              (vy) => vy.copyWith(useMrpForBatchTracking: val ?? false),
            ),
          ),
        ),
        ItemSettingsVyaparCheckboxRow(
          label: 'Calculate Tax based on MRP',
          value: settings.calculateTaxBasedOnMrp,
          infoKey: ItemSettingsInfoKey.calculateTaxBasedOnMrp,
          onChanged: (val) => onPatch(
            (s) => s.copyWith(calculateTaxBasedOnMrp: val ?? false),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text(
              'Serial No. Tracking',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            SettingsInfoHoverIcon(
              heading: 'Serial No. Tracking',
              sections: ItemSettingsInfoCatalog.sectionsFor(
                ItemSettingsInfoKey.serialTracking,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _LabeledFieldRow(
          enabled: v.serialTrackingEnabled,
          label: 'Serial No./ IMEI No. etc',
          hint: v.serialFieldLabel,
          onEnabled: (e) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(serialTrackingEnabled: e)),
          ),
          onLabel: (t) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(serialFieldLabel: t)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text(
              'Batch Tracking',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            SettingsInfoHoverIcon(
              heading: 'Batch Tracking',
              sections: ItemSettingsInfoCatalog.sectionsFor(
                ItemSettingsInfoKey.batchTracking,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _BatchFieldRow(
          settings: settings,
          onPatch: onPatch,
          enabled: v.batchNoEnabled,
          label: v.batchNoLabel,
          hint: 'Batch No.',
          onToggle: (e) => onPatch(
            (s) => s.copyWithVyapar(
              (vy) => vy.copyWith(batchNoEnabled: e, batchTrackingEnabled: e),
            ),
          ),
          onLabel: (t) =>
              onPatch((s) => s.copyWithVyapar((vy) => vy.copyWith(batchNoLabel: t))),
        ),
        _BatchDateFieldRow(
          settings: settings,
          onPatch: onPatch,
          enabled: v.batchExpDateEnabled,
          label: v.batchExpDateLabel,
          formatId: v.batchExpDateFormatId,
          onToggle: (e) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchExpDateEnabled: e)),
          ),
          onLabel: (t) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchExpDateLabel: t)),
          ),
          onFormat: (id) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchExpDateFormatId: id)),
          ),
        ),
        _BatchDateFieldRow(
          settings: settings,
          onPatch: onPatch,
          enabled: v.batchMfgDateEnabled,
          label: v.batchMfgDateLabel,
          formatId: v.batchMfgDateFormatId,
          onToggle: (e) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchMfgDateEnabled: e)),
          ),
          onLabel: (t) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchMfgDateLabel: t)),
          ),
          onFormat: (id) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchMfgDateFormatId: id)),
          ),
        ),
        _BatchFieldRow(
          settings: settings,
          onPatch: onPatch,
          enabled: v.batchModelNoEnabled,
          label: v.batchModelNoLabel,
          hint: 'Model No.',
          onToggle: (e) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchModelNoEnabled: e)),
          ),
          onLabel: (t) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchModelNoLabel: t)),
          ),
        ),
        _BatchFieldRow(
          settings: settings,
          onPatch: onPatch,
          enabled: v.batchSizeEnabled,
          label: v.batchSizeLabel,
          hint: 'Size',
          onToggle: (e) => onPatch(
            (s) => s.copyWithVyapar((vy) => vy.copyWith(batchSizeEnabled: e)),
          ),
          onLabel: (t) =>
              onPatch((s) => s.copyWithVyapar((vy) => vy.copyWith(batchSizeLabel: t))),
        ),
      ],
    );
  }
}

class _CustomFieldsColumn extends StatelessWidget {
  const _CustomFieldsColumn({
    required this.settings,
    required this.onPatch,
  });

  final ItemSettings settings;
  final Future<void> Function(ItemSettingsUpdater) onPatch;

  @override
  Widget build(BuildContext context) {
    return GeneralSettingsSectionCard(
      title: 'Item Custom Fields',
      children: [
        OutlinedButton(
          onPressed: () async {
            final saved = await showItemCustomFieldsDialog(
              context: context,
              initial: settings.vyapar.customFields,
            );
            if (saved == null) return;
            await onPatch(
              (s) => s.copyWithVyapar((vy) => vy.copyWith(customFields: saved)),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
          child: const Text('Add Custom Fields >'),
        ),
      ],
    );
  }
}

class _LabeledFieldRow extends StatelessWidget {
  const _LabeledFieldRow({
    required this.enabled,
    required this.label,
    required this.hint,
    required this.onEnabled,
    required this.onLabel,
    this.infoKey,
  });

  final bool enabled;
  final String label;
  final String hint;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<String> onLabel;
  final ItemSettingsInfoKey? infoKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: enabled,
            onChanged: (v) => onEnabled(v ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          if (infoKey != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SettingsInfoHoverIcon(
                heading: label,
                sections: ItemSettingsInfoCatalog.sectionsFor(infoKey!),
              ),
            ),
          Expanded(
            child: TextFormField(
              initialValue: hint,
              enabled: enabled,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(borderRadius: AppRadius.smBorder),
              ),
              onChanged: onLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchFieldRow extends StatelessWidget {
  const _BatchFieldRow({
    required this.settings,
    required this.onPatch,
    required this.enabled,
    required this.label,
    required this.hint,
    required this.onToggle,
    required this.onLabel,
  });

  final ItemSettings settings;
  final Future<void> Function(ItemSettingsUpdater) onPatch;
  final bool enabled;
  final String label;
  final String hint;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: enabled,
            onChanged: (v) => onToggle(v ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: AppTypography.inter(fontSize: AppTypography.bodySmallSize),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  initialValue: hint,
                  enabled: enabled,
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: AppRadius.smBorder),
                  ),
                  onChanged: onLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchDateFieldRow extends StatelessWidget {
  const _BatchDateFieldRow({
    required this.settings,
    required this.onPatch,
    required this.enabled,
    required this.label,
    required this.formatId,
    required this.onToggle,
    required this.onLabel,
    required this.onFormat,
  });

  final ItemSettings settings;
  final Future<void> Function(ItemSettingsUpdater) onPatch;
  final bool enabled;
  final String label;
  final String formatId;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onLabel;
  final ValueChanged<String> onFormat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: enabled,
            onChanged: (v) => onToggle(v ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: AppTypography.inter(fontSize: AppTypography.bodySmallSize),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: formatId,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.smBorder,
                          ),
                        ),
                        items: [
                          for (final o in ItemFieldCatalog.dateFormatOptions)
                            DropdownMenuItem(
                              value: o.id,
                              child: Text(
                                o.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: enabled
                            ? (id) {
                                if (id != null) onFormat(id);
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        initialValue: label,
                        enabled: enabled,
                        decoration: InputDecoration(
                          hintText: label,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.smBorder,
                          ),
                        ),
                        onChanged: onLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
