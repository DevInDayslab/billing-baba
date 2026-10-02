import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_tier_pricing_section.dart';
import 'package:billing_baba/features/inventory/presentation/shared/price_amount_in_words_hint.dart';
import 'package:billing_baba/features/inventory/utils/item_pricing_discount.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/widgets/gst_tax_rate_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vyapar-style pricing tab for mobile Add Item.
class MobileAddItemPricingSection extends StatelessWidget {
  const MobileAddItemPricingSection({
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
    required this.purchasePriceController,
    required this.purchasePriceTaxMode,
    required this.onPurchasePriceChanged,
    required this.onPurchasePriceTaxModeChanged,
    required this.taxRate,
    required this.onTaxRateChanged,
    required this.showWholesaleSection,
    required this.onAddWholesale,
    this.showWholesalePrice = false,
    this.showTierPricing = false,
    this.tierPrices = const [],
    this.apiTierLabels = const {},
    this.priceControllerFor,
    this.onUpdateTierPrice,
    this.showPriceAmountInWords = true,
    this.mrpAmount = 0,
    this.salePriceAmount = 0,
    this.wholesalePriceAmount = 0,
    this.purchasePriceAmount = 0,
    super.key,
  });

  final bool isService;
  final bool showWholesaleSection;
  final VoidCallback onAddWholesale;
  final bool showPriceAmountInWords;
  final double mrpAmount;
  final double salePriceAmount;
  final double wholesalePriceAmount;
  final double purchasePriceAmount;
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
  final TextEditingController purchasePriceController;
  final PriceTaxMode purchasePriceTaxMode;
  final ValueChanged<double> onPurchasePriceChanged;
  final ValueChanged<PriceTaxMode> onPurchasePriceTaxModeChanged;
  final String taxRate;
  final ValueChanged<String> onTaxRateChanged;
  final bool showWholesalePrice;
  final bool showTierPricing;
  final List<ItemTierPriceRow> tierPrices;
  final Map<String, String> apiTierLabels;
  final TextEditingController Function(String id, String initial)?
  priceControllerFor;
  final void Function(String id, {String? tierKey, double? price})?
  onUpdateTierPrice;

  static const List<TextInputFormatter> _priceFormatters = [
    indianItemPriceInputFormatter,
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileAddItemTheme.sectionBandDivider(),
          MobileAddItemTheme.sectionHeader('MRP'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MobileAddItemTheme.horizontalPadding,
            ),
            child: Column(
              children: [
                MobileAddItemField(
                  controller: mrpController,
                  label: 'MRP',
                  hint: 'MRP',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _priceFormatters,
                  onChanged: (v) => onMrpChanged(parseIndianItemPriceInput(v)),
                ),
                PriceAmountInWordsHint(
                  amount: mrpAmount,
                  enabled: showPriceAmountInWords,
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                MobileAddItemField(
                  controller: mrpSaleDiscountController,
                  label: 'Disc. On MRP For Sale (%)',
                  hint: 'Disc. On MRP For Sale (%)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) =>
                      onMrpSaleDiscountChanged(double.tryParse(v) ?? 0),
                  suffix: _DiscountTypeChip(
                    kind: mrpSaleDiscountKind,
                    onChanged: onMrpSaleDiscountKindChanged,
                  ),
                ),
              ],
            ),
          ),
          MobileAddItemTheme.sectionBandDivider(),
          MobileAddItemTheme.sectionHeader('Sale Price'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MobileAddItemTheme.horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MobileAddItemField(
                  controller: salePriceController,
                  label: 'Sale Price',
                  hint: 'Sale Price',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _priceFormatters,
                  onChanged: (v) =>
                      onSalePriceChanged(parseIndianItemPriceInput(v)),
                  suffix: _TaxModeChip(
                    mode: salePriceTaxMode,
                    onChanged: onSalePriceTaxModeChanged,
                  ),
                ),
                PriceAmountInWordsHint(
                  amount: salePriceAmount,
                  enabled: showPriceAmountInWords,
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                MobileAddItemField(
                  controller: salePriceDiscountController,
                  label: 'Disc. On Sale Price...',
                  hint: 'Disc. On Sale Price...',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) =>
                      onSalePriceDiscountChanged(double.tryParse(v) ?? 0),
                  suffix: _DiscountTypeChip(
                    kind: salePriceDiscountKind,
                    onChanged: onSalePriceDiscountKindChanged,
                  ),
                ),
                if (showWholesaleSection) ...[
                  const SizedBox(height: 8),
                  MobileAddItemField(
                    controller: wholesalePriceController,
                    label: 'Wholesale Price',
                    hint: 'Wholesale Price',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _priceFormatters,
                    onChanged: (v) => onWholesalePriceChanged(
                      parseIndianItemPriceInput(v),
                    ),
                    suffix: _TaxModeChip(
                      mode: wholesalePriceTaxMode,
                      onChanged: onWholesalePriceTaxModeChanged,
                    ),
                  ),
                  PriceAmountInWordsHint(
                    amount: wholesalePriceAmount,
                    enabled: showPriceAmountInWords,
                  ),
                ] else if (showWholesalePrice) ...[
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isService) ...[
            MobileAddItemTheme.sectionBandDivider(),
            MobileAddItemTheme.sectionHeader('Purchase Price'),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MobileAddItemTheme.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MobileAddItemField(
                    controller: purchasePriceController,
                    label: 'Purchase Price',
                    hint: 'Purchase Price',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _priceFormatters,
                    onChanged: (v) =>
                        onPurchasePriceChanged(parseIndianItemPriceInput(v)),
                    suffix: _TaxModeChip(
                      mode: purchasePriceTaxMode,
                      onChanged: onPurchasePriceTaxModeChanged,
                    ),
                  ),
                  PriceAmountInWordsHint(
                    amount: purchasePriceAmount,
                    enabled: showPriceAmountInWords,
                  ),
                ],
              ),
            ),
          ],
          MobileAddItemTheme.sectionBandDivider(),
          MobileAddItemTheme.sectionHeader('Taxes'),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MobileAddItemTheme.horizontalPadding,
              0,
              MobileAddItemTheme.horizontalPadding,
              16,
            ),
            child: InputDecorator(
              decoration: MobileAddItemTheme.fieldDecoration(label: 'Tax Rate'),
              child: GstTaxRateSelectDropdown(
                borderless: true,
                value: taxRate,
                onSelected: onTaxRateChanged,
              ),
            ),
          ),
          if (showTierPricing &&
              priceControllerFor != null &&
              onUpdateTierPrice != null)
            MobileTierPricingSection(
              tierPrices: tierPrices,
              apiTierLabels: apiTierLabels,
              priceControllerFor: priceControllerFor!,
              onUpdateTierPrice: onUpdateTierPrice!,
            ),
        ],
      ),
    );
  }
}

class _DiscountTypeChip extends StatelessWidget {
  const _DiscountTypeChip({
    required this.kind,
    required this.onChanged,
  });

  final PriceDiscountKind kind;
  final ValueChanged<PriceDiscountKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = ItemPricingDiscount.labelForKind(kind);

    return PopupMenuButton<PriceDiscountKind>(
      initialValue: kind,
      onSelected: onChanged,
      offset: const Offset(0, 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: PriceDiscountKind.percentage,
          child: Text(
            ItemPricingDiscount.labelForKind(PriceDiscountKind.percentage),
          ),
        ),
        PopupMenuItem(
          value: PriceDiscountKind.amount,
          child: Text(
            ItemPricingDiscount.labelForKind(PriceDiscountKind.amount),
          ),
        ),
      ],
    );
  }
}

class _TaxModeChip extends StatelessWidget {
  const _TaxModeChip({
    required this.mode,
    required this.onChanged,
  });

  final PriceTaxMode mode;
  final ValueChanged<PriceTaxMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = priceTaxModeLabel(mode);

    return PopupMenuButton<PriceTaxMode>(
      initialValue: mode,
      onSelected: onChanged,
      offset: const Offset(0, 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: PriceTaxMode.withoutTax,
          child: Text(priceTaxModeLabel(PriceTaxMode.withoutTax)),
        ),
        PopupMenuItem(
          value: PriceTaxMode.withTax,
          child: Text(priceTaxModeLabel(PriceTaxMode.withTax)),
        ),
      ],
    );
  }
}
