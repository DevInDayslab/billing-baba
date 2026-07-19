import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_error_mapper.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/collaboration_empty_state.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/member_status_chip.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/role_badge.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/role_select_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_table_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef MemberRoleChangeCallback =
    void Function(BusinessMember member, Role newRole);

enum _PendingMemberAction { reinvite, cancelInvitation }

class MembersTable extends StatelessWidget {
  const MembersTable({
    required this.membersAsync,
    required this.onRefresh,
    required this.onInvite,
    required this.onEdit,
    required this.onDelete,
    this.onReinvite,
    this.onRoleChange,
    super.key,
  });

  final AsyncValue<List<BusinessMember>> membersAsync;
  final VoidCallback onRefresh;
  final VoidCallback onInvite;
  final ValueChanged<BusinessMember> onEdit;
  final ValueChanged<BusinessMember> onDelete;
  final ValueChanged<BusinessMember>? onReinvite;
  final MemberRoleChangeCallback? onRoleChange;

  static const _cellPadding = EdgeInsets.symmetric(horizontal: 12);

  @override
  Widget build(BuildContext context) {
    return membersAsync.when(
      skipLoadingOnReload: true,
      loading: () => const SalesLoadingState(),
      error: (error, _) => SalesErrorState(
        message: CollaborationErrorMapper.messageFor(error),
        onRetry: onRefresh,
      ),
      data: (members) {
        if (members.isEmpty) {
          return CollaborationEmptyState(onInvitePressed: onInvite);
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: ResizableDataTable(
              columns: [
                _column('NAME', 160),
                _column('PHONE / EMAIL', 200),
                _column('ROLE', 200),
                _column('STATUS', 140),
                _column('ACTIONS', 88, resizable: false),
              ],
              rows: [
                for (final member in members)
                  ResizableDataRow(
                    cells: [
                      _tableCell(
                        Text(
                          member.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _tableCell(
                        Text(
                          _formatContactDisplay(member.phoneOrEmail),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _tableCell(
                        _RoleCell(
                          member: member,
                          onRoleChange: onRoleChange,
                        ),
                      ),
                      _tableCell(MemberStatusChip(status: member.status)),
                      _tableCell(
                        _MemberActionsCell(
                          member: member,
                          onEdit: onEdit,
                          onDelete: onDelete,
                          onReinvite: onReinvite,
                        ),
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatContactDisplay(String contact) {
    if (isPhoneContact(contact)) {
      return formatPhoneOrEmailContact(contact);
    }
    return contact;
  }

  Widget _tableCell(
    Widget child, {
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: _cellPadding,
        child: child,
      ),
    );
  }

  ResizableDataColumn _column(
    String label,
    double width, {
    bool resizable = true,
  }) {
    return ResizableDataColumn(
      initialWidth: width,
      resizable: resizable,
      header: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: _cellPadding,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberActionsCell extends StatelessWidget {
  const _MemberActionsCell({
    required this.member,
    required this.onEdit,
    required this.onDelete,
    this.onReinvite,
  });

  final BusinessMember member;
  final ValueChanged<BusinessMember> onEdit;
  final ValueChanged<BusinessMember> onDelete;
  final ValueChanged<BusinessMember>? onReinvite;

  @override
  Widget build(BuildContext context) {
    final isPending = member.status == MemberStatus.pending;
    final canReinvite =
        !member.isOwner &&
        isPending &&
        member.invitationId != null &&
        onReinvite != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _compactIconButton(
          tooltip: 'Edit',
          onPressed: () => onEdit(member),
          icon: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        if (!member.isOwner)
          if (canReinvite)
            _pendingActionsMenu(context)
          else
            _compactIconButton(
              tooltip: isPending ? 'Cancel Invitation' : 'Delete',
              onPressed: () => onDelete(member),
              icon: Icon(
                isPending ? Icons.cancel_outlined : Icons.delete_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
      ],
    );
  }

  Widget _pendingActionsMenu(BuildContext context) {
    return PopupMenuButton<_PendingMemberAction>(
      tooltip: 'More actions',
      padding: EdgeInsets.zero,
      iconSize: 18,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: const Icon(
        Icons.more_vert,
        size: 18,
        color: AppColors.textSecondary,
      ),
      onSelected: (action) {
        switch (action) {
          case _PendingMemberAction.reinvite:
            onReinvite!(member);
          case _PendingMemberAction.cancelInvitation:
            onDelete(member);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _PendingMemberAction.reinvite,
          child: _ActionMenuRow(
            icon: Icons.send_outlined,
            label: 'Reinvite',
          ),
        ),
        const PopupMenuItem(
          value: _PendingMemberAction.cancelInvitation,
          child: _ActionMenuRow(
            icon: Icons.cancel_outlined,
            label: 'Cancel Invitation',
          ),
        ),
      ],
    );
  }

  Widget _compactIconButton({
    required String tooltip,
    required VoidCallback onPressed,
    required Widget icon,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: icon,
    );
  }
}

class _ActionMenuRow extends StatelessWidget {
  const _ActionMenuRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}

class _RoleCell extends StatelessWidget {
  const _RoleCell({
    required this.member,
    required this.onRoleChange,
  });

  final BusinessMember member;
  final MemberRoleChangeCallback? onRoleChange;

  @override
  Widget build(BuildContext context) {
    if (member.isOwner || onRoleChange == null) {
      return RoleBadge(role: member.role);
    }

    return RoleSelectTrigger(
      dense: true,
      selectedRole: member.role,
      onChanged: (role) => onRoleChange!(member, role),
    );
  }
}
