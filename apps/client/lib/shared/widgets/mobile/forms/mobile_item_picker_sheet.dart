import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Result from picking an item and optional quantity/price for a line.
class MobileItemPickResult {
  const MobileItemPickResult({
    required this.item,
    required this.quantity,
    required this.pricePerUnit,
  });

  final InventoryItem item;
  final double quantity;
  final double pricePerUnit;
}

Future<MobileItemPickResult?> showMobileItemPickerSheet(
  BuildContext context, {
  String title = 'Add item',
}) {
  return showMobileBottomSheet<MobileItemPickResult>(
    context: context,
    builder: (context) => MobileItemPickerSheet(title: title),
  );
}

class MobileItemPickerSheet extends ConsumerStatefulWidget {
  const MobileItemPickerSheet({required this.title, super.key});

  final String title;

  @override
  ConsumerState<MobileItemPickerSheet> createState() =>
      _MobileItemPickerSheetState();
}

class _MobileItemPickerSheetState extends ConsumerState<MobileItemPickerSheet> {
  String _query = '';
  InventoryItem? _selected;
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _selectItem(InventoryItem item) {
    setState(() {
      _selected = item;
      _priceController.text = (item.salePrice ?? 0).toStringAsFixed(2);
    });
  }

  void _confirm() {
    final item = _selected;
    if (item == null) return;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ??
        item.salePrice ??
        0;
    if (qty <= 0) return;
    Navigator.of(context).pop(
      MobileItemPickResult(
        item: item,
        quantity: qty,
        pricePerUnit: price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inventoryItemListProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTypography.inter(
                      fontSize: AppTypography.titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          if (_selected == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MobileSearchField(
                hint: 'Search items',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: Builder(
                builder: (context) {
                  final q = _query.trim().toLowerCase();
                  final filtered = items.where((InventoryItem item) {
                    if (q.isEmpty) return true;
                    return item.name.toLowerCase().contains(q) ||
                        (item.barcode?.contains(q) ?? false);
                  }).toList();
                  if (filtered.isEmpty) {
                    return const MobileEmptyState(
                      title: 'No items found',
                      icon: Icons.inventory_2_outlined,
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '₹ ${(item.salePrice ?? 0).toStringAsFixed(2)}',
                        ),
                        onTap: () => _selectItem(item),
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _selected!.name,
                    style: AppTypography.inter(
                      fontSize: AppTypography.subtitleSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Price per unit',
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _confirm,
                    child: const Text('Add line'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () => setState(() => _selected = null),
                    child: const Text('Choose different item'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
