import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/application/item_alternatives_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (alternatives.isEmpty)
          _buildEmptyState()
        else
          _buildAlternativesList(context, ref, alternatives),
        const SizedBox(height: 16),
        _buildAddButton(context, ref, alternatives),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
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
        final altItem = (alternative as dynamic).alternativeItem;
        return _buildAlternativeCard(context, ref, alternative, altItem);
      }).toList(),
    );
  }

  Widget _buildAlternativeCard(
    BuildContext context,
    WidgetRef ref,
    dynamic alternative,
    dynamic altItem,
  ) {
    final name = altItem.name as String;
    final barcode = altItem.barcode as String?;
    final brandName = altItem.brandName as String?;
    final categoryName = altItem.categoryName as String?;
    final salePrice = altItem.salePrice as double;
    final stockQuantity = altItem.stockQuantity as double;
    final alternativeItemId =
        (alternative as dynamic).alternativeItemId as String;

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
            onPressed: () =>
                _confirmDelete(context, ref, alternativeItemId, name),
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
    String alternativeItemId,
    String itemName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Alternative'),
        content: Text('Remove "$itemName" from alternatives?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(itemAlternativesProvider(itemId!).notifier)
          .removeAlternative(alternativeItemId);
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
    }
  }

  Widget _buildAddButton(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> alternatives,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () => _showAddAlternativeSheet(context, ref, alternatives),
        icon: const Icon(LucideIcons.plus, size: 16),
        label: const Text('Add Alternative'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: _cardBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddAlternativeSheet(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> alternatives,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _AddAlternativeSheet(
        itemId: itemId!,
        existingAlternatives: alternatives,
      ),
    );

    ref.invalidate(itemAlternativesProvider(itemId!));
  }
}

class _AddAlternativeSheet extends ConsumerStatefulWidget {
  const _AddAlternativeSheet({
    required this.itemId,
    required this.existingAlternatives,
  });

  final String itemId;
  final List<dynamic> existingAlternatives;

  @override
  ConsumerState<_AddAlternativeSheet> createState() =>
      _AddAlternativeSheetState();
}

class _AddAlternativeSheetState extends ConsumerState<_AddAlternativeSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: _cardBorder),
            _buildSearchField(),
            const Divider(height: 1, color: _cardBorder),
            Flexible(child: _buildItemsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Add Alternative',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search items...',
          prefixIcon: const Icon(LucideIcons.search, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        style: const TextStyle(fontSize: 13),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildItemsList() {
    final itemsAsync = ref.watch(inventoryItemsProvider).itemsOnly;

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(
        child: Text(
          'Failed to load items',
          style: TextStyle(fontSize: 13, color: AppColors.error),
        ),
      ),
      data: (items) {
        final existingIds = widget.existingAlternatives
            .map((alt) => (alt as dynamic).alternativeItemId as String)
            .toSet();

        var filteredItems = items
            .where(
              (item) =>
                  item.type == ItemType.product &&
                  item.id != widget.itemId &&
                  !existingIds.contains(item.id),
            )
            .toList();

        if (_searchQuery.trim().isNotEmpty) {
          final searchEngine = InventorySearchEngine.build(
            items: filteredItems.map(
              InventorySearchableFields.fromInventoryItem,
            ),
          );
          filteredItems = searchEngine.searchItems(
            filteredItems,
            query: _searchQuery.trim(),
          );
        }

        if (filteredItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                _searchQuery.trim().isEmpty
                    ? 'No items available'
                    : 'No items found',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return _buildItemTile(item);
          },
        );
      },
    );
  }

  Widget _buildItemTile(InventoryItem item) {
    final categories = ref.watch(inventoryCategoriesProvider).value ?? [];
    final brands = ref.watch(inventoryBrandsProvider).value ?? [];

    final categoryById = {for (final c in categories) c.id: c.name};
    final brandById = {for (final b in brands) b.id: b.name};

    final brandName = item.brandId != null ? brandById[item.brandId] : null;
    final categoryName = item.categoryId != null
        ? categoryById[item.categoryId]
        : null;

    final subtitle = [
      ?brandName,
      ?categoryName,
    ].join(' · ');

    final stockQty = item.quantity ?? 0;

    return InkWell(
      onTap: () => _addAlternative(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _cardBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Stock: ${stockQty.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (item.salePrice != null)
                  Text(
                    '₹${item.salePrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addAlternative(InventoryItem item) async {
    try {
      await ref
          .read(itemAlternativesProvider(widget.itemId).notifier)
          .addAlternative(item.id);

      if (!mounted) return;
      Navigator.of(context).pop();
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add alternative: $e')),
      );
    }
  }
}
