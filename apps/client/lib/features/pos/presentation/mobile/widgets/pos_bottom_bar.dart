import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/presentation/mobile/pos_cart_page.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_held_bills_sheet.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_quick_add_item_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

class PosBottomBar extends ConsumerWidget {
  const PosBottomBar({super.key, this.onScanTap});

  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(posCartProvider);
    final cart = ref.read(posCartProvider.notifier);
    final isEmpty = cartState.items.isEmpty;
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _OutlinedActionButton(
                      label: 'Hold bill',
                      onPressed: isEmpty
                          ? null
                          : () async {
                              await cart.holdBill();
                              if (context.mounted) {
                                await showPosHeldBillsSheet(context);
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _OutlinedActionButton(
                      label: 'Clear',
                      onPressed: isEmpty ? null : cart.clearCart,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _OutlinedActionButton(
                      label: 'Add new item',
                      onPressed: () => showPosQuickAddItemSheet(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Material(
                      color: AppColors.background,
                      borderRadius: AppRadius.mdBorder,
                      child: InkWell(
                        onTap: onScanTap,
                        borderRadius: AppRadius.mdBorder,
                        child: const SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.textSecondary,
                            size: AppIconSize.lg,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: isEmpty
                            ? null
                            : () {
                                unawaited(
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const PosCartPage(),
                                    ),
                                  ),
                                );
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.35,
                          ),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${cartState.totalQty} items · ${_currencyFormat.format(cartState.subtotal)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              'Go to cart →',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.textSecondary,
        side: BorderSide(
          color: onPressed == null
              ? const Color(0xFFE8EAED)
              : const Color(0xFFE8EAED),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdBorder,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelMedium,
      ),
    );
  }
}
