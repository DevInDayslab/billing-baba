import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/item_alternatives_provider.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/alternative_items_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _chipGreen = Color(0xFF4CAF50);
const _chipRed = Color(0xFFE53935);

class AlternativesSection extends ConsumerWidget {
  const AlternativesSection({
    required this.itemId,
    super.key,
  });

  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemId == null) {
      return Center(
        child: Text(
          'Save the item first to add alternatives.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    final alternativesAsync = ref.watch(itemAlternativesProvider(itemId!));

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
      data: (alternatives) => _buildContent(context, ref, alternatives),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> alternatives,
  ) {
    if (alternatives.isEmpty) {
      return _buildEmptyState(context, ref, alternatives);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAlternativesList(context, ref, alternatives),
        const SizedBox(height: 16),
        _buildAddButton(context, ref, alternatives),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> alternatives,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.arrowLeftRight,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No alternatives added',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add items that can substitute this product',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            _buildAddButton(
              context,
              ref,
              alternatives,
              centered: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativesList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> alternatives,
  ) {
    return Column(
      children: alternatives.map((alternative) {
        final dto = alternative as ItemAlternativeDto;
        return _buildAlternativeCard(context, ref, dto, dto.alternativeItem);
      }).toList(),
    );
  }

  Widget _buildAlternativeCard(
    BuildContext context,
    WidgetRef ref,
    ItemAlternativeDto alternative,
    AlternativeItemDto altItem,
  ) {
    final name = altItem.name;
    final barcode = altItem.barcode;
    final brandName = altItem.brandName;
    final categoryName = altItem.categoryName;
    final salePrice = altItem.salePrice;
    final stockQuantity = altItem.stockQuantity;

    final subtitle = [
      ?brandName,
      ?categoryName,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                if (barcode != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      barcode,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stockQuantity > 0
                      ? _chipGreen.withValues(alpha: 0.1)
                      : _chipRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stockQuantity > 0 ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: stockQuantity > 0 ? _chipGreen : _chipRed,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${salePrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
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

  Widget _buildAddButton(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> alternatives, {
    bool centered = false,
  }) {
    final button = AddAlternativeButton(
      onPressed: () =>
          _showAlternativeItemsPicker(context, ref, alternatives),
    );

    if (centered) return button;

    return Align(
      alignment: Alignment.centerLeft,
      child: button,
    );
  }

  Future<void> _showAlternativeItemsPicker(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> alternatives,
  ) async {
    final existingIds = alternatives
        .map((alt) => (alt as ItemAlternativeDto).alternativeItemId)
        .toList();

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
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update alternatives: $e')),
      );
    }
  }
}
