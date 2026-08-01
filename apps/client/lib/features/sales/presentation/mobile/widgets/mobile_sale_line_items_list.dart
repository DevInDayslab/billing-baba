import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Compact line-item row for mobile sale/purchase create forms.
class MobileTransactionLineTile extends StatelessWidget {
  const MobileTransactionLineTile({
    required this.name,
    required this.qtyLabel,
    required this.amountLabel,
    required this.onRemove,
    super.key,
    this.subtitle,
  });

  final String name;
  final String qtyLabel;
  final String amountLabel;
  final String? subtitle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle ?? qtyLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                amountLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove item',
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats currency amounts consistently for mobile transaction line tiles.
abstract final class MobileTransactionLineFormat {
  static final currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String amount(double value) => currency.format(value);

  static String qty({
    required double qty,
    required String unit,
  }) {
    final qtyText = qty == qty.roundToDouble()
        ? qty.toStringAsFixed(0)
        : qty.toStringAsFixed(2);
    final unitLabel = unit.trim();
    if (unitLabel.isEmpty || unitLabel == 'NONE') {
      return 'Qty: $qtyText';
    }
    return 'Qty: $qtyText $unitLabel';
  }
}
