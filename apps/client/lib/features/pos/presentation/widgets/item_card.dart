import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_category_style.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_item_thumbnail.dart';
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

  /// Image area height — dominates the card so product photos read clearly.
  static const imageHeight = 118.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = item.isOutOfStock;
    final stockColor = isOutOfStock
        ? posNegativeColor
        : (item.stock <= 5 ? posNegativeColor : posPositiveColor);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () => ref.read(posCartProvider.notifier).addItem(item),
        borderRadius: AppRadius.mdBorder,
        hoverColor: isOutOfStock
            ? null
            : posSelectedBackground.withValues(alpha: 0.5),
        child: Opacity(
          opacity: isOutOfStock ? 0.72 : 1,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdBorder,
              border: Border.all(
                color: isOutOfStock
                    ? posNegativeColor.withValues(alpha: 0.4)
                    : posCardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: PosCategoryStyle.backgroundColor(
                            item.categoryStyleKey,
                          ),
                          borderRadius: AppRadius.smBorder,
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadius.smBorder,
                          child: PosItemThumbnail(item: item),
                        ),
                      ),
                      if (isOutOfStock)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: posNegativeColor,
                              borderRadius: AppRadius.smBorder,
                            ),
                            child: const Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                      isOutOfStock ? 'Out of Stock' : 'Stock: ${item.stock}',
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
      ),
    );
  }
}
