import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
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

class CartRow extends ConsumerWidget {
  const CartRow({required this.cartItem, super.key});

  final CartItem cartItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(posCartProvider.notifier);
    final item = cartItem.item;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: PosCategoryStyle.backgroundColor(item.category),
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Icon(
                    PosCategoryStyle.icon(item.category),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item.sku,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PosStyles.metadataStyle.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () => notifier.updateQuantity(
                      item.id,
                      cartItem.quantity - 1,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () => notifier.updateQuantity(
                      item.id,
                      cartItem.quantity + 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Pcs',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: PosStyles.metadataStyle.copyWith(fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              _currencyFormat.format(item.price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: PosStyles.metadataStyle.copyWith(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${cartItem.discountPercent.toStringAsFixed(0)}%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: PosStyles.metadataStyle.copyWith(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _currencyFormat.format(cartItem.lineTotal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: posNegativeColor,
              onPressed: () => notifier.removeItem(item.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: posCardBorder),
          borderRadius: AppRadius.smBorder,
        ),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
