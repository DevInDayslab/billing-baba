import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_category_style.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_styles.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockColor = item.stock <= 5 ? posNegativeColor : posPositiveColor;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        onTap: () => ref.read(posCartProvider.notifier).addItem(item),
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
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: AppRadius.smBorder,
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, _) => Center(
                              child: Icon(
                                PosCategoryStyle.icon(item.category),
                                size: 36,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            errorWidget: (_, _, _) => Center(
                              child: Icon(
                                PosCategoryStyle.icon(item.category),
                                size: 36,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        )
                      : Center(
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
