import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/application/notification_navigation.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete notification?'),
        content: const Text('This notification will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasRoute = NotificationNavigation.resolveRoute(notification) != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: InkWell(
          onTap: onTap,
          onLongPress: onDelete == null ? null : () => _confirmDelete(context),
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: AppColors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      notification.type.icon,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTypography.inter(
                                  fontSize: 14,
                                  fontWeight: notification.read
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (!notification.read)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(
                                  left: AppSpacing.sm,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: AppTypography.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatNotificationTime(notification.createdAt),
                          style: AppTypography.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasRoute) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      LucideIcons.chevronRight,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
