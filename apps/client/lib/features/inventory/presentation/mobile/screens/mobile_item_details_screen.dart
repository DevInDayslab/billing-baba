import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_button.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/add_item_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/adjust_stock_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_details/mobile_item_detail_metrics.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_details/mobile_item_stock_history_tile.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/item_details/mobile_item_transaction_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Mobile item ledger screen — pricing, stock metrics, and history/transactions.
class MobileItemDetailsScreen extends ConsumerStatefulWidget {
  const MobileItemDetailsScreen({
    required this.itemId,
    this.fallbackItem,
    super.key,
  });

  final String itemId;
  final InventoryItem? fallbackItem;

  @override
  ConsumerState<MobileItemDetailsScreen> createState() =>
      _MobileItemDetailsScreenState();
}

class _MobileItemDetailsScreenState
    extends ConsumerState<MobileItemDetailsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(productTransactionSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    ref.read(productTransactionSearchQueryProvider.notifier).query = '';
    ref.read(productTransactionFiltersProvider.notifier).setPage(0);
    super.dispose();
  }

  InventoryItem? _resolveDisplayItem() {
    final listItem = ref
        .watch(inventoryItemListProvider)
        .where((entry) => entry.id == widget.itemId)
        .firstOrNull;
    final detailAsync = ref.watch(productDetailProvider(widget.itemId));
    final fallback = widget.fallbackItem ?? listItem ?? detailAsync.value;
    if (fallback == null) return null;
    return InventoryStockCalculator.resolveDisplayItem(
      listItem: listItem,
      detailItem: detailAsync.value,
      fallback: fallback,
    );
  }

  InventoryDetailHeaderMode _headerMode(InventoryItem item) {
    return item.type == ItemType.service
        ? InventoryDetailHeaderMode.service
        : InventoryDetailHeaderMode.product;
  }

  Future<void> _editItem(InventoryItem item) async {
    await showAddItemDialog(
      context,
      initialType: item.type,
      editItem: item,
    );
    if (!mounted) return;
    ref.invalidate(productDetailProvider(widget.itemId));
    ref.invalidate(productTransactionsProvider(widget.itemId));
  }

  void _onSearchChanged(String query) {
    ref.read(productTransactionSearchQueryProvider.notifier).query = query;
    ref.read(productTransactionFiltersProvider.notifier).setPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final displayItem = _resolveDisplayItem();
    final detailAsync = ref.watch(productDetailProvider(widget.itemId));

    if (displayItem == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const MobileAppBar(
          title: 'Item Details',
          showBackButton: true,
          showBusinessHeader: false,
          showNotification: false,
          showSettings: false,
        ),
        body: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppError(
            message: InventoryErrorMapper.messageFor(error),
            onRetry: () =>
                ref.invalidate(productDetailProvider(widget.itemId)),
          ),
          data: (_) => const MobileEmptyState(
            title: 'Item not found',
            message: 'This item may have been deleted or is unavailable.',
            icon: Icons.inventory_2_outlined,
          ),
        ),
      );
    }

    final mode = _headerMode(displayItem);
    final isProduct = mode == InventoryDetailHeaderMode.product;
    final stockMetrics = ref.watch(itemStockMetricsProvider(widget.itemId));
    final stockSummary = isProduct
        ? ref.watch(productStockSummaryProvider(widget.itemId))
        : null;
    final latestStockUpdate = isProduct
        ? ref.watch(latestStockUpdateProvider(widget.itemId))
        : null;
    final contextData = ref.watch(productDetailContextProvider(widget.itemId));
    final unitLabel = displayItem.baseUnitShortName ?? 'pcs';
    final transactionsAsync =
        ref.watch(productTransactionsProvider(widget.itemId));
    final paginated =
        ref.watch(paginatedProductTransactionsProvider(widget.itemId));
    final stockAfter = ref.watch(productStockAfterProvider(widget.itemId));
    final hasSearch =
        ref.watch(productTransactionSearchQueryProvider).isNotEmpty;
    final sectionTitle = isProduct ? 'Stock History' : 'Transactions';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: 'Item Details',
        showBackButton: true,
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
        actions: [
          MobileIconActionButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit item',
            onPressed: () => unawaited(_editItem(displayItem)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(inventoryItemsProvider.notifier).refresh();
          ref.invalidate(productDetailProvider(widget.itemId));
          ref.invalidate(productTransactionsProvider(widget.itemId));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: MobileItemDetailMetrics(
                  item: displayItem,
                  mode: mode,
                  stockMetrics: stockMetrics,
                  stockSummary: stockSummary,
                  latestStockUpdate: latestStockUpdate,
                  categoryName: contextData.categoryName,
                ),
              ),
            ),
            if (isProduct)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: AppButton(
                    label: 'Adjust Stock',
                    onPressed: () => showAdjustStockDialog(
                      context,
                      item: displayItem,
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      sectionTitle.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    MobileSearchField(
                      controller: _searchController,
                      hint: isProduct
                          ? 'Search stock history'
                          : 'Search transactions',
                      onChanged: _onSearchChanged,
                    ),
                  ],
                ),
              ),
            ),
            transactionsAsync.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: AppError(
                  message: InventoryErrorMapper.messageFor(error),
                  onRetry: () => ref.invalidate(
                    productTransactionsProvider(widget.itemId),
                  ),
                ),
              ),
              data: (_) {
                if (paginated.totalItems == 0) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: MobileEmptyState(
                      title: hasSearch
                          ? 'No matching entries'
                          : isProduct
                          ? 'No stock history yet'
                          : 'No transactions yet',
                      icon: Icons.history_rounded,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  sliver: SliverList.separated(
                    itemCount: paginated.items.length,
                    separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final transaction = paginated.items[index];
                      if (isProduct) {
                        return MobileItemStockHistoryTile(
                          transaction: transaction,
                          unitLabel: unitLabel,
                          balance: stockAfter[transaction.id],
                        );
                      }
                      return MobileItemTransactionTile(
                        transaction: transaction,
                        unitLabel: unitLabel,
                      );
                    },
                  ),
                );
              },
            ),
            if (paginated.totalPages > 1)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                sliver: SliverToBoxAdapter(
                  child: _PaginationBar(
                    currentPage: paginated.currentPage,
                    totalPages: paginated.totalPages,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends ConsumerWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productTransactionFiltersProvider.notifier);
    final canGoBack = currentPage > 0;
    final canGoNext = currentPage < totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Previous page',
          onPressed: canGoBack ? () => notifier.setPage(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Text(
          'Page ${currentPage + 1} of $totalPages',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed:
              canGoNext ? () => notifier.setPage(currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
