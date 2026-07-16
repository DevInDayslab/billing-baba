import 'package:flutter/material.dart';

/// Single source of truth for Vyapar-style proportional dashboard layout.
///
/// Reference canvas: 1920 × 1080. All sizes derive from ratios — no magic
/// pixel positioning. Typography stays fixed; spacing scales with width.
abstract final class DashboardLayout {
  static const referenceWidth = 1920.0;
  static const referenceHeight = 1080.0;

  // Column widths (main + side ≈ 1.0; gap is separate).
  static const mainAreaRatio = 0.79;
  static const sidePanelRatio = 0.21;

  // Main-area row height shares (sum = 1.0).
  // KPI and reports are slightly taller than the base Vyapar spec.
  static const kpiHeightRatio = 0.18;
  static const chartHeightRatio = 0.56;
  static const reportsHeightRatio = 0.24;

  // Chart row column split.
  static const chartRatio = 0.70;
  static const todoRatio = 0.30;

  // In-card chart area (remaining whitespace below, like Vyapar).
  static const chartAreaHeightRatio = 0.60;

  // Spacing ratios.
  static const gapRatio = 0.008;
  static const paddingRatio = 0.012;
  static const paddingMin = 12.0;
  static const paddingMax = 24.0;

  // Chrome height ratios (fixed typography, proportional bar heights).
  static const topBarHeightRatio = 0.048;
  static const tabBarHeightRatio = 0.037;
  static const supportStripHeightRatio = 0.028;

  // Card chrome.
  static const cardRadius = 4.0;
  static const cardShadowBlur = 3.0;
  static const cardShadowOpacity = 0.08;

  // Flex integers for [Expanded] / [Flexible].
  static const chartColumnFlex = 70;
  static const todoColumnFlex = 30;

  static DashboardMetrics metricsFrom(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : referenceHeight;

    final padding = (width * paddingRatio).clamp(paddingMin, paddingMax);
    final gap = width * gapRatio;

    final contentWidth = width - padding * 2;
    final contentHeight = height - padding * 2;

    final sideWidth = contentWidth * sidePanelRatio;
    final mainWidth = contentWidth - sideWidth - gap;

    final rowArea = contentHeight - gap * 2;
    final kpiRowHeight = rowArea * kpiHeightRatio;
    final chartRowHeight = rowArea * chartHeightRatio;
    final reportsRowHeight = rowArea * reportsHeightRatio;

    return DashboardMetrics(
      padding: padding,
      gap: gap,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      mainWidth: mainWidth,
      sideWidth: sideWidth,
      kpiRowHeight: kpiRowHeight,
      chartRowHeight: chartRowHeight,
      reportsRowHeight: reportsRowHeight,
      topBarHeight: height * topBarHeightRatio,
      tabBarHeight: height * tabBarHeightRatio,
      supportStripHeight: height * supportStripHeightRatio,
    );
  }
}

/// Resolved layout metrics for the current viewport.
final class DashboardMetrics {
  const DashboardMetrics({
    required this.padding,
    required this.gap,
    required this.contentWidth,
    required this.contentHeight,
    required this.mainWidth,
    required this.sideWidth,
    required this.kpiRowHeight,
    required this.chartRowHeight,
    required this.reportsRowHeight,
    required this.topBarHeight,
    required this.tabBarHeight,
    required this.supportStripHeight,
  });

  final double padding;
  final double gap;
  final double contentWidth;
  final double contentHeight;
  final double mainWidth;
  final double sideWidth;
  final double kpiRowHeight;
  final double chartRowHeight;
  final double reportsRowHeight;
  final double topBarHeight;
  final double tabBarHeight;
  final double supportStripHeight;

  int get chartColumnFlex => DashboardLayout.chartColumnFlex;
  int get todoColumnFlex => DashboardLayout.todoColumnFlex;

  EdgeInsets get pagePadding => EdgeInsets.all(padding);
  EdgeInsets get cardPadding => EdgeInsets.all(padding);
  EdgeInsets get sideWidgetPadding => EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.65,
      );
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
    final scope =
        context.dependOnInheritedWidgetOfExactType<DashboardLayoutScope>();
    assert(scope != null, 'DashboardLayoutScope not found in widget tree');
    return scope!.metrics;
  }

  @override
  bool updateShouldNotify(DashboardLayoutScope oldWidget) =>
      oldWidget.metrics.padding != metrics.padding ||
      oldWidget.metrics.contentWidth != metrics.contentWidth ||
      oldWidget.metrics.contentHeight != metrics.contentHeight;
}
