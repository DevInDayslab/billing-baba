import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/item_alternatives_provider.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/alternative_items_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_item_list_thumbnail.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _currentItemBackground = Color(0xFFE8F5E9);
const _currentItemBorder = Color(0xFFC8E6C9);
const _tintPurple = Color(0xFFF5F0FF);
const _dashedBorder = Color(0xFFD0D0D0);

final _currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

class AlternativesSection extends ConsumerWidget {
  const AlternativesSection({
    this.itemId,
    this.draftAlternativeItemIds,
    this.onDraftAlternativeItemIdsChanged,
    super.key,
  }) : assert(
         itemId != null ||
             (draftAlternativeItemIds != null &&
                 onDraftAlternativeItemIdsChanged != null),
         'Provide itemId or draft alternative item handlers',
       );

  final String? itemId;
  final List<String>? draftAlternativeItemIds;
  final ValueChanged<List<String>>? onDraftAlternativeItemIdsChanged;

  bool get _isDraftMode => itemId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isDraftMode) {
      return _DraftAlternativesContent(
        selectedItemIds: draftAlternativeItemIds!,
        onChanged: onDraftAlternativeItemIdsChanged!,
      );
    }

    final alternativesAsync = ref.watch(itemAlternativesProvider(itemId!));
    final currentItem = ref
        .watch(inventoryItemListProvider)
        .where((item) => item.id == itemId)
        .firstOrNull;

    return alternativesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Failed to load alternatives',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.invalidate(itemAlternativesProvider(itemId!)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (alternatives) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (currentItem != null) ...[
              _CurrentItemCard(item: currentItem),
              const SizedBox(height: AppSpacing.lg),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Available alternatives',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (alternatives.isNotEmpty)
                  TextButton(
                    onPressed: () => _showAlternativeItemsPicker(
                      context,
                      ref,
                      alternatives,
                    ),
                    child: const Text('+ Add alternative'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'These items can be used as an alternative when this item is '
              'unavailable.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (alternatives.isEmpty)
              _AlternativesEmptyState(
                onAdd: () =>
                    _showAlternativeItemsPicker(context, ref, alternatives),
              )
            else ...[
              for (final row in alternatives)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildAlternativeCard(
                    context,
                    ref,
                    row,
                    row.alternativeItem,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeCard(
    BuildContext context,
    WidgetRef ref,
    ItemAlternativeDto alternative,
    AlternativeItemDto altItem,
  ) {
    final stockQuantity = altItem.stockQuantity;
    final inStock = stockQuantity > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: AppRadius.mdBorder,
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          InventoryItemListThumbnail(
            item: InventoryItem(
              id: altItem.id,
              name: altItem.name,
              type: ItemType.product,
              barcode: altItem.barcode,
              salePrice: altItem.salePrice,
              quantity: altItem.stockQuantity,
            ),
            size: 48,
            borderRadius: 6,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  altItem.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  altItem.barcode ?? altItem.id,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currency.format(altItem.salePrice),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              _StockBadge(inStock: inStock),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: () => _confirmDelete(context, ref, alternative),
            icon: Icon(
              LucideIcons.trash2,
              size: 16,
              color: Colors.grey.shade600,
            ),
            tooltip: 'Remove alternative',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ItemAlternativeDto alternative,
  ) async {
    final itemName = alternative.alternativeItem.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Alternative'),
        content: Text('Remove "$itemName" from alternatives?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(itemAlternativesProvider(itemId!).notifier)
          .removeAlternative(
            alternative.alternativeItemId,
            relationId: alternative.id,
          );
    } on InventoryOfflineException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network unavailable. Please check your connection.'),
        ),
      );
    } on InventoryException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove alternative. Please try again.'),
        ),
      );
    }
  }

  Future<void> _showAlternativeItemsPicker(
    BuildContext context,
    WidgetRef ref,
    List<ItemAlternativeDto> alternatives,
  ) async {
    final existingIds =
        alternatives.map((alt) => alt.alternativeItemId).toList();

    final picked = await showAlternativeItemsPickerDialog(
      context: context,
      ref: ref,
      initialSelection: existingIds,
      excludeItemId: itemId,
    );

    if (picked == null || !context.mounted) return;

    try {
      await ref
          .read(itemAlternativesProvider(itemId!).notifier)
          .replaceAlternatives(picked);
    } on InventoryOfflineException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network unavailable. Please check your connection.'),
        ),
      );
    } on InventoryException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update alternatives: $e')),
      );
    }
  }
}

class _DraftAlternativesContent extends ConsumerWidget {
  const _DraftAlternativesContent({
    required this.selectedItemIds,
    required this.onChanged,
  });

  final List<String> selectedItemIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inventoryItemListProvider);
    final itemsById = {for (final item in items) item.id: item};
    final selectedItems = selectedItemIds
        .map((id) => itemsById[id])
        .whereType<InventoryItem>()
        .toList();

    Future<void> openPicker() async {
      final picked = await showAlternativeItemsPickerDialog(
        context: context,
        ref: ref,
        initialSelection: selectedItemIds,
        excludeItemId: null,
      );
      if (picked != null) onChanged(picked);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Available alternatives',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selectedItems.isNotEmpty)
                TextButton(
                  onPressed: openPicker,
                  child: const Text('+ Add alternative'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'These items can be used as an alternative when this item is '
            'unavailable.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (selectedItems.isEmpty)
            _AlternativesEmptyState(onAdd: openPicker)
          else
            for (final item in selectedItems)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _DraftAlternativeCard(
                  item: item,
                  onRemove: () => onChanged(
                    selectedItemIds
                        .where((id) => id != item.id)
                        .toList(),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _DraftAlternativeCard extends StatelessWidget {
  const _DraftAlternativeCard({
    required this.item,
    required this.onRemove,
  });

  final InventoryItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final metrics = InventoryStockCalculator.metricsFromItem(item);
    final stockQuantity = metrics.availableForSale;
    final inStock = stockQuantity > 0;
    final salePrice = item.salePrice ?? item.mrp ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: AppRadius.mdBorder,
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          InventoryItemListThumbnail(
            item: item,
            size: 48,
            borderRadius: 6,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.barcode ?? item.id,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currency.format(salePrice),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              _StockBadge(inStock: inStock),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              LucideIcons.trash2,
              size: 16,
              color: Colors.grey.shade600,
            ),
            tooltip: 'Remove alternative',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CurrentItemCard extends StatelessWidget {
  const _CurrentItemCard({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity ?? item.availableForSale ?? 0;
    final inStock = qty > 0;
    final price = item.salePrice ?? item.mrp ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _currentItemBackground,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _currentItemBorder),
      ),
      child: Row(
        children: [
          InventoryItemListThumbnail(item: item, size: 48, borderRadius: 6),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.barcode ?? item.id,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currency.format(price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                _StockBadge(inStock: inStock),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternativesEmptyState extends StatelessWidget {
  const _AlternativesEmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _dashedBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: _tintPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.arrowLeftRight,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No alternatives configured',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Add alternative items that can be used when this item is '
            'out of stock.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add alternative item'),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: _currentItemBorder,
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: inStock ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        inStock ? 'In Stock' : 'Out of Stock',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: inStock ? const Color(0xFF2E7D32) : AppColors.error,
        ),
      ),
    );
  }
}
