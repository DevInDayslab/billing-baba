import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Canonical spacing and sizing for desktop ERP forms (Vyapar-style).
abstract final class FormSpacing {
  static const int columns = 12;

  /// Dialog content / section padding.
  static const double page = 20;

  /// Gap between major body blocks (basic details → image → tabs).
  static const double section = 12;

  /// Vertical gap between grid rows.
  static const double row = 16;

  /// Horizontal gap between grid columns.
  static const double gutter = 16;

  /// Label → control.
  static const double label = 6;

  /// Shared control height.
  static const double inputHeight = 44;

  /// Compact image upload strip.
  static const double imageHeight = 76;

  /// Modal header height.
  static const double headerHeight = 56;

  /// Modal footer height.
  static const double footerHeight = 64;

  /// Section card padding.
  static const double cardPadding = 16;

  static const double cardRadius = AppRadius.md;

  static const double dialogWidth = 1000;
  static const double dialogMaxWidth = 1040;
  static const double dialogMaxHeightFactor = 0.9;

  /// Stack grid cells below this width.
  static const double narrowBreakpoint = 720;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);
}
