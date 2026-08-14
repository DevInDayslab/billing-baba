import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/application/notification_navigation.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/notification_card.dart';
import 'package:flutter/material.dart';

class NotificationGroupedList extends StatelessWidget {
  const NotificationGroupedList({
    required this.notifications,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final List<AppNotification> notifications;
  final ValueChanged<AppNotification> onTap;
  final ValueChanged<AppNotification>? onDelete;

  @override
  Widget build(BuildContext context) {
    final grouped = <NotificationDateGroup, List<AppNotification>>{};
    for (final notification in notifications) {
      final group = NotificationDateGroup.forDate(notification.createdAt);
      grouped.putIfAbsent(group, () => []).add(notification);
    }

    final sections = NotificationDateGroup.values
        .where(grouped.containsKey)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      itemCount: sections.fold<int>(
        0,
        (count, group) => count + 1 + grouped[group]!.length,
      ),
      itemBuilder: (context, index) {
        var cursor = 0;
        for (final group in sections) {
          if (index == cursor) {
            return Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                group.label,
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          cursor++;

          final items = grouped[group]!;
          for (final notification in items) {
            if (index == cursor) {
              return NotificationCard(
                notification: notification,
                onTap: () => onTap(notification),
                onDelete:
                    onDelete == null ? null : () => onDelete!(notification),
              );
            }
            cursor++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
