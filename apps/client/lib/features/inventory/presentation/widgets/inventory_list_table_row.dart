import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

/// Zebra background for odd rows — matches inventory transactions table.
const Color inventoryListZebraRowColor = listPanelZebraRowColor;

/// Row hover background used across inventory list tables.
const Color inventoryListRowHoverColor = listPanelRowHoverColor;

/// Row keyboard-focus background used across inventory list tables.
const Color inventoryListRowFocusColor = listPanelRowFocusColor;

const inventoryItemListRowHeight = 44.0;

/// Shared row shell for left-panel lists and right-side detail tables.
///
/// Background colors are owned here via [MouseRegion] + [AnimatedContainer], not
/// [InkWell] only handles tap/semantics; ink overlays are forced transparent so
/// Material 3 never paints theme fallback ink (which can appear dark/black
/// changes under an active pointer).
class InventoryListTableRow extends StatefulWidget {
  const InventoryListTableRow({
    required this.index,
    required this.child,
    this.isSelected = false,
    this.isFocused = false,
    this.onTap,
    super.key,
  });

  final int index;
  final Widget child;
  final bool isSelected;
  final bool isFocused;
  final VoidCallback? onTap;

  @override
  State<InventoryListTableRow> createState() => _InventoryListTableRowState();
}

class _InventoryListTableRowState extends State<InventoryListTableRow> {
  var _isHovered = false;
  var _isPressed = false;

  @override
  void didUpdateWidget(InventoryListTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected && widget.isSelected) {
      _isHovered = false;
      _isPressed = false;
    }
  }

  Color get _backgroundColor {
    if (widget.isSelected) {
      return _isPressed
          ? listPanelSelectedRowPressedColor
          : listPanelSelectedRowColor;
    }
    if (_isPressed) return listPanelRowPressedColor;
    if (_isHovered) return listPanelRowHoverColor;
    if (widget.isFocused) return listPanelRowFocusColor;
    return widget.index.isOdd ? listPanelZebraRowColor : AppColors.surface;
  }

  static const _transparentOverlay = WidgetStatePropertyAll<Color?>(
    Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: inventoryItemListRowHeight,
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: const Border(bottom: BorderSide(color: inventoryCardBorder)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: widget.onTap == null
                ? null
                : (pressed) => setState(() => _isPressed = pressed),
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            overlayColor: _transparentOverlay,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
