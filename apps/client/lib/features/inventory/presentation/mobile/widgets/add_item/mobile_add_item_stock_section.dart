import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
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

  static final _decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  String get _asOfDateLabel {
    final date = asOfDate;
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
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
                  onChanged: (v) => onMinStockChanged(double.tryParse(v) ?? 0),
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
