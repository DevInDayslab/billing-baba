import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/application/subscription_order_pricing.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/utils/subscription_price_format.dart';
import 'package:flutter/material.dart';

class OrderPriceBreakdown extends StatelessWidget {
  const OrderPriceBreakdown({
    required this.pricing,
    super.key,
  });

  final SubscriptionOrderPricing pricing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: formatSubscriptionPrice(pricing.subtotal),
          ),
          if (pricing.planDiscount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Plan discount',
              value: '- ${formatSubscriptionPrice(pricing.planDiscount)}',
              valueColor: const Color(0xFF2E7D32),
            ),
          ],
          if (pricing.couponDiscount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Coupon discount',
              value: '- ${formatSubscriptionPrice(pricing.couponDiscount)}',
              valueColor: const Color(0xFF2E7D32),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'GST (18%)',
            value: formatSubscriptionPrice(pricing.gstAmount),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(height: 1),
          ),
          _SummaryRow(
            label: 'Total',
            value: formatSubscriptionPrice(pricing.total),
            isEmphasized: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isEmphasized ? 15 : 13,
            fontWeight: isEmphasized ? FontWeight.w600 : FontWeight.normal,
            color: isEmphasized ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isEmphasized ? 18 : 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
