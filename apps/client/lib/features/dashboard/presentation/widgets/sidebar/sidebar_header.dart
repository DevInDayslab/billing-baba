import 'package:billing_baba/features/dashboard/presentation/widgets/sidebar/sidebar_search.dart';
import 'package:flutter/material.dart';

/// Top-of-sidebar search / command palette placeholder.
class SidebarHeader extends StatelessWidget {
  const SidebarHeader({
    required this.collapsed,
    required this.onToggleCollapse,
    super.key,
  });

  final bool collapsed;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return SidebarSearch(
      collapsed: collapsed,
      onToggleCollapse: onToggleCollapse,
    );
  }
}
