import 'package:flutter/material.dart';

/// Desktop width breakpoints — layout only, never typography.
enum DesktopBreakpoint {
  compact,
  normal,
  large,
  xl,
}

/// Width-based breakpoints for desktop layout decisions.
///
/// Affects column counts, widget widths, and grid density — not fonts or spacing.
abstract final class DesktopBreakpoints {
  static const compactMax = 1365.0;
  static const normalMax = 1599.0;
  static const largeMax = 1919.0;

  static DesktopBreakpoint fromWidth(double width) {
    if (width <= compactMax) return DesktopBreakpoint.compact;
    if (width <= normalMax) return DesktopBreakpoint.normal;
    if (width <= largeMax) return DesktopBreakpoint.large;
    return DesktopBreakpoint.xl;
  }

  static DesktopBreakpoint of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
