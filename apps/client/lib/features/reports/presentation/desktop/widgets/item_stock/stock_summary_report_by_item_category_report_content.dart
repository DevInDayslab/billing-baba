import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/item_stock/stock_summary_by_item_category_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/stock_summary_by_item_category_export.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StockSummaryReportByItemCategoryReportContent
    extends ConsumerStatefulWidget {
  const StockSummaryReportByItemCategoryReportContent({super.key});

  @override
  ConsumerState<StockSummaryReportByItemCategoryReportContent> createState() =>
      _StockSummaryReportByItemCategoryReportContentState();
}

class _StockSummaryReportByItemCategoryReportContentState
    extends ConsumerState<StockSummaryReportByItemCategoryReportContent> {
  final _datePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  bool _useDateFilter = true;
  bool _includeZeroStock = false;
  bool _lowStockOnly = false;
  late DateTime _asOnDate;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _asOnDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyDateFilter());
  }

  void _applyDateFilter() {
    if (!_useDateFilter) return;
    ref.read(reportFiltersProvider.notifier).setCustomDateRange(
      DateTimeRange(start: _asOnDate, end: _asOnDate),
    );
    ref.read(stockSummaryByItemCategoryReportProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(stockSummaryByItemCategoryReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(stockSummaryByItemCategoryReportProvider.notifier).refresh(),
      data: (report) {
        List<List<String>> exportRows() => [
          for (final row in report.rows)
            stockSummaryByItemCategoryExportRow(row),
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Stock Summary by Item Category',
            filename: 'stock-summary-by-item-category',
            headers: stockSummaryByItemCategoryExportHeaders,
            rows: exportRows(),
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Stock Summary by Item Category',
            headers: stockSummaryByItemCategoryExportHeaders,
            rows: exportRows(),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReportCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'FILTERS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _useDateFilter,
                            onChanged: (value) {
                              setState(() => _useDateFilter = value ?? false);
                              _applyDateFilter();
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                          const Text(
                            'As on date',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SaleSingleDatePickerAnchor(
                            key: _datePickerKey,
                            selectedDate: _asOnDate,
                            onDateSelected: (date) {
                              setState(() => _asOnDate = date);
                              _applyDateFilter();
                            },
                            child: InkWell(
                              onTap: _useDateFilter
                                  ? () => _datePickerKey.currentState?.toggle()
                                  : null,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: Opacity(
                                opacity: _useDateFilter ? 1 : 0.5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                    border: Border.all(color: reportCardBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _dateFormat.format(_asOnDate),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _includeZeroStock,
                            onChanged: (value) => setState(
                              () => _includeZeroStock = value ?? false,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          const Text(
                            'Include zero stock categories',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _lowStockOnly,
                            onChanged: (value) => setState(
                              () => _lowStockOnly = value ?? false,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          const Text(
                            'Low stock categories only',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      ReportTextActionButton(
                        label: 'Excel',
                        icon: Icons.table_chart_outlined,
                        onTap: exportExcel,
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: exportPrint,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: StockSummaryByItemCategoryTransactionsTable(
                    includeZeroStock: _includeZeroStock,
                    lowStockOnly: _lowStockOnly,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
