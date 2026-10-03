import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_quantity_pad_sheet.dart';
import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

class PosItemCard extends ConsumerWidget {
  const PosItemCard({
    required this.item,
    required this.cartQty,
    super.key,
  });

  final PosItem item;
  final int cartQty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.read(posCartProvider.notifier);
    final isOutOfStock = item.isOutOfStock;
    final primaryTint = AppColors.primary.withValues(alpha: 0.08);

    return Opacity(
      opacity: isOutOfStock ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              // Slightly shorter image so price + qty controls always fit.
              aspectRatio: 1.3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: _ItemImage(item: item),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            isOutOfStock
                                ? 'Out of stock'
                                : 'Stock: ${item.stock} ${item.unit}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOutOfStock
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price alone — never shares a row with −/+.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _currencyFormat.format(item.price),
                        maxLines: 1,
                        softWrap: false,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // − / qty / + on the next row so price stays fully visible.
                    if (!isOutOfStock && cartQty == 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _CircleAddButton(
                          onPressed: () => cart.addItem(item),
                        ),
                      )
                    else if (!isOutOfStock)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _QuantityStepper(
                          quantity: cartQty,
                          tint: primaryTint,
                          onDecrease: () =>
                              cart.updateQuantity(item.id, cartQty - 1),
                          onIncrease: () => cart.addItem(item),
                          onQuantityTap: () async {
                            final qty = await showPosQuantityPad(
                              context,
                              itemName: item.name,
                              initialQuantity: cartQty,
                              maxQuantity: item.stock > 0 ? item.stock : null,
                            );
                            if (qty == null || !context.mounted) return;
                            cart.updateQuantity(item.id, qty);
                          },
                        ),
                      )
                    else
                      const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.item});

  final PosItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return ColoredBox(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: Icon(
          LucideIcons.package,
          color: AppColors.primary.withValues(alpha: 0.6),
          size: AppIconSize.xl,
        ),
      );
    }

    return AppNetworkImage(
      imageUrl: url,
      sourceMediaAssetId: item.imageMediaAssetId,
      displayContext: ImageDisplayContext.grid,
      memCacheWidth: 300,
      loadWhenVisible: false,
    );
  }
}

class _CircleAddButton extends StatelessWidget {
  const _CircleAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            LucideIcons.plus,
            color: AppColors.primary,
            size: AppIconSize.md,
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.tint,
    required this.onDecrease,
    required this.onIncrease,
    required this.onQuantityTap,
  });

  final int quantity;
  final Color tint;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onQuantityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: LucideIcons.minus,
            onPressed: onDecrease,
          ),
          InkWell(
            onTap: onQuantityTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                '$quantity',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          _StepperButton(
            icon: LucideIcons.plus,
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 36,
          height: 32,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppIconSize.md,
          ),
        ),
      ),
    );
  }
}
