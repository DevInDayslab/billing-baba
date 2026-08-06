import 'package:billing_baba/core/theme/app_colors.dart';
import 'package:billing_baba/core/theme/app_radius.dart';
import 'package:billing_baba/core/theme/app_spacing.dart';
import 'package:billing_baba/core/theme/app_typography.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'app_colors.dart';
export 'app_gradients.dart';
export 'app_icons.dart';
export 'app_radius.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// Forces light appearance and disables OS text scaling for all routes.
class AppThemeScope extends StatelessWidget {
  const AppThemeScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightSystemUi,
      child: MediaQuery(
        data: mediaQuery.copyWith(
          textScaler: TextScaler.noScaling,
          platformBrightness: Brightness.light,
        ),
        child: CupertinoTheme(
          data: const CupertinoThemeData(brightness: Brightness.light),
          child: child,
        ),
      ),
    );
  }
}

/// Application theme configuration.
abstract final class AppTheme {
  /// Dark status/navigation icons for light app surfaces (white/gray).
  static const lightSystemUi = SystemUiOverlayStyle(
    statusBarColor: AppColors.surface,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  static ThemeData get light {
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    final base = FlexThemeData.light(
      scheme: FlexScheme.material,
      colorScheme: colorScheme,
      textTheme: textTheme,
    );

    return base.copyWith(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      typography: AppTypography.typography,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      extensions: const [AppSemanticColors.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: lightSystemUi,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
        shadowColor: Colors.black.withValues(alpha: 0.06),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          side: const BorderSide(color: AppColors.chipBorder),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fabBorder),
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBackground,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.inter(fontSize: AppTypography.bodySmallSize),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
          side: const BorderSide(color: AppColors.chipBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogBorder),
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
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
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
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheetBorder,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return AppTypography.inter(
            fontSize: AppTypography.captionSize,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.navInactive,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.inter(
          fontSize: AppTypography.bodyMediumSize,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: AppTypography.inter(
          fontSize: AppTypography.bodySmallSize,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: AppRadius.smBorder,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: const BorderSide(color: AppColors.chipBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: const BorderSide(color: AppColors.chipBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
