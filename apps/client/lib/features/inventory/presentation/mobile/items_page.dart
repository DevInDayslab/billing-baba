import 'dart:async';

import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/application/mobile_items_models.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_inventory_item_card.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_items_header.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_items_more_options_sheet.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_items_quick_links.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_items_search_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Vyapar-style mobile items screen with quick links, search, and item cards.
class MobileItemsPage extends ConsumerStatefulWidget {
  const MobileItemsPage({super.key});

  @override
  ConsumerState<MobileItemsPage> createState() => _MobileItemsPageState();
}

class _MobileItemsPageState extends ConsumerState<MobileItemsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(productSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshItems() async {
    await ref.read(inventoryItemsProvider.notifier).refresh();
  }

  void _showAddItem() {
    unawaited(showAddItemDialog(context));
  }

  void _showMoreMenu() {
    unawaited(showMobileItemsMoreOptionsSheet(context, ref));
  }

  List<MobileItemsQuickLink> _quickLinks() {
    return [
      MobileItemsQuickLink(
        label: 'Online Store',
        icon: Icons.storefront_outlined,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Online Store coming soon')),
          );
        },
      ),
      MobileItemsQuickLink(
        label: 'Stock Summary',
        icon: Icons.inventory_outlined,
        onTap: () => context.push(AppRoutes.itemsStockSummary),
      ),
      MobileItemsQuickLink(
        label: 'Item Settings',
        icon: Icons.folder_outlined,
        onTap: () => context.push(AppRoutes.itemsSettings),
      ),
      MobileItemsQuickLink(
        label: 'Show All',
        icon: Icons.arrow_forward_rounded,
        onTap: _showMoreMenu,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryItemsProvider);
    final products = ref.watch(productsProvider);

    return MobilePlatformScope(
      child: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  MobileItemsHeader(
                    onBusinessTap: () => context.push(AppRoutes.businessList),
                    onNotificationTap: () =>
                        context.push(AppRoutes.notifications),
                    onSettingsTap: () => context.push(AppRoutes.settings),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshItems,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: MobileItemsQuickLinks(
                              links: _quickLinks(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: MobileItemsSearchToolbar(
                              controller: _searchController,
                              onChanged: (query) {
                                ref
                                    .read(productSearchQueryProvider.notifier)
                                    .query = query;
                              },
                              onFilterTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Filters coming soon'),
                                  ),
                                );
                              },
                              onScanTap: () => context.push(
                                AppRoutes.utilitiesAddItemsBarcode,
                              ),
                              onMoreTap: _showMoreMenu,
                            ),
                          ),
                          ..._buildItemSlivers(itemsAsync, products),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: MobileBottomNavigation.fabBottomInset +
                                  AppSpacing.xl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: MobileBottomNavigation.fabBottomInset,
                child: Center(
                  child: MobileHomeAddSaleFab(
                    label: 'Add New Item',
                    icon: Icons.inventory_2_outlined,
                    onPressed: _showAddItem,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItemSlivers(
    AsyncValue<List<InventoryItem>> itemsAsync,
    List<InventoryItem> products,
  ) {
    return itemsAsync.when(
      loading: () => [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (error, _) => [
        SliverFillRemaining(
          child: MobileEmptyState(
            title: 'Could not load items',
            message: error.toString(),
            actionLabel: 'Retry',
            onAction: _refreshItems,
          ),
        ),
      ],
      data: (_) {
        if (products.isEmpty) {
          return [
            SliverFillRemaining(
              child: MobileEmptyState(
                title: 'No items found',
                message: _searchController.text.isNotEmpty
                    ? 'Try a different search term.'
                    : 'Add your first item to get started.',
                actionLabel: 'Add New Item',
                onAction: _showAddItem,
              ),
            ),
          ];
        }

        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = products[index];
                return MobileInventoryItemCard(
                  item: item,
                  initiallyExpanded: index == products.length - 1 &&
                      item.reservedQuantity != null,
                  onShareTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing ${item.name}…')),
                    );
                  },
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${item.name}…')),
                    );
                  },
                );
              },
              childCount: products.length,
            ),
          ),
        ];
      },
    );
  }
}
