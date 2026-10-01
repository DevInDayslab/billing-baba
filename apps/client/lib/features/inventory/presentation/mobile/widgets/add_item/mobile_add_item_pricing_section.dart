import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/shared/price_amount_in_words_hint.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_tier_pricing_section.dart';
import 'package:flutter/material.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/widgets/gst_tax_rate_select_dropdown.dart';
import 'package:flutter/services.dart';

/// Vyapar-style pricing tab for mobile Add Item.
class MobileAddItemPricingSection extends StatefulWidget {
  const MobileAddItemPricingSection({
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
    required this.purchasePriceController,
    required this.purchasePriceTaxMode,
    required this.onPurchasePriceChanged,
    required this.onPurchasePriceTaxModeChanged,
    required this.taxRate,
    required this.onTaxRateChanged,
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
  final bool showPriceAmountInWords;
  final double mrpAmount;
  final double salePriceAmount;
  final double wholesalePriceAmount;
  final double purchasePriceAmount;
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

  @override
  State<MobileAddItemPricingSection> createState() =>
      _MobileAddItemPricingSectionState();
}

class _MobileAddItemPricingSectionState
    extends State<MobileAddItemPricingSection> {
  static const _priceFormatters = [indianItemPriceInputFormatter];

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
                  controller: widget.mrpController,
                  label: 'MRP',
                  hint: 'MRP',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _priceFormatters,
                  onChanged: (v) =>
                      widget.onMrpChanged(parseIndianItemPriceInput(v)),
                  suffixIcon: Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                PriceAmountInWordsHint(
                  amount: widget.mrpAmount,
                  enabled: widget.showPriceAmountInWords,
                ),
                const SizedBox(height: MobileAddItemTheme.fieldSpacing),
                InputDecorator(
                  decoration: MobileAddItemTheme.fieldDecoration(
                    label: 'Disc. On MRP For Sale (%)',
                    hint: 'Disc. On MRP For Sale (%)',
                  ),
                  child: const SizedBox(height: 20),
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
                  controller: widget.salePriceController,
                  label: 'Sale Price',
                  hint: 'Sale Price',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _priceFormatters,
                  onChanged: (v) =>
                      widget.onSalePriceChanged(parseIndianItemPriceInput(v)),
                  suffix: _TaxModeChip(
                    mode: widget.salePriceTaxMode,
                    onChanged: widget.onSalePriceTaxModeChanged,
                  ),
                ),
                PriceAmountInWordsHint(
                  amount: widget.salePriceAmount,
                  enabled: widget.showPriceAmountInWords,
                ),
                if (widget.showWholesalePrice) ...[
                  const SizedBox(height: 8),
                  MobileAddItemField(
                    controller: widget.wholesalePriceController,
                    label: 'Wholesale Price',
                    hint: 'Wholesale Price',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _priceFormatters,
                    onChanged: (v) => widget.onWholesalePriceChanged(
                      parseIndianItemPriceInput(v),
                    ),
                    suffix: _TaxModeChip(
                      mode: widget.wholesalePriceTaxMode,
                      onChanged: widget.onWholesalePriceTaxModeChanged,
                    ),
                  ),
                  PriceAmountInWordsHint(
                    amount: widget.wholesalePriceAmount,
                    enabled: widget.showPriceAmountInWords,
                  ),
                ],
              ],
            ),
          ),
          if (!widget.isService) ...[
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
                    controller: widget.purchasePriceController,
                    label: 'Purchase Price',
                    hint: 'Purchase Price',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                inputFormatters: _priceFormatters,
                onChanged: (v) =>
                    widget.onPurchasePriceChanged(parseIndianItemPriceInput(v)),
                    suffix: _TaxModeChip(
                      mode: widget.purchasePriceTaxMode,
                      onChanged: widget.onPurchasePriceTaxModeChanged,
                    ),
                  ),
                  PriceAmountInWordsHint(
                    amount: widget.purchasePriceAmount,
                    enabled: widget.showPriceAmountInWords,
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
                value: widget.taxRate,
                onSelected: widget.onTaxRateChanged,
              ),
            ),
          ),
          if (widget.showTierPricing &&
              widget.priceControllerFor != null &&
              widget.onUpdateTierPrice != null)
            MobileTierPricingSection(
              tierPrices: widget.tierPrices,
              apiTierLabels: widget.apiTierLabels,
              priceControllerFor: widget.priceControllerFor!,
              onUpdateTierPrice: widget.onUpdateTierPrice!,
            ),
        ],
      ),
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
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
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
