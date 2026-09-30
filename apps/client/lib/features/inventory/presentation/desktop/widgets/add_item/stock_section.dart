import 'package:billing_baba/features/inventory/presentation/desktop/widgets/rack_photo_uploader.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Stock tab — Vyapar-aligned flat grid (Opening Stock through Rack Image).
class StockSection extends StatelessWidget {
  const StockSection({
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
    this.rackLocationId,
    this.rackPhotoUrl,
    this.onRackPhotoChanged,
    this.decimalInputFormatter,
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
  final String? rackLocationId;
  final String? rackPhotoUrl;
  final ValueChanged<String?>? onRackPhotoChanged;
  final TextInputFormatter? decimalInputFormatter;

  static final _defaultDecimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  List<TextInputFormatter> get _formatters => [
    decimalInputFormatter ?? _defaultDecimalFormatter,
  ];

  Widget _floatingField({required String label, required Widget child}) {
    return AppFormField(
      label: label,
      floatingLabel: true,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormGrid(
      rowGap: 12,
      cells: [
        FormGridCell(
          span: 4,
          child: _floatingField(
            label: 'Opening Stock',
            child: TextField(
              controller: openingQtyController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(labelText: 'Opening Stock'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: _formatters,
              onChanged: (v) => onOpeningQtyChanged(double.tryParse(v) ?? 0),
            ),
          ),
        ),
        FormGridCell(
          span: 4,
          child: _floatingField(
            label: 'At Price',
            child: TextField(
              controller: openingPriceController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(labelText: 'At Price'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: _formatters,
              onChanged: (v) => onOpeningPriceChanged(double.tryParse(v) ?? 0),
            ),
          ),
        ),
        FormGridCell(
          span: 4,
          child: _floatingField(
            label: 'As of Date',
            child: InputDecorator(
              decoration: buildFormControlDecoration(labelText: 'As of Date'),
              child: SaleSingleDatePickerAnchor(
                key: asOfDatePickerKey,
                selectedDate: asOfDate,
                onDateSelected: onAsOfDateSelected,
                child: SaleFieldTrigger(
                  onTap: () => asOfDatePickerKey.currentState?.toggle(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatSaleSingleDate(asOfDate),
                          style: saleFieldTextStyle,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        FormGridCell(
          span: 4,
          child: _floatingField(
            label: 'Minimum Stock',
            child: TextField(
              controller: minStockController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(labelText: 'Minimum Stock'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: _formatters,
              onChanged: (v) => onMinStockChanged(double.tryParse(v) ?? 0),
            ),
          ),
        ),
        FormGridCell(
          span: 4,
          child: _floatingField(
            label: 'Rack / Shelf',
            child: TextField(
              controller: locationController,
              style: saleFieldTextStyle,
              decoration: buildFormControlDecoration(labelText: 'Rack / Shelf'),
              onChanged: onLocationChanged,
            ),
          ),
        ),
        FormGridCell(
          span: 12,
          child: RackPhotoUploader(
            locationId: rackLocationId,
            photoUrl: rackPhotoUrl,
            onPhotoChanged: onRackPhotoChanged,
          ),
        ),
      ],
    );
  }
}
