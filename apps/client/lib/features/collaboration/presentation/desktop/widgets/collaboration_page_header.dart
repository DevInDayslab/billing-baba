import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_error_mapper.dart';
import 'package:billing_baba/features/collaboration/application/sync_share_live_sync_service.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/permissions/permission_gate.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/sync_confirmation_dialogs.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';

class CollaborationPageHeader extends StatelessWidget {
  const CollaborationPageHeader({
    required this.onInviteUser,
    required this.onRefresh,
    required this.onDisableSync,
    required this.onLogout,
    this.isRefreshing = false,
    super.key,
  });

  final VoidCallback onInviteUser;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onDisableSync;
  final Future<void> Function() onLogout;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Sync & Share',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        PermissionGate(
          module: PermissionModule.syncSettings,
          action: PermissionAction.share,
          child: FilledButton.icon(
            onPressed: onInviteUser,
            icon: const Icon(Icons.person_add_outlined, size: 18),
            label: const Text('Invite User'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Tooltip(
          message: 'Refresh',
          child: IconButton(
            onPressed: isRefreshing ? null : () => _handleManualRefresh(context),
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 20),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        SalesActionMenuButton(
          items: [
            SalesActionMenuItem(
              label: 'Disable Sync',
              onSelected: () async {
                final confirmed = await showDisableSyncDialog(context);
                if (confirmed != true || !context.mounted) return;
                await _runAction(
                  context,
                  onDisableSync,
                  successMessage: 'Cloud sync disabled',
                );
              },
            ),
            SalesActionMenuItem(
              label: 'Logout from Sync',
              isDestructive: true,
              onSelected: () async {
                final confirmed = await showLogoutSyncDialog(context);
                if (confirmed != true || !context.mounted) return;
                await _runAction(
                  context,
                  onLogout,
                  successMessage: 'Logged out from sync',
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleManualRefresh(BuildContext context) async {
    await _runAction(
      context,
      onRefresh,
      successMessage: 'Sync refreshed',
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    try {
      await action();
      if (!context.mounted) return;
      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on SyncShareRefreshOfflineException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(CollaborationErrorMapper.messageFor(error)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
