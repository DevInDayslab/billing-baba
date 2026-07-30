import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _cardBorder = Color(0xFFE0E0E0);

/// Tier-based pricing rows for the item pricing tab (local dummy data).
class TierPricingSection extends StatelessWidget {
  const TierPricingSection({
    required this.tierPrices,
    required this.priceControllerFor,
    required this.onUpdateTierPrice,
    required this.onRemoveTierPrice,
    required this.onAddTierPrice,
    this.apiTierLabels,
    this.onCustomizeTierNames,
    this.decimalInputFormatter,
    super.key,
  });

  final List<ItemTierPriceRow> tierPrices;
  final TextEditingController Function(String id, String initial)
  priceControllerFor;
  final void Function(String id, {String? tierKey, double? price})
  onUpdateTierPrice;
  final ValueChanged<String> onRemoveTierPrice;
  final VoidCallback onAddTierPrice;
  final Map<String, String>? apiTierLabels;
  final VoidCallback? onCustomizeTierNames;
  final TextInputFormatter? decimalInputFormatter;

  static final _defaultDecimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  List<TextInputFormatter> get _formatters => [
    decimalInputFormatter ?? _defaultDecimalFormatter,
  ];

  List<String> _tierOptionsFor(ItemTierPriceRow row) {
    final used = tierPrices
        .where((entry) => entry.id != row.id)
        .map((entry) => entry.tierKey)
        .toSet();
    final options = PriceTier.all
        .where((tier) => tier == row.tierKey || !used.contains(tier))
        .map(
          (tier) => PriceTier.labelFor(tier, apiTierLabels: apiTierLabels),
        )
        .toList();
    return options;
  }

  String get _emptyStateMessage {
    final extraTiers = PriceTier.all
        .where((tier) => tier != PriceTier.retail)
        .map((tier) => PriceTier.labelFor(tier, apiTierLabels: apiTierLabels))
        .join(', ');
    return 'No tier prices added. Use "+ Add Tier" to set $extraTiers prices.';
  }

  @override
  Widget build(BuildContext context) {
    final canAddMore = tierPrices.length < PriceTier.all.length;

    return FormSection(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tier Pricing',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (onCustomizeTierNames != null)
                TextButton(
                  onPressed: onCustomizeTierNames,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Customize names',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: FormSpacing.row),
          if (tierPrices.isEmpty)
            Text(
              _emptyStateMessage,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          if (tierPrices.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: _cardBorder),
                borderRadius: FormSpacing.cardBorderRadius,
              ),
              child: Column(
                children: [
                  const _TierPricingHeader(),
                  for (final row in tierPrices)
                    _TierPricingRow(
                      row: row,
                      tierOptions: _tierOptionsFor(row),
                      apiTierLabels: apiTierLabels,
                      priceController: priceControllerFor(
                        row.id,
                        row.price == 0 ? '' : row.price.toString(),
                      ),
                      formatters: _formatters,
                      onTierChanged: (label) => onUpdateTierPrice(
                        row.id,
                        tierKey: PriceTier.keyFromLabel(
                          label,
                          apiTierLabels: apiTierLabels,
                        ),
                      ),
                      onPriceChanged: (value) => onUpdateTierPrice(
                        row.id,
                        price: double.tryParse(value) ?? 0,
                      ),
                      onRemove: () => onRemoveTierPrice(row.id),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: canAddMore ? onAddTierPrice : null,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Tier'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierPricingHeader extends StatelessWidget {
  const _TierPricingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Tier',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Price',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _TierPricingRow extends StatelessWidget {
  const _TierPricingRow({
    required this.row,
    required this.tierOptions,
    required this.apiTierLabels,
    required this.priceController,
    required this.formatters,
    required this.onTierChanged,
    required this.onPriceChanged,
    required this.onRemove,
  });

  final ItemTierPriceRow row;
  final List<String> tierOptions;
  final Map<String, String>? apiTierLabels;
  final TextEditingController priceController;
  final List<TextInputFormatter> formatters;
  final ValueChanged<String> onTierChanged;
  final ValueChanged<String> onPriceChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: SaleGenericSelectDropdown(
              value: PriceTier.labelFor(
                row.tierKey,
                apiTierLabels: apiTierLabels,
              ),
              options: tierOptions,
              onSelected: onTierChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: TextField(
              controller: priceController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: '0.00'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: formatters,
              onChanged: onPriceChanged,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Remove tier',
          ),
        ],
      ),
    );
  }
}
