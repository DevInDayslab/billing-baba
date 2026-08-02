import 'dart:async';

import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/application/mobile_stock_summary_provider.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_stock_summary_filters_section.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_stock_summary_item_card.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/mobile_stock_summary_metrics_banner.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vyapar-style mobile stock summary report.
class MobileStockSummaryPage extends ConsumerStatefulWidget {
  const MobileStockSummaryPage({super.key});

  @override
  ConsumerState<MobileStockSummaryPage> createState() =>
      _MobileStockSummaryPageState();
}

class _MobileStockSummaryPageState
    extends ConsumerState<MobileStockSummaryPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(mobileStockSummaryFiltersProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(inventoryItemsProvider.notifier).refresh();
  }

  void _toggleSearch() {
    final notifier = ref.read(mobileStockSummaryFiltersProvider.notifier);
    final visible = !ref.read(mobileStockSummaryFiltersProvider).searchVisible;
    notifier.setSearchVisible(visible);
    if (!visible) {
      _searchController.clear();
      notifier.setSearchQuery('');
    }
  }

  void _exportExcel() {
    final rows = ref.read(mobileStockSummaryRowsProvider);
    reportExportTable(
      context: context,
      title: 'Stock Summary',
      filename: 'stock-summary',
      headers: const [
        'Item Name',
        'Stock Qty',
        'Stock Value',
      ],
      rows: [
        for (final row in rows)
          [
            row.item.name,
            row.stockQty.toStringAsFixed(0),
            formatReportCurrency(row.stockValue),
          ],
      ],
    );
  }

  void _exportPdf() {
    final rows = ref.read(mobileStockSummaryRowsProvider);
    reportPrintTable(
      context: context,
      title: 'Stock Summary',
      headers: const [
        'Item Name',
        'Stock Qty',
        'Stock Value',
      ],
      rows: [
        for (final row in rows)
          [
            row.item.name,
            row.stockQty.toStringAsFixed(0),
            formatReportCurrency(row.stockValue),
          ],
      ],
    );
  }

  void _showMoreMenu() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Refresh'),
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(_refresh());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(inventoryItemsProvider);
    final rows = ref.watch(mobileStockSummaryRowsProvider);
    final metrics = ref.watch(mobileStockSummaryMetricsProvider);
    final categoryLabel = ref.watch(mobileStockSummaryCategoryLabelProvider);
    final filters = ref.watch(mobileStockSummaryFiltersProvider);

    return MobilePlatformScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: MobileAppBar(
          title: 'Stock Summary',
          showBackButton: true,
          showBusinessHeader: false,
          showNotification: false,
          showSettings: false,
          actions: [
            MobileIconActionButton(
              icon: filters.searchVisible
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              tooltip: 'Search',
              onPressed: _toggleSearch,
            ),
            MobileIconActionButton(
              icon: Icons.picture_as_pdf_outlined,
              tooltip: 'Export PDF',
              iconColor: const Color(0xFFD32F2F),
              onPressed: _exportPdf,
            ),
            MobileIconActionButton(
              icon: Icons.table_chart_outlined,
              tooltip: 'Export Excel',
              iconColor: const Color(0xFF2E7D32),
              onPressed: _exportExcel,
            ),
            MobileIconActionButton(
              icon: Icons.more_vert_rounded,
              tooltip: 'More',
              onPressed: _showMoreMenu,
            ),
          ],
        ),
        body: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => MobileEmptyState(
            title: 'Could not load stock summary',
            message: error.toString(),
            actionLabel: 'Retry',
            onAction: _refresh,
          ),
          data: (_) => RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (filters.searchVisible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: MobileSearchField(
                        controller: _searchController,
                        hint: 'Search items...',
                        autofocus: true,
                        onChanged: ref
                            .read(mobileStockSummaryFiltersProvider.notifier)
                            .setSearchQuery,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: MobileStockSummaryFiltersSection(
                    categoryLabel: categoryLabel,
                    onFiltersTap: () =>
                        showMobileStockSummaryFiltersSheet(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: MobileStockSummaryMetricsBanner(metrics: metrics),
                ),
                if (rows.isEmpty)
                  SliverFillRemaining(
                    child: MobileEmptyState(
                      title: 'No items found',
                      message: filters.searchQuery.isNotEmpty
                          ? 'Try a different search term or filter.'
                          : 'Add items to see stock summary.',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final row = rows[index];
                        return MobileStockSummaryItemCard(
                          row: row,
                          initiallyExpanded: row.item.reservedQuantity != null,
                        );
                      },
                      childCount: rows.length,
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
