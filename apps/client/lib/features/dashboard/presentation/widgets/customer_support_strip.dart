import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';

/// Vyapar-style customer support strip shown above the app header.
class CustomerSupportStrip extends StatelessWidget {
  const CustomerSupportStrip({super.key});

  static const supportPhones = '9333911911 / 080-68195500';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: DashboardSpacing.supportStripHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Customer Support :',
            style: DashboardTypography.supportStrip,
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.phone_outlined,
            size: 12,
            color: AppColors.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            supportPhones,
            style: DashboardTypography.supportStripLink,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('|', style: DashboardTypography.supportStrip),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.support_agent_outlined,
            size: 12,
            color: AppColors.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Get Instant Online Support',
            style: DashboardTypography.supportStripLink,
          ),
        ],
      ),
    );
  }
}
