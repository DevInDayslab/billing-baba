import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:billing_baba/features/notifications/application/notification_providers.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/notification_icon_button.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared mobile app bar with business identity, notifications, and settings.
///
/// Pass [title] to override the business header. Pass [actions] for page-specific
/// trailing widgets (rendered before notification/settings).
class MobileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MobileAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.onBack,
    this.showBusinessHeader = true,
    this.onBusinessTap,
    this.showNotification = true,
    this.onNotificationTap,
    this.showSettings = true,
    this.onSettingsTap,
    this.actions,
    this.backgroundColor,
    this.elevation,
  });

  final String? title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showBusinessHeader;
  final VoidCallback? onBusinessTap;
  final bool showNotification;
  final VoidCallback? onNotificationTap;
  final bool showSettings;
  final VoidCallback? onSettingsTap;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;

  static const double _toolbarHeight = kToolbarHeight;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(sidebarBusinessProvider);
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      systemOverlayStyle: AppTheme.lightSystemUi,
      leading: _buildLeading(context, business),
      title: _buildTitle(context, theme, business),
      actions: _buildActions(ref),
    );
  }

  Widget? _buildLeading(BuildContext context, SidebarBusiness business) {
    if (showBackButton) {
      return IconButton(
        tooltip: 'Back',
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: onBack ?? () => context.pop(),
      );
    }

    if (title != null || !showBusinessHeader) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: InkWell(
        onTap: onBusinessTap,
        borderRadius: AppRadius.mdBorder,
        child: BusinessAvatar(
          name: business.name,
          seed: business.seed,
          logoUrl: business.logoUrl,
        ),
      ),
    );
  }

  Widget? _buildTitle(
    BuildContext context,
    ThemeData theme,
    SidebarBusiness business,
  ) {
    if (title != null) {
      return Text(
        title!,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (!showBusinessHeader) return null;

    return InkWell(
      onTap: onBusinessTap,
      borderRadius: AppRadius.mdBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            if (showBackButton) ...[
              BusinessAvatar(
                name: business.name,
                seed: business.seed,
                diameter: 32,
                logoUrl: business.logoUrl,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    business.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Business',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onBusinessTap != null)
              Icon(
                LucideIcons.chevronDown,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                size: AppIconSize.lg,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(WidgetRef ref) {
    final unreadCount = ref.watch(notificationUnreadCountProvider).value ?? 0;
    final trailing = <Widget>[
      ...?actions,
      if (showNotification && AppConfig.showMobileNotifications)
        NotificationIconButton(
          onTap: onNotificationTap,
          unreadCount: unreadCount,
          icon: LucideIcons.bell,
        ),
      if (showSettings)
        MobileIconActionButton(
          icon: LucideIcons.settings,
          tooltip: 'Settings',
          onPressed: onSettingsTap,
        ),
      const SizedBox(width: AppSpacing.xs),
    ];
    return trailing;
  }
}
