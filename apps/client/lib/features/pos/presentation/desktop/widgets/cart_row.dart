import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_item_thumbnail.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                PosItemThumbnail(item: item, size: 32),
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
                  InkWell(
                    onTap: () => _showQuantityDialog(context, ref),
                    borderRadius: AppRadius.smBorder,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
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
            child: InkWell(
              onTap: () => _showDiscountDialog(context, ref),
              borderRadius: AppRadius.smBorder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${cartItem.discountPercent.toStringAsFixed(0)}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: PosStyles.metadataStyle.copyWith(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
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

  Future<void> _showQuantityDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: '${cartItem.quantity}');

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Quantity — ${cartItem.item.name}'),
          content: SizedBox(
            width: 280,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity',
              ),
              autofocus: true,
              onSubmitted: (_) {
                final value = int.tryParse(controller.text.trim()) ?? 0;
                Navigator.of(dialogContext).pop(value);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim()) ?? 0;
                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (result != null) {
      ref
          .read(posCartProvider.notifier)
          .updateQuantity(cartItem.item.id, result);
    }
  }

  Future<void> _showDiscountDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: cartItem.discountPercent > 0
          ? cartItem.discountPercent.toStringAsFixed(0)
          : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Discount — ${cartItem.item.name}'),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount %',
                    suffixText: '%',
                    hintText: '0–100',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [5, 10, 15, 20].map((preset) {
                    return OutlinedButton(
                      onPressed: () {
                        controller.text = '$preset';
                      },
                      child: Text('$preset%'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim()) ?? 0;
                Navigator.of(dialogContext).pop(value.clamp(0, 100));
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (result != null) {
      ref
          .read(posCartProvider.notifier)
          .updateDiscount(cartItem.item.id, result);
    }
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
