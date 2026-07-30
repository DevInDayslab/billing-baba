import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/features/inventory/application/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_stock_summary_mock_data.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/stock_summary_display_row.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/stock_summary_mobile_filters.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/stock_summary_cards.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/stock_summary_filter_sheet.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Mobile stock summary report with filters, stats, and item list.
class MobileStockSummaryScreen extends ConsumerStatefulWidget {
  const MobileStockSummaryScreen({
    this.initialStockFilter,
    super.key,
  });

  final StockSummaryStockFilter? initialStockFilter;

  @override
  ConsumerState<MobileStockSummaryScreen> createState() =>
      _MobileStockSummaryScreenState();
}

class _MobileStockSummaryScreenState
    extends ConsumerState<MobileStockSummaryScreen> {
  late final TextEditingController _searchController;
  StockSummaryMobileFilters _filters = StockSummaryMobileFilters.initial;
  bool _showStockAsOnDate = false;
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _syncFiltersFromProvider();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncFiltersFromProvider() {
    final reportFilters = ref.read(reportFiltersProvider);
    final initialStock = widget.initialStockFilter;
    _filters = StockSummaryMobileFilters(
      categoryId: reportFilters.categoryId,
      categoryLabel: _categoryLabelForId(reportFilters.categoryId),
      stock:
          initialStock ??
          (reportFilters.inStockOnly
              ? StockSummaryStockFilter.inStock
              : StockSummaryStockFilter.all),
      status: switch (reportFilters.status) {
        'active' => StockSummaryStatusFilter.active,
        'inactive' => StockSummaryStatusFilter.inactive,
        _ => StockSummaryStatusFilter.all,
      },
    );
    _showStockAsOnDate = reportFilters.selectedDate != null;
  }

  String _categoryLabelForId(String? categoryId) {
    if (categoryId == null) return 'All';
    if (categoryId == InventoryCatalog.uncategorizedCategoryId) {
      return 'Uncategorized';
    }
    final categories = ref.read(inventoryCategoriesProvider).value ?? [];
    return categories
            .where((category) => category.id == categoryId)
            .map((category) => category.name)
            .firstOrNull ??
        categoryId;
  }

  List<StockSummaryCategoryOption> _categoryOptions(
    List<InventoryCategory> categories,
  ) {
    return [
      const StockSummaryCategoryOption(id: null, label: 'All'),
      const StockSummaryCategoryOption(
        id: InventoryCatalog.uncategorizedCategoryId,
        label: 'Uncategorized',
      ),
      for (final category in categories)
        if (!category.isUncategorized)
          StockSummaryCategoryOption(
            id: category.id,
            label: category.name,
          ),
    ];
  }

  void _applyFilters(StockSummaryMobileFilters filters) {
    setState(() => _filters = filters);
    final notifier = ref.read(reportFiltersProvider.notifier);
    notifier.setCategoryId(filters.categoryId);
    notifier.setInStockOnly(filters.stock == StockSummaryStockFilter.inStock);
    notifier.setStatus(switch (filters.status) {
      StockSummaryStatusFilter.active => 'active',
      StockSummaryStatusFilter.inactive => 'inactive',
      StockSummaryStatusFilter.all => null,
    });
    unawaited(ref.read(stockSummaryReportProvider.notifier).refresh());
  }

  Future<void> _openFilterSheet() async {
    final categories = ref.read(inventoryCategoriesProvider).value ?? [];
    final result = await showStockSummaryFilterSheet(
      context: context,
      initial: _filters,
      categories: _categoryOptions(categories),
    );
    if (result == null || !mounted) return;
    _applyFilters(result);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    ref.read(reportFiltersProvider.notifier).setSearchQuery(query);
  }

  List<StockSummaryDisplayRow> _mapReportRows(
    StockSummaryReportData report,
    Map<String, String> categoryNamesById,
  ) {
    return [
      for (final row in report.rows)
        StockSummaryDisplayRow.fromReportRow(row).withCategoryName(
          categoryNamesById[row.categoryId],
        ),
    ];
  }

  List<StockSummaryDisplayRow> _applyLocalFilters(
    List<StockSummaryDisplayRow> rows,
  ) {
    var filtered = rows;

    if (_filters.stock == StockSummaryStockFilter.lowStock) {
      filtered = filtered.where((row) => row.isLowStock).toList();
    }

    if (_filters.status == StockSummaryStatusFilter.active) {
      filtered = filtered
          .where((row) => !row.isInactive && row.stockQty > 0)
          .toList();
    } else if (_filters.status == StockSummaryStatusFilter.inactive) {
      filtered = filtered
          .where((row) => row.isInactive || row.stockQty <= 0)
          .toList();
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((row) => row.itemName.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  bool _isUsingMockData(StockSummaryReportData? report) {
    return kDebugMode && (report == null || report.rows.isEmpty);
  }

  _StockSummaryViewData _resolveViewData({
    required StockSummaryReportData? report,
    required Map<String, String> categoryNamesById,
  }) {
    if (_isUsingMockData(report)) {
      final rows = _applyLocalFilters(MobileStockSummaryMockData.rows);
      return _StockSummaryViewData(
        rows: rows,
        itemCount: MobileStockSummaryMockData.itemCount,
        lowStockCount: MobileStockSummaryMockData.lowStockCount,
        stockValue: MobileStockSummaryMockData.totalStockValue,
        usingMock: true,
      );
    }

    final mapped = _mapReportRows(report!, categoryNamesById);
    final rows = _applyLocalFilters(mapped);
    final lowStockCount = mapped.where((row) => row.isLowStock).length;

    return _StockSummaryViewData(
      rows: rows,
      itemCount: report.meta.total,
      lowStockCount: lowStockCount,
      stockValue: report.totalStockValue,
      usingMock: false,
    );
  }

  void _exportExcel(List<StockSummaryDisplayRow> rows) {
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
            row.itemName,
            row.stockQty.toStringAsFixed(1),
            formatReportCurrency(row.stockValue),
          ],
      ],
    );
  }

  void _exportPdf(List<StockSummaryDisplayRow> rows) {
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
            row.itemName,
            row.stockQty.toStringAsFixed(1),
            formatReportCurrency(row.stockValue),
          ],
      ],
    );
  }

  void _showMoreActions(List<StockSummaryDisplayRow> rows) {
    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: 'Stock Summary',
        actions: [
          MobileSheetAction(
            icon: Icons.table_chart_outlined,
            label: 'Export Excel',
            onTap: () => _exportExcel(rows),
          ),
          MobileSheetAction(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Export PDF',
            onTap: () => _exportPdf(rows),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(stockSummaryReportProvider);
    final categories = ref.watch(inventoryCategoriesProvider).value ?? [];
    final categoryNamesById = {
      for (final category in categories) category.id: category.name,
      for (final category in InventoryCatalog.categories)
        category.id: category.name,
    };

    final viewData = reportAsync.maybeWhen(
      data: (report) => _resolveViewData(
        report: report,
        categoryNamesById: categoryNamesById,
      ),
      orElse: () => _resolveViewData(
        report: reportAsync.value,
        categoryNamesById: categoryNamesById,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        showBackButton: true,
        title: 'Stock Summary',
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
        actions: [
          MobileIconActionButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          MobileIconActionButton(
            icon: Icons.picture_as_pdf_outlined,
            tooltip: 'Export PDF',
            iconColor: const Color(0xFFE53935),
            onPressed: () => _exportPdf(viewData.rows),
          ),
          MobileIconActionButton(
            icon: Icons.grid_on_rounded,
            tooltip: 'Export Excel',
            iconColor: const Color(0xFF2E7D32),
            onPressed: () => _exportExcel(viewData.rows),
          ),
          MobileIconActionButton(
            icon: Icons.more_vert_rounded,
            tooltip: 'More',
            onPressed: () => _showMoreActions(viewData.rows),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateToggle(
            enabled: _showStockAsOnDate,
            date:
                ref.watch(reportFiltersProvider).selectedDate ?? DateTime.now(),
            hasActiveFilters: _filters.hasActiveFilters,
            onChanged: (enabled) {
              setState(() => _showStockAsOnDate = enabled);
              final notifier = ref.read(reportFiltersProvider.notifier);
              if (enabled) {
                notifier.setSelectedDate(DateTime.now());
              } else {
                notifier.clearSelectedDate();
              }
              unawaited(
                ref.read(stockSummaryReportProvider.notifier).refresh(),
              );
            },
            onFilterTap: () => unawaited(_openFilterSheet()),
          ),
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: MobileSearchField(
                controller: _searchController,
                hint: 'Search items...',
                onChanged: _onSearchChanged,
              ),
            ),
          if (viewData.usingMock)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Showing demo stock data — connect to load live report.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          StockSummaryStatCards(
            itemCount: viewData.itemCount,
            lowStockCount: viewData.lowStockCount,
            stockValue: viewData.stockValue,
          ),
          Expanded(
            child: reportAsync.when(
              loading: () => viewData.rows.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _StockSummaryList(rows: viewData.rows),
              error: (error, _) => viewData.rows.isEmpty
                  ? AppError(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(stockSummaryReportProvider),
                    )
                  : _StockSummaryList(rows: viewData.rows),
              data: (_) => viewData.rows.isEmpty
                  ? MobileEmptyState(
                      title: 'No stock items',
                      message:
                          _filters.hasActiveFilters || _searchQuery.isNotEmpty
                          ? 'Try changing your search or filters.'
                          : 'Add items to see stock summary.',
                      icon: Icons.inventory_2_outlined,
                    )
                  : _StockSummaryList(rows: viewData.rows),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockSummaryViewData {
  const _StockSummaryViewData({
    required this.rows,
    required this.itemCount,
    required this.lowStockCount,
    required this.stockValue,
    required this.usingMock,
  });

  final List<StockSummaryDisplayRow> rows;
  final int itemCount;
  final int lowStockCount;
  final double stockValue;
  final bool usingMock;
}

class _StockSummaryList extends StatelessWidget {
  const _StockSummaryList({required this.rows});

  final List<StockSummaryDisplayRow> rows;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Gap(AppSpacing.md),
      itemBuilder: (context, index) => StockSummaryRowCard(row: rows[index]),
    );
  }
}

class _DateToggle extends StatelessWidget {
  const _DateToggle({
    required this.enabled,
    required this.date,
    required this.onChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  final bool enabled;
  final DateTime date;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  static const _activeFilterColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: enabled,
              onChanged: (value) => onChanged(value ?? false),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Text(
              'Show stock as on Date: ${formatReportDate(date)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onFilterTap != null)
            MobileIconActionButton(
              icon: Icons.filter_list_rounded,
              tooltip: 'Filter',
              iconColor: hasActiveFilters ? _activeFilterColor : null,
              onPressed: onFilterTap,
            ),
        ],
      ),
    );
  }
}
