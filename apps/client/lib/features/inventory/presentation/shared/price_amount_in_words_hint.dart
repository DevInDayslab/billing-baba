import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/application/print_amount_words.dart';
import 'package:flutter/material.dart';

/// Helper text below price fields (Indian English amount in words).
class PriceAmountInWordsHint extends StatelessWidget {
  const PriceAmountInWordsHint({
    required this.amount,
    required this.enabled,
    super.key,
  });

  final double amount;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || amount <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        PrintAmountWords.fromDouble(amount),
        style: AppTypography.inter(
          fontSize: AppTypography.bodySmallSize,
          color: AppColors.textSecondary,
          height: 1.35,
        ),
      ),
    );
  }
}
