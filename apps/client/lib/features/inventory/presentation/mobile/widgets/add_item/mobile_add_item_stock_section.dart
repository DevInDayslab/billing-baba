import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/godowns/mobile_add_godown_sheet.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

  static final _decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  String get _asOfDateLabel {
    final date = asOfDate;
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String? get _selectedGodownName {
    return godowns
        .where((godown) => godown.id == selectedGodownId)
        .map((godown) => godown.name)
        .firstOrNull;
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
                          ? const Icon(Icons.check, color: AppColors.primary)
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
                  inputFormatters: [_decimalFormatter],
                  onChanged: (v) =>
                      onOpeningQtyChanged(double.tryParse(v) ?? 0),
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                MobileAddItemField(
                  controller: openingPriceController,
                  label: 'At Price',
                  hint: 'At Price',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [_decimalFormatter],
                  onChanged: (v) =>
                      onOpeningPriceChanged(double.tryParse(v) ?? 0),
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                InkWell(
                  onTap: () => _openGodownPicker(context),
                  borderRadius:
                      BorderRadius.circular(MobileAddItemTheme.fieldRadius),
                  child: InputDecorator(
                    decoration: MobileAddItemTheme.fieldDecoration(
                      label: 'Godown',
                      hint: 'Godown',
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedGodownName ?? 'Select godown',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedGodownName == null
                                  ? AppColors.textSecondary
                                      .withValues(alpha: 0.7)
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                SaleSingleDatePickerAnchor(
                  key: asOfDatePickerKey,
                  selectedDate: asOfDate,
                  onDateSelected: onAsOfDateSelected,
                  child: InkWell(
                    onTap: () => asOfDatePickerKey.currentState?.showPicker(),
                    child: InputDecorator(
                      decoration: MobileAddItemTheme.fieldDecoration(
                        label: 'As Of Date',
                        hint: 'As Of Date',
                      ),
                      child: Text(
                        _asOfDateLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: _asOfDateLabel.isEmpty
                              ? AppColors.textSecondary.withValues(alpha: 0.7)
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
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
                  inputFormatters: [_decimalFormatter],
                  onChanged: (v) =>
                      onMinStockChanged(double.tryParse(v) ?? 0),
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
