import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/godowns/mobile_add_godown_sheet.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/item_qty_unit_suffix.dart';
import 'package:billing_baba/features/inventory/utils/item_quantity_input.dart';
import 'package:billing_baba/features/inventory/utils/item_unit_qty_conversion.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vyapar-style Stock tab for mobile Add Item.
class MobileAddItemStockSection extends StatelessWidget {
  const MobileAddItemStockSection({
    required this.openingQtyController,
    required this.openingPriceController,
    required this.minStockController,
    required this.locationController,
    required this.asOfDate,
    required this.onOpeningQtyChanged,
    required this.onOpeningPriceChanged,
    required this.onMinStockChanged,
    required this.onLocationChanged,
    required this.onAsOfDateSelected,
    required this.asOfDatePickerKey,
    required this.godowns,
    required this.selectedGodownId,
    required this.onGodownSelected,
    required this.stockQtyUnitOptions,
    required this.baseUnitId,
    required this.secondaryUnitId,
    required this.baseToSecondaryRate,
    required this.openingQtyUnitId,
    required this.minStockUnitId,
    required this.onOpeningQtyUnitChanged,
    required this.onMinStockUnitChanged,
    required this.quantityDecimalPlaces,
    super.key,
  });

  final TextEditingController openingQtyController;
  final TextEditingController openingPriceController;
  final TextEditingController minStockController;
  final TextEditingController locationController;
  final DateTime? asOfDate;
  final ValueChanged<double> onOpeningQtyChanged;
  final ValueChanged<double> onOpeningPriceChanged;
  final ValueChanged<double> onMinStockChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<DateTime> onAsOfDateSelected;
  final GlobalKey<SaleSingleDatePickerAnchorState> asOfDatePickerKey;
  final List<GodownModel> godowns;
  final String? selectedGodownId;
  final ValueChanged<String?> onGodownSelected;
  final List<InventoryUnit> stockQtyUnitOptions;
  final String? baseUnitId;
  final String? secondaryUnitId;
  final double? baseToSecondaryRate;
  final String? openingQtyUnitId;
  final String? minStockUnitId;
  final ValueChanged<String> onOpeningQtyUnitChanged;
  final ValueChanged<String> onMinStockUnitChanged;
  final int quantityDecimalPlaces;

  List<TextInputFormatter> get _qtyFormatters =>
      ItemQuantityInput.formatters(quantityDecimalPlaces);

  static final _priceDecimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  String? get _selectedGodownName {
    return godowns
        .where((godown) => godown.id == selectedGodownId)
        .map((godown) => godown.name)
        .firstOrNull;
  }

  String _effectiveUnitId(String? selectedUnitId) {
    return selectedUnitId ?? baseUnitId ?? '';
  }

  void _onQtyUnitChanged({
    required TextEditingController controller,
    required String? currentUnitId,
    required String newUnitId,
    required ValueChanged<String> onUnitChanged,
    required ValueChanged<double> onBaseQtyChanged,
  }) {
    if (baseUnitId == null) return;
    final fromUnitId = _effectiveUnitId(currentUnitId);
    final displayQty = double.tryParse(controller.text.trim()) ?? 0;
    final baseQty = qtyInBaseUnit(
      qty: displayQty,
      qtyUnitId: fromUnitId,
      baseUnitId: baseUnitId!,
      secondaryUnitId: secondaryUnitId,
      baseToSecondaryRate: baseToSecondaryRate,
    );
    onUnitChanged(newUnitId);
    final newDisplay = qtyFromBaseUnit(
      baseQty: baseQty,
      displayUnitId: newUnitId,
      baseUnitId: baseUnitId!,
      secondaryUnitId: secondaryUnitId,
      baseToSecondaryRate: baseToSecondaryRate,
    );
    controller.text = formatItemQtyFieldValue(
      newDisplay,
      decimalPlaces: quantityDecimalPlaces,
    );
    onBaseQtyChanged(baseQty);
  }

  void _onDisplayQtyChanged({
    required String text,
    required String? displayUnitId,
    required ValueChanged<double> onBaseQtyChanged,
  }) {
    final parsed = double.tryParse(text) ?? 0;
    final displayQty = ItemQuantityInput.roundToPlaces(
      parsed,
      quantityDecimalPlaces,
    );
    if (baseUnitId == null) {
      onBaseQtyChanged(displayQty);
      return;
    }
    onBaseQtyChanged(
      qtyInBaseUnit(
        qty: displayQty,
        qtyUnitId: _effectiveUnitId(displayUnitId),
        baseUnitId: baseUnitId!,
        secondaryUnitId: secondaryUnitId,
        baseToSecondaryRate: baseToSecondaryRate,
      ),
    );
  }

  Future<void> _openGodownPicker(BuildContext context) async {
    if (godowns.isEmpty) {
      final created = await showMobileAddGodownSheet(context);
      if (created != null) onGodownSelected(created.id);
      return;
    }

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Opening Godown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        final created = await showMobileAddGodownSheet(context);
                        if (created != null) onGodownSelected(created.id);
                      },
                      child: const Text('Add New'),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: godowns.length,
                  itemBuilder: (context, index) {
                    final godown = godowns[index];
                    final selected = godown.id == selectedGodownId;
                    return ListTile(
                      title: Text(godown.name),
                      subtitle: godown.isDefault
                          ? const Text('Default godown')
                          : null,
                      trailing: selected
                          ? const Icon(
                              LucideIcons.check,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () => Navigator.of(sheetContext).pop(godown.id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) onGodownSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileAddItemTheme.sectionBandDivider(),
          MobileAddItemTheme.sectionHeader('Opening Stock'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MobileAddItemTheme.horizontalPadding,
            ),
            child: Column(
              children: [
                MobileAddItemField(
                  controller: openingQtyController,
                  label: 'Opening Stock',
                  hint: 'Opening Stock',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _qtyFormatters,
                  suffix: ItemQtyUnitSuffix(
                    unitOptions: stockQtyUnitOptions,
                    selectedUnitId: openingQtyUnitId,
                    fallbackBaseUnitId: baseUnitId,
                    onUnitSelected: (unitId) => _onQtyUnitChanged(
                      controller: openingQtyController,
                      currentUnitId: openingQtyUnitId,
                      newUnitId: unitId,
                      onUnitChanged: onOpeningQtyUnitChanged,
                      onBaseQtyChanged: onOpeningQtyChanged,
                    ),
                  ),
                  onChanged: (v) => _onDisplayQtyChanged(
                    text: v,
                    displayUnitId: openingQtyUnitId,
                    onBaseQtyChanged: onOpeningQtyChanged,
                  ),
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                MobileAddItemField(
                  controller: openingPriceController,
                  label: 'At Price',
                  hint: 'At Price',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [_priceDecimalFormatter],
                  onChanged: (v) =>
                      onOpeningPriceChanged(double.tryParse(v) ?? 0),
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                InkWell(
                  onTap: () => _openGodownPicker(context),
                  borderRadius: BorderRadius.circular(
                    MobileAddItemTheme.fieldRadius,
                  ),
                  child: InputDecorator(
                    decoration: MobileAddItemTheme.fieldDecoration(
                      label: 'Godown',
                      hint: 'Godown',
                    ),
                    child: Text(
                      _selectedGodownName ?? 'Select godown',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedGodownName == null
                            ? AppColors.textSecondary.withValues(alpha: 0.7)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                SaleEditableSingleDateField(
                  datePickerKey: asOfDatePickerKey,
                  selectedDate: asOfDate,
                  onDateSelected: onAsOfDateSelected,
                  hintText: 'DD/MM/YYYY',
                  decoration: MobileAddItemTheme.fieldDecoration(
                    label: 'As Of Date',
                    hint: 'DD/MM/YYYY',
                  ),
                ),
              ],
            ),
          ),
          MobileAddItemTheme.sectionBandDivider(),
          MobileAddItemTheme.sectionHeader('Stock Alert'),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MobileAddItemTheme.horizontalPadding,
              0,
              MobileAddItemTheme.horizontalPadding,
              16,
            ),
            child: Column(
              children: [
                MobileAddItemField(
                  controller: minStockController,
                  label: 'Minimum Stock',
                  hint: 'Minimum Stock',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _qtyFormatters,
                  suffix: ItemQtyUnitSuffix(
                    unitOptions: stockQtyUnitOptions,
                    selectedUnitId: minStockUnitId,
                    fallbackBaseUnitId: baseUnitId,
                    onUnitSelected: (unitId) => _onQtyUnitChanged(
                      controller: minStockController,
                      currentUnitId: minStockUnitId,
                      newUnitId: unitId,
                      onUnitChanged: onMinStockUnitChanged,
                      onBaseQtyChanged: onMinStockChanged,
                    ),
                  ),
                  onChanged: (v) => _onDisplayQtyChanged(
                    text: v,
                    displayUnitId: minStockUnitId,
                    onBaseQtyChanged: onMinStockChanged,
                  ),
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                MobileAddItemField(
                  controller: locationController,
                  label: 'Location / Rack',
                  hint: 'Location / Rack',
                  onChanged: onLocationChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
