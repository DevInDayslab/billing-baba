import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

/// Zebra background for odd rows — matches inventory transactions table.
const inventoryListZebraRowColor = Color(0xFFFAFAFA);

/// Row hover background used across inventory list tables.
const inventoryListRowHoverColor = Color(0xFFF5F5F5);

/// Row keyboard-focus background used across inventory list tables.
const inventoryListRowFocusColor = Color(0xFFFAFAFA);

const inventoryItemListRowHeight = 44.0;

/// Shared row shell for inventory list tables (Products, Services, Categories).
class InventoryListTableRow extends StatefulWidget {
  const InventoryListTableRow({
    required this.index,
    required this.child,
    this.isSelected = false,
    this.isFocused = false,
    this.onHover,
    this.onTap,
    super.key,
  });

  final int index;
  final Widget child;
  final bool isSelected;
  final bool isFocused;
  final VoidCallback? onHover;
  final VoidCallback? onTap;

  @override
  State<InventoryListTableRow> createState() => _InventoryListTableRowState();
}

class _InventoryListTableRowState extends State<InventoryListTableRow> {
  var _isHovered = false;

  Color get _backgroundColor {
    if (widget.isSelected) return inventorySelectedRowColor;
    if (_isHovered) return inventoryListRowHoverColor;
    if (widget.isFocused) return inventoryListRowFocusColor;
    return widget.index.isOdd ? inventoryListZebraRowColor : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.onHover?.call();
      },
      onExit: (_) => setState(() => _isHovered = false),
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
            hoverColor: Colors.transparent,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
