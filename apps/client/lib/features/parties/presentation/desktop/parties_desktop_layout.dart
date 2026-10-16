import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:flutter/material.dart';

/// Parties desktop chrome — same outer gutters as the home dashboard.
abstract final class PartiesDesktopLayout {
  static const titleBarPadding = EdgeInsets.fromLTRB(
    DashboardLayout.pageGutterHorizontal,
    DashboardLayout.pageGutterTop,
    DashboardLayout.pageGutterHorizontal,
    0,
  );

  /// Split workspace is flush to the sidebar; only inset right and bottom.
  static const workspacePadding = EdgeInsets.fromLTRB(
    0,
    0,
    DashboardLayout.pageGutterHorizontal,
    DashboardLayout.pageGutterBottom,
  );
}
