import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Quick-link shortcut model for the mobile items screen.
class ItemQuickLink {
  const ItemQuickLink({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.backgroundColor = const Color(0xFFE3F2FD),
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
}

/// Quick Links card row on the mobile items screen.
class ItemQuickLinks extends StatelessWidget {
  const ItemQuickLinks({
    required this.links,
    super.key,
  });

  final List<ItemQuickLink> links;

  static const _title = 'Quick Links';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: MobileCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(AppSpacing.md),
            Row(
              children: [
                for (var i = 0; i < links.length; i++) ...[
                  if (i > 0) const Gap(AppSpacing.sm),
                  Expanded(child: _QuickLinkButton(link: links[i])),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinkButton extends StatelessWidget {
  const _QuickLinkButton({required this.link});

  final ItemQuickLink link;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: link.onTap,
      borderRadius: AppRadius.mdBorder,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: link.backgroundColor,
              borderRadius: AppRadius.mdBorder,
            ),
            child: Icon(link.icon, color: link.iconColor, size: 24),
          ),
          const Gap(AppSpacing.sm),
          Text(
            link.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
