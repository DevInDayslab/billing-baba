import 'dart:async';

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_init_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_scope_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/application/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/application/members_provider.dart';
import 'package:billing_baba/features/collaboration/application/sync_share_live_sync_provider.dart';
import 'package:billing_baba/features/collaboration/application/sync_share_live_sync_service.dart';
import 'package:billing_baba/features/collaboration/application/sync_share_refresh_provider.dart';
import 'package:billing_baba/features/collaboration/application/sync_status_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/collaboration_action_helper.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/collaboration_page_header.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/collaboration_page_skeleton.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/collaboration_section_empty_state.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/delete_member_dialog.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/logged_in_status_bar.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/member_form_dialog.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/members_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class DesktopSyncSharePage extends ConsumerStatefulWidget {
  const DesktopSyncSharePage({super.key});

  @override
  ConsumerState<DesktopSyncSharePage> createState() => _SyncSharePageState();
}

class _SyncSharePageState extends ConsumerState<DesktopSyncSharePage>
    with WidgetsBindingObserver, WindowListener {
  bool get _supportsWindowFocus {
    if (kIsWeb) return false;
    return AppPlatform.current.isDesktop;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_supportsWindowFocus) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (_supportsWindowFocus) {
      windowManager.removeListener(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefresh(SyncShareRefreshTrigger.appResume);
    }
  }

  @override
  void onWindowFocus() {
    _silentRefresh(SyncShareRefreshTrigger.windowFocus);
  }

  void _silentRefresh(SyncShareRefreshTrigger trigger) {
    unawaited(
      ref.read(syncShareRefreshProvider.notifier).refresh(
            trigger: trigger,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(collaborationScopeProvider);
    ref.watch(syncShareLiveSyncProvider);

    final initAsync = ref.watch(collaborationInitProvider);
    final membersAsync = ref.watch(membersProvider);
    final companyAccessAsync = ref.watch(companyAccessProvider);
    final syncStatusAsync = ref.watch(syncStatusProvider);
    final isRefreshing = ref.watch(syncShareRefreshProvider);

    return initAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: CollaborationPageSkeleton(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: CollaborationSectionEmptyState(
          title: 'Could not load collaboration',
          message: OfflineUiMessages.messageFor(error),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(collaborationInitProvider),
          showIllustration: false,
        ),
      ),
      data: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CollaborationPageHeader(
              isRefreshing: isRefreshing,
              onInviteUser: () => showAddMemberDialog(context, ref),
              onRefresh: () => ref
                  .read(syncShareRefreshProvider.notifier)
                  .refresh(
                    manual: true,
                    trigger: SyncShareRefreshTrigger.manual,
                  ),
              onDisableSync: () =>
                  ref.read(syncStatusProvider.notifier).disableSync(),
              onLogout: () =>
                  ref.read(syncStatusProvider.notifier).logoutSync(),
            ),
            const SizedBox(height: AppSpacing.lg),
            syncStatusAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (status) {
                if (!status.isOffline) return const SizedBox.shrink();
                return const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _OfflineModeBanner(),
                );
              },
            ),
            companyAccessAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (access) => LoggedInStatusBar(
                loggedInPhone: access.loggedInPhone,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Members',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: MembersTable(
                membersAsync: membersAsync,
                onRefresh: () => _silentRefresh(SyncShareRefreshTrigger.manual),
                onInvite: () => showAddMemberDialog(context, ref),
                onEdit: (member) => showEditMemberDialog(context, ref, member),
                onDelete: (member) => _confirmDelete(context, ref, member),
                onReinvite: (member) => _reinvite(context, ref, member),
                onRoleChange: (member, newRole) => runCollaborationAction(
                  context,
                  () => ref
                      .read(membersProvider.notifier)
                      .changeRole(member.id, newRole),
                  successMessage: 'Role updated',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BusinessMember member,
  ) async {
    final isPending = member.status == MemberStatus.pending;
    final confirmed = isPending
        ? await showCancelInvitationDialog(
            context,
            memberName: member.fullName,
          )
        : await showDeleteMemberDialog(
            context,
            memberName: member.fullName,
          );
    if (confirmed != true || !context.mounted) return;

    if (isPending && member.invitationId != null) {
      await runCollaborationAction(
        context,
        () =>
            ref.read(invitationsProvider.notifier).cancel(member.invitationId!),
        successMessage: 'Invitation cancelled for ${member.fullName}',
      );
      return;
    }

    await runCollaborationAction(
      context,
      () => ref.read(membersProvider.notifier).removeMember(member.id),
      successMessage: '${member.fullName} removed successfully',
    );
  }

  Future<void> _reinvite(
    BuildContext context,
    WidgetRef ref,
    BusinessMember member,
  ) async {
    final invitationId = member.invitationId;
    if (invitationId == null) return;

    await runCollaborationAction(
      context,
      () async {
        final invitation = await ref
            .read(invitationsProvider.notifier)
            .reinvite(invitationId);
        ref.read(collaborationServiceProvider).shareViaWhatsApp(invitation);
      },
      successMessage: 'Invitation resent to ${member.fullName}',
    );
  }
}

class _OfflineModeBanner extends StatelessWidget {
  const _OfflineModeBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, size: 18, color: Color(0xFFF57F17)),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Offline mode — showing cached data. Changes will sync when you reconnect.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
