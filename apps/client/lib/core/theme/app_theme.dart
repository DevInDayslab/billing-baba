import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Design token placeholders — finalize values from Figma.
abstract final class AppColors {
  static const primary = Color(0xFF1565C0);
  static const secondary = Color(0xFF455A64);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

/// Global typography scale — platform-independent Inter styles.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  static const double displayLargeSize = 40;
  static const double displayMediumSize = 36;
  static const double displaySmallSize = 32;

  static const double headlineLargeSize = 28;
  static const double headlineMediumSize = 24;
  static const double headlineSmallSize = 20;

  static const double titleLargeSize = 18;
  static const double titleMediumSize = 16;
  static const double titleSmallSize = 14;

  static const double bodyLargeSize = 16;
  static const double bodyMediumSize = 14;
  static const double bodySmallSize = 13;

  static const double labelLargeSize = 14;
  static const double labelMediumSize = 12;
  static const double labelSmallSize = 11;

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
      displayLarge: style(displayLargeSize),
      displayMedium: style(displayMediumSize),
      displaySmall: style(displaySmallSize),
      headlineLarge: style(headlineLargeSize),
      headlineMedium: style(headlineMediumSize),
      headlineSmall: style(headlineSmallSize),
      titleLarge: style(titleLargeSize, weight: FontWeight.w500),
      titleMedium: style(titleMediumSize, weight: FontWeight.w500),
      titleSmall: style(titleSmallSize, weight: FontWeight.w500),
      bodyLarge: style(bodyLargeSize),
      bodyMedium: style(bodyMediumSize),
      bodySmall: style(bodySmallSize),
      labelLarge: style(labelLargeSize, weight: FontWeight.w500),
      labelMedium: style(labelMediumSize, weight: FontWeight.w500),
      labelSmall: style(labelSmallSize, weight: FontWeight.w500),
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

/// Spacing design tokens.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Border radius design tokens.
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
}

/// Forces light appearance and disables OS text scaling for all routes.
class AppThemeScope extends StatelessWidget {
  const AppThemeScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.noScaling,
        platformBrightness: Brightness.light,
      ),
      child: CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.light),
        child: child,
      ),
    );
  }
}

/// Application theme configuration.
abstract final class AppTheme {
  static ThemeData get light {
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final base = FlexThemeData.light(
      scheme: FlexScheme.material,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      textTheme: textTheme,
    );

    return base.copyWith(
      brightness: Brightness.light,
      typography: AppTypography.typography,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: AppColors.surface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: AppTypography.inter(
          fontSize: AppTypography.bodyMediumSize,
          color: AppColors.textPrimary,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTypography.inter(fontSize: AppTypography.bodyMediumSize),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.surface),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.inter(
          fontSize: AppTypography.bodyMediumSize,
          color: Colors.white,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: AppTypography.inter(
          fontSize: AppTypography.bodySmallSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
