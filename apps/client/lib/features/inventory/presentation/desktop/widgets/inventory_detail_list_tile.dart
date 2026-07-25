import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_table_row.dart';
import 'package:flutter/material.dart';

export 'inventory_list_table_row.dart' show inventoryItemListRowHeight;

const inventoryDetailListRowHorizontalPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.md,
);

/// Trailing/value text style shared by detail table rows.
TextStyle inventoryListValueTextStyle({Color? color}) {
  return TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
  );
}

class InventoryListValueText extends StatelessWidget {
  const InventoryListValueText({
    required this.value,
    this.color,
    this.textAlign = TextAlign.left,
    super.key,
  });

  final String value;
  final Color? color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: inventoryListValueTextStyle(color: color),
    );
  }
}

/// Multi-column row for right-side detail tables (Category Items, etc.).
class InventoryDetailListTile extends StatelessWidget {
  const InventoryDetailListTile({
    required this.index,
    required this.flexValues,
    required this.cells,
    required this.alignEnds,
    this.showColumnSeparators = true,
    this.onTap,
    this.onDoubleTap,
    this.onDoubleTapDown,
    super.key,
  });

  final int index;
  final List<int> flexValues;
  final List<Widget> cells;
  final List<bool> alignEnds;
  final bool showColumnSeparators;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapDownCallback? onDoubleTapDown;

  @override
  Widget build(BuildContext context) {
    return InventoryListTableRow(
      index: index,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onDoubleTapDown: onDoubleTapDown,
      child: Padding(
        padding: inventoryDetailListRowHorizontalPadding,
        child: SizedBox(
          height: inventoryItemListRowHeight,
          child: InventoryListRowLayout(
            flexValues: flexValues,
            alignEnds: alignEnds,
            showColumnSeparators: showColumnSeparators,
            trailing: const SizedBox.shrink(),
            children: cells,
          ),
        ),
      ),
    );
  }
}
