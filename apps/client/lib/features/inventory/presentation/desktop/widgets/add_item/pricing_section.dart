import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/shared/price_amount_in_words_hint.dart';
import 'package:billing_baba/features/inventory/utils/item_pricing_discount.dart';
import 'package:billing_baba/features/inventory/utils/min_wholesale_qty_units.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/widgets/gst_tax_rate_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pricing tab — Sale Price, Purchase Price, and Taxes (Vyapar-style layout).
class PricingSection extends StatelessWidget {
  const PricingSection({
    required this.isService,
    required this.mrpController,
    required this.onMrpChanged,
    required this.mrpSaleDiscountController,
    required this.onMrpSaleDiscountChanged,
    required this.mrpSaleDiscountKind,
    required this.onMrpSaleDiscountKindChanged,
    required this.salePriceController,
    required this.salePriceTaxMode,
    required this.onSalePriceChanged,
    required this.onSalePriceTaxModeChanged,
    required this.salePriceDiscountController,
    required this.onSalePriceDiscountChanged,
    required this.salePriceDiscountKind,
    required this.onSalePriceDiscountKindChanged,
    required this.wholesalePriceController,
    required this.wholesalePriceTaxMode,
    required this.onWholesalePriceChanged,
    required this.onWholesalePriceTaxModeChanged,
    required this.minWholesaleQtyController,
    required this.onMinWholesaleQtyChanged,
    required this.minWholesaleQtyUnitOptions,
    required this.minWholesaleQtyUnitId,
    required this.onMinWholesaleQtyUnitChanged,
    required this.purchasePriceController,
    required this.purchasePriceTaxMode,
    required this.onPurchasePriceChanged,
    required this.onPurchasePriceTaxModeChanged,
    required this.taxRate,
    required this.onTaxRateChanged,
    required this.showWholesaleSection,
    required this.onAddWholesale,
    this.showPriceAmountInWords = true,
    this.wholesalePriceEnabled = false,
    this.mrpAmount = 0,
    this.salePriceAmount = 0,
    this.wholesalePriceAmount = 0,
    this.purchasePriceAmount = 0,
    this.decimalInputFormatter,
    this.baseUnitId,
    super.key,
  });

  final String? baseUnitId;
  final bool isService;
  final bool wholesalePriceEnabled;
  final bool showWholesaleSection;
  final VoidCallback onAddWholesale;
  final TextEditingController mrpController;
  final ValueChanged<double> onMrpChanged;
  final TextEditingController mrpSaleDiscountController;
  final ValueChanged<double> onMrpSaleDiscountChanged;
  final PriceDiscountKind mrpSaleDiscountKind;
  final ValueChanged<PriceDiscountKind> onMrpSaleDiscountKindChanged;
  final TextEditingController salePriceController;
  final PriceTaxMode salePriceTaxMode;
  final ValueChanged<double> onSalePriceChanged;
  final ValueChanged<PriceTaxMode> onSalePriceTaxModeChanged;
  final TextEditingController salePriceDiscountController;
  final ValueChanged<double> onSalePriceDiscountChanged;
  final PriceDiscountKind salePriceDiscountKind;
  final ValueChanged<PriceDiscountKind> onSalePriceDiscountKindChanged;
  final TextEditingController wholesalePriceController;
  final PriceTaxMode wholesalePriceTaxMode;
  final ValueChanged<double> onWholesalePriceChanged;
  final ValueChanged<PriceTaxMode> onWholesalePriceTaxModeChanged;
  final TextEditingController minWholesaleQtyController;
  final ValueChanged<double> onMinWholesaleQtyChanged;
  final List<InventoryUnit> minWholesaleQtyUnitOptions;
  final String? minWholesaleQtyUnitId;
  final ValueChanged<String> onMinWholesaleQtyUnitChanged;
  final TextEditingController purchasePriceController;
  final PriceTaxMode purchasePriceTaxMode;
  final ValueChanged<double> onPurchasePriceChanged;
  final ValueChanged<PriceTaxMode> onPurchasePriceTaxModeChanged;
  final String taxRate;
  final ValueChanged<String> onTaxRateChanged;
  final bool showPriceAmountInWords;
  final double mrpAmount;
  final double salePriceAmount;
  final double wholesalePriceAmount;
  final double purchasePriceAmount;
  final TextInputFormatter? decimalInputFormatter;

  static final _defaultDecimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  static const List<TextInputFormatter> _priceFormatters = [
    indianItemPriceInputFormatter,
  ];

  List<TextInputFormatter> get _qtyFormatters => [
    decimalInputFormatter ?? _defaultDecimalFormatter,
  ];

  List<String> get _taxModeOptions => [
    priceTaxModeLabel(PriceTaxMode.withoutTax),
    priceTaxModeLabel(PriceTaxMode.withTax),
  ];

  void _onTaxMode(String label, ValueChanged<PriceTaxMode> onChanged) {
    onChanged(
      label == priceTaxModeLabel(PriceTaxMode.withTax)
          ? PriceTaxMode.withTax
          : PriceTaxMode.withoutTax,
    );
  }

  static const EdgeInsets _cardPadding = EdgeInsets.all(12);

  Widget _discountKindSuffix({
    required PriceDiscountKind value,
    required ValueChanged<PriceDiscountKind> onChanged,
  }) {
    final label = ItemPricingDiscount.labelForKind(value);
    return SizedBox(
      width: 108,
      child: SaleGenericSelectDropdown(
        borderless: true,
        compact: true,
        triggerHeight: saleFieldHeight - 20,
        value: label,
        options: ItemPricingDiscount.discountKindLabels,
        onSelected: (v) => onChanged(ItemPricingDiscount.kindFromLabel(v)),
      ),
    );
  }

  Widget _taxModeSuffix({
    required PriceTaxMode value,
    required ValueChanged<PriceTaxMode> onChanged,
  }) {
    return SizedBox(
      width: 118,
      child: SaleGenericSelectDropdown(
        borderless: true,
        compact: true,
        triggerHeight: saleFieldHeight - 20,
        value: priceTaxModeLabel(value),
        options: _taxModeOptions,
        onSelected: (v) => _onTaxMode(v, onChanged),
      ),
    );
  }

  Widget? _minWholesaleQtyUnitSuffix({required String? baseUnitId}) {
    final options = minWholesaleQtyUnitOptions;
    if (options.isEmpty) return null;

    final selectedShortName = minWholesaleQtyUnitShortName(
      options: options,
      selectedUnitId: minWholesaleQtyUnitId,
      fallbackBaseUnitId: baseUnitId,
    );
    if (selectedShortName == null) return null;

    if (options.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          selectedShortName,
          style: saleFieldTextStyle.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return SizedBox(
      width: 88,
      child: SaleGenericSelectDropdown(
        borderless: true,
        compact: true,
        triggerHeight: saleFieldHeight - 20,
        value: selectedShortName,
        options: options.map((unit) => unit.shortName).toList(),
        onSelected: (shortName) {
          final unit = options.firstWhereOrNull(
            (entry) => entry.shortName == shortName,
          );
          if (unit != null) {
            onMinWholesaleQtyUnitChanged(unit.id);
          }
        },
      ),
    );
  }

  Widget _priceField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<double> onChanged,
    required PriceTaxMode taxMode,
    required ValueChanged<PriceTaxMode> onTaxModeChanged,
  }) {
    return TextField(
      controller: controller,
      style: saleFieldTextStyle,
      decoration: buildFormControlDecoration(
        hint: hint,
        suffix: _taxModeSuffix(value: taxMode, onChanged: onTaxModeChanged),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: _priceFormatters,
      onChanged: (v) => onChanged(parseIndianItemPriceInput(v)),
    );
  }

  Widget _amountInWords(double amount) {
    return PriceAmountInWordsHint(
      amount: amount,
      enabled: showPriceAmountInWords,
    );
  }

  Widget _buildMrpSection() {
    return FormSection(
      title: 'MRP',
      padding: _cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormGrid(
            rowGap: 12,
            cells: [
              FormGridCell(
                span: 3,
                child: TextField(
                  controller: mrpController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(hint: 'MRP'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _priceFormatters,
                  onChanged: (v) => onMrpChanged(parseIndianItemPriceInput(v)),
                ),
              ),
              FormGridCell(
                span: 3,
                child: TextField(
                  controller: mrpSaleDiscountController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    hint: 'Disc. On MRP For Sale (%)',
                    suffix: _discountKindSuffix(
                      value: mrpSaleDiscountKind,
                      onChanged: onMrpSaleDiscountKindChanged,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _qtyFormatters,
                  onChanged: (v) =>
                      onMrpSaleDiscountChanged(double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          _amountInWords(mrpAmount),
        ],
      ),
    );
  }

  Widget _buildSalePriceSection() {
    return FormSection(
      title: 'Sale Price',
      padding: _cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormGrid(
            rowGap: 12,
            cells: [
              FormGridCell(
                span: 3,
                child: _priceField(
                  controller: salePriceController,
                  hint: 'Sale Price',
                  onChanged: onSalePriceChanged,
                  taxMode: salePriceTaxMode,
                  onTaxModeChanged: onSalePriceTaxModeChanged,
                ),
              ),
              FormGridCell(
                span: 3,
                child: TextField(
                  controller: salePriceDiscountController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    hint: 'Disc. On Sale Price...',
                    suffix: _discountKindSuffix(
                      value: salePriceDiscountKind,
                      onChanged: onSalePriceDiscountKindChanged,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _qtyFormatters,
                  onChanged: (v) =>
                      onSalePriceDiscountChanged(double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          _amountInWords(salePriceAmount),
          if (wholesalePriceEnabled && !showWholesaleSection) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onAddWholesale,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '+ Add Wholesale Price',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWholesaleSection() {
    return FormSection(
      title: 'Wholesale Price',
      padding: _cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormGrid(
            rowGap: 12,
            cells: [
              FormGridCell(
                span: 3,
                child: _priceField(
                  controller: wholesalePriceController,
                  hint: 'Wholesale Price',
                  onChanged: onWholesalePriceChanged,
                  taxMode: wholesalePriceTaxMode,
                  onTaxModeChanged: onWholesalePriceTaxModeChanged,
                ),
              ),
              FormGridCell(
                span: 3,
                child: TextField(
                  controller: minWholesaleQtyController,
                  style: saleFieldTextStyle,
                  decoration: buildFormControlDecoration(
                    hint: 'Minimum Wholesale Qty',
                    suffix: _minWholesaleQtyUnitSuffix(baseUnitId: baseUnitId),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _qtyFormatters,
                  onChanged: (v) =>
                      onMinWholesaleQtyChanged(double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          _amountInWords(wholesalePriceAmount),
        ],
      ),
    );
  }

  Widget _buildPurchaseAndTaxesRow() {
    final purchaseSection = FormSection(
      title: 'Purchase Price',
      padding: _cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _priceField(
            controller: purchasePriceController,
            hint: 'Purchase Price',
            onChanged: onPurchasePriceChanged,
            taxMode: purchasePriceTaxMode,
            onTaxModeChanged: onPurchasePriceTaxModeChanged,
          ),
          _amountInWords(purchasePriceAmount),
        ],
      ),
    );

    final taxesSection = FormSection(
      title: 'Taxes',
      padding: _cardPadding,
      child: AppFormField(
        label: 'Tax Rate',
        floatingLabel: true,
        child: InputDecorator(
          isEmpty: taxRate.isEmpty,
          decoration: buildFormControlDecoration(labelText: 'Tax Rate'),
          child: GstTaxRateSelectDropdown(
            borderless: true,
            triggerHeight: saleFieldHeight - 20,
            value: taxRate,
            onSelected: onTaxRateChanged,
          ),
        ),
      ),
    );

    if (isService) {
      return taxesSection;
    }

    return FormGrid(
      rowGap: 12,
      cells: [
        FormGridCell(span: 3, child: purchaseSection),
        FormGridCell(span: 3, child: taxesSection),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMrpSection(),
        const SizedBox(height: 12),
        _buildSalePriceSection(),
        if (showWholesaleSection) ...[
          const SizedBox(height: 12),
          _buildWholesaleSection(),
        ],
        const SizedBox(height: 12),
        _buildPurchaseAndTaxesRow(),
      ],
    );
  }
}
