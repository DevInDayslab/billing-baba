import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mobile tier price rows shown when wholesale pricing is enabled.
class MobileTierPricingSection extends StatelessWidget {
  const MobileTierPricingSection({
    required this.tierPrices,
    required this.apiTierLabels,
    required this.priceControllerFor,
    required this.onUpdateTierPrice,
    super.key,
  });

  final List<ItemTierPriceRow> tierPrices;
  final Map<String, String> apiTierLabels;
  final TextEditingController Function(String id, String initial)
  priceControllerFor;
  final void Function(String id, {String? tierKey, double? price})
  onUpdateTierPrice;

  @override
  Widget build(BuildContext context) {
    final rowsByTier = {
      for (final row in tierPrices) row.tierKey: row,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileAddItemTheme.sectionBandDivider(),
        MobileAddItemTheme.sectionHeader('Tier Pricing'),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MobileAddItemTheme.horizontalPadding,
            0,
            MobileAddItemTheme.horizontalPadding,
            16,
          ),
          child: Column(
            children: [
              for (final tierKey in PriceTier.all) ...[
                MobileAddItemField(
                  controller: priceControllerFor(
                    rowsByTier[tierKey]!.id,
                    _initialPrice(rowsByTier[tierKey]),
                  ),
                  label: PriceTier.labelFor(
                    tierKey,
                    apiTierLabels: apiTierLabels,
                  ),
                  hint: PriceTier.labelFor(
                    tierKey,
                    apiTierLabels: apiTierLabels,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) => onUpdateTierPrice(
                    rowsByTier[tierKey]!.id,
                    price: double.tryParse(value) ?? 0,
                  ),
                ),
                if (tierKey != PriceTier.all.last)
                  const SizedBox(height: MobileAddItemTheme.fieldSpacing),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _initialPrice(ItemTierPriceRow? row) {
    if (row == null || row.price == 0) return '';
    return row.price.toString();
  }
}
