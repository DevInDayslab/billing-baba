import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/presentation/shared/price_amount_in_words_hint.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
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
    this.showPriceAmountInWords = true,
    this.mrpAmount = 0,
    this.salePriceAmount = 0,
    this.wholesalePriceAmount = 0,
    this.purchasePriceAmount = 0,
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
  final bool showPriceAmountInWords;
  final double mrpAmount;
  final double salePriceAmount;
  final double wholesalePriceAmount;
  final double purchasePriceAmount;
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

  List<TextInputFormatter> get _qtyFormatters => [
    decimalInputFormatter ?? _defaultDecimalFormatter,
  ];

  static const _priceFormatters = [indianItemPriceInputFormatter];

  List<String> get _taxModeOptions => [
    priceTaxModeLabel(PriceTaxMode.withoutTax),
    priceTaxModeLabel(PriceTaxMode.withTax),
  ];

  void _onTaxMode(String label, ValueChanged<PriceTaxMode> onChanged) {
    onChanged(
      label == 'With Tax' ? PriceTaxMode.withTax : PriceTaxMode.withoutTax,
    );
  }

  static const _fullRowSpan = FormSpacing.columns;

  Widget _priceInput({
    required String label,
    required TextEditingController controller,
    required ValueChanged<double> onChanged,
  }) {
    return AppFormField(
      label: label,
      floatingLabel: true,
      child: TextField(
        controller: controller,
        style: saleFieldTextStyle,
        decoration: buildFormControlDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: _priceFormatters,
        onChanged: (v) => onChanged(parseIndianItemPriceInput(v)),
      ),
    );
  }

  Widget _pricingFieldsWithWords({
    required List<FormGridCell> cells,
    required double amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormGrid(rowGap: 12, cells: cells),
        PriceAmountInWordsHint(
          amount: amount,
          enabled: showPriceAmountInWords,
        ),
      ],
    );
  }

  Widget _taxModeField({
    required PriceTaxMode value,
    required ValueChanged<PriceTaxMode> onChanged,
  }) {
    const label = 'Tax mode';
    return AppFormField(
      label: label,
      floatingLabel: true,
      child: InputDecorator(
        isEmpty: false,
        decoration: buildFormControlDecoration(labelText: label),
        child: SaleGenericSelectDropdown(
          borderless: true,
          triggerHeight: saleFieldHeight - 20,
          value: priceTaxModeLabel(value),
          options: _taxModeOptions,
          onSelected: (v) => _onTaxMode(v, onChanged),
        ),
      ),
    );
  }

  Widget _taxRateField() {
    const label = 'Tax Rate';
    return AppFormField(
      label: label,
      floatingLabel: true,
      child: InputDecorator(
        isEmpty: taxRate.isEmpty,
        decoration: buildFormControlDecoration(labelText: label),
        child: SaleGenericSelectDropdown(
          borderless: true,
          triggerHeight: saleFieldHeight - 20,
          value: taxRate,
          options: _taxRateOptions,
          onSelected: onTaxRateChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _pricingFieldsWithWords(
          amount: mrpAmount,
          cells: [
            FormGridCell(
              span: _fullRowSpan,
              child: _priceInput(
                label: 'MRP',
                controller: mrpController,
                onChanged: onMrpChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _pricingFieldsWithWords(
          amount: salePriceAmount,
          cells: [
            FormGridCell(
              span: 3,
              child: _priceInput(
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
        const SizedBox(height: 12),
        _pricingFieldsWithWords(
          amount: wholesalePriceAmount,
          cells: [
            FormGridCell(
              span: 3,
              child: _priceInput(
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
                floatingLabel: true,
                child: TextField(
                  controller: minWholesaleQtyController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    labelText: 'Minimum Wholesale Qty',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _qtyFormatters,
                  onChanged: (v) =>
                      onMinWholesaleQtyChanged(double.tryParse(v) ?? 0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!isService)
          _pricingFieldsWithWords(
            amount: purchasePriceAmount,
            cells: [
              FormGridCell(
                span: 3,
                child: _priceInput(
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
              FormGridCell(span: 3, child: _taxRateField()),
            ],
          )
        else
          FormGrid(
            rowGap: 12,
            cells: [FormGridCell(span: 3, child: _taxRateField())],
          ),
      ],
    );
  }
}
