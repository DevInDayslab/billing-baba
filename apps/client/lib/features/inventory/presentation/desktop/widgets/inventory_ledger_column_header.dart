import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/inventory_transaction_filters.dart';
import 'package:flutter/material.dart';

/// Vyapar-style ledger column header: label + sort arrow (left), filter icon (right).
class InventoryLedgerColumnHeader extends StatelessWidget {
  const InventoryLedgerColumnHeader({
    required this.label,
    required this.sortColumn,
    required this.filters,
    required this.onSort,
    this.filter,
    this.sortable = true,
    super.key,
  });

  final String label;
  final InventoryTransactionSortColumn sortColumn;
  final InventoryTransactionFiltersState filters;
  final VoidCallback onSort;
  final Widget? filter;
  final bool sortable;

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    final isSorted =
        sortable &&
        filters.sortColumn == sortColumn &&
        filters.sortDirection != InventoryTransactionSortDirection.none;

    final sortIcon = switch (filters.sortDirection) {
      InventoryTransactionSortDirection.ascending => Icons.arrow_upward,
      InventoryTransactionSortDirection.descending => Icons.arrow_downward,
      _ => Icons.arrow_upward,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: sortable ? onSort : null,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label.toUpperCase(),
                      style: _headerStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (isSorted) ...[
                    const SizedBox(width: 2),
                    Icon(
                      sortIcon,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          ?filter,
        ],
      ),
    );
  }
}
