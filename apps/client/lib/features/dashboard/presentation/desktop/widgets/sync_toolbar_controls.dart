import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/sync/application/sync_activity_log.dart';
import 'package:billing_baba/core/sync/application/sync_ui_state.dart';
import 'package:billing_baba/core/sync/application/sync_ui_state_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SyncNowToolbarButton extends ConsumerWidget {
  const SyncNowToolbarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(syncUiStateProvider);
    final tooltip = _tooltipFor(snapshot.manualSyncState, snapshot.lastSyncTime);

    return _TopBarIconButton(
      tooltip: tooltip,
      onPressed: snapshot.manualSyncState == ManualSyncVisualState.syncing
          ? null
          : () => ref.read(manualSyncVisualStateProvider.notifier).syncNow(),
      child: _ManualSyncIcon(state: snapshot.manualSyncState),
    );
  }

  String _tooltipFor(ManualSyncVisualState state, DateTime? lastSync) {
    return switch (state) {
      ManualSyncVisualState.syncing => 'Synchronizing...',
      ManualSyncVisualState.completed => 'Last synced just now',
      ManualSyncVisualState.failed => 'Sync failed',
      ManualSyncVisualState.idle => 'Sync now',
    };
  }
}

class CloudSyncToolbarButton extends ConsumerStatefulWidget {
  const CloudSyncToolbarButton({super.key});

  @override
  ConsumerState<CloudSyncToolbarButton> createState() =>
      _CloudSyncToolbarButtonState();
}

class _CloudSyncToolbarButtonState extends ConsumerState<CloudSyncToolbarButton>
    with SingleTickerProviderStateMixin {
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  var _open = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _pulseController.dispose();
    super.dispose();
  }

  void _onCloudPressed() {
    if (AppConfig.showSyncDiagnostics) {
      _toggleMenu();
      return;
    }
    unawaited(ref.read(manualSyncVisualStateProvider.notifier).syncNow());
  }

  void _toggleMenu() {
    if (_open) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, AppSpacing.xs),
            child: SyncStatusDropdownPanel(onClose: _removeOverlay),
          ),
        ],
      ),
    );
    overlay.insert(_overlay!);
    setState(() => _open = true);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    if (_open && mounted) {
      setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(syncUiStateProvider);
    final isAnimating = snapshot.cloudState == SyncCloudVisualState.syncing;
    if (isAnimating) {
      if (!_pulseController.isAnimating) {
        unawaited(_pulseController.repeat());
      }
    } else if (_pulseController.isAnimating) {
      _pulseController
        ..stop()
        ..reset();
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: _TopBarIconButton(
        tooltip: _cloudTooltip(snapshot),
        onPressed: _onCloudPressed,
        child: _CloudSyncIcon(
          state: snapshot.cloudState,
          pendingCount: snapshot.queueSize,
          pulse: _pulseController,
        ),
      ),
    );
  }

  String _cloudTooltip(SyncUiSnapshot snapshot) {
    if (!AppConfig.showSyncDiagnostics) {
      return _productionTooltip(snapshot);
    }

    return switch (snapshot.cloudState) {
      SyncCloudVisualState.synced => _syncedTooltip(snapshot),
      SyncCloudVisualState.syncing => _syncingTooltip(snapshot),
      SyncCloudVisualState.offline => _offlineTooltip(snapshot),
      SyncCloudVisualState.pending => _pendingTooltip(snapshot),
      SyncCloudVisualState.error => _errorTooltip(snapshot),
    };
  }

  String _productionTooltip(SyncUiSnapshot snapshot) {
    final status = switch (snapshot.cloudState) {
      SyncCloudVisualState.synced => 'Synced',
      SyncCloudVisualState.syncing => 'Syncing',
      SyncCloudVisualState.offline => 'Offline',
      SyncCloudVisualState.pending => 'Pending changes',
      SyncCloudVisualState.error => 'Sync failed',
    };
    final last = _formatLastSync(snapshot.lastSyncTime);
    final pending = snapshot.queueSize;
    return 'Status: $status\n'
        'Last sync: $last\n'
        'Pending changes: $pending\n'
        'Click to sync now';
  }

  String _syncedTooltip(SyncUiSnapshot snapshot) {
    final last = _formatLastSync(snapshot.lastSyncTime);
    return 'Status: Synced\n'
        'Last sync: $last\n'
        'Pending rows: ${snapshot.pendingRows}\n'
        'Pending commands: ${snapshot.pendingCommands}\n'
        'Device: ${snapshot.deviceName}\n'
        'Business: ${snapshot.businessName}';
  }

  String _syncingTooltip(SyncUiSnapshot snapshot) {
    return '${snapshot.currentOperation ?? 'Synchronizing...'}\n'
        '${snapshot.progress ?? ''}\n'
        'Queue: ${snapshot.queueSize}';
  }

  String _offlineTooltip(SyncUiSnapshot snapshot) {
    return 'Offline\n'
        'Waiting for connection\n'
        'Pending uploads: ${snapshot.queueSize}';
  }

  String _pendingTooltip(SyncUiSnapshot snapshot) {
    return 'Pending synchronization\n'
        'Rows waiting: ${snapshot.pendingRows}\n'
        'Commands waiting: ${snapshot.pendingCommands}';
  }

  String _errorTooltip(SyncUiSnapshot snapshot) {
    return 'Synchronization failed\n'
        '${snapshot.lastError ?? 'Unknown error'}\n'
        'Retry available';
  }

  String _formatLastSync(DateTime? time) {
    if (time == null) return 'Never';
    return DateFormat.jm().format(time.toLocal());
  }
}

class SyncStatusDropdownPanel extends ConsumerWidget {
  const SyncStatusDropdownPanel({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(syncUiStateProvider);
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: AppRadius.mdBorder,
      color: AppColors.surface,
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Synchronization',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(label: 'Status', value: _statusLabel(snapshot)),
              _InfoRow(label: 'Business', value: snapshot.businessName),
              _InfoRow(label: 'Device', value: snapshot.deviceName),
              _InfoRow(
                label: 'Last Sync',
                value: _formatLastSync(snapshot.lastSyncTime),
              ),
              _InfoRow(
                label: 'Cursor',
                value: _shortCursor(snapshot.pullCursor),
              ),
              _InfoRow(
                label: 'Pending Rows',
                value: '${snapshot.pendingRows}',
              ),
              _InfoRow(
                label: 'Pending Commands',
                value: '${snapshot.pendingCommands}',
              ),
              _InfoRow(
                label: 'Current Operation',
                value: snapshot.currentOperation ?? 'Idle',
              ),
              const Divider(height: AppSpacing.lg),
              Text(
                'Recent Activity',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (snapshot.recentActivity.isEmpty)
                const Text(
                  'No recent sync activity',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                )
              else
                ...snapshot.recentActivity.take(6).map(_activityTile),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: snapshot.manualSyncState ==
                              ManualSyncVisualState.syncing
                          ? null
                          : () {
                              onClose();
                              unawaited(
                                ref
                                    .read(manualSyncVisualStateProvider.notifier)
                                    .syncNow(),
                              );
                            },
                      child: const Text('Sync Now'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        onClose();
                        unawaited(context.push(AppRoutes.developerDiagnostics));
                      },
                      child: const Text('View Logs'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(SyncUiSnapshot snapshot) {
    return switch (snapshot.cloudState) {
      SyncCloudVisualState.synced => 'Synced',
      SyncCloudVisualState.syncing => 'Syncing',
      SyncCloudVisualState.offline => 'Offline',
      SyncCloudVisualState.pending => 'Pending',
      SyncCloudVisualState.error => 'Error',
    };
  }

  String _formatLastSync(DateTime? time) {
    if (time == null) return 'Never';
    return DateFormat.jm().format(time.toLocal());
  }

  String _shortCursor(String? cursor) {
    if (cursor == null || cursor.isEmpty) return '—';
    if (cursor.length <= 12) return cursor;
    return '${cursor.substring(0, 8)}…';
  }

  Widget _activityTile(SyncActivityEntry entry) {
    final icon = switch (entry.kind) {
      SyncActivityKind.success => Icons.check_circle_outline,
      SyncActivityKind.warning => Icons.warning_amber_outlined,
      SyncActivityKind.error => Icons.error_outline,
      SyncActivityKind.info => Icons.info_outline,
    };
    final color = switch (entry.kind) {
      SyncActivityKind.success => Colors.green.shade700,
      SyncActivityKind.warning => Colors.orange.shade700,
      SyncActivityKind.error => AppColors.error,
      SyncActivityKind.info => AppColors.textSecondary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              entry.message,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualSyncIcon extends StatelessWidget {
  const _ManualSyncIcon({required this.state});

  final ManualSyncVisualState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ManualSyncVisualState.syncing => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ManualSyncVisualState.completed => Icon(
          Icons.check,
          size: 20,
          color: Colors.green.shade600,
        ),
      ManualSyncVisualState.failed => Icon(
          Icons.warning_amber_rounded,
          size: 20,
          color: Colors.orange.shade700,
        ),
      ManualSyncVisualState.idle => const Icon(
          Icons.refresh,
          size: 20,
          color: AppColors.textSecondary,
        ),
    };
  }
}

class _CloudSyncIcon extends StatelessWidget {
  const _CloudSyncIcon({
    required this.state,
    required this.pendingCount,
    required this.pulse,
  });

  final SyncCloudVisualState state;
  final int pendingCount;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (state) {
      SyncCloudVisualState.synced => (Icons.cloud_done_outlined, Colors.green.shade600),
      SyncCloudVisualState.syncing => (Icons.cloud_sync_outlined, AppColors.primary),
      SyncCloudVisualState.offline => (Icons.cloud_off_outlined, AppColors.textSecondary),
      SyncCloudVisualState.pending => (Icons.cloud_upload_outlined, Colors.orange.shade700),
      SyncCloudVisualState.error => (Icons.cloud_off_outlined, AppColors.error),
    };

    Widget iconWidget = Icon(icon, size: 20, color: color);
    if (state == SyncCloudVisualState.syncing) {
      iconWidget = FadeTransition(
        opacity: Tween<double>(begin: 0.55, end: 1).animate(
          CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
        ),
        child: iconWidget,
      );
    }

    if (state == SyncCloudVisualState.pending && pendingCount > 0) {
      return Badge(
        label: Text(
          pendingCount > 99 ? '99+' : '$pendingCount',
          style: const TextStyle(fontSize: 10),
        ),
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: child,
      onPressed: onPressed,
      padding: const EdgeInsets.all(AppSpacing.sm),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      visualDensity: VisualDensity.compact,
    );
  }
}
