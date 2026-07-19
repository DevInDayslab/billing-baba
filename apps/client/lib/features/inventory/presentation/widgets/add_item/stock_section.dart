import 'package:billing_baba/features/inventory/presentation/widgets/rack_photo_uploader.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
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

  @override
  Widget build(BuildContext context) {
    return FormGrid(
      cells: [
        FormGridCell(
          span: 4,
          child: AppFormField(
            label: 'Opening Stock',
            child: TextField(
              controller: openingQtyController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'Opening Stock'),
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
          child: AppFormField(
            label: 'At Price',
            child: TextField(
              controller: openingPriceController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'At Price'),
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
          child: AppFormField(
            label: 'As of Date',
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
        FormGridCell(
          span: 4,
          child: AppFormField(
            label: 'Minimum Stock',
            child: TextField(
              controller: minStockController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'Minimum Stock'),
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
          child: AppFormField(
            label: 'Rack / Shelf',
            child: TextField(
              controller: locationController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: 'Ex: Rack A-12'),
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
