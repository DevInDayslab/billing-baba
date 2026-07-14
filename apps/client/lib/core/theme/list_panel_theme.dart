import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const listPanelCardBorder = Color(0xFFE0E0E0);
const listPanelSelectedRowColor = Color(0xFFE3F2FD);
const listPanelSelectedRowPressedColor = Color(0xFFBBDEFB);
const listPanelZebraRowColor = Color(0xFFFAFAFA);
const listPanelRowHoverColor = Color(0xFFF5F9FF);
const listPanelRowFocusColor = Color(0xFFF5F9FF);
const listPanelRowPressedColor = Color(0xFFE8F0FE);
const listPanelNegativeColor = Color(0xFFD32F2F);
const listPanelPositiveColor = Color(0xFF2E7D32);

const listPanelPopupMenuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(6)),
  side: BorderSide(color: listPanelCardBorder),
);

const listPanelPopupMenuConstraints = BoxConstraints(minWidth: 180);

const TextStyle listPanelPopupMenuItemStyle = TextStyle(
  fontFamily: AppTypography.fontFamily,
  fontSize: AppTypography.bodyMediumSize,
  color: AppColors.textPrimary,
);

class ListPanelPopupMenuButton<T> extends StatelessWidget {
  const ListPanelPopupMenuButton({
    required this.itemBuilder,
    required this.onSelected,
    required this.child,
    this.offset = const Offset(0, 40),
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

  static ThemeData _popupMenuTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: Theme.of(context).useMaterial3,
      colorScheme: const ColorScheme.light(
        onSurface: AppColors.textPrimary,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        textStyle: listPanelPopupMenuItemStyle,
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
        shape: listPanelPopupMenuShape,
        constraints: listPanelPopupMenuConstraints,
        itemBuilder: itemBuilder,
        child: child,
      ),
    );
  }
}

abstract final class ListPanelStyles {
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
}
