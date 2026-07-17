import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/collaboration_action_helper.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/sync_confirmation_dialogs.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
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
        FilledButton.icon(
          onPressed: onInviteUser,
          icon: const Icon(Icons.person_add_outlined, size: 18),
          label: const Text('Invite User'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SalesActionMenuButton(
          items: [
            SalesActionMenuItem(
              label: 'Refresh',
              onSelected: () async {
                if (isRefreshing) return;
                await runCollaborationAction(
                  context,
                  onRefresh,
                  successMessage: 'Sync refreshed',
                );
              },
            ),
            SalesActionMenuItem(
              label: 'Disable Sync',
              dividerBefore: true,
              onSelected: () async {
                final confirmed = await showDisableSyncDialog(context);
                if (confirmed != true || !context.mounted) return;
                await runCollaborationAction(
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
                await runCollaborationAction(
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
}
