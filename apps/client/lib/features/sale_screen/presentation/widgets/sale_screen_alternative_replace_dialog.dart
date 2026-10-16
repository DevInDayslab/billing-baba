import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/item_alternatives_provider.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item/alternative_items_field.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_item_thumbnail.dart';
import 'package:billing_baba/features/sale_screen/presentation/widgets/sale_screen_pos_item_from_alternative.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final _currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

const _currentItemBackground = Color(0xFFE8F5E9);
const _currentItemBorder = Color(0xFFC8E6C9);
const _tintPurple = Color(0xFFF5F0FF);
const _dashedBorder = Color(0xFFD0D0D0);

/// Replaces selected cart lines with alternatives, one line per step.
class SaleScreenAlternativeReplaceDialog extends ConsumerStatefulWidget {
  const SaleScreenAlternativeReplaceDialog({
    required this.cartSessionKey,
    required this.lines,
    super.key,
  });

  final String cartSessionKey;
  final List<CartItem> lines;

  static Future<void> show(
    BuildContext context, {
    required String cartSessionKey,
    required List<CartItem> lines,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SaleScreenAlternativeReplaceDialog(
        cartSessionKey: cartSessionKey,
        lines: lines,
      ),
    );
  }

  @override
  ConsumerState<SaleScreenAlternativeReplaceDialog> createState() =>
      _SaleScreenAlternativeReplaceDialogState();
}

class _SaleScreenAlternativeReplaceDialogState
    extends ConsumerState<SaleScreenAlternativeReplaceDialog> {
  var _lineIndex = 0;
  String? _selectedAlternativeId;

  CartItem get _currentLine => widget.lines[_lineIndex];

  bool get _hasMoreLines => _lineIndex < widget.lines.length - 1;

  void _advance() {
    if (_hasMoreLines) {
      setState(() {
        _lineIndex += 1;
        _selectedAlternativeId = null;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _replaceSelected() {
    final alternatives = ref
        .read(itemAlternativesProvider(_currentLine.item.id))
        .value;
    final selected = alternatives
        ?.map((row) => row.alternativeItem)
        .where((item) => item.id == _selectedAlternativeId)
        .firstOrNull;
    if (selected == null) return;

    final posItem = posItemFromAlternative(ref, selected, _currentLine);
    ref
        .read(posCartProvider(sessionKey: widget.cartSessionKey).notifier)
        .replaceLineItem(_currentLine.item.id, posItem);
    _advance();
  }

  Future<void> _openAddAlternativesPicker(
    List<ItemAlternativeDto> current,
  ) async {
    final itemId = _currentLine.item.id;
    final existingIds = current.map((row) => row.alternativeItemId).toList();
    final picked = await showAlternativeItemsPickerDialog(
      context: context,
      ref: ref,
      initialSelection: existingIds,
      excludeItemId: itemId,
    );
    if (picked == null || !mounted) return;

    try {
      await ref
          .read(itemAlternativesProvider(itemId).notifier)
          .replaceAlternatives(picked);
    } on InventoryOfflineException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network unavailable. Please check your connection.'),
        ),
      );
    } on InventoryException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update alternatives. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alternativesAsync = ref.watch(
      itemAlternativesProvider(_currentLine.item.id),
    );
    final textTheme = Theme.of(context).textTheme;
    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.88;
    final multi = widget.lines.length > 1;

    return Dialog(
      alignment: Alignment.center,
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: maxDialogHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _tintPurple,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: const Icon(
                      LucideIcons.shuffle,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alternative items',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          multi
                              ? 'Item ${_lineIndex + 1} of ${widget.lines.length}: '
                                  'choose a replacement.'
                              : 'Configure alternative items for this product.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: alternativesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Failed to load alternatives.',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  data: (alternatives) => _AlternativesBody(
                    currentLine: _currentLine,
                    alternatives: alternatives,
                    selectedAlternativeId: _selectedAlternativeId,
                    onSelect: (id) =>
                        setState(() => _selectedAlternativeId = id),
                    onAddAlternative: () =>
                        _openAddAlternativesPicker(alternatives),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  if (_hasMoreLines) ...[
                    TextButton(
                      onPressed: _advance,
                      child: const Text('Next item'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          _selectedAlternativeId == null ? null : _replaceSelected,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(LucideIcons.shuffle, size: 18),
                      label: const Text('Replace'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlternativesBody extends ConsumerWidget {
  const _AlternativesBody({
    required this.currentLine,
    required this.alternatives,
    required this.selectedAlternativeId,
    required this.onSelect,
    required this.onAddAlternative,
  });

  final CartItem currentLine;
  final List<ItemAlternativeDto> alternatives;
  final String? selectedAlternativeId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddAlternative;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CurrentItemCard(line: currentLine),
        const SizedBox(height: AppSpacing.lg),
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
                onPressed: onAddAlternative,
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
          _AlternativesEmptyState(onAddAlternative: onAddAlternative)
        else
          for (final row in alternatives)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _AlternativeCard(
                alternative: row.alternativeItem,
                originalLine: currentLine,
                selected: selectedAlternativeId == row.alternativeItem.id,
                onTap: () => onSelect(row.alternativeItem.id),
              ),
            ),
      ],
    );
  }
}

class _CurrentItemCard extends StatelessWidget {
  const _CurrentItemCard({required this.line});

  final CartItem line;

  @override
  Widget build(BuildContext context) {
    final item = line.item;
    final inStock = item.stock > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _currentItemBackground,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _currentItemBorder),
      ),
      child: Row(
        children: [
          PosItemThumbnail(item: item, size: 48),
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
                  item.sku,
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
                  _currency.format(line.unitPrice),
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
                _StockBadge(inStock: inStock, quantity: item.stock),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternativesEmptyState extends StatelessWidget {
  const _AlternativesEmptyState({required this.onAddAlternative});

  final VoidCallback onAddAlternative;

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
            onPressed: onAddAlternative,
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

class _AlternativeCard extends ConsumerWidget {
  const _AlternativeCard({
    required this.alternative,
    required this.originalLine,
    required this.selected,
    required this.onTap,
  });

  final AlternativeItemDto alternative;
  final CartItem originalLine;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posItem = posItemFromAlternative(ref, alternative, originalLine);
    final hasStock = alternative.stockQuantity > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? _tintPurple : AppColors.surface,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              PosItemThumbnail(item: posItem, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alternative.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alternative.barcode ?? alternative.id,
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
                    _currency.format(alternative.salePrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StockBadge(
                    inStock: hasStock,
                    quantity: alternative.stockQuantity.round(),
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
  const _StockBadge({
    required this.inStock,
    required this.quantity,
  });

  final bool inStock;
  final int quantity;

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
