import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_sub_route.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/manage_party_groups_dialog.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_page_switcher_menu.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyPageTitleBar extends ConsumerStatefulWidget {
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

  static const _titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  @override
  ConsumerState<PartyPageTitleBar> createState() => _PartyPageTitleBarState();
}

class _PartyPageTitleBarState extends ConsumerState<PartyPageTitleBar> {
  static const Color _hoverColor = AppColors.primary;
  static const Color _defaultColor = Colors.black87;

  bool _isHovered = false;

  Color get _contentColor => _isHovered ? _hoverColor : _defaultColor;

  bool get _isGroupsView => widget.currentRoute == AppRoutes.partyGroups;

  String get _addButtonLabel => _isGroupsView ? 'Add Group' : 'Add Party';

  VoidCallback? get _addAction {
    final permissions = ref.read(permissionServiceProvider);
    if (!permissions.canCreate(PermissionModule.party)) return null;
    return _isGroupsView ? widget.onAddGroup : widget.onAddParty;
  }

  void _setHovered(bool hovered) {
    if (_isHovered == hovered) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isHovered != hovered) {
        setState(() => _isHovered = hovered);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLabel = PartySubRoutes.labelForRoute(widget.currentRoute);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleSwitcher(currentLabel),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (_addAction != null)
                    Expanded(child: _buildAddButton(compact: true)),
                  IconButton(
                    onPressed: widget.onSettingsTap,
                    icon: const Icon(Icons.settings_outlined),
                    color: AppColors.textSecondary,
                    tooltip: 'Settings',
                  ),
                  _buildMoreMenu(context),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildTitleSwitcher(currentLabel)),
            if (_addAction != null) _buildAddButton(compact: false),
            IconButton(
              onPressed: widget.onSettingsTap,
              icon: const Icon(Icons.settings_outlined),
              color: AppColors.textSecondary,
              tooltip: 'Settings',
            ),
            _buildMoreMenu(context),
          ],
        );
      },
    );
  }

  Widget _buildTitleSwitcher(String currentLabel) {
    return PartyPageSwitcherMenu(
      currentRoute: widget.currentRoute,
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentLabel,
                  style: PartyPageTitleBar._titleStyle.copyWith(
                    color: _contentColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 22,
                  color: _contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton({required bool compact}) {
    final onPressed = _addAction;
    if (onPressed == null) return const SizedBox.shrink();

    if (compact) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: PartyPageTitleBar._addPartyRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, 42),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: const Icon(Icons.add, size: 22),
        label: Text(_addButtonLabel),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: PartyPageTitleBar._addPartyRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        minimumSize: const Size(0, 42),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: const Icon(Icons.add, size: 22),
      label: Text(_addButtonLabel),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More options',
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
        size: 22,
      ),
      onSelected:
          widget.onMoreSelected ??
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
