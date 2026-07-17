import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dialogMaxWidth = 560.0;
const _listMaxHeight = 320.0;

enum _ItemSortField { name, quantity }

Future<void> showSelectItemsForCategoryDialog(
  BuildContext context, {
  required String targetCategoryId,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SelectItemsForCategoryDialog(targetCategoryId: targetCategoryId),
    ),
  );
}

class SelectItemsForCategoryDialog extends ConsumerStatefulWidget {
  const SelectItemsForCategoryDialog({
    required this.targetCategoryId,
    super.key,
  });

  final String targetCategoryId;

  @override
  ConsumerState<SelectItemsForCategoryDialog> createState() =>
      _SelectItemsForCategoryDialogState();
}

class _SelectItemsForCategoryDialogState
    extends ConsumerState<SelectItemsForCategoryDialog> {
  final _selectedIds = <String>{};
  var _searchQuery = '';
  var _removeFromExistingCategory = true;
  _ItemSortField _sortField = _ItemSortField.name;
  var _sortAscending = true;

  bool _isMoving = false;

  bool _isInTargetCategory(InventoryItem item) {
    if (widget.targetCategoryId == uncategorizedCategoryId) {
      return item.categoryId == null ||
          item.categoryId == uncategorizedCategoryId;
    }
    return item.categoryId == widget.targetCategoryId;
  }

  List<InventoryItem> _filteredItems(List<InventoryItem> allItems) {
    final engine = ref.read(inventorySearchEngineProvider);
    final items = searchInventoryItems(
      engine,
      allItems.where((item) => !_isInTargetCategory(item)),
      query: _searchQuery,
    ).toList()
      ..sort((a, b) {
        final comparison = switch (_sortField) {
          _ItemSortField.name => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
          _ItemSortField.quantity =>
            (a.quantity ?? 0).compareTo(b.quantity ?? 0),
        };
        return _sortAscending ? comparison : -comparison;
      });

    return items;
  }

  void _toggleSort(_ItemSortField field) {
    setState(() {
      if (_sortField == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortField = field;
        _sortAscending = true;
      }
    });
  }

  void _toggleSelectAll(List<InventoryItem> visibleItems) {
    setState(() {
      if (_selectedIds.length == visibleItems.length &&
          visibleItems.isNotEmpty) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(visibleItems.map((item) => item.id));
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _moveItems() async {
    if (_selectedIds.isEmpty || _isMoving) return;

    setState(() => _isMoving = true);
    final error = await ref
        .read(inventoryItemsProvider.notifier)
        .moveItemsToCategory(
          itemIds: _selectedIds.toList(),
          categoryId: widget.targetCategoryId,
          removeFromExistingCategory: _removeFromExistingCategory,
        );

    if (!mounted) return;
    setState(() => _isMoving = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(inventoryItemsProvider).value ?? [];
    final visibleItems = _filteredItems(allItems);
    final allVisibleSelected =
        visibleItems.isNotEmpty &&
        visibleItems.every((item) => _selectedIds.contains(item.id));

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              InventorySearchField(
                hint: 'Search items',
                onChanged: (query) => setState(() => _searchQuery = query),
              ),
              const SizedBox(height: AppSpacing.md),
              _ItemsTableHeader(
                allSelected: allVisibleSelected,
                hasItems: visibleItems.isNotEmpty,
                sortField: _sortField,
                sortAscending: _sortAscending,
                onSelectAll: () => _toggleSelectAll(visibleItems),
                onSortName: () => _toggleSort(_ItemSortField.name),
                onSortQuantity: () => _toggleSort(_ItemSortField.quantity),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: _listMaxHeight),
                child: visibleItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: Text(
                            'No items available to move',
                            style: InventoryStyles.emptyStateStyle,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: visibleItems.length,
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          return _ItemSelectRow(
                            item: item,
                            isSelected: _selectedIds.contains(item.id),
                            onToggle: () => _toggleItem(item.id),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Checkbox(
                    value: _removeFromExistingCategory,
                    onChanged: (value) => setState(
                      () => _removeFromExistingCategory = value ?? true,
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: inventoryTabActiveColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                        () => _removeFromExistingCategory =
                            !_removeFromExistingCategory,
                      ),
                      child: const Text(
                        'Remove selected items from existing category',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: const Color(0xFFF5F5F5),
                      side: const BorderSide(color: inventoryCardBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _selectedIds.isEmpty || _isMoving
                        ? null
                        : _moveItems,
                    style: FilledButton.styleFrom(
                      backgroundColor: inventoryNegativeColor,
                      disabledBackgroundColor: inventoryNegativeColor
                          .withValues(
                            alpha: 0.4,
                          ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Move to this category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemsTableHeader extends StatelessWidget {
  const _ItemsTableHeader({
    required this.allSelected,
    required this.hasItems,
    required this.sortField,
    required this.sortAscending,
    required this.onSelectAll,
    required this.onSortName,
    required this.onSortQuantity,
  });

  final bool allSelected;
  final bool hasItems;
  final _ItemSortField sortField;
  final bool sortAscending;
  final VoidCallback onSelectAll;
  final VoidCallback onSortName;
  final VoidCallback onSortQuantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: allSelected && hasItems,
              tristate: true,
              onChanged: hasItems ? (_) => onSelectAll() : null,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: inventoryTabActiveColor,
            ),
          ),
          Expanded(
            child: _SortableHeaderCell(
              label: 'Item Name',
              isActive: sortField == _ItemSortField.name,
              ascending: sortAscending,
              onTap: onSortName,
            ),
          ),
          SizedBox(
            width: 100,
            child: _SortableHeaderCell(
              label: 'Quantity',
              isActive: sortField == _ItemSortField.quantity,
              ascending: sortAscending,
              onTap: onSortQuantity,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortableHeaderCell extends StatelessWidget {
  const _SortableHeaderCell({
    required this.label,
    required this.isActive,
    required this.ascending,
    required this.onTap,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final bool isActive;
  final bool ascending;
  final VoidCallback onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Align(
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: InventoryStyles.listHeaderStyle),
            const SizedBox(width: 4),
            Icon(
              isActive
                  ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.swap_vert,
              size: 14,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemSelectRow extends StatelessWidget {
  const _ItemSelectRow({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  final InventoryItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final quantity = item.quantity;
    final quantityColor = quantity != null && quantity < 0
        ? inventoryNegativeColor
        : inventoryPositiveColor;

    return Material(
      color: isSelected ? inventorySelectedRowColor : Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 10,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inventoryCardBorder)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: inventoryTabActiveColor,
                ),
              ),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  quantity?.toString() ?? '-',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, color: quantityColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
