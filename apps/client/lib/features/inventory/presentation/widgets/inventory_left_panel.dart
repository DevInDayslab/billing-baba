import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_async_list.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_item_list_tile.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_items_filter_trigger.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Canonical Inventory left panel — Products/Services share this layout.
class InventoryLeftPanel extends ConsumerWidget {
  const InventoryLeftPanel({
    required this.items,
    required this.itemsAsync,
    required this.selectedId,
    required this.focusedIndex,
    required this.searchQuery,
    required this.searchFieldKey,
    required this.searchHint,
    required this.addButtonLabel,
    required this.emptyMessage,
    required this.primaryColumnLabel,
    required this.secondaryColumnLabel,
    required this.trailingValueBuilder,
    required this.trailingColorBuilder,
    required this.onSearchChanged,
    required this.onSearchDebounced,
    required this.onSearchEscape,
    required this.onArrowDown,
    required this.onArrowUp,
    required this.onEnter,
    required this.onRefresh,
    required this.onItemHover,
    required this.onItemSelected,
    required this.onAddPressed,
    required this.onMenuSelected,
    this.leadingIcon = Icons.inventory_2_outlined,
    this.showListFilters = true,
    super.key,
  });

  final List<InventoryItem> items;
  final AsyncValue<List<InventoryItem>> itemsAsync;
  final String? selectedId;
  final int focusedIndex;
  final String searchQuery;
  final Key searchFieldKey;
  final String searchHint;
  final String addButtonLabel;
  final String emptyMessage;
  final String primaryColumnLabel;
  final String secondaryColumnLabel;
  final String Function(InventoryItem item) trailingValueBuilder;
  final Color? Function(InventoryItem item) trailingColorBuilder;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchDebounced;
  final VoidCallback onSearchEscape;
  final VoidCallback onArrowDown;
  final VoidCallback onArrowUp;
  final VoidCallback onEnter;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onItemHover;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddPressed;
  final void Function(String value, InventoryItem item) onMenuSelected;
  final IconData leadingIcon;
  final bool showListFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InventorySearchField(
                key: searchFieldKey,
                hint: searchHint,
                initialValue: searchQuery,
                debounceDuration: const Duration(milliseconds: 300),
                onChanged: onSearchChanged,
                onDebouncedChanged: onSearchDebounced,
                onEscape: onSearchEscape,
                onArrowDown: onArrowDown,
                onArrowUp: onArrowUp,
                onEnter: onEnter,
              ),
              const SizedBox(height: 12),
              InventoryPrimaryButton(
                label: addButtonLabel,
                onPressed: onAddPressed,
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        InventoryListHeader(
          showColumnSeparators: false,
          columns: [
            InventoryListColumn(
              label: primaryColumnLabel,
              flex: 3,
              trailing: showListFilters
                  ? InventoryItemsFilterTrigger(
                      compact: true,
                      initialFilters: ref.watch(inventoryItemFiltersProvider),
                      onApply: ref
                          .read(inventoryItemFiltersProvider.notifier)
                          .apply,
                    )
                  : null,
            ),
            InventoryListColumn(
              label: secondaryColumnLabel,
              alignEnd: true,
            ),
          ],
        ),
        Expanded(
          child: InventoryAsyncList<InventoryItem>(
            asyncValue: itemsAsync,
            items: items,
            onRefresh: onRefresh,
            emptyMessage: emptyMessage,
            itemBuilder: (context, item) {
              final index = items.indexOf(item);
              return InventoryItemListTile(
                title: item.name,
                trailingValue: trailingValueBuilder(item),
                trailingColor: trailingColorBuilder(item),
                isSelected: item.id == selectedId,
                isFocused: index == focusedIndex,
                searchQuery: searchQuery,
                leadingIcon: leadingIcon,
                onHover: () => onItemHover(item.id),
                onTap: () => onItemSelected(item.id),
                onMenuSelected: (value) => onMenuSelected(value, item),
              );
            },
          ),
        ),
      ],
    );
  }
}
