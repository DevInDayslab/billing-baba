import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

/// Zebra background for odd rows — matches inventory transactions table.
const inventoryListZebraRowColor = Color(0xFFFAFAFA);

/// Row hover background used across inventory list tables.
const inventoryListRowHoverColor = Color(0xFFF5F5F5);

/// Row keyboard-focus background used across inventory list tables.
const inventoryListRowFocusColor = Color(0xFFFAFAFA);

const inventoryItemListRowHeight = 44.0;

/// Shared row shell for right-side detail tables.
///
/// Hover uses [InkWell] (same as Sales tables) so popup menus anchored in the
/// actions column do not leave a stuck row highlight.
class InventoryListTableRow extends StatelessWidget {
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

  Color get _backgroundColor {
    if (isSelected) return inventorySelectedRowColor;
    if (isFocused) return inventoryListRowFocusColor;
    return index.isOdd ? inventoryListZebraRowColor : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final canHover = onTap != null && !isSelected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: inventoryItemListRowHeight,
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: const Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: canHover ? inventoryListRowHoverColor : Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}
