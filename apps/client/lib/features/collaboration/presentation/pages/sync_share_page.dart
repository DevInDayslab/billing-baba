import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_init_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_refresh_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
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

class SyncSharePage extends ConsumerWidget {
  const SyncSharePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                onRefresh: () => ref.read(membersProvider.notifier).reload(),
                onInvite: () => showAddMemberDialog(context, ref),
                onEdit: (member) => showEditMemberDialog(context, ref, member),
                onDelete: (member) => _confirmDelete(context, ref, member),
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
}
