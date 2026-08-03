import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_field.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vyapar-style Online Store tab for mobile Add Item.
class MobileAddItemOnlineStoreSection extends StatelessWidget {
  const MobileAddItemOnlineStoreSection({
    required this.itemType,
    required this.priceController,
    required this.descriptionController,
    required this.onPriceChanged,
    required this.onDescriptionChanged,
    super.key,
  });

  final ItemType itemType;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final ValueChanged<double> onPriceChanged;
  final ValueChanged<String> onDescriptionChanged;

  static final _decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  bool get _isProduct => itemType == ItemType.product;

  @override
  Widget build(BuildContext context) {
    final priceLabel = _isProduct
        ? 'Online Store Item Price'
        : 'Online Store Service Price';
    final descriptionLabel = _isProduct
        ? 'Online Store Item Description'
        : 'Online Store Service Description';

    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MobileAddItemTheme.horizontalPadding,
          16,
          MobileAddItemTheme.horizontalPadding,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MobileAddItemField(
              controller: priceController,
              label: priceLabel,
              hint: priceLabel,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalFormatter],
              onChanged: (v) => onPriceChanged(double.tryParse(v) ?? 0),
              suffixIcon: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: MobileAddItemTheme.fieldSpacing),
            MobileAddItemField(
              controller: descriptionController,
              label: descriptionLabel,
              hint: descriptionLabel,
              maxLines: 4,
              onChanged: onDescriptionChanged,
              suffixIcon: Align(
                alignment: Alignment.bottomRight,
                widthFactor: 1,
                heightFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, right: 4),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
