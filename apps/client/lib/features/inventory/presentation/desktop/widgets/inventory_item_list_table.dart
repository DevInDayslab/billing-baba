import 'package:billing_baba/features/inventory/models/inventory_item_filters.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_items_filter_trigger.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Column definition for [buildInventoryItemListColumns].
class InventoryItemListColumnSpec {
  const InventoryItemListColumnSpec({
    required this.label,
    this.flex = 1,
    this.alignEnd = false,
    this.showFilter = true,
    this.sortable = false,
    this.isSorted = false,
    this.sortAscending = true,
    this.onSort,
  });

  final String label;
  final int flex;
  final bool alignEnd;
  final bool showFilter;
  final bool sortable;
  final bool isSorted;
  final bool sortAscending;
  final VoidCallback? onSort;
}

/// Canonical right-side detail list table (Category Items, party ledger, etc.).
class InventoryItemListTable<T> extends StatelessWidget {
  const InventoryItemListTable({
    required this.columns,
    required this.items,
    required this.itemsAsync,
    required this.emptyMessage,
    required this.onRefresh,
    required this.itemBuilder,
    this.includeTrailingSpace = true,
    this.showColumnSeparators = true,
    super.key,
  });

  final List<InventoryListColumn> columns;
  final List<T> items;
  final AsyncValue<List<T>> itemsAsync;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool includeTrailingSpace;
  final bool showColumnSeparators;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InventoryListHeader(
          columns: columns,
          includeTrailingSpace: includeTrailingSpace,
          showColumnSeparators: showColumnSeparators,
        ),
        Expanded(
          child: InventoryAsyncList<T>(
            asyncValue: itemsAsync,
            items: items,
            onRefresh: onRefresh,
            emptyMessage: emptyMessage,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}

/// Builds column headers with the shared filter and sort widgets.
List<InventoryListColumn> buildInventoryItemListColumns({
  required List<InventoryItemListColumnSpec> specs,
  required InventoryItemFiltersState filters,
  required ValueChanged<InventoryItemFiltersState> onFilterApply,
}) {
  return [
    for (final spec in specs)
      InventoryListColumn(
        label: spec.label,
        flex: spec.flex,
        alignEnd: spec.alignEnd,
        sortable: spec.sortable,
        isSorted: spec.isSorted,
        sortAscending: spec.sortAscending,
        onSort: spec.onSort,
        trailing: spec.showFilter
            ? InventoryItemsFilterTrigger(
                compact: true,
                initialFilters: filters,
                onApply: onFilterApply,
              )
            : null,
      ),
  ];
}
