import 'package:billing_baba/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Brand and chart gradients.
abstract final class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6338E0),
      Color(0xFF5B4FCF),
    ],
  );

  static const primarySoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF3EEFF),
      Color(0xFFEDE7FF),
      Color(0xFFF5F0FF),
    ],
  );

  static const chartFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x406C3CE9),
      Color(0x006C3CE9),
    ],
  );

  static const metricsCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF3EEFF),
      Color(0xFFEDE7FF),
    ],
  );

  static LinearGradient chartLine({Color? start, Color? end}) {
    return LinearGradient(
      colors: [
        start ?? AppColors.primary,
        end ?? AppColors.accent,
      ],
    );
  }
}
