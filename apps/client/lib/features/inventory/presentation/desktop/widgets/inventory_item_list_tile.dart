import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_list_thumbnail.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

const inventoryItemListRowHeight = 48.0;

/// Gap between ellipsized item name and quantity value.
const inventoryListQtyNameGap = 6.0;

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
    this.onDoubleTap,
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
  final VoidCallback? onDoubleTap;
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

  double _resolveThumbSize(double rowContentWidth) {
    if (rowContentWidth < 48) return 0;
    if (rowContentWidth < 72) return 24;
    if (rowContentWidth < 96) return 28;
    return math.min(
      inventoryItemListThumbSize,
      rowContentWidth * 0.22,
    ).toDouble();
  }

  Widget _buildLeading(double thumbSize) {
    if (thumbSize <= 0) {
      return const SizedBox.shrink();
    }
    final item = widget.item;
    if (item != null) {
      return InventoryItemListThumbnail(item: item, size: thumbSize);
    }
    return Icon(
      widget.leadingIcon,
      size: thumbSize * 0.45,
      color: Colors.grey.shade500,
    );
  }

  TextStyle get _nameStyle =>
      InventoryStyles.listPanelCompactCellStyle.copyWith(
        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
      );

  TextStyle get _qtyStyle => InventoryStyles.listPanelCompactCellStyle.copyWith(
    fontWeight: FontWeight.w600,
    color: widget.trailingColor ?? AppColors.textPrimary,
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rowWidth = constraints.maxWidth;
                  final contentWidth = math.max(
                    0,
                    rowWidth - inventoryListRowMenuWidth,
                  ).toDouble();
                  final thumbSize = _resolveThumbSize(contentWidth);
                  final double thumbGap =
                      thumbSize > 0 ? AppSpacing.xs.toDouble() : 0.0;

                  return Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (thumbSize > 0) ...[
                              _buildLeading(thumbSize),
                              SizedBox(width: thumbGap),
                            ],
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InventoryHighlightedText(
                                      text: widget.title,
                                      query: widget.searchQuery,
                                      style: _nameStyle,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: inventoryListQtyNameGap,
                                    ),
                                    child: Text(
                                      widget.trailingValue,
                                      maxLines: 1,
                                      textAlign: TextAlign.right,
                                      style: _qtyStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: inventoryListRowMenuWidth,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: InventoryListRowMenu(
                            onSelected: widget.onMenuSelected,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
