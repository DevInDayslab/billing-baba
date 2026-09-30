import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _alternativeRowMinHeight = 40.0;

Future<void> _openAlternativeItemsPicker({
  required BuildContext context,
  required WidgetRef ref,
  required List<String> selectedItemIds,
  required String? excludeItemId,
  required ValueChanged<List<String>> onChanged,
}) async {
  final items = ref.read(inventoryItemListProvider);
  final picked = await showDialog<List<String>>(
    context: context,
    builder: (dialogContext) => _AlternativeItemsPickerDialog(
      items: items,
      initialSelection: selectedItemIds,
      excludeItemId: excludeItemId,
    ),
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
  late final TextEditingController _searchController;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selected = widget.initialSelection.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final engine = ref.watch(inventorySearchEngineProvider);
    final candidates = widget.items
        .where((item) => item.id != widget.excludeItemId)
        .toList();
    final filtered = query.isEmpty
        ? candidates
        : engine.searchItems(candidates, query: query);

    return AlertDialog(
      title: const Text('Select alternative items'),
      content: SizedBox(
        width: 480,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: buildFormControlDecoration(hint: 'Search items'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final checked = _selected.contains(item.id);
                  return CheckboxListTile(
                    value: checked,
                    title: Text(item.name),
                    subtitle: item.shortName?.isNotEmpty == true
                        ? Text(item.shortName!)
                        : null,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(item.id);
                        } else {
                          _selected.remove(item.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected.toList()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
