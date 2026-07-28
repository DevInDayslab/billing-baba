import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/mobile_notifications_theme.dart';
import 'package:flutter/material.dart';

/// Centered bell empty state for the notifications screen body.
class MobileNotificationsEmptyState extends StatelessWidget {
  const MobileNotificationsEmptyState({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MobileNotificationsTheme.emptyCircleSize,
              height: MobileNotificationsTheme.emptyCircleSize,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: MobileNotificationsTheme.emptyIconSize,
                color: MobileNotificationsTheme.emptyIcon,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: MobileNotificationsTheme.emptyMessageSize,
                fontWeight: FontWeight.w400,
                color: MobileNotificationsTheme.emptyMessage,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
