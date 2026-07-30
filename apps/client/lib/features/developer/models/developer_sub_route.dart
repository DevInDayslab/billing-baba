import 'package:billing_baba/core/router/app_routes.dart';
import 'package:flutter/material.dart';

/// Visual weight for a component catalog tile in the bento grid.
enum DeveloperBentoSize {
  /// Spans two columns — used for the primary implemented playground.
  hero,

  /// Standard single-cell tile.
  standard,
}

/// A developer components sub-section route with display metadata.
class DeveloperSubRoute {
  const DeveloperSubRoute({
    required this.route,
    required this.label,
    required this.description,
    required this.icon,
    this.implemented = false,
    this.size = DeveloperBentoSize.standard,
  });

  final String route;
  final String label;
  final String description;
  final IconData icon;
  final bool implemented;
  final DeveloperBentoSize size;
}

/// Developer > Components navigation entries.
abstract final class DeveloperSubRoutes {
  static const String componentsIndex = AppRoutes.developerComponents;

  static const items = [
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsTableFilters,
      label: 'Table Filters',
      description:
          'Canonical column filter widgets with live playground and reference.',
      icon: Icons.filter_list_rounded,
      implemented: true,
      size: DeveloperBentoSize.hero,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsButtons,
      label: 'Buttons',
      description: 'Primary, secondary, and icon button variants.',
      icon: Icons.smart_button_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsInputs,
      label: 'Inputs',
      description: 'Text fields, number fields, and form controls.',
      icon: Icons.edit_note_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsDialogs,
      label: 'Dialogs',
      description: 'Modals, confirmations, and alert patterns.',
      icon: Icons.web_asset_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsDataTables,
      label: 'Data Tables',
      description: 'Sortable tables, headers, and row actions.',
      icon: Icons.table_chart_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsBadges,
      label: 'Badges',
      description: 'Status pills and count indicators.',
      icon: Icons.verified_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsChips,
      label: 'Chips',
      description: 'Filter chips and removable tags.',
      icon: Icons.label_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsCards,
      label: 'Cards',
      description: 'Surface containers and content panels.',
      icon: Icons.dashboard_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsTypography,
      label: 'Typography',
      description: 'Type scale, weights, and text styles.',
      icon: Icons.text_fields_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsColors,
      label: 'Colors',
      description: 'Brand, semantic, and surface tokens.',
      icon: Icons.palette_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsIcons,
      label: 'Icons',
      description: 'Icon set and sizing conventions.',
      icon: Icons.apps_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsLoading,
      label: 'Loading',
      description: 'Spinners, shimmer, and progress states.',
      icon: Icons.autorenew_rounded,
    ),
    DeveloperSubRoute(
      route: AppRoutes.developerComponentsEmptyStates,
      label: 'Empty States',
      description: 'Zero-data and no-results layouts.',
      icon: Icons.inbox_rounded,
    ),
  ];

  static String labelForRoute(String route) {
    if (route == componentsIndex) return 'Components';
    for (final item in items) {
      if (item.route == route) return item.label;
    }
    return 'Components';
  }
}
