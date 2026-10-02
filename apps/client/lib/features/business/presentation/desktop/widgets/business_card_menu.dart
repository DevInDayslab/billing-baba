import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:flutter/material.dart';

enum CompanyCardMenuAction {
  open,
  manageUsers,
  backup,
  leave,
  delete,
  edit,
  accept,
  reject,
}

enum BusinessCardMenuVariant { full, mobile }

class BusinessCardMenu extends StatelessWidget {
  const BusinessCardMenu({
    required this.entry,
    required this.onAction,
    this.variant = BusinessCardMenuVariant.full,
    super.key,
  });

  final CompanyListEntry entry;
  final ValueChanged<CompanyCardMenuAction>? onAction;
  final BusinessCardMenuVariant variant;

  @override
  Widget build(BuildContext context) {
    final items = _menuItems();
    if (items.isEmpty) {
      return const SizedBox(width: 40);
    }

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          textStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
      child: PopupMenuButton<CompanyCardMenuAction>(
        tooltip: 'More options',
        icon: Icon(
          Icons.more_vert,
          color: AppColors.textSecondary.withValues(alpha: 0.85),
          size: 22,
        ),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        offset: const Offset(0, 8),
        onSelected: onAction,
        itemBuilder: (context) => items,
      ),
    );
  }

  List<PopupMenuEntry<CompanyCardMenuAction>> _menuItems() {
    if (variant == BusinessCardMenuVariant.mobile) {
      return _mobileMenuItems();
    }

    return switch (entry.relationship) {
      CompanyRelationship.owner => [
        const PopupMenuItem(
          value: CompanyCardMenuAction.edit,
          child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit Company'),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.manageUsers,
          child: _MenuRow(
            icon: Icons.people_outline,
            label: 'Manage Users',
          ),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.backup,
          child: _MenuRow(icon: Icons.backup_outlined, label: 'Backup'),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.leave,
          child: _MenuRow(icon: Icons.logout, label: 'Leave'),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.delete,
          child: _MenuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Company',
            destructive: true,
          ),
        ),
      ],
      CompanyRelationship.secondaryAdmin => [
        const PopupMenuItem(
          value: CompanyCardMenuAction.manageUsers,
          child: _MenuRow(
            icon: Icons.people_outline,
            label: 'Manage Users',
          ),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.leave,
          child: _MenuRow(icon: Icons.logout, label: 'Leave'),
        ),
      ],
      CompanyRelationship.member => [
        const PopupMenuItem(
          value: CompanyCardMenuAction.leave,
          child: _MenuRow(icon: Icons.logout, label: 'Leave'),
        ),
      ],
      CompanyRelationship.pendingInvite => [
        const PopupMenuItem(
          value: CompanyCardMenuAction.accept,
          child: _MenuRow(
            icon: Icons.check_circle_outline,
            label: 'Accept',
          ),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.reject,
          child: _MenuRow(
            icon: Icons.cancel_outlined,
            label: 'Reject',
            destructive: true,
          ),
        ),
      ],
      CompanyRelationship.expiredInvite => const [],
    };
  }

  List<PopupMenuEntry<CompanyCardMenuAction>> _mobileMenuItems() {
    return switch (entry.relationship) {
      CompanyRelationship.owner => [
        const PopupMenuItem(
          value: CompanyCardMenuAction.edit,
          child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit Company'),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.manageUsers,
          child: _MenuRow(
            icon: Icons.people_outline,
            label: 'Manage Users',
          ),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.delete,
          child: _MenuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Company',
            destructive: true,
          ),
        ),
      ],
      CompanyRelationship.secondaryAdmin || CompanyRelationship.member => [
        const PopupMenuItem(
          value: CompanyCardMenuAction.leave,
          child: _MenuRow(icon: Icons.logout, label: 'Leave'),
        ),
      ],
      CompanyRelationship.pendingInvite => [
        const PopupMenuItem(
          value: CompanyCardMenuAction.accept,
          child: _MenuRow(
            icon: Icons.check_circle_outline,
            label: 'Accept',
          ),
        ),
        const PopupMenuItem(
          value: CompanyCardMenuAction.reject,
          child: _MenuRow(
            icon: Icons.cancel_outlined,
            label: 'Reject',
            destructive: true,
          ),
        ),
      ],
      CompanyRelationship.expiredInvite => const [],
    };
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.destructive = false,
  }) : muted = false;

  final IconData icon;
  final String label;
  final bool destructive;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? AppColors.error
        : muted
        ? AppColors.textSecondary.withValues(alpha: 0.6)
        : AppColors.textPrimary;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
