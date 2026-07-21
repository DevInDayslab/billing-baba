import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:billing_baba/features/parties/models/party_sub_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _menuHoverColor = Color(0xFFF5F5F5);
const _itemVerticalPadding = 12.0;
const _iconSize = 18.0;

/// Dropdown menu for switching between Parties and Groups views.
class PartyPageSwitcherMenu extends ConsumerWidget {
  const PartyPageSwitcherMenu({
    required this.currentRoute,
    required this.child,
    super.key,
  });

  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canViewHiddenLedger =
        ref.watch(permissionServiceProvider).canViewHiddenLedger;
    final items = PartySubRoutes.items
        .where(
          (item) =>
              item.route != AppRoutes.partyHiddenLedger || canViewHiddenLedger,
        )
        .toList();

    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        elevation: const WidgetStatePropertyAll(4),
        shadowColor: const WidgetStatePropertyAll(Colors.black26),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size(200, 0)),
      ),
      menuChildren: [
        for (final item in items)
          _PartyPageSwitcherMenuItem(
            label: item.label,
            isSelected: item.route == currentRoute,
            icon: switch (item.route) {
              AppRoutes.partyDetails => Icons.format_list_bulleted,
              AppRoutes.partyHiddenLedger => Icons.visibility_off_outlined,
              _ => Icons.groups_outlined,
            },
            onSelected: () {
              if (item.route != currentRoute) {
                context.go(item.route);
              }
            },
          ),
      ],
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: this.child,
        );
      },
    );
  }
}

class _PartyPageSwitcherMenuItem extends StatelessWidget {
  const _PartyPageSwitcherMenuItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final contentColor = isSelected ? AppColors.primary : AppColors.textPrimary;

    return MenuItemButton(
      onPressed: onSelected,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: _itemVerticalPadding,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return _menuHoverColor;
          }
          return null;
        }),
        splashFactory: NoSplash.splashFactory,
      ),
      child: Row(
        children: [
          Icon(icon, size: _iconSize, color: contentColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: contentColor,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, size: _iconSize, color: AppColors.primary),
        ],
      ),
    );
  }
}
