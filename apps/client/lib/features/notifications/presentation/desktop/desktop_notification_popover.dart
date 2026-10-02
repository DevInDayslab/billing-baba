import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/notifications/application/notification_navigation.dart'
    show NotificationNavigation, formatNotificationTime;
import 'package:billing_baba/features/notifications/application/notification_providers.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/widgets/notification_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Dashboard bell that opens an anchored notification popover (desktop).
class DesktopNotificationBellAnchor extends ConsumerStatefulWidget {
  const DesktopNotificationBellAnchor({super.key});

  @override
  ConsumerState<DesktopNotificationBellAnchor> createState() =>
      _DesktopNotificationBellAnchorState();
}

class _DesktopNotificationBellAnchorState
    extends ConsumerState<DesktopNotificationBellAnchor> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry == null) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {});
  }

  void _togglePopover() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showPopover();
    setState(() {});
  }

  void _showPopover() {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 4),
              child: _DesktopNotificationPopoverPanel(
                onClose: _removeOverlay,
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(notificationUnreadCountProvider).value ?? 0;
    final isOpen = _overlayEntry != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: NotificationIconButton(
        onTap: _togglePopover,
        unreadCount: unreadCount,
        icon: isOpen
            ? Icons.notifications_rounded
            : Icons.notifications_none_rounded,
      ),
    );
  }
}

class _DesktopNotificationPopoverPanel extends ConsumerStatefulWidget {
  const _DesktopNotificationPopoverPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<_DesktopNotificationPopoverPanel> createState() =>
      _DesktopNotificationPopoverPanelState();
}

class _DesktopNotificationPopoverPanelState
    extends ConsumerState<_DesktopNotificationPopoverPanel> {
  static const _panelWidth = 380.0;
  static const _panelMaxHeight = 440.0;

  var _actionsMenuOpen = false;

  Future<void> _onNotificationTap(AppNotification notification) async {
    await ref
        .read(notificationActionsProvider.notifier)
        .markRead(notification.id);
    widget.onClose();
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

  void _closeActionsMenu() => setState(() => _actionsMenuOpen = false);

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.none,
      child: SizedBox(
        width: _panelWidth,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _panelMaxHeight),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: AppRadius.mdBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Notifications',
                              style: AppTypography.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(
                              () => _actionsMenuOpen = !_actionsMenuOpen,
                            ),
                            icon: const Icon(Icons.more_vert_rounded),
                            color: AppColors.textPrimary,
                            iconSize: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    Expanded(
                      child: notificationsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text(error.toString()),
                          ),
                        ),
                        data: (notifications) {
                          if (notifications.isEmpty) {
                            return const _NotificationPopoverEmptyState();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.sm,
                              AppSpacing.md,
                              AppSpacing.md,
                            ),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return _NotificationPopoverTile(
                                notification: notification,
                                onTap: () => _onNotificationTap(notification),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_actionsMenuOpen)
                Positioned(
                  top: 44,
                  right: AppSpacing.sm,
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    color: AppColors.surface,
                    borderRadius: AppRadius.smBorder,
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PopoverMenuItem(
                            label: 'Mark all as read',
                            onTap: () async {
                              _closeActionsMenu();
                              await ref
                                  .read(notificationActionsProvider.notifier)
                                  .markAllRead();
                            },
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _PopoverMenuItem(
                            label: 'Clear all',
                            onTap: () async {
                              _closeActionsMenu();
                              await _confirmDeleteAll();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopoverMenuItem extends StatelessWidget {
  const _PopoverMenuItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _NotificationPopoverEmptyState extends StatelessWidget {
  const _NotificationPopoverEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 32,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Notifications yet!',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Stay tuned! Notifications about your activity will show up here.',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationPopoverTile extends StatelessWidget {
  const _NotificationPopoverTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.read
          ? Colors.transparent
          : AppColors.primary.withValues(alpha: 0.04),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                notification.type.icon,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTypography.inter(
                        fontSize: 13,
                        fontWeight: notification.read
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: AppTypography.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatNotificationTime(notification.createdAt),
                      style: AppTypography.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: AppSpacing.xs, top: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
