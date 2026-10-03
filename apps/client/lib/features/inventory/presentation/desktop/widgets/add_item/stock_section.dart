import 'package:billing_baba/features/inventory/models/item_location_history_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/rack_shelf_section.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/item_qty_unit_suffix.dart';
import 'package:billing_baba/features/inventory/utils/item_unit_qty_conversion.dart';
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
    required this.employeeController,
    required this.asOfDate,
    required this.onOpeningQtyChanged,
    required this.onOpeningPriceChanged,
    required this.onMinStockChanged,
    required this.onLocationChanged,
    required this.onAsOfDateSelected,
    required this.asOfDatePickerKey,
    required this.stockQtyUnitOptions,
    required this.baseUnitId,
    required this.secondaryUnitId,
    required this.baseToSecondaryRate,
    required this.openingQtyUnitId,
    required this.minStockUnitId,
    required this.onOpeningQtyUnitChanged,
    required this.onMinStockUnitChanged,
    this.rackLocationId,
    this.rackPhotoUrl,
    this.rackPhotoTakenAt,
    this.rackLastUpdatedAt,
    this.rackHistory = const [],
    this.onRackPhotoChanged,
    this.onRackHistoryRefresh,
    this.pendingRackPhotoBytes,
    this.onPendingRackPhotoChanged,
    this.pendingRackPhotoRawBytes,
    this.onPendingRackPhotoRawChanged,
    this.initialRackLocation = '',
    this.rackEmployeeError,
    this.onRackEmployeeChanged,
    this.onRackPhotoUploaded,
    this.onRackLocationSynced,
    this.decimalInputFormatter,
    super.key,
  });

  final TextEditingController openingQtyController;
  final TextEditingController openingPriceController;
  final TextEditingController minStockController;
  final TextEditingController locationController;
  final TextEditingController employeeController;
  final DateTime? asOfDate;
  final ValueChanged<double> onOpeningQtyChanged;
  final ValueChanged<double> onOpeningPriceChanged;
  final ValueChanged<double> onMinStockChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<DateTime> onAsOfDateSelected;
  final GlobalKey<SaleSingleDatePickerAnchorState> asOfDatePickerKey;
  final List<InventoryUnit> stockQtyUnitOptions;
  final String? baseUnitId;
  final String? secondaryUnitId;
  final double? baseToSecondaryRate;
  final String? openingQtyUnitId;
  final String? minStockUnitId;
  final ValueChanged<String> onOpeningQtyUnitChanged;
  final ValueChanged<String> onMinStockUnitChanged;
  final String? rackLocationId;
  final String? rackPhotoUrl;
  final DateTime? rackPhotoTakenAt;
  final DateTime? rackLastUpdatedAt;
  final List<ItemLocationHistoryModel> rackHistory;
  final void Function(String? url, DateTime? takenAt)? onRackPhotoChanged;
  final Future<void> Function()? onRackHistoryRefresh;
  final Uint8List? pendingRackPhotoBytes;
  final ValueChanged<Uint8List?>? onPendingRackPhotoChanged;
  final Uint8List? pendingRackPhotoRawBytes;
  final ValueChanged<Uint8List?>? onPendingRackPhotoRawChanged;
  final String initialRackLocation;
  final String? rackEmployeeError;
  final VoidCallback? onRackEmployeeChanged;
  final VoidCallback? onRackPhotoUploaded;
  final ValueChanged<String>? onRackLocationSynced;
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
    controller.text = formatItemQtyFieldValue(newDisplay);
    onBaseQtyChanged(baseQty);
  }

  void _onDisplayQtyChanged({
    required String text,
    required String? displayUnitId,
    required ValueChanged<double> onBaseQtyChanged,
  }) {
    if (baseUnitId == null) {
      onBaseQtyChanged(double.tryParse(text) ?? 0);
      return;
    }
    final displayQty = double.tryParse(text) ?? 0;
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
              decoration: buildFormControlDecoration(
                labelText: 'Opening Stock',
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
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: _formatters,
              onChanged: (v) => _onDisplayQtyChanged(
                text: v,
                displayUnitId: openingQtyUnitId,
                onBaseQtyChanged: onOpeningQtyChanged,
              ),
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
            child: SaleEditableSingleDateField(
              datePickerKey: asOfDatePickerKey,
              selectedDate: asOfDate,
              onDateSelected: onAsOfDateSelected,
              decoration: buildFormControlDecoration(labelText: 'As of Date'),
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
              decoration: buildFormControlDecoration(
                labelText: 'Minimum Stock',
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
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: _formatters,
              onChanged: (v) => _onDisplayQtyChanged(
                text: v,
                displayUnitId: minStockUnitId,
                onBaseQtyChanged: onMinStockChanged,
              ),
            ),
          ),
        ),
        FormGridCell(
          span: 12,
          child: RackShelfSection(
            locationController: locationController,
            employeeController: employeeController,
            onLocationChanged: onLocationChanged,
            locationId: rackLocationId,
            photoUrl: rackPhotoUrl,
            photoTakenAt: rackPhotoTakenAt,
            lastUpdatedAt: rackLastUpdatedAt,
            history: rackHistory,
            onPhotoChanged: onRackPhotoChanged,
            onHistoryRefresh: onRackHistoryRefresh,
            pendingPhotoBytes: pendingRackPhotoBytes,
            onPendingPhotoChanged: onPendingRackPhotoChanged,
            pendingRawPhotoBytes: pendingRackPhotoRawBytes,
            onPendingRawPhotoChanged: onPendingRackPhotoRawChanged,
            initialRackLocation: initialRackLocation,
            employeeError: rackEmployeeError,
            onEmployeeChanged: onRackEmployeeChanged,
            onRackPhotoUploaded: onRackPhotoUploaded,
            onRackLocationSynced: onRackLocationSynced,
          ),
        ),
      ],
    );
  }
}
