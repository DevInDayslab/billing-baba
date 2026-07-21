import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/out_of_stock_dialog.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_category_style.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_styles.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

class ItemCard extends ConsumerWidget {
  const ItemCard({required this.item, super.key});

  final PosItem item;

  void _handleItemTap(BuildContext context, WidgetRef ref) {
    if (item.stock == 0) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => OutOfStockDialog(
          itemId: item.id,
          itemName: item.name,
          onSelectAlternative: (alternativeItem) {
            final alternativePosItem = PosItem(
              id: alternativeItem.id,
              name: alternativeItem.name,
              sku: alternativeItem.barcode ?? '',
              category: alternativeItem.categoryName ?? item.category,
              price: alternativeItem.salePrice,
              stock: alternativeItem.stockQuantity.toInt(),
              unit: item.unit,
            );
            ref.read(posCartProvider.notifier).addItem(alternativePosItem);
          },
          onContinueAnyway: () {
            ref.read(posCartProvider.notifier).addItem(item);
          },
        ),
      );
    } else {
      ref.read(posCartProvider.notifier).addItem(item);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockColor = item.stock <= 5 ? posNegativeColor : posPositiveColor;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        onTap: () => _handleItemTap(context, ref),
        borderRadius: AppRadius.mdBorder,
        hoverColor: posSelectedBackground.withValues(alpha: 0.5),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: posCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: PosCategoryStyle.backgroundColor(item.category),
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Center(
                    child: Icon(
                      PosCategoryStyle.icon(item.category),
                      size: 36,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: PosStyles.itemNameStyle,
              ),
              const SizedBox(height: 2),
              Text(
                item.sku,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PosStyles.metadataStyle.copyWith(fontSize: 10),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _currencyFormat.format(item.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PosStyles.priceStyle,
                    ),
                  ),
                  Text(
                    'Stock: ${item.stock}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PosStyles.metadataStyle.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: stockColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
