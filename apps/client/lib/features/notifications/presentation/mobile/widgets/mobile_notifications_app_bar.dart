import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/mobile_notifications_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// White centered-title app bar used on the notifications screen.
class MobileNotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MobileNotificationsAppBar({
    super.key,
    this.title = 'Notifications',
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MobileNotificationsTheme.headerBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: onBack ?? () => context.pop(),
      ),
      title: Text(
        title,
        style: AppTypography.inter(
          fontSize: MobileNotificationsTheme.appBarTitleSize,
          fontWeight: MobileNotificationsTheme.appBarTitleWeight,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
