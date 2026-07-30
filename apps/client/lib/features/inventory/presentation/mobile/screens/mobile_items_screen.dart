import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_filter_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/models/inventory_item_filters.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/application/mobile_item_mock_data.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_barcode_scanner_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_list_view.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_more_options_sheet.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_quick_links.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_search_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile Items tab — product list with search, quick links, and add-item flow.
class MobileItemsScreen extends ConsumerStatefulWidget {
  const MobileItemsScreen({super.key});

  @override
  ConsumerState<MobileItemsScreen> createState() => _MobileItemsScreenState();
}

class _MobileItemsScreenState extends ConsumerState<MobileItemsScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  Future<void> _onRefresh() {
    return ref.read(inventoryItemsProvider.notifier).refresh();
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    final filters = ref.read(inventoryItemFiltersProvider);
    final products = items.where((item) => item.type == ItemType.product);
    final filtered = products.where(
      (item) => InventoryItemFilterService.matches(item, filters: filters),
    );

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return filtered.toList();

    return filtered
        .where((item) {
          final name = item.name.toLowerCase();
          final barcode = item.barcode?.toLowerCase() ?? '';
          final alias = item.alias?.toLowerCase() ?? '';
          final shortName = item.shortName?.toLowerCase() ?? '';
          return name.contains(query) ||
              barcode.contains(query) ||
              alias.contains(query) ||
              shortName.contains(query);
        })
        .toList();
  }

  Map<String, String> _categoryNamesById() {
    final categories = ref.watch(inventoryCategoriesProvider).value ?? [];
    if (categories.isNotEmpty) {
      return {
        for (final category in categories) category.id: category.name,
      };
    }
    return MobileItemMockData.categoryNamesById;
  }

  List<InventoryItem> _displayItems(List<InventoryItem> apiItems) {
    final fromApi = _filterItems(apiItems);
    if (fromApi.isNotEmpty || !kDebugMode) return fromApi;
    return _filterItems(MobileItemMockData.items);
  }

  bool _isUsingMockData(List<InventoryItem> apiItems) {
    return kDebugMode &&
        _filterItems(apiItems).isEmpty &&
        _displayItems(apiItems).isNotEmpty;
  }

  Widget _itemsSliver({
    required List<InventoryItem> items,
    required Map<String, String> categoryNamesById,
  }) {
    return ItemListView(
      items: items,
      categoryNamesById: categoryNamesById,
      onRefresh: _onRefresh,
      onItemTap: (item) {
        context.push(
          '${AppRoutes.itemsDetail}/${item.id}',
          extra: item,
        );
      },
    ).buildSliver();
  }

  Future<void> _onBarcodeScan() async {
    final barcode = await showMobileBarcodeScanner(context);
    if (!mounted || barcode == null) return;

    final items = ref.read(inventoryItemListProvider);
    final displayItems = items.isNotEmpty
        ? items
        : (kDebugMode ? MobileItemMockData.items : const <InventoryItem>[]);
    final engine = ref.read(inventorySearchEngineProvider);
    final match = findInventoryItemByBarcodeOrQuery(
      engine,
      displayItems,
      query: barcode,
    );

    if (match != null) {
      if (!mounted) return;
      await context.push(
        '${AppRoutes.itemsDetail}/${match.id}',
        extra: match,
      );
      return;
    }

    _searchController.text = barcode;
    _onSearchChanged(barcode);
  }

  Future<void> _showFilterSheet() async {
    final current = ref.read(inventoryItemFiltersProvider);
    final result = await showMobileFilterSheet<InventoryItemFilterOption>(
      context: context,
      title: 'Filter Items',
      selected: current.selected.isNotEmpty ? current.selected.first : null,
      options: [
        for (final option in inventoryListFilterOptions)
          MobileOption(
            value: option,
            label: option.label,
          ),
      ],
    );
    if (result == null || !mounted) return;
    ref.read(inventoryItemFiltersProvider.notifier).apply(
      InventoryItemFiltersState(selected: {result}),
    );
    setState(() {});
  }

  void _showMoreSheet() {
    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: 'Items',
        actions: [
          MobileSheetAction(
            icon: Icons.category_outlined,
            label: 'Categories',
            onTap: () => context.push(AppRoutes.itemsCategories),
          ),
          MobileSheetAction(
            icon: Icons.straighten_outlined,
            label: 'Units',
            onTap: () => context.push(AppRoutes.itemsUnits),
          ),
          MobileSheetAction(
            icon: Icons.upload_file_outlined,
            label: 'Import Items',
            onTap: () => context.push(AppRoutes.utilitiesImportItems),
          ),
        ],
      ),
    );
  }

  void _showShowAllSheet() {
    unawaited(
      showItemMoreOptionsSheet(
        context: context,
        options: [
          ItemMoreOption(
            label: 'Import Items',
            icon: Icons.upload_file_outlined,
            onTap: () => context.push(AppRoutes.utilitiesImportItems),
          ),
          ItemMoreOption(
            label: 'Item Details',
            icon: Icons.inventory_2_outlined,
            onTap: () => context.push(AppRoutes.reportsItemDetail),
          ),
          ItemMoreOption(
            label: 'Low Stock Summary',
            icon: Icons.trending_down_outlined,
            onTap: () => context.push(
              '${AppRoutes.reportsStockSummary}?stock=low',
            ),
          ),
        ],
      ),
    );
  }

  List<ItemQuickLink> _quickLinks() {
    return [
      ItemQuickLink(
        label: 'Categories',
        icon: Icons.category_outlined,
        onTap: () => context.push(AppRoutes.itemsCategories),
      ),
      ItemQuickLink(
        label: 'Stock Summary',
        icon: Icons.assessment_outlined,
        iconColor: const Color(0xFF2E7D32),
        backgroundColor: const Color(0xFFE8F5E9),
        onTap: () => context.push(AppRoutes.reportsStockSummary),
      ),
      ItemQuickLink(
        label: 'Item Settings',
        icon: Icons.tune_outlined,
        iconColor: const Color(0xFF5D5FEF),
        backgroundColor: const Color(0xFFEDE7F6),
        onTap: () => context.push(AppRoutes.itemsSettings),
      ),
      ItemQuickLink(
        label: 'Show All',
        icon: Icons.arrow_forward_rounded,
        iconColor: AppColors.textSecondary,
        backgroundColor: AppColors.background,
        onTap: _showShowAllSheet,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryItemsProvider);
    final filters = ref.watch(inventoryItemFiltersProvider);
    final categoryNamesById = _categoryNamesById();
    final apiItems = itemsAsync.value?.items ?? const <InventoryItem>[];
    final displayItems = _displayItems(apiItems);
    final usingMock = _isUsingMockData(apiItems);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        onBusinessTap: () => context.push(AppRoutes.businessList),
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications coming soon')),
          );
        },
        onSettingsTap: () => context.push(AppRoutes.settingsPreferences),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: ItemQuickLinks(links: _quickLinks()),
                      ),
                      SliverToBoxAdapter(
                        child: ItemSearchBar(
                          searchController: _searchController,
                          onSearchChanged: _onSearchChanged,
                          hasActiveFilter: filters.hasActiveFilters,
                          onFilterTap: () => unawaited(_showFilterSheet()),
                          onScanTap: () => unawaited(_onBarcodeScan()),
                          onMoreTap: _showMoreSheet,
                        ),
                      ),
                      if (usingMock)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Text(
                              'Showing demo items — connect to load live data.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        ),
                      itemsAsync.when(
                        loading: () => displayItems.isEmpty
                            ? const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _itemsSliver(
                                items: displayItems,
                                categoryNamesById: categoryNamesById,
                              ),
                        error: (error, _) => displayItems.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: AppError(
                                  message: InventoryErrorMapper.messageFor(
                                    error,
                                  ),
                                  onRetry: () =>
                                      ref.invalidate(inventoryItemsProvider),
                                ),
                              )
                            : _itemsSliver(
                                items: displayItems,
                                categoryNamesById: categoryNamesById,
                              ),
                        data: (_) {
                          if (displayItems.isEmpty) {
                            return SliverFillRemaining(
                              hasScrollBody: false,
                              child: MobileEmptyState(
                                title: 'No items found',
                                message: _searchQuery.isNotEmpty ||
                                    filters.hasActiveFilters
                                    ? 'Try changing your search or filter.'
                                    : 'Add your first item to get started.',
                                icon: Icons.inventory_2_outlined,
                                actionLabel: 'Add New Item',
                                onAction: () =>
                                    unawaited(showAddItemDialog(context)),
                              ),
                            );
                          }

                          return _itemsSliver(
                            items: displayItems,
                            categoryNamesById: categoryNamesById,
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: MobileBottomNavigation.scrollBottomPadding(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MobileBottomNavigation.floatingActionBottomOffset(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AddItemFab(
                  onPressed: () => unawaited(showAddItemDialog(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact pill FAB for adding a new inventory item.
class _AddItemFab extends StatelessWidget {
  const _AddItemFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MobileHomeAddSaleFab.accentRed,
      elevation: 2,
      shadowColor: MobileHomeAddSaleFab.accentRed.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Add Item',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
