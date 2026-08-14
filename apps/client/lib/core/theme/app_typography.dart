import 'package:flutter/material.dart';

/// Global typography — fixed sizes, no viewport scaling.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  /// Semantic scale.
  static const double displaySize = 28;
  static const double headlineSize = 22;
  static const double titleSize = 18;
  static const double subtitleSize = 16;
  static const double bodySize = 14;
  static const double captionSize = 12;

  // Material-style aliases mapped to the semantic scale.
  static const double displayLargeSize = displaySize;
  static const double displayMediumSize = headlineSize;
  static const double displaySmallSize = titleSize;

  static const double headlineLargeSize = headlineSize;
  static const double headlineMediumSize = titleSize;
  static const double headlineSmallSize = subtitleSize;

  static const double titleLargeSize = titleSize;
  static const double titleMediumSize = subtitleSize;
  static const double titleSmallSize = bodySize;

  static const double bodyLargeSize = subtitleSize;
  static const double bodyMediumSize = bodySize;
  static const double bodySmallSize = captionSize;

  static const double labelLargeSize = bodySize;
  static const double labelMediumSize = captionSize;
  static const double labelSmallSize = captionSize;

  /// Builds an Inter [TextStyle] without relying on platform defaults.
  static TextStyle inter({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
    TextBaseline textBaseline = TextBaseline.alphabetic,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      textBaseline: textBaseline,
    );
  }

  static TextTheme get textTheme {
    TextStyle style(double size, {FontWeight weight = FontWeight.w400}) =>
        inter(fontSize: size, fontWeight: weight);

    return TextTheme(
      displayLarge: style(displayLargeSize, weight: FontWeight.w700),
      displayMedium: style(displayMediumSize, weight: FontWeight.w700),
      displaySmall: style(displaySmallSize, weight: FontWeight.w600),
      headlineLarge: style(headlineLargeSize, weight: FontWeight.w700),
      headlineMedium: style(headlineMediumSize, weight: FontWeight.w600),
      headlineSmall: style(headlineSmallSize, weight: FontWeight.w600),
      titleLarge: style(titleLargeSize, weight: FontWeight.w600),
      titleMedium: style(titleMediumSize, weight: FontWeight.w600),
      titleSmall: style(titleSmallSize, weight: FontWeight.w500),
      bodyLarge: style(bodyLargeSize, weight: FontWeight.w500),
      bodyMedium: style(bodyMediumSize, weight: FontWeight.w500),
      bodySmall: style(bodySmallSize),
      labelLarge: style(labelLargeSize, weight: FontWeight.w500),
      labelMedium: style(labelMediumSize, weight: FontWeight.w500),
      labelSmall: style(labelSmallSize),
    );
  }

  /// Replaces platform-specific [Typography] with the global text theme.
  static Typography get typography {
    final theme = textTheme;
    return Typography(
      englishLike: theme,
      dense: theme,
      tall: theme,
    );
  }
}
