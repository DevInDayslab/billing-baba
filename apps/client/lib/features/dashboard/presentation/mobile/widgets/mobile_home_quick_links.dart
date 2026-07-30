import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

/// Horizontal quick-link shortcuts on the mobile home screen.
class MobileHomeQuickLinks extends StatelessWidget {
  const MobileHomeQuickLinks({
    required this.links,
    super.key,
  });

  final List<MobileHomeQuickLink> links;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK LINKS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < links.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                Expanded(child: _QuickLinkItem(link: links[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickLinkItem extends StatelessWidget {
  const _QuickLinkItem({required this.link});

  final MobileHomeQuickLink link;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: link.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: link.backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(link.icon, color: link.iconColor, size: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            link.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
