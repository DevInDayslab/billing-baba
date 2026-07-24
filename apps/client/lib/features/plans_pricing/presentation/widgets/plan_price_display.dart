import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlanPriceDisplay extends StatelessWidget {
  const PlanPriceDisplay({
    required this.pricing,
    this.compact = false,
    this.loading = false,
    super.key,
  });

  final PlanPricing pricing;
  final bool compact;
  final bool loading;

  static final _priceFormat = NumberFormat('#,##0.##', 'en_IN');

  String _formatPrice(double price) => '₹${_priceFormat.format(price)}';

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatPrice(0),
            style: TextStyle(
              fontSize: compact ? 20 : 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Only ${_formatPrice(0)} per month',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    final showOriginal = pricing.originalPrice > pricing.discountedPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (showOriginal) ...[
                Text(
                  _formatPrice(pricing.originalPrice),
                  style: TextStyle(
                    fontSize: compact ? 13 : 15,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                _formatPrice(pricing.discountedPrice),
                style: TextStyle(
                  fontSize: compact ? 20 : 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Only ${_formatPrice(pricing.perMonthPrice)} per month',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 12 : 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
