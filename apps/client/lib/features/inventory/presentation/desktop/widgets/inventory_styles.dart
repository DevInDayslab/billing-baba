import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:flutter/material.dart';

const inventoryCardBorder = Color(0xFFE0E0E0);
const inventoryTabActiveColor = Color(0xFF1565C0);
const inventoryPrimaryOrange = Color(0xFFFF9800);
const Color inventorySelectedRowColor = listPanelSelectedRowColor;
const inventoryNegativeColor = Color(0xFFD32F2F);
const inventoryPositiveColor = Color(0xFF2E7D32);
const inventoryButtonHeight = 48.0;
const inventoryDropdownWidth = 36.0;

const inventoryPopupMenuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(6)),
  side: BorderSide(color: inventoryCardBorder),
);

const inventoryPopupMenuOffset = Offset(0, inventoryButtonHeight);

/// Minimum width for popup menus (applies to the menu panel, not the trigger).
const inventoryPopupMenuConstraints = BoxConstraints(minWidth: 180);

const TextStyle inventoryPopupMenuItemStyle = TextStyle(
  fontFamily: AppTypography.fontFamily,
  fontSize: AppTypography.bodyMediumSize,
  color: AppColors.textPrimary,
);

/// Popup menu with inventory styling. Resets text/icon colors so items stay
/// readable when the trigger sits inside a colored button.
class InventoryPopupMenuButton<T> extends StatelessWidget {
  const InventoryPopupMenuButton({
    required this.itemBuilder,
    required this.onSelected,
    required this.child,
    this.offset = inventoryPopupMenuOffset,
    this.tooltip,
    this.padding = EdgeInsets.zero,
    this.splashRadius = 18,
    super.key,
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final ValueChanged<T> onSelected;
  final Widget child;
  final Offset offset;
  final String? tooltip;
  final EdgeInsets padding;
  final double splashRadius;

  /// Light popup theme so menu text stays dark on the white menu panel even
  /// when the OS/app uses dark mode (onSurface would otherwise be near-white).
  static ThemeData _popupMenuTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: Theme.of(context).useMaterial3,
      colorScheme: const ColorScheme.light(
        onSurface: AppColors.textPrimary,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        textStyle: inventoryPopupMenuItemStyle,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 18,
      ),
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _popupMenuTheme(context),
      child: PopupMenuButton<T>(
        onSelected: onSelected,
        padding: padding,
        splashRadius: splashRadius,
        tooltip: tooltip ?? '',
        offset: offset,
        color: Colors.white,
        shadowColor: Colors.black26,
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shape: inventoryPopupMenuShape,
        constraints: inventoryPopupMenuConstraints,
        itemBuilder: itemBuilder,
        child: child,
      ),
    );
  }
}

abstract final class InventoryStyles {
  static const TextStyle listHeaderStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.labelSmallSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle panelTitleStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.titleMediumSize,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle emptyStateStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodyMediumSize,
    color: AppColors.textSecondary,
  );

  static const TextStyle listCellStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySmallSize,
    color: AppColors.textPrimary,
  );

  /// Narrow list panel (Products/Services sidebar).
  static const double listPanelCompactFontSize = 11;

  static TextStyle get listPanelCompactCellStyle => listCellStyle.copyWith(
    fontSize: listPanelCompactFontSize,
    height: 1.2,
  );

  static TextStyle get listPanelCompactHeaderStyle => listHeaderStyle.copyWith(
    fontSize: listPanelCompactFontSize,
    letterSpacing: 0.35,
  );
}
