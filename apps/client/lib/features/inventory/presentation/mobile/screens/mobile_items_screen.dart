import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/sync/application/sync_ui_state_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/permissions/permission_gate.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_app_header.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/application/item_settings_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/screens/mobile_barcode_scanner_screen.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/add_item/mobile_add_item_tab_bar.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/inventory_item_filter_sheet.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_list_view.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_more_options_sheet.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_quick_links.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_search_bar.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_item_delete.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile Items tab — product/service list with search, quick links, and add-item flow.
class MobileItemsScreen extends ConsumerStatefulWidget {
  const MobileItemsScreen({super.key});

  @override
  ConsumerState<MobileItemsScreen> createState() => _MobileItemsScreenState();
}

class _MobileItemsScreenState extends ConsumerState<MobileItemsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scope =
          ref.read(itemSettingsProvider).value?.itemTypeScope ??
          ItemTypeScope.productsAndServices;
      _ensureTabMatchesScope(scope);
      _syncSearchControllerFromProvider();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncSearchControllerFromProvider() {
    final tabIndex = ref.read(inventoryItemsTabIndexProvider);
    final query = tabIndex == inventoryServicesTabIndex
        ? ref.read(serviceSearchQueryProvider)
        : ref.read(productSearchQueryProvider);
    if (_searchController.text != query) {
      _searchController.text = query;
    }
  }

  bool get _isServicesTab =>
      ref.watch(inventoryItemsTabIndexProvider) == inventoryServicesTabIndex;

  ItemType get _activeItemType =>
      _isServicesTab ? ItemType.service : ItemType.product;

  bool _showTypeTabs(ItemTypeScope scope) =>
      scope == ItemTypeScope.productsAndServices;

  void _onSearchChanged(String query) {
    if (_isServicesTab) {
      ref.read(serviceSearchQueryProvider.notifier).query = query;
    } else {
      ref.read(productSearchQueryProvider.notifier).query = query;
    }
  }

  Future<void> _onRefresh() {
    return ref.read(inventoryItemsProvider.notifier).refresh();
  }

  Map<String, String> _categoryNamesById() {
    final categories = ref.watch(inventoryCategoriesProvider).value ?? [];
    return {
      for (final category in categories) category.id: category.name,
    };
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
      onItemLongPress: _showItemActions,
    ).buildSliver();
  }

  void _showItemActions(InventoryItem item) {
    final permissions = ref.read(permissionServiceProvider);
    final actions = <MobileSheetAction>[
      if (permissions.canEdit(PermissionModule.item))
        MobileSheetAction(
          icon: Icons.edit_outlined,
          label: 'Edit Item',
          onTap: () => unawaited(
            showAddItemDialog(
              context,
              initialType: item.type,
              editItem: item,
            ),
          ),
        ),
      if (permissions.canDelete(PermissionModule.item))
        MobileSheetAction(
          icon: Icons.delete_outline_rounded,
          label: 'Delete Item',
          onTap: () => unawaited(_deleteItem(item)),
        ),
    ];
    if (actions.isEmpty) return;
    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: item.name,
        actions: actions,
      ),
    );
  }

  Future<void> _deleteItem(InventoryItem item) async {
    await confirmAndDeleteInventoryItem(context, ref, item);
  }

  Future<void> _onBarcodeScan() async {
    final barcode = await showMobileBarcodeScanner(context);
    if (!mounted || barcode == null) return;

    final products = ref.read(productsProvider);
    final services = ref.read(servicesProvider);
    final allItems = [...products, ...services];
    final engine = ref.read(inventorySearchEngineProvider);
    final match = findInventoryItemByBarcodeOrQuery(
      engine,
      allItems,
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
    final result = await showMobileInventoryItemFilterSheet(
      context: context,
      initial: current,
    );
    if (result == null || !mounted) return;
    ref.read(inventoryItemFiltersProvider.notifier).apply(result);
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
            icon: Icons.branding_watermark_outlined,
            label: 'Brands',
            onTap: () => context.push(AppRoutes.itemsBrands),
          ),
          MobileSheetAction(
            icon: Icons.warehouse_outlined,
            label: 'Godowns',
            onTap: () => context.push(AppRoutes.itemsGodowns),
          ),
          MobileSheetAction(
            icon: Icons.straighten_outlined,
            label: 'Units',
            onTap: () => context.push(AppRoutes.itemsUnits),
          ),
          // MobileSheetAction(
          //   icon: Icons.upload_file_outlined,
          //   label: 'Import Items',
          //   onTap: () => context.push(AppRoutes.utilitiesImportItems),
          // ),
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
        iconColor: AppColors.primary,
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

  void _onTabSelected(int index) {
    ref.read(inventoryItemsTabIndexProvider.notifier).tabIndex = index;
    _syncSearchControllerFromProvider();
  }

  void _ensureTabMatchesScope(ItemTypeScope scope) {
    final notifier = ref.read(inventoryItemsTabIndexProvider.notifier);
    switch (scope) {
      case ItemTypeScope.productsOnly:
        if (notifier.tabIndex != inventoryProductsTabIndex) {
          notifier.tabIndex = inventoryProductsTabIndex;
        }
      case ItemTypeScope.servicesOnly:
        if (notifier.tabIndex != inventoryServicesTabIndex) {
          notifier.tabIndex = inventoryServicesTabIndex;
        }
      case ItemTypeScope.productsAndServices:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryItemsProvider);
    final filters = ref.watch(inventoryItemFiltersProvider);
    final categoryNamesById = _categoryNamesById();
    final itemSettings =
        ref.watch(itemSettingsProvider).value ?? ItemSettings.defaults();
    final scope = itemSettings.itemTypeScope;
    final showTypeTabs = _showTypeTabs(scope);

    ref.listen<ItemTypeScope>(
      itemSettingsProvider.select(
        (async) =>
            async.value?.itemTypeScope ?? ItemTypeScope.productsAndServices,
      ),
      (previous, next) {
        _ensureTabMatchesScope(next);
        _syncSearchControllerFromProvider();
      },
    );

    final tabIndex = ref.watch(inventoryItemsTabIndexProvider);
    final displayItems = showTypeTabs && tabIndex == inventoryServicesTabIndex
        ? ref.watch(servicesProvider)
        : ref.watch(productsProvider);
    final searchQuery = _isServicesTab
        ? ref.watch(serviceSearchQueryProvider)
        : ref.watch(productSearchQueryProvider);
    final emptyMessage = _isServicesTab
        ? 'No services found'
        : 'No products found';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MobileAppHeader(
                  onBusinessTap: () => context.push(AppRoutes.businessList),
                  onSettingsTap: () => context.push(AppRoutes.settings),
                  onNotificationTap: () =>
                      context.push(AppRoutes.notifications),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 200) {
                          unawaited(
                            ref
                                .read(inventoryItemsProvider.notifier)
                                .loadMore(),
                          );
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: ItemQuickLinks(links: _quickLinks()),
                          ),
                          if (showTypeTabs)
                            SliverToBoxAdapter(
                              child: MobileAddItemTabBar(
                                tabs: const ['Products', 'Services'],
                                activeIndex: tabIndex,
                                onTabSelected: _onTabSelected,
                              ),
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
                                      onRetry: () => ref.invalidate(
                                        inventoryItemsProvider,
                                      ),
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
                                    message:
                                        searchQuery.isNotEmpty ||
                                            filters.hasActiveFilters
                                        ? 'Try changing your search or filter.'
                                        : emptyMessage,
                                    icon: Icons.inventory_2_outlined,
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
                              height:
                                  MobileBottomNavigation.scrollBottomPadding(
                                    context,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MobileBottomNavigation.fabBottomInset,
              child: PermissionGate(
                module: PermissionModule.item,
                action: PermissionAction.create,
                child: Center(
                  child: MobileHomeAddSaleFab(
                    label: _isServicesTab ? 'Add Service' : 'Add Item',
                    icon: Icons.add_rounded,
                    onPressed: () => unawaited(
                      showAddItemDialog(
                        context,
                        initialType: _activeItemType,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
