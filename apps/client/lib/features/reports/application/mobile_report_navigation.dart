import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/report_nav_group_extensions.dart';

/// Resolves mobile routes for report subsections.
abstract final class MobileReportNavigation {
  /// Returns a route for the subsection mobile screen.
  static String routeFor(ReportNavGroup group, String subsectionId) {
    final dedicated = switch (group) {
      ReportNavGroup.itemStock => _itemStockRoute(subsectionId),
      _ => null,
    };
    return dedicated ??
        AppRoutes.settingsReportSubsection(group.id, subsectionId);
  }

  static String? _itemStockRoute(String subsectionId) {
    ItemStockReportSubSection? sub;
    for (final value in ItemStockReportSubSection.values) {
      if (value.name == subsectionId) {
        sub = value;
        break;
      }
    }
    if (sub == null) return null;

    return switch (sub) {
      ItemStockReportSubSection.stockSummary => AppRoutes.reportsStockSummary,
      ItemStockReportSubSection.lowStockSummary =>
        '${AppRoutes.reportsStockSummary}?stock=low',
      ItemStockReportSubSection.itemDetail => AppRoutes.reportsItemDetail,
      _ => AppRoutes.settingsReportSubsection(
        ReportNavGroup.itemStock.id,
        subsectionId,
      ),
    };
  }
}
