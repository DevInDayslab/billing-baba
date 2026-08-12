import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/layout/desktop_breakpoints.dart';
import 'package:flutter/material.dart';

/// Proportional dashboard layout — ratios apply to widths/heights only.
///
/// Typography, spacing, icons, and radii use fixed design tokens.
/// Widget tap targets use DashboardNavigation for route mapping.
abstract final class DashboardLayout {
  /// Smallest window the dashboard layout supports (fits 1366×768 laptops).
  static const minimumWindowWidth = 960.0;
  static const minimumWindowHeight = 640.0;

  /// Default opening size as a fraction of the monitor work area (not maximized).
  /// Clamped to [minimumWindowWidth]/[minimumWindowHeight] so layout stays usable.
  static const defaultWindowWidthRatio = 0.85;
  static const defaultWindowHeightRatio = 0.88;

  // Column width ratios (main + side ≈ 1.0; gap is separate).
  static const mainAreaRatio = 0.74;
  static const sidePanelRatio = 0.26;

  // Main-area row height shares (sum = 1.0).
  static const kpiHeightRatio = 0.16;
  static const chartHeightRatio = 0.64;
  static const reportsHeightRatio = 0.20;

  // Flex weights for main-column rows (match height ratios × 100).
  static const kpiRowFlex = 16;
  static const chartRowFlex = 64;
  static const reportsRowFlex = 20;

  // Chart row column split.
  static const chartRatio = 0.64;
  static const todoRatio = 0.36;

  // In-card chart area (remaining whitespace below header/value).
  static const chartAreaHeightRatio = 0.60;

  // Fixed chrome heights.
  /// Compact Windows/Linux MenuBar row (Billing Baba / Help / Versions…).
  static const menuBarHeight = 28.0;
  static const supportStripHeight = 30.0;
  static const topBarHeight = 52.0;
  static const tabBarHeight = 40.0;

  // Fixed dashboard spacing.
  static const double pagePadding = AppSpacing.lg;
  static const double gridGap = AppSpacing.xs;

  // Card chrome.
  static const cardRadius = 4.0;
  static const cardShadowBlur = 3.0;
  static const cardShadowOpacity = 0.08;

  // Card height constraints (layout only).
  static const kpiRowMinHeight = 88.0;
  static const chartCardMinHeight = 320.0;
  static const chartCardPreferredHeight = 380.0;
  static const chartCardMaxHeight = 520.0;
  static const reportsRowMinHeight = 112.0;
  static const todoMinWidth = 320.0;

  // Side-column widget content heights (padding added separately).
  static const sideWidgetMetricHeight = 68.0;
  static const sideWidgetLowStockTitleBlockHeight = 32.0;
  static const sideWidgetLowStockRowHeight = 20.0;
  static const double sideWidgetLowStockRowGap = AppSpacing.xs;
  static const sideWidgetLowStockEmptyBodyHeight = 24.0;
  static const sideWidgetLowStockMaxVisibleRows = 3;

  // Flex integers for [Expanded] / [Flexible].
  static const chartColumnFlex = 70;
  static const todoColumnFlex = 30;

  static DashboardMetrics metricsFrom(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : 800.0;

    const padding = pagePadding;
    const gap = gridGap;

    final contentWidth = width - padding * 2;
    final contentHeight = height - padding * 2;

    final sideWidth = contentWidth * sidePanelRatio;
    final mainWidth = contentWidth - sideWidth - gap;

    final rowArea = contentHeight - gap * 2;
    final kpiRowHeight = rowArea * kpiHeightRatio;
    final chartRowHeight = rowArea * chartHeightRatio;
    final reportsRowHeight = rowArea * reportsHeightRatio;

    return DashboardMetrics(
      breakpoint: DesktopBreakpoints.fromWidth(width),
      padding: padding,
      gap: gap,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      mainWidth: mainWidth,
      sideWidth: sideWidth,
      kpiRowHeight: kpiRowHeight,
      chartRowHeight: chartRowHeight,
      reportsRowHeight: reportsRowHeight,
    );
  }
}

/// Resolved layout metrics for the current viewport.
final class DashboardMetrics {
  const DashboardMetrics({
    required this.breakpoint,
    required this.padding,
    required this.gap,
    required this.contentWidth,
    required this.contentHeight,
    required this.mainWidth,
    required this.sideWidth,
    required this.kpiRowHeight,
    required this.chartRowHeight,
    required this.reportsRowHeight,
  });

  final DesktopBreakpoint breakpoint;
  final double padding;
  final double gap;
  final double contentWidth;
  final double contentHeight;
  final double mainWidth;
  final double sideWidth;
  final double kpiRowHeight;
  final double chartRowHeight;
  final double reportsRowHeight;

  int get chartColumnFlex => DashboardLayout.chartColumnFlex;
  int get todoColumnFlex => DashboardLayout.todoColumnFlex;
  int get kpiRowFlex => DashboardLayout.kpiRowFlex;
  int get chartRowFlex => DashboardLayout.chartRowFlex;
  int get reportsRowFlex => DashboardLayout.reportsRowFlex;

  EdgeInsets get pagePadding =>
      const EdgeInsets.all(DashboardLayout.pagePadding);
  EdgeInsets get cardPadding =>
      const EdgeInsets.all(DashboardLayout.pagePadding);
  EdgeInsets get sideWidgetPadding => const EdgeInsets.symmetric(
    horizontal: DashboardLayout.pagePadding,
    vertical: AppSpacing.md,
  );

  double get sideWidgetMetricHeight =>
      sideWidgetPadding.vertical * 2 + DashboardLayout.sideWidgetMetricHeight;

  /// Low-stock panel grows with visible row count (capped at 3 items).
  double sideWidgetLowStockHeight(int itemCount) {
    const rowHeight = DashboardLayout.sideWidgetLowStockRowHeight;
    final bodyHeight = itemCount == 0
        ? DashboardLayout.sideWidgetLowStockEmptyBodyHeight
        : () {
            final rows = itemCount.clamp(
              1,
              DashboardLayout.sideWidgetLowStockMaxVisibleRows,
            );
            return rows * rowHeight +
                (rows - 1) * DashboardLayout.sideWidgetLowStockRowGap;
          }();

    return sideWidgetPadding.vertical +
        DashboardLayout.sideWidgetLowStockTitleBlockHeight +
        bodyHeight +
        sideWidgetPadding.vertical;
  }
}

/// Provides [DashboardMetrics] to the dashboard widget tree.
class DashboardLayoutScope extends InheritedWidget {
  const DashboardLayoutScope({
    required this.metrics,
    required super.child,
    super.key,
  });

  final DashboardMetrics metrics;

  static DashboardMetrics of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DashboardLayoutScope>();
    assert(scope != null, 'DashboardLayoutScope not found in widget tree');
    return scope!.metrics;
  }

  @override
  bool updateShouldNotify(DashboardLayoutScope oldWidget) =>
      oldWidget.metrics.padding != metrics.padding ||
      oldWidget.metrics.contentWidth != metrics.contentWidth ||
      oldWidget.metrics.contentHeight != metrics.contentHeight ||
      oldWidget.metrics.breakpoint != metrics.breakpoint;
}
