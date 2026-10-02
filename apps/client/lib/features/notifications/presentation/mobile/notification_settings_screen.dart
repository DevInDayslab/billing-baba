import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/application/notification_providers.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile notification preferences screen.
class MobileNotificationSettingsScreen extends ConsumerWidget {
  const MobileNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(
      notificationPreferencesControllerProvider,
    );
    final permissionAsync = ref.watch(notificationPermissionStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (preferences) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _SettingsCard(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: Text(
                      permissionAsync.value == true
                          ? 'Permission granted'
                          : 'Tap to enable system notifications',
                    ),
                    value: preferences.enabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) async {
                      if (value) {
                        final granted = await ref
                            .read(notificationPermissionStateProvider.notifier)
                            .request(force: true);
                        if (!granted) return;
                      }
                      await ref
                          .read(
                            notificationPreferencesControllerProvider.notifier,
                          )
                          .savePreferences(
                            preferences.copyWith(enabled: value),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _preferenceSwitch(
                    ref: ref,
                    preferences: preferences,
                    title: 'Reminder Notifications',
                    read: (current) => current.reminderNotifications,
                    write: (current, value) =>
                        current.copyWith(reminderNotifications: value),
                  ),
                  _preferenceSwitch(
                    ref: ref,
                    preferences: preferences,
                    title: 'Sync Notifications',
                    read: (current) => current.syncNotifications,
                    write: (current, value) =>
                        current.copyWith(syncNotifications: value),
                  ),
                  _preferenceSwitch(
                    ref: ref,
                    preferences: preferences,
                    title: 'Backup Notifications',
                    read: (current) => current.backupNotifications,
                    write: (current, value) =>
                        current.copyWith(backupNotifications: value),
                  ),
                  _preferenceSwitch(
                    ref: ref,
                    preferences: preferences,
                    title: 'Subscription Notifications',
                    read: (current) => current.subscriptionNotifications,
                    write: (current, value) =>
                        current.copyWith(subscriptionNotifications: value),
                  ),
                  _preferenceSwitch(
                    ref: ref,
                    preferences: preferences,
                    title: 'Low Stock Notifications',
                    read: (current) => current.lowStockNotifications,
                    write: (current, value) =>
                        current.copyWith(lowStockNotifications: value),
                  ),
                  _preferenceSwitch(
                    ref: ref,
                    preferences: preferences,
                    title: 'Sound',
                    read: (current) => current.sound,
                    write: (current, value) => current.copyWith(sound: value),
                  ),
                  _preferenceSwitch(
                    ref: ref,
                    preferences: preferences,
                    title: 'Vibration',
                    read: (current) => current.vibration,
                    write: (current, value) =>
                        current.copyWith(vibration: value),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _preferenceSwitch({
    required WidgetRef ref,
    required NotificationPreferences preferences,
    required String title,
    required bool Function(NotificationPreferences current) read,
    required NotificationPreferences Function(
      NotificationPreferences current,
      bool value,
    )
    write,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: read(preferences),
      activeThumbColor: AppColors.primary,
      onChanged: (value) async {
        if (value) {
          final granted = await ref
              .read(notificationPermissionStateProvider.notifier)
              .request(force: true);
          if (!granted) return;
        }
        await ref
            .read(notificationPreferencesControllerProvider.notifier)
            .savePreferences(write(preferences, value));
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
