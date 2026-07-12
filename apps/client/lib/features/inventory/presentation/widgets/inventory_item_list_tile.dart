import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_table_row.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

export 'inventory_list_table_row.dart' show inventoryItemListRowHeight;

const inventoryListRowHorizontalPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.md,
);

/// Trailing/value text style shared by Products and Category list rows.
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

/// Shared inventory list row used by Products, Services, and Categories.
class InventoryItemListTile extends StatelessWidget {
  /// Products / Services row.
  const InventoryItemListTile({
    required this.index,
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
    this.showColumnSeparators = true,
    super.key,
  }) : flexValues = const [3, 1],
       alignEnds = const [false, true],
       cells = null;

  /// Category rows — same [InventoryListTableRow] + [InventoryListRowLayout] tree.
  const InventoryItemListTile.columns({
    required this.index,
    required this.flexValues,
    required this.cells,
    required this.alignEnds,
    this.showColumnSeparators = true,
    super.key,
  }) : title = '',
       trailingValue = '',
       trailingColor = null,
       isSelected = false,
       isFocused = false,
       searchQuery = '',
       onHover = null,
       onTap = null,
       onMenuSelected = null,
       leadingIcon = Icons.inventory_2_outlined;

  final int index;
  final List<int> flexValues;
  final List<Widget>? cells;
  final List<bool> alignEnds;
  final bool showColumnSeparators;

  final String title;
  final String trailingValue;
  final Color? trailingColor;
  final bool isSelected;
  final bool isFocused;
  final String searchQuery;
  final VoidCallback? onHover;
  final VoidCallback? onTap;
  final ValueChanged<String>? onMenuSelected;
  final IconData leadingIcon;

  bool get _isProductRow => cells == null;

  @override
  Widget build(BuildContext context) {
    final layoutChildren =
        cells ??
        [
          InventoryHighlightedText(
            text: title,
            query: searchQuery,
            style: InventoryStyles.listCellStyle.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          SizedBox(
            width: 56,
            child: InventoryListValueText(
              value: trailingValue,
              color: trailingColor,
              textAlign: TextAlign.right,
            ),
          ),
        ];

    final layout = InventoryListRowLayout(
      flexValues: flexValues,
      alignEnds: alignEnds,
      showColumnSeparators: showColumnSeparators,
      trailing: onMenuSelected != null
          ? InventoryListRowMenu(onSelected: onMenuSelected)
          : const SizedBox.shrink(),
      children: layoutChildren,
    );

    final inner = _isProductRow
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  leadingIcon,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: layout),
            ],
          )
        : layout;

    return InventoryListTableRow(
      index: index,
      isSelected: isSelected,
      isFocused: isFocused,
      onHover: onHover,
      onTap: onTap,
      child: Padding(
        padding: inventoryListRowHorizontalPadding,
        child: SizedBox(
          height: inventoryItemListRowHeight,
          child: inner,
        ),
      ),
    );
  }
}
