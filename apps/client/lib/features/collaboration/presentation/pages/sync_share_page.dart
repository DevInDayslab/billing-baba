import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_init_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_refresh_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_scope_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/sync_share_live_sync_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/sync_status_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/collaboration_action_helper.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/collaboration_page_header.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/collaboration_page_skeleton.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/collaboration_section_empty_state.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/delete_member_dialog.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/logged_in_status_bar.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/member_form_dialog.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/members_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncSharePage extends ConsumerStatefulWidget {
  const SyncSharePage({super.key});

  @override
  ConsumerState<SyncSharePage> createState() => _SyncSharePageState();
}

class _SyncSharePageState extends ConsumerState<SyncSharePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCollaborationData();
    }
  }

  void _refreshCollaborationData() {
    unawaited(ref.read(membersProvider.notifier).reload(showLoading: false));
    unawaited(ref.read(invitationsProvider.notifier).reload(showLoading: false));
    ref.invalidate(companyAccessProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(collaborationScopeProvider);
    ref.watch(syncShareLiveSyncProvider);

    final initAsync = ref.watch(collaborationInitProvider);
    final membersAsync = ref.watch(membersProvider);
    final companyAccessAsync = ref.watch(companyAccessProvider);
    final isRefreshing = ref.watch(collaborationRefreshProvider);

    return initAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: CollaborationPageSkeleton(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: CollaborationSectionEmptyState(
          title: 'Could not load collaboration',
          message: error.toString(),
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
              onRefresh: () =>
                  ref.read(collaborationRefreshProvider.notifier).refreshAll(),
              onDisableSync: () =>
                  ref.read(syncStatusProvider.notifier).disableSync(),
              onLogout: () =>
                  ref.read(syncStatusProvider.notifier).logoutSync(),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                onRefresh: _refreshCollaborationData,
                onInvite: () => showAddMemberDialog(context, ref),
                onEdit: (member) => showEditMemberDialog(context, ref, member),
                onDelete: (member) => _confirmDelete(context, ref, member),
                onReinvite: (member) => _reinvite(context, ref, member),
                onRoleChange: (member, newRole) => runCollaborationAction(
                  context,
                  () => ref
                      .read(membersProvider.notifier)
                      .updateMember(
                        member.id,
                        UpdateMemberInput(
                          fullName: member.fullName,
                          phoneOrEmail: member.phoneOrEmail,
                          role: newRole,
                        ),
                      ),
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
