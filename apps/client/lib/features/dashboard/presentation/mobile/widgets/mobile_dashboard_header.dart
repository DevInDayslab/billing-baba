import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vyapar-style dashboard header: logo, business name, notification & settings.
class MobileDashboardHeader extends ConsumerWidget {
  const MobileDashboardHeader({
    super.key,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onBusinessTap,
    this.notificationBadgeCount = 0,
    this.settingsBadgeVisible = true,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBusinessTap;
  final int notificationBadgeCount;
  final bool settingsBadgeVisible;

  static const accentPurple = Color(0xFF5D5FEF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(sidebarBusinessProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBusinessTap,
            borderRadius: BorderRadius.circular(22),
            child: BusinessAvatar(
              name: business.name,
              seed: business.seed,
              diameter: 44,
              logoUrl: business.logoUrl,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: InkWell(
              onTap: onBusinessTap,
              borderRadius: AppRadius.mdBorder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        business.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _HeaderIconButton(
            icon: Icons.notifications_none_rounded,
            badgeCount: notificationBadgeCount,
            onTap: onNotificationTap,
          ),
          const SizedBox(width: AppSpacing.sm),
          _HeaderIconButton(
            icon: Icons.settings_outlined,
            showDotBadge: settingsBadgeVisible,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
    this.showDotBadge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;
  final bool showDotBadge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 24, color: AppColors.textPrimary),
            if (badgeCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else if (showDotBadge)
              const Positioned(
                right: 0,
                top: 0,
                child: _DotBadge(),
              ),
          ],
        ),
      ),
    );
  }
}

class _DotBadge extends StatelessWidget {
  const _DotBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 1.5),
      ),
    );
  }
}
