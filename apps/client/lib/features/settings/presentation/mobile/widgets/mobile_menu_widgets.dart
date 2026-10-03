import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/settings/models/mobile_menu_item.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Tappable navigation card matching [MobileMenuAccordionCard] styling.
class MobileMenuNavCard extends StatelessWidget {
  const MobileMenuNavCard({
    required this.item,
    required this.onTap,
    this.isDestructive = false,
    super.key,
  });

  final MobileMenuItem item;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconBg = isDestructive
        ? AppColors.error.withValues(alpha: 0.08)
        : const Color(0xFFF3F4F8);
    final iconColor = isDestructive ? AppColors.error : const Color(0xFF5D5FEF);

    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: item.subtitle != null ? AppSpacing.md : 18,
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width expandable row matching [MobileMenuLeafTile] styling.
class MobileMenuExpandableTile extends StatelessWidget {
  const MobileMenuExpandableTile({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    super.key,
  });

  final MobileMenuItem item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: item.subtitle != null ? 12 : 14,
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: const Color(0xFF5D5FEF),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      LucideIcons.chevronDown,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1, indent: 72, color: Color(0xFFE8ECF1)),
              child,
            ],
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}

/// Vyapar-style expandable card used for Menu accordion sections.
class MobileMenuAccordionCard extends StatelessWidget {
  const MobileMenuAccordionCard({
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    this.subtitle,
    this.nested = false,
    super.key,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;
  final bool nested;

  static const _chevronBlue = Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: nested ? AppSpacing.sm + 2 : AppSpacing.md,
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      if (nested)
                        Icon(
                          icon,
                          size: 20,
                          color: AppColors.textPrimary,
                        )
                      else
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            size: 22,
                            color: const Color(0xFF5D5FEF),
                          ),
                        ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        LucideIcons.chevronDown,
                        color: _chevronBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Divider(
                    height: 1,
                    color: AppColors.textSecondary.withValues(alpha: 0.12),
                  ),
                ),
                child,
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

/// Tappable leaf row inside a Menu accordion or section list.
class MobileMenuLeafTile extends StatelessWidget {
  const MobileMenuLeafTile({
    required this.item,
    required this.onTap,
    this.dense = false,
    this.showSubtitle = true,
    this.showChevron = true,
    super.key,
  });

  final MobileMenuItem item;
  final VoidCallback onTap;
  final bool dense;
  final bool showSubtitle;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final isVersion = item.action == MobileMenuAction.versionInfo;

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: isVersion ? null : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: dense
                ? 10
                : (showSubtitle && item.subtitle != null ? 12 : 16),
          ),
          child: Row(
            children: [
              if (item.icon != null) ...[
                Container(
                  width: dense ? 36 : 40,
                  height: dense ? 36 : 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: dense ? 20 : 22,
                    color: const Color(0xFF5D5FEF),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (showSubtitle && item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron && !isVersion)
                Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileMenuGroupHeader extends StatelessWidget {
  const MobileMenuGroupHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
