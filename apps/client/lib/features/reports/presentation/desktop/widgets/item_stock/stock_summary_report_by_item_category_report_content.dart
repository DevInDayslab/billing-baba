import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/utils/report_table_builders.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(stockSummaryByItemCategoryReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(stockSummaryByItemCategoryReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalPurchaseValue = rows.fold<double>(
          0,
          (sum, row) => sum + row.purchaseAmount,
        );
        final totalSaleValue = rows.fold<double>(
          0,
          (sum, row) => sum + row.saleAmount,
        );
        const exportHeaders = [
          'Item Category',
          'No. of Items',
          'Stock Qty',
          'Purchase Value',
          'Sale Value',
          'Low Stock Items',
        ];
        final exportRows = [
          for (final row in rows)
            [
              row.category,
              '—',
              '—',
              formatReportCurrency(row.purchaseAmount),
              formatReportCurrency(row.saleAmount),
              '—',
            ],
        ];

        return ColoredBox(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ReportCard(
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
                            onChanged: (value) => setState(
                              () => _useDateFilter = value ?? false,
                            ),
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
                            onDateSelected: (date) =>
                                setState(() => _asOnDate = date),
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
                        onTap: () => reportExportTable(
                          context: context,
                          title: 'Stock Summary by Item Category',
                          filename: 'stock-summary-by-item-category',
                          headers: exportHeaders,
                          rows: exportRows,
                        ),
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: () => reportPrintTable(
                          context: context,
                          title: 'Stock Summary by Item Category',
                          headers: exportHeaders,
                          rows: exportRows,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: ReportCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'STOCK SUMMARY REPORT BY ITEM CATEGORY',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _SummaryChip(
                                label: 'Categories',
                                value: '${rows.length}',
                                icon: Icons.category_outlined,
                              ),
                              _SummaryChip(
                                label: 'Stock Value',
                                value: formatReportCurrency(totalPurchaseValue),
                                icon: Icons.payments_outlined,
                                highlight: true,
                              ),
                              _SummaryChip(
                                label: 'Sale Value',
                                value: formatReportCurrency(totalSaleValue),
                                icon: Icons.trending_up_outlined,
                              ),
                              const SizedBox(
                                width: 280,
                                child: ReportSearchField(
                                  hintText: 'Search category...',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportTableArea(
                            child:
                                ReportFilterableSyncTable<
                                  ReportCategoryAmountRow
                                >(
                                  reportScope:
                                      stockSummaryByCategoryReportScope,
                                  columns: stockSummaryByCategoryColumns(),
                                  rows: rows,
                                  emptyState: const Center(
                                    child: Text(
                                      'No stock data found for the selected filters.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: const BoxDecoration(
                            color: reportTableHeaderBg,
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          child: ReportHorizontalScroll(
                            minWidth: 720,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 150,
                                  child: Text(
                                    'Grand Total',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 110,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '—',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 100,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '—',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      formatReportCurrency(totalPurchaseValue),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      formatReportCurrency(totalSaleValue),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: reportTeal,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 130,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '—',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? reportTeal.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: highlight
              ? reportTeal.withValues(alpha: 0.35)
              : reportCardBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlight ? reportTeal : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: highlight ? reportTeal : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
