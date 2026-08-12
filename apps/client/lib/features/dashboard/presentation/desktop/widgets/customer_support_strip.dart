import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';

/// Customer support contact line for the desktop chrome.
///
/// [compact] embeds in the MenuBar row (Windows/Linux). When false, renders a
/// full-width strip (used under the native macOS menu).
class CustomerSupportStrip extends StatelessWidget {
  const CustomerSupportStrip({
    super.key,
    this.compact = false,
  });

  /// When true, content-sized only (no full-width border). For MenuBar row.
  final bool compact;

  static const supportPhones = '9333911911 / 080-68195500';

  Widget get _content => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Customer Support :',
            style: DashboardTypography.supportStrip,
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.phone_outlined,
            size: AppIconSize.sm,
            color: AppColors.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            supportPhones,
            style: DashboardTypography.supportStripLink,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('|', style: DashboardTypography.supportStrip),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.support_agent_outlined,
            size: AppIconSize.sm,
            color: AppColors.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            'Get Instant Online Support',
            style: DashboardTypography.supportStripLink,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: _content,
      );
    }

    return Container(
      width: double.infinity,
      height: DashboardSpacing.supportStripHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      alignment: Alignment.center,
      child: _content,
    );
  }
}
