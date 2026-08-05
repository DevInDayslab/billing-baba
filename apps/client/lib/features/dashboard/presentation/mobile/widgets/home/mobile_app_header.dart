import 'package:billing_baba/core/sync/application/sync_ui_state.dart';
import 'package:billing_baba/core/sync/application/sync_ui_state_provider.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Compact mobile header — profile, business selector, sync row, actions.
class MobileAppHeader extends ConsumerWidget {
  const MobileAppHeader({
    super.key,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onBusinessTap,
    this.showWelcome = true,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBusinessTap;
  final bool showWelcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(sidebarBusinessProvider);
    final userName = ref.watch(authProvider).session?.user.name ?? 'User';
    final firstName = userName.split(' ').first;
    final sync = ref.watch(syncUiStateProvider);
    final manualState = ref.watch(manualSyncVisualStateProvider);
    final nowLabel = DateFormat('hh:mm a, d MMM yyyy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onBusinessTap,
                borderRadius: BorderRadius.circular(22),
                child: BusinessAvatar(
                  name: userName,
                  seed: business.seed,
                  diameter: 44,
                  logoUrl: business.logoUrl,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: InkWell(
                  onTap: onBusinessTap,
                  borderRadius: AppRadius.smBorder,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showWelcome)
                        Text(
                          'Welcome, $firstName 👋',
                          style: AppTypography.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              business.name,
                              style: AppTypography.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(Icons.notifications_none_rounded),
                color: AppColors.textPrimary,
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
              IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(Icons.settings_outlined),
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
          const SizedBox(height: 2),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sync_rounded,
                  size: 11,
                  color: AppColors.textSecondary.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _syncLabel(sync, manualState),
                    style: AppTypography.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  ' | ',
                  style: AppTypography.inter(
                    fontSize: 10.5,
                    color: AppColors.textSecondary.withValues(alpha: 0.45),
                  ),
                ),
                Flexible(
                  child: Text(
                    nowLabel,
                    style: AppTypography.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _onlineColor(sync),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _syncLabel(
    SyncUiSnapshot sync,
    ManualSyncVisualState manualState,
  ) {
    if (manualState == ManualSyncVisualState.syncing) {
      return 'Syncing…';
    }
    if (manualState == ManualSyncVisualState.failed) {
      return 'Sync failed';
    }
    final last = sync.lastSyncTime;
    if (last == null) return 'Not synced yet';
    final diff = DateTime.now().difference(last);
    if (diff.inMinutes < 1) return 'Last sync just now';
    if (diff.inMinutes < 60) return 'Last sync ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Last sync ${diff.inHours} hr ago';
    return 'Last sync ${DateFormat('d MMM').format(last)}';
  }

  static Color _onlineColor(SyncUiSnapshot sync) {
    return switch (sync.connectivity) {
      SyncConnectivityStatus.online => AppColors.success,
      SyncConnectivityStatus.offline => AppColors.warning,
      _ => AppColors.textSecondary,
    };
  }
}
