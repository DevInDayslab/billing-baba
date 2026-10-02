import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/parties/models/party_sub_route.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/manage_party_groups_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compact page action row below the global search bar.
class PartyPageTitleBar extends ConsumerWidget {
  const PartyPageTitleBar({
    required this.currentRoute,
    this.onAddParty,
    this.onAddGroup,
    this.onSettingsTap,
    this.onMoreSelected,
    super.key,
  });

  final String currentRoute;
  final VoidCallback? onAddParty;
  final VoidCallback? onAddGroup;
  final VoidCallback? onSettingsTap;
  final ValueChanged<String>? onMoreSelected;

  static const _addPartyRed = Color(0xFFE53935);

  static const double _barHeight = DashboardSpacing.topBarHeight;

  static const _titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  bool get _isGroupsView => currentRoute == AppRoutes.partyGroups;

  bool get _isHiddenLedgerView => currentRoute == AppRoutes.partyHiddenLedger;

  String get _addButtonLabel => _isGroupsView ? 'Add Group' : 'Add Party';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionServiceProvider);
    final addAction =
        !_isHiddenLedgerView && permissions.canCreate(PermissionModule.party)
        ? (_isGroupsView ? onAddGroup : onAddParty)
        : null;
    final pageLabel = PartySubRoutes.labelForRoute(currentRoute);

    // Match [AppTopBar] height and vertical alignment (search row above).
    return SizedBox(
      height: _barHeight,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                pageLabel,
                style: _titleStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (addAction != null) ...[
            _AddPartyButton(
              label: _addButtonLabel,
              onPressed: addAction,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (onSettingsTap != null)
            IconButton(
              onPressed: onSettingsTap,
              icon: const Icon(Icons.settings_outlined, size: 18),
              color: AppColors.textSecondary,
              tooltip: 'Settings',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              visualDensity: VisualDensity.compact,
            ),
          if (!_isHiddenLedgerView) _MoreMenu(onMoreSelected: onMoreSelected),
        ],
      ),
    );
  }
}

class _AddPartyButton extends StatelessWidget {
  const _AddPartyButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: PartyPageTitleBar._addPartyRed,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        minimumSize: const Size(0, 40),
        maximumSize: const Size(double.infinity, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({this.onMoreSelected});

  final ValueChanged<String>? onMoreSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More options',
      padding: EdgeInsets.zero,
      splashRadius: 18,
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
        size: 18,
      ),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      iconSize: 18,
      onSelected:
          onMoreSelected ??
          (value) {
            if (value == 'Manage Party Groups') {
              unawaited(showManagePartyGroupsDialog(context));
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$value coming soon')),
            );
          },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'Manage Party Groups',
          child: Text('View All Party Groups'),
        ),
        PopupMenuItem(
          value: 'Import Parties',
          child: Text('Import Parties'),
        ),
        PopupMenuItem(
          value: 'Export Parties',
          child: Text('Export Parties'),
        ),
      ],
    );
  }
}
