import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/application/notification_navigation.dart';
import 'package:billing_baba/features/notifications/application/notification_providers.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_type.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/notification_empty_state.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/notification_filter_chips.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/notification_grouped_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile notification center.
class MobileNotificationsPage extends ConsumerStatefulWidget {
  const MobileNotificationsPage({super.key});

  @override
  ConsumerState<MobileNotificationsPage> createState() =>
      _MobileNotificationsPageState();
}

class _MobileNotificationsPageState
    extends ConsumerState<MobileNotificationsPage> {
  var _requestedPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeRequestPermission();
    });
  }

  Future<void> _maybeRequestPermission() async {
    if (_requestedPermission) return;
    _requestedPermission = true;

    final service = await ref.read(notificationServiceProvider.future);
    if (service.permissionDenied || service.permissionAsked) return;

    if (!mounted) return;
    await _showPermissionDialog();
  }

  Future<void> _showPermissionDialog() async {
    final enable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable notifications'),
        content: const Text(
          'Enable notifications to receive business alerts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (enable == true) {
      await ref
          .read(notificationPermissionStateProvider.notifier)
          .request(force: true);
    } else {
      await ref.read(notificationPermissionStateProvider.notifier).dismiss();
    }
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    await ref
        .read(notificationActionsProvider.notifier)
        .markRead(notification.id);
    if (!mounted) return;
    NotificationNavigation.navigate(GoRouter.of(context), notification);
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(notificationActionsProvider.notifier).deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final filterAsync = ref.watch(notificationFilterControllerProvider);

    final filter = filterAsync.value ?? NotificationFilter.appNotifications;

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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              switch (value) {
                case 'mark_all':
                  await ref
                      .read(notificationActionsProvider.notifier)
                      .markAllRead();
                case 'clear_all':
                  await _confirmDeleteAll();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'mark_all',
                child: Text('Mark all as read'),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NotificationFilterTabs(
            selected: filter,
            onSelected: (value) => ref
                .read(notificationFilterControllerProvider.notifier)
                .setFilter(value),
          ),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (notifications) {
                final filtered = notifications
                    .where((item) => item.matchesFilter(filter))
                    .toList();

                if (filtered.isEmpty) {
                  return const NotificationEmptyState();
                }

                return NotificationGroupedList(
                  notifications: filtered,
                  onTap: _handleNotificationTap,
                  onDelete: (notification) => ref
                      .read(notificationActionsProvider.notifier)
                      .delete(notification.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
