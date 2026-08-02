import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/members_provider.dart';
import 'package:billing_baba/features/collaboration/application/sync_status_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/models/sync_status.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/widgets/member_form_dialog.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_offline_banner.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileSyncSharePage extends ConsumerWidget {
  const MobileSyncSharePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);
    final syncStatusAsync = ref.watch(syncStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: 'Sync & share',
        showBusinessHeader: false,
        showNotification: false,
        actions: [
          IconButton(
            onPressed: () => showAddMemberDialog(context, ref),
            icon: const Icon(Icons.person_add_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          syncStatusAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (status) {
              if (!status.isOffline) return const SizedBox.shrink();
              return const MobileOfflineBanner(
                message: 'Collaboration sync is offline. Changes queue locally.',
              );
            },
          ),
          syncStatusAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (status) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                status.state.displayLabel,
                style: AppTypography.inter(
                  fontSize: AppTypography.captionSize,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppError(
                message: OfflineUiMessages.messageFor(error),
                onRetry: () => ref.invalidate(membersProvider),
              ),
              data: (members) {
                if (members.isEmpty) {
                  return const Center(
                    child: Text(
                      'No members yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(membersProvider.notifier).reload(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: members.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _MemberTile(member: member);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final BusinessMember member;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        title: Text(
          member.fullName,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${member.role.displayLabel} · ${member.status.name}',
          style: AppTypography.inter(
            fontSize: AppTypography.captionSize,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: member.isCurrentUser
            ? Text(
                'You',
                style: AppTypography.inter(
                  fontSize: AppTypography.captionSize,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
      ),
    );
  }
}
