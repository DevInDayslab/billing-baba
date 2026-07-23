import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_table_row.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';

/// Width reserved for amount values in expense list panels.
/// Must fit header label + filter icon (see party list: 88px without filter).
const expenseListAmountColWidth = 88.0;

/// Trailing menu column width — matches [InventoryListHeader] default trailing.
const expenseListMenuTrailingWidth = 28.0;

class ExpenseListPanelHeader extends StatelessWidget {
  const ExpenseListPanelHeader({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftFilter,
    required this.rightFilter,
    super.key,
  });

  final String leftLabel;
  final String rightLabel;
  final Widget leftFilter;
  final Widget rightFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: SizedBox(
        height: inventoryListHeaderCompactHeight,
        child: InventoryListRowLayout(
          flexValues: const [1, 0],
          fixedWidths: const [null, expenseListAmountColWidth],
          showColumnSeparators: false,
          trailing: const SizedBox(width: expenseListMenuTrailingWidth),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(leftLabel, style: InventoryStyles.listHeaderStyle),
                  const SizedBox(width: 4),
                  leftFilter,
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rightLabel, style: InventoryStyles.listHeaderStyle),
                    const SizedBox(width: 4),
                    rightFilter,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseListPanelRow extends StatelessWidget {
  const ExpenseListPanelRow({
    required this.index,
    required this.primaryText,
    required this.amountText,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final int index;
  final String primaryText;
  final String amountText;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InventoryListTableRow(
      index: index,
      isSelected: isSelected,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: InventoryListRowLayout(
          flexValues: const [1, 0],
          fixedWidths: const [null, expenseListAmountColWidth],
          alignEnds: const [false, true],
          showColumnSeparators: false,
          trailing: const InventoryListRowMenu(),
          children: [
            AppEllipsisText(
              primaryText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            AppEllipsisText(
              amountText,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
