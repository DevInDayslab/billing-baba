import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_row_menu.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

const inventoryItemListRowHeight = 44.0;

/// Shared inventory list row used by Products and Services.
class InventoryItemListTile extends StatefulWidget {
  const InventoryItemListTile({
    required this.title,
    required this.trailingValue,
    required this.isSelected,
    required this.isFocused,
    required this.searchQuery,
    required this.onHover,
    required this.onTap,
    required this.onMenuSelected,
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
  final VoidCallback onHover;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;
  final IconData leadingIcon;

  @override
  State<InventoryItemListTile> createState() => _InventoryItemListTileState();
}

class _InventoryItemListTileState extends State<InventoryItemListTile> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isSelected
        ? inventorySelectedRowColor
        : _isHovered
            ? const Color(0xFFF5F5F5)
            : widget.isFocused
                ? const Color(0xFFFAFAFA)
                : Colors.transparent;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: inventoryItemListRowHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: const Border(bottom: BorderSide(color: inventoryCardBorder)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    widget.leadingIcon,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
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
                  SizedBox(
                    width: 56,
                    child: Text(
                      widget.trailingValue,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
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
