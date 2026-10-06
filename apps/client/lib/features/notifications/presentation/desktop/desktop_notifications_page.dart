import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/notifications/application/notification_providers.dart';
import 'package:billing_baba/features/notifications/presentation/widgets/notifications_center_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Desktop notification history (dashboard tab or full route).
class DesktopNotificationsPage extends ConsumerWidget {
  const DesktopNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationUnreadCountProvider).value ?? 0;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: DashboardTypography.cardTitle,
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          unreadCount == 1
                              ? '1 unread notification'
                              : '$unreadCount unread notifications',
                          style: AppTypography.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const NotificationsCenterActions(),
              ],
            ),
          ),
          const Expanded(
            child: NotificationsCenterView(),
          ),
        ],
      ),
    );
  }
}
