import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_item_hover_tooltip.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_row_menu.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

const inventoryItemListRowHeight = 44.0;

/// Left sidebar list row used by Products and Services.
class InventoryItemListTile extends StatefulWidget {
  const InventoryItemListTile({
    required this.title,
    required this.trailingValue,
    required this.isSelected,
    required this.isFocused,
    required this.searchQuery,
    required this.onTap,
    required this.onMenuSelected,
    this.item,
    this.trailingColor,
    this.leadingIcon = Icons.inventory_2_outlined,
    super.key,
  });

  final String title;
  final String trailingValue;
  final Color? trailingColor;
  final bool isSelected;
  final bool isFocused;
  final String searchQuery;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;
  final InventoryItem? item;
  final IconData leadingIcon;

  @override
  State<InventoryItemListTile> createState() => _InventoryItemListTileState();
}

class _InventoryItemListTileState extends State<InventoryItemListTile> {
  var _isHovered = false;
  var _isPressed = false;

  @override
  void didUpdateWidget(InventoryItemListTile oldWidget) {
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
    return Colors.transparent;
  }

  static const _transparentOverlay = WidgetStatePropertyAll<Color?>(
    Colors.transparent,
  );

  Widget _buildHoverZone({required Widget child}) {
    final item = widget.item;
    if (item == null) return child;
    return InventoryItemRowPreviewTooltip(item: item, child: child);
  }

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
            onHighlightChanged: (pressed) => setState(() => _isPressed = pressed),
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            overlayColor: _transparentOverlay,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildHoverZone(
                      child: Row(
                        children: [
                          Icon(
                            widget.leadingIcon,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InventoryHighlightedText(
                              text: widget.title,
                              query: widget.searchQuery,
                              style: InventoryStyles.listCellStyle.copyWith(
                                fontWeight: widget.isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: AppEllipsisText(
                      widget.trailingValue,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.trailingColor ?? AppColors.textPrimary,
                      ),
                    ),
                  ),
                  InventoryListRowMenu(onSelected: widget.onMenuSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
