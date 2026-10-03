import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Notification bell with unread badge for mobile headers.
class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({
    required this.onTap,
    this.unreadCount = 0,
    this.icon = LucideIcons.bell,
    super.key,
  });

  final VoidCallback? onTap;
  final int unreadCount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final label = unreadCount > 99 ? '99+' : unreadCount.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          color: AppColors.textPrimary,
          iconSize: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
