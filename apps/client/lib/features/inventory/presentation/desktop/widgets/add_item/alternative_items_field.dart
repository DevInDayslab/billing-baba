import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _alternativeRowMinHeight = 40.0;
const _pickerDialogWidth = 560.0;
const _pickerDialogHeight = 520.0;

String alternativePickerStockLabel(InventoryItem item) {
  if (item.type == ItemType.service) {
    return 'Stock: $inventoryEmDash';
  }
  final metrics = InventoryStockCalculator.metricsFromItem(item);
  final quantityLabel = formatQuantityValue(metrics.availableForSale);
  final unit = item.baseUnitShortName?.trim();
  if (unit != null && unit.isNotEmpty) {
    return 'Stock: $quantityLabel $unit';
  }
  return 'Stock: $quantityLabel';
}

/// Multi-select picker for alternative items (desktop).
Future<List<String>?> showAlternativeItemsPickerDialog({
  required BuildContext context,
  required WidgetRef ref,
  required List<String> initialSelection,
  required String? excludeItemId,
}) {
  final items = ref.read(inventoryItemListProvider);
  return showDialog<List<String>>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: _AlternativeItemsPickerDialog(
        items: items,
        initialSelection: initialSelection,
        excludeItemId: excludeItemId,
      ),
    ),
  );
}

Future<void> _openAlternativeItemsPicker({
  required BuildContext context,
  required WidgetRef ref,
  required List<String> selectedItemIds,
  required String? excludeItemId,
  required ValueChanged<List<String>> onChanged,
}) async {
  final picked = await showAlternativeItemsPickerDialog(
    context: context,
    ref: ref,
    initialSelection: selectedItemIds,
    excludeItemId: excludeItemId,
  );
  if (picked != null) onChanged(picked);
}

/// Pill button — sits inline to the right of the description field.
class AlternativeItemsAddButton extends ConsumerWidget {
  const AlternativeItemsAddButton({
    required this.selectedItemIds,
    required this.excludeItemId,
    required this.onChanged,
    super.key,
  });

  final List<String> selectedItemIds;
  final String? excludeItemId;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AddAlternativeButton(
      onPressed: () => _openAlternativeItemsPicker(
        context: context,
        ref: ref,
        selectedItemIds: selectedItemIds,
        excludeItemId: excludeItemId,
        onChanged: onChanged,
      ),
    );
  }
}

/// Selected alternatives list — shown below the form grid (party pattern).
class AlternativeItemsListSection extends ConsumerWidget {
  const AlternativeItemsListSection({
    required this.selectedItemIds,
    required this.excludeItemId,
    required this.onChanged,
    super.key,
  });

  final List<String> selectedItemIds;
  final String? excludeItemId;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inventoryItemListProvider);
    final itemsById = {for (final item in items) item.id: item};
    final selectedItems = selectedItemIds
        .map((id) => itemsById[id])
        .whereType<InventoryItem>()
        .toList();

    if (selectedItems.isEmpty) return const SizedBox.shrink();

    return _AlternativesListCard(
      items: selectedItems,
      onEdit: () => _openAlternativeItemsPicker(
        context: context,
        ref: ref,
        selectedItemIds: selectedItemIds,
        excludeItemId: excludeItemId,
        onChanged: onChanged,
      ),
      onRemove: (id) =>
          onChanged(selectedItemIds.where((itemId) => itemId != id).toList()),
    );
  }
}

class _AlternativesListCard extends StatelessWidget {
  const _AlternativesListCard({
    required this.items,
    required this.onEdit,
    required this.onRemove,
  });

  final List<InventoryItem> items;
  final VoidCallback onEdit;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.package,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Alternative Items',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          for (var index = 0; index < items.length; index++) ...[
            _AlternativeItemRow(
              item: items[index],
              onEdit: onEdit,
              onRemove: () => onRemove(items[index].id),
            ),
            if (index < items.length - 1)
              const Divider(height: 1, color: _cardBorder),
          ],
        ],
      ),
    );
  }
}

class AddAlternativeButton extends StatelessWidget {
  const AddAlternativeButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      shape: StadiumBorder(
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Text(
                'Add alternative',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlternativeItemRow extends StatelessWidget {
  const _AlternativeItemRow({
    required this.item,
    required this.onEdit,
    required this.onRemove,
  });

  final InventoryItem item;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final subtitle = item.shortName?.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _alternativeRowMinHeight),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.gripVertical,
              size: 18,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              LucideIcons.package,
              size: 18,
              color: AppColors.textSecondary.withValues(alpha: 0.65),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit alternatives',
              onPressed: onEdit,
              icon: Icon(
                LucideIcons.pencil,
                size: 17,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
              ),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              tooltip: 'Remove alternative',
              onPressed: onRemove,
              icon: Icon(
                LucideIcons.trash2,
                size: 17,
                color: AppColors.error.withValues(alpha: 0.9),
              ),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlternativeItemsPickerDialog extends ConsumerStatefulWidget {
  const _AlternativeItemsPickerDialog({
    required this.items,
    required this.initialSelection,
    this.excludeItemId,
  });

  final List<InventoryItem> items;
  final List<String> initialSelection;
  final String? excludeItemId;

  @override
  ConsumerState<_AlternativeItemsPickerDialog> createState() =>
      _AlternativeItemsPickerDialogState();
}

class _AlternativeItemsPickerDialogState
    extends ConsumerState<_AlternativeItemsPickerDialog> {
  late Set<String> _selected;
  var _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection.toSet();
  }

  List<InventoryItem> get _candidates =>
      widget.items.where((item) => item.id != widget.excludeItemId).toList();

  List<InventoryItem> get _visibleItems {
    final engine = ref.read(inventorySearchEngineProvider);
    return searchInventoryItems(
      engine,
      _candidates,
      query: _searchQuery,
    ).toList();
  }

  void _toggleAll(List<InventoryItem> visible) {
    final allSelected =
        visible.isNotEmpty && visible.every((i) => _selected.contains(i.id));
    setState(() {
      if (allSelected) {
        for (final item in visible) {
          _selected.remove(item.id);
        }
      } else {
        _selected.addAll(visible.map((i) => i.id));
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;
    final allSelected =
        visible.isNotEmpty && visible.every((i) => _selected.contains(i.id));
    final selectionCount = _selected.length;

    return ClipRRect(
      borderRadius: AppRadius.lgBorder,
      child: SizedBox(
        width: _pickerDialogWidth,
        height: _pickerDialogHeight,
        child: Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.package,
                      size: 22,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select alternative items',
                            style: AppTypography.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose items that can be suggested as alternatives '
                            'for this product.',
                            style: AppTypography.inter(
                              fontSize: AppTypography.bodySmallSize,
                              height: 1.45,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                InventorySearchField(
                  hint: 'Search items by name or code...',
                  onChanged: (query) => setState(() => _searchQuery = query),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Checkbox(
                        value: allSelected,
                        onChanged: visible.isEmpty
                            ? null
                            : (_) => _toggleAll(visible),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Text(
                        'Select all',
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySmallSize,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$selectionCount selected',
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySmallSize,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: listPanelCardBorder),
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.mdBorder,
                      child: visible.isEmpty
                          ? Center(
                              child: Text(
                                'No items found',
                                style: InventoryStyles.emptyStateStyle,
                              ),
                            )
                          : ListView.separated(
                              itemCount: visible.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: listPanelCardBorder,
                              ),
                              itemBuilder: (context, index) {
                                final item = visible[index];
                                return _AlternativePickerItemRow(
                                  item: item,
                                  isSelected: _selected.contains(item.id),
                                  onToggle: () => _toggleItem(item.id),
                                );
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pop(_selected.toList()),
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: Text('Save ($selectionCount)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlternativePickerItemRow extends StatefulWidget {
  const _AlternativePickerItemRow({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  final InventoryItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  State<_AlternativePickerItemRow> createState() =>
      _AlternativePickerItemRowState();
}

class _AlternativePickerItemRowState extends State<_AlternativePickerItemRow> {
  var _isHovered = false;

  Color get _backgroundColor {
    if (widget.isSelected) return listPanelSelectedRowColor;
    if (_isHovered) return listPanelRowHoverColor;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _backgroundColor,
        child: InkWell(
          onTap: widget.onToggle,
          hoverColor: Colors.transparent,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.package,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.65),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alternativePickerStockLabel(widget.item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: 11,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (_) => widget.onToggle(),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
