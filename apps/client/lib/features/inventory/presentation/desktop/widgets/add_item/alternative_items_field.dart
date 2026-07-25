import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlternativeItemsField extends ConsumerWidget {
  const AlternativeItemsField({
    required this.selectedItemIds,
    required this.excludeItemId,
    required this.onChanged,
    super.key,
  });

  final List<String> selectedItemIds;
  final String? excludeItemId;
  final ValueChanged<List<String>> onChanged;

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final items = ref.read(inventoryItemsProvider).value ?? const [];
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inventoryItemsProvider).value ?? const [];
    final itemsById = {for (final item in items) item.id: item};
    final selectedItems = selectedItemIds
        .map((id) => itemsById[id])
        .whereType<InventoryItem>()
        .toList();

    return AppFormField(
      label: 'Alternative Items',
      fixedHeight: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in selectedItems)
                InputChip(
                  label: Text(item.name),
                  onDeleted: () => onChanged(
                    selectedItemIds.where((id) => id != item.id).toList(),
                  ),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Add alternative'),
                onPressed: () => _openPicker(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Suggested when users search for this item on invoices.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
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
