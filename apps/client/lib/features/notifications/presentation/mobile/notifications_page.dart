import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/presentation/widgets/notifications_center_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile notification center.
class MobileNotificationsPage extends ConsumerWidget {
  const MobileNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTypography.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const [NotificationsCenterActions()],
      ),
      body: const NotificationsCenterView(requestPermissionOnOpen: true),
    );
  }
}
