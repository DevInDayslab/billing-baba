import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/models/sidebar_menu.dart';
import 'package:billing_baba/features/dashboard/presentation/models/sidebar_route_utils.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_footer.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_item.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_search.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_section.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.currentLocation,
    required this.collapsed,
    required this.expandedSections,
    required this.companyName,
    required this.onToggleCollapse,
    required this.onToggleSection,
    required this.onEditProfile,
    required this.onSwitchCompany,
    required this.onLogout,
    super.key,
  });

  final String currentLocation;
  final bool collapsed;
  final Set<String> expandedSections;
  final String companyName;
  final VoidCallback onToggleCollapse;
  final ValueChanged<String> onToggleSection;
  final VoidCallback onEditProfile;
  final VoidCallback onSwitchCompany;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SidebarTokens.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarSearch(
            collapsed: collapsed,
            onToggleCollapse: onToggleCollapse,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in SidebarMenu.items) _buildNode(context, item),
                ],
              ),
            ),
          ),
          SidebarFooter(
            collapsed: collapsed,
            companyName: companyName,
            onEditProfile: onEditProfile,
            onSwitchCompany: onSwitchCompany,
            onLogout: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildNode(BuildContext context, SidebarMenuItem item) {
    if (item.isExpandable) {
      final isExpanded = expandedSections.contains(item.id);
      final isActive = SidebarRouteUtils.isItemActive(currentLocation, item);

      return SidebarSection(
        item: item,
        collapsed: collapsed,
        isExpanded: isExpanded,
        isActive: isActive,
        onToggle: () => onToggleSection(item.id),
        childBuilder: () => [
          for (final child in item.children)
            SidebarSubItem(
              item: child,
              collapsed: collapsed,
              isActive: child.route != null &&
                  SidebarRouteUtils.matchesRoute(currentLocation, child.route!),
              onTap: child.route != null
                  ? () => context.go(child.route!)
                  : null,
            ),
        ],
      );
    }

    final isActive = item.route != null &&
        SidebarRouteUtils.matchesRoute(currentLocation, item.route!);

    return SidebarItem(
      item: item,
      collapsed: collapsed,
      isActive: isActive,
      onTap: item.route != null ? () => context.go(item.route!) : null,
    );
  }
}
