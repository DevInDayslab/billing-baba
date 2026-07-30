import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/review_order_summary_input.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/utils/subscription_price_format.dart';
import 'package:flutter/material.dart';

class SelectedPlanSummaryCard extends StatelessWidget {
  const SelectedPlanSummaryCard({
    required this.input,
    super.key,
  });

  final ReviewOrderSummaryInput input;

  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);
  static const _platinumBg = Color(0xFFF3F0FF);
  static const _platinumIconBg = Color(0xFFEDE7F6);
  static const _platinumIconColor = Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context) {
    final isGold = input.planType == SubscriptionPlanType.gold;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isGold ? AppColors.surface : _platinumBg,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: isGold ? Colors.grey.shade300 : const Color(0xFFB39DDB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isGold ? _goldIconBg : _platinumIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGold ? Icons.change_history : Icons.flag_outlined,
                  color: isGold ? _goldIconColor : _platinumIconColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      input.planName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      input.durationLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(label: 'Duration', value: input.platformDurationLabel),
          _DetailRow(label: 'License Type', value: input.licenseType),
          _DetailRow(
            label: 'Device Access',
            value: '${input.deviceLimit} devices',
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (input.discountAmount > 0)
                Text(
                  formatSubscriptionPrice(input.originalPrice),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                formatSubscriptionPrice(input.discountedPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
