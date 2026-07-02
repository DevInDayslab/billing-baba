import 'package:flutter/material.dart';

/// Sidebar layout and color tokens.
abstract final class SidebarTokens {
  static const expandedWidth = 250.0;
  static const collapsedWidth = 72.0;
  static const animationDuration = Duration(milliseconds: 200);
  static const Cubic animationCurve = Curves.easeOut;

  static const background = Color(0xFF1C2333);
  static const searchBackground = Color(0xFF141B27);
  static const activeBackground = Color(0xFF2A3447);
  static const border = Color(0xFF2A3447);
  static const text = Color(0xFFB0BEC5);
  static const textActive = Color(0xFFFFFFFF);
}
