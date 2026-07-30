import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pricing tab — flat grid matching the general information field style.
class PricingSection extends StatelessWidget {
  const PricingSection({
    required this.isService,
    required this.mrpController,
    required this.onMrpChanged,
    required this.salePriceController,
    required this.salePriceTaxMode,
    required this.onSalePriceChanged,
    required this.onSalePriceTaxModeChanged,
    required this.wholesalePriceController,
    required this.wholesalePriceTaxMode,
    required this.onWholesalePriceChanged,
    required this.onWholesalePriceTaxModeChanged,
    required this.minWholesaleQtyController,
    required this.onMinWholesaleQtyChanged,
    required this.purchasePriceController,
    required this.purchasePriceTaxMode,
    required this.onPurchasePriceChanged,
    required this.onPurchasePriceTaxModeChanged,
    required this.taxRate,
    required this.onTaxRateChanged,
    required this.unitLabel,
    this.decimalInputFormatter,
    super.key,
  });

  final bool isService;
  final TextEditingController mrpController;
  final ValueChanged<double> onMrpChanged;
  final TextEditingController salePriceController;
  final PriceTaxMode salePriceTaxMode;
  final ValueChanged<double> onSalePriceChanged;
  final ValueChanged<PriceTaxMode> onSalePriceTaxModeChanged;
  final TextEditingController wholesalePriceController;
  final PriceTaxMode wholesalePriceTaxMode;
  final ValueChanged<double> onWholesalePriceChanged;
  final ValueChanged<PriceTaxMode> onWholesalePriceTaxModeChanged;
  final TextEditingController minWholesaleQtyController;
  final ValueChanged<double> onMinWholesaleQtyChanged;
  final TextEditingController purchasePriceController;
  final PriceTaxMode purchasePriceTaxMode;
  final ValueChanged<double> onPurchasePriceChanged;
  final ValueChanged<PriceTaxMode> onPurchasePriceTaxModeChanged;
  final String taxRate;
  final ValueChanged<String> onTaxRateChanged;
  final String unitLabel;
  final TextInputFormatter? decimalInputFormatter;

  static final _defaultDecimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  static const _taxRateOptions = [
    'None',
    'GST @ 0%',
    'GST @ 5%',
    'GST @ 12%',
    'GST @ 18%',
    'GST @ 28%',
  ];

  List<TextInputFormatter> get _formatters => [
    decimalInputFormatter ?? _defaultDecimalFormatter,
  ];

  List<String> get _taxModeOptions => [
    priceTaxModeLabel(PriceTaxMode.withoutTax),
    priceTaxModeLabel(PriceTaxMode.withTax),
  ];

  void _onTaxMode(String label, ValueChanged<PriceTaxMode> onChanged) {
    onChanged(
      label == 'With Tax' ? PriceTaxMode.withTax : PriceTaxMode.withoutTax,
    );
  }

  String get _qtyHint {
    final label = unitLabel.trim();
    if (label.isEmpty || label == 'None' || label == 'Select unit') {
      return '0 PCS';
    }
    return '0 $label';
  }

  Widget _priceField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<double> onChanged,
    String? hint,
  }) {
    return AppFormField(
      label: label,
      child: TextField(
        controller: controller,
        style: saleFieldTextStyle,
        decoration: buildFormControlDecoration(hint: hint ?? label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: _formatters,
        onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }

  Widget _taxModeField({
    required PriceTaxMode value,
    required ValueChanged<PriceTaxMode> onChanged,
  }) {
    return AppFormField(
      label: ' ',
      child: SaleGenericSelectDropdown(
        value: priceTaxModeLabel(value),
        options: _taxModeOptions,
        onSelected: (v) => _onTaxMode(v, onChanged),
      ),
    );
  }

  Widget _taxRateField() {
    return AppFormField(
      label: 'Tax Rate',
      child: SaleGenericSelectDropdown(
        value: taxRate,
        options: _taxRateOptions,
        onSelected: onTaxRateChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormGrid(
          cells: [
            FormGridCell(
              span: 3,
              child: _priceField(
                label: 'MRP',
                controller: mrpController,
                onChanged: onMrpChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: FormSpacing.row),
        FormGrid(
          cells: [
            FormGridCell(
              span: 3,
              child: _priceField(
                label: 'Selling Price',
                controller: salePriceController,
                onChanged: onSalePriceChanged,
              ),
            ),
            FormGridCell(
              span: 3,
              child: _taxModeField(
                value: salePriceTaxMode,
                onChanged: onSalePriceTaxModeChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: FormSpacing.row),
        FormGrid(
          cells: [
            FormGridCell(
              span: 3,
              child: _priceField(
                label: 'Wholesale Price',
                controller: wholesalePriceController,
                onChanged: onWholesalePriceChanged,
              ),
            ),
            FormGridCell(
              span: 3,
              child: _taxModeField(
                value: wholesalePriceTaxMode,
                onChanged: onWholesalePriceTaxModeChanged,
              ),
            ),
            FormGridCell(
              span: 3,
              child: AppFormField(
                label: 'Minimum Wholesale Qty',
                child: TextField(
                  controller: minWholesaleQtyController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(hint: _qtyHint),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _formatters,
                  onChanged: (v) =>
                      onMinWholesaleQtyChanged(double.tryParse(v) ?? 0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FormSpacing.row),
        FormGrid(
          cells: [
            if (!isService) ...[
              FormGridCell(
                span: 3,
                child: _priceField(
                  label: 'Purchase Price',
                  controller: purchasePriceController,
                  onChanged: onPurchasePriceChanged,
                ),
              ),
              FormGridCell(
                span: 3,
                child: _taxModeField(
                  value: purchasePriceTaxMode,
                  onChanged: onPurchasePriceTaxModeChanged,
                ),
              ),
            ],
            FormGridCell(span: 3, child: _taxRateField()),
          ],
        ),
      ],
    );
  }
}
