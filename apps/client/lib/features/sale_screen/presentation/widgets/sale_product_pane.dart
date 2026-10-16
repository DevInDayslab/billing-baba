import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_item_thumbnail.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

List<String> _itemStorageTooltipLines(List<ItemLocationModel> locations) {
  for (final location in locations) {
    final lines = <String>[];
    final rack = location.rack?.trim();
    if (rack != null && rack.isNotEmpty) {
      lines.add('Rack: $rack');
    }
    final shelf = location.shelf?.trim();
    if (shelf != null && shelf.isNotEmpty) {
      lines.add('Shelf: $shelf');
    }
    if (lines.isNotEmpty) return lines;
  }
  return const [];
}

String _saleProductInfoTooltip(
  PosItem item,
  List<ItemLocationModel> locations,
) {
  final lines = <String>[];
  final purchase = item.purchasePrice;

  lines.add(
    'Purchase price: ${purchase != null ? _currency.format(purchase) : '—'}',
  );

  final selling = item.price;
  if (purchase != null) {
    final profit = selling - purchase;
    final marginPercent = selling > 0 ? (profit / selling * 100).round() : 0;
    lines.add('Profit: ${_currency.format(profit)} ($marginPercent%)');
  }

  final hsn = item.hsnCode?.trim();
  if (hsn != null && hsn.isNotEmpty) {
    lines.add('HSN: $hsn');
  }

  lines.addAll(_itemStorageTooltipLines(locations));

  final category = item.categoryName.trim();
  if (category.isNotEmpty && category.toLowerCase() != 'uncategorized') {
    lines.add('Category: $category');
  }

  final brand = item.brandName?.trim();
  if (brand != null && brand.isNotEmpty) {
    lines.add('Brand: $brand');
  }

  return lines.join('\n');
}

/// Each card is ~60% of the original width/height so more products fit per row.
const kSaleProductCardSizeScale = 0.6;

const _saleProductCardHeightFactor = 1.55;

/// Columns follow the catalog pane width (more columns when [kSaleProductCardSizeScale] < 1).
int saleProductColumnCount(double width) {
  final int baseColumns;
  if (width >= PosBreakpoints.laptop) {
    baseColumns = 4;
  } else if (width >= PosBreakpoints.mobile) {
    baseColumns = 3;
  } else {
    baseColumns = 2;
  }
  return (baseColumns / kSaleProductCardSizeScale).ceil();
}

class SaleProductPane extends ConsumerWidget {
  const SaleProductPane({
    required this.query,
    required this.categoryId,
    required this.highlightIndex,
    required this.searchController,
    required this.searchFocus,
    required this.onQueryChanged,
    required this.onMoveHighlight,
    required this.onSubmitSearch,
    required this.onClearQuery,
    required this.onCategoryChanged,
    required this.onItemSelected,
    super.key,
  });

  final String query;
  final String? categoryId;
  final int highlightIndex;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int> onMoveHighlight;
  final VoidCallback onSubmitSearch;
  final VoidCallback onClearQuery;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<PosItem> onItemSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryItemsProvider);
    final categories = ref.watch(posCategoriesProvider);
    final items = ref.watch(
      posFilteredCatalogProvider(
        searchQuery: query,
        categoryId: categoryId,
      ),
    );
    final searching = query.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SaleSearchBar(
            controller: searchController,
            focusNode: searchFocus,
            onChanged: onQueryChanged,
            onMoveHighlight: onMoveHighlight,
            onSubmitted: onSubmitSearch,
            onClear: onClearQuery,
          ),
          const SizedBox(height: AppSpacing.md),
          _CategoryStrip(
            categories: categories,
            selectedId: categoryId,
            onSelected: onCategoryChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: inventory.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Could not load products',
                  style: PosStyles.emptyStateStyle,
                ),
              ),
              data: (_) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      searching
                          ? 'No products match "$query"'
                          : 'No products yet',
                      style: PosStyles.emptyStateStyle,
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = saleProductColumnCount(
                      constraints.maxWidth,
                    );
                    final gap = AppSpacing.sm;
                    final cardWidth =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: gap,
                        crossAxisSpacing: gap,
                        mainAxisExtent: cardWidth * _saleProductCardHeightFactor,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _SaleProductCard(
                          item: item,
                          rank: searching ? index + 1 : null,
                          highlighted: searching && index == highlightIndex,
                          onTap: () => onItemSelected(item),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleSearchBar extends StatelessWidget {
  const _SaleSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onMoveHighlight,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<int> onMoveHighlight;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackSearch = constraints.maxWidth < 520;
        final searchField = Expanded(
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                onMoveHighlight(1);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                onMoveHighlight(-1);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search products, brand, or barcode',
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    if (controller.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      tooltip: 'Clear',
                      onPressed: onClear,
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.lgBorder,
                  borderSide: const BorderSide(color: posCardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lgBorder,
                  borderSide: const BorderSide(color: posCardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lgBorder,
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        );
        final searchButton = stackSearch
            ? FilledButton(
                onPressed: onSubmitted,
                child: const Icon(Icons.search),
              )
            : FilledButton.icon(
                onPressed: onSubmitted,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              );

        if (stackSearch) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: searchButton,
              ),
            ],
          );
        }

        return Row(
          children: [
            searchField,
            const SizedBox(width: AppSpacing.sm),
            searchButton,
          ],
        );
      },
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<PosCategoryOption> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final labelSize = Theme.of(context).textTheme.labelLarge?.fontSize ?? 14;
    return SizedBox(
      height: labelSize + AppSpacing.lg * 2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              selected: selectedId == null,
              onTap: () => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return _CategoryChip(
            label: category.name,
            selected: selectedId == category.id,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.tabActiveTint : AppColors.surface,
      borderRadius: AppRadius.buttonBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.buttonBorder,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.buttonBorder,
            border: Border.all(
              color: selected ? AppColors.primary : posCardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SaleProductCard extends ConsumerWidget {
  const _SaleProductCard({
    required this.item,
    required this.highlighted,
    required this.onTap,
    this.rank,
  });

  final PosItem item;
  final int? rank;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations =
        ref.watch(itemLocationsProvider(item.id)).value ?? const [];

    final mrp = item.mrp;
    final hasMrp = mrp != null && mrp > 0;
    final selling = item.price;
    final inStock = !item.isOutOfStock;
    final brand = item.brandName?.trim();
    final category = item.categoryName.trim();
    final showCategory =
        category.isNotEmpty && category.toLowerCase() != 'uncategorized';
    final qtyFooter = showCategory
        ? 'Qty Left: ${item.stock}  ·  $category'
        : 'Qty Left: ${item.stock}';
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: highlighted ? AppColors.primary : posCardBorder,
              width: highlighted ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.mdBorder,
                        child: ColoredBox(
                          color: AppColors.iconBackground,
                          child: PosItemThumbnail(item: item),
                        ),
                      ),
                      if (rank != null)
                        Positioned(
                          left: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: _Badge(
                            label: '#$rank',
                            background: AppColors.primary,
                            foreground: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (brand != null && brand.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Badge(
                    label: inStock ? 'In Stock' : 'Out of Stock',
                    background: inStock
                        ? AppColors.successSoft
                        : AppColors.dangerSoft,
                    foreground: inStock ? AppColors.success : AppColors.danger,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (hasMrp) ...[
                      Text(
                        _currency.format(mrp),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        _currency.format(selling),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        qtyFooter,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    _SaleProductInfoButton(
                      tooltip: _saleProductInfoTooltip(item, locations),
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

class _SaleProductInfoButton extends StatelessWidget {
  const _SaleProductInfoButton({required this.tooltip});

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.smBorder,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.smBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
