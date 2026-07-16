import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/presentation/widgets/item_card.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_styles.dart';
import 'package:billing_baba/features/pos/providers/pos_items_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemGrid extends ConsumerStatefulWidget {
  const ItemGrid({super.key});

  @override
  ConsumerState<ItemGrid> createState() => _ItemGridState();
}

class _ItemGridState extends ConsumerState<ItemGrid> {
  final _localSearchDebouncer = Debouncer();
  String _debouncedLocalQuery = '';
  String _selectedCategory = 'All';
  int _visibleCount = 9;

  static const _categories = [
    'All',
    'Grocery',
    'Dairy',
    'Bakery',
    'Snacks',
  ];

  static const double _gridSpacing = AppSpacing.sm;
  static const _cardHeight = 180.0;

  @override
  void dispose() {
    _localSearchDebouncer.dispose();
    super.dispose();
  }

  List<PosItem> _filterByCategory(List<PosItem> items) {
    if (_selectedCategory == 'All') return items;
    return items.where((item) => item.category == _selectedCategory).toList();
  }

  String get _effectiveQuery {
    if (_debouncedLocalQuery.isNotEmpty) return _debouncedLocalQuery;
    return ref.watch(posItemSearchQueryProvider);
  }

  double _maxCrossAxisExtent(double panelWidth) {
    if (panelWidth >= 560) return 168;
    if (panelWidth >= 380) return 155;
    return panelWidth - _gridSpacing;
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(posItemSearchProvider(_effectiveQuery));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  _localSearchDebouncer.run(() {
                    setState(() {
                      _debouncedLocalQuery = value;
                      _visibleCount = 9;
                    });
                  });
                },
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(color: posCardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(color: posCardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Material(
              color: AppColors.background,
              borderRadius: AppRadius.mdBorder,
              child: InkWell(
                onTap: () {},
                borderRadius: AppRadius.mdBorder,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(color: posCardBorder),
                  ),
                  child: const Icon(
                    Icons.tune,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final selected = _selectedCategory == category;
              return _CategoryChip(
                label: category,
                selected: selected,
                onTap: () => setState(() {
                  _selectedCategory = category;
                  _visibleCount = 9;
                }),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Failed to load items: $error',
                style: PosStyles.emptyStateStyle,
                textAlign: TextAlign.center,
              ),
            ),
            data: (items) {
              final filtered = _filterByCategory(items);
              final visibleItems = filtered.take(_visibleCount).toList();
              final hasMore = filtered.length > _visibleCount;

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No items match your search',
                    style: PosStyles.emptyStateStyle,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: _maxCrossAxisExtent(
                                  constraints.maxWidth,
                                ),
                                mainAxisExtent: _cardHeight,
                                mainAxisSpacing: _gridSpacing,
                                crossAxisSpacing: _gridSpacing,
                              ),
                          itemCount: visibleItems.length,
                          itemBuilder: (context, index) =>
                              ItemCard(item: visibleItems[index]),
                        );
                      },
                    ),
                  ),
                  if (hasMore)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _visibleCount += 9),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: posCardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Load More Items'),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
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
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: selected ? AppColors.primary : posCardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
