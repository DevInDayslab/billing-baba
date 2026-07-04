import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ItemCategoryWiseProfitLossReportContent extends ConsumerStatefulWidget {
  const ItemCategoryWiseProfitLossReportContent({super.key});

  @override
  ConsumerState<ItemCategoryWiseProfitLossReportContent> createState() =>
      _ItemCategoryWiseProfitLossReportContentState();
}

class _ItemCategoryWiseProfitLossReportContentState
    extends ConsumerState<ItemCategoryWiseProfitLossReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _firm = 'ALL FIRMS';
  bool _showInactiveCategories = false;
  bool _categoriesHavingSale = false;
  late DateTimeRange _dateRange;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(reportCategoryWiseProfitLossProvider);
    final totalSale =
        rows.fold<double>(0, (sum, row) => sum + row.saleAmount);
    final totalProfit =
        rows.fold<double>(0, (sum, row) => sum + row.profit);

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
                  SaleFilterDropdown(
                    label: _firm,
                    options: const ['ALL FIRMS', 'Firm A', 'Firm B'],
                    selected: _firm,
                    onSelected: (value) => setState(() => _firm = value),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _dateFormat.format(_dateRange.start),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Text(
                        'To',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SaleDateRangePickerAnchor(
                        key: _datePickerKey,
                        initialRange: _dateRange,
                        onRangeSelected: (range) =>
                            setState(() => _dateRange = range),
                        child: InkWell(
                          onTap: () => _datePickerKey.currentState?.toggle(),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _dateFormat.format(_dateRange.end),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
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
                        value: _showInactiveCategories,
                        onChanged: (value) => setState(
                          () => _showInactiveCategories = value ?? false,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Show Inactive Categories',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _categoriesHavingSale,
                        onChanged: (value) => setState(
                          () => _categoriesHavingSale = value ?? false,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Categories Having Sale',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const ReportTextActionButton(
                    label: 'Excel',
                    icon: Icons.table_chart_outlined,
                  ),
                  const ReportTextActionButton(
                    label: 'Print',
                    icon: Icons.print_outlined,
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
                        'DETAILS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    Expanded(
                      child: rows.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  minWidth: 1180,
                                  headerChildren: const [
                                    ReportAlignedHeaderCell(label: 'ITEM CATEGORY', width: 150, showFilter: false),
                                    ReportAlignedHeaderCell(label: 'SALE', width: 100, showFilter: false, alignment: Alignment.centerRight),
                                    ReportAlignedHeaderCell(label: 'CR. NOTE / SALE RETURN', width: 150, showFilter: false, alignment: Alignment.centerRight),
                                    ReportAlignedHeaderCell(label: 'PURCHASE', width: 110, showFilter: false, alignment: Alignment.centerRight),
                                    ReportAlignedHeaderCell(label: 'DR. NOTE / PURCHASE RETURN', width: 170, showFilter: false, alignment: Alignment.centerRight),
                                    ReportAlignedHeaderCell(label: 'OPENING STOCK', width: 120, showFilter: false, alignment: Alignment.centerRight),
                                    ReportAlignedHeaderCell(label: 'CLOSING STOCK', width: 120, showFilter: false, alignment: Alignment.centerRight),
                                    ReportAlignedHeaderCell(label: 'NET PROFIT (+) / LOSS (-)', width: 160, showFilter: false, alignment: Alignment.centerRight),
                                  ],
                                  rows: const [],
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'No profit or loss data for the selected period.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                minWidth: 1180,
                                headerChildren: const [
                                  ReportAlignedHeaderCell(label: 'ITEM CATEGORY', width: 150, showFilter: false),
                                  ReportAlignedHeaderCell(label: 'SALE', width: 100, showFilter: false, alignment: Alignment.centerRight),
                                  ReportAlignedHeaderCell(label: 'CR. NOTE / SALE RETURN', width: 150, showFilter: false, alignment: Alignment.centerRight),
                                  ReportAlignedHeaderCell(label: 'PURCHASE', width: 110, showFilter: false, alignment: Alignment.centerRight),
                                  ReportAlignedHeaderCell(label: 'DR. NOTE / PURCHASE RETURN', width: 170, showFilter: false, alignment: Alignment.centerRight),
                                  ReportAlignedHeaderCell(label: 'OPENING STOCK', width: 120, showFilter: false, alignment: Alignment.centerRight),
                                  ReportAlignedHeaderCell(label: 'CLOSING STOCK', width: 120, showFilter: false, alignment: Alignment.centerRight),
                                  ReportAlignedHeaderCell(label: 'NET PROFIT (+) / LOSS (-)', width: 160, showFilter: false, alignment: Alignment.centerRight),
                                ],
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.fixed(150, child: Text(rows[i].itemName)),
                                          ReportAlignedCell.fixed(100, alignment: Alignment.centerRight, child: Text(formatReportCurrency(rows[i].saleAmount))),
                                          const ReportAlignedCell.fixed(150, alignment: Alignment.centerRight, child: Text('-')),
                                          ReportAlignedCell.fixed(110, alignment: Alignment.centerRight, child: Text(formatReportCurrency(rows[i].purchaseAmount))),
                                          const ReportAlignedCell.fixed(170, alignment: Alignment.centerRight, child: Text('-')),
                                          const ReportAlignedCell.fixed(120, alignment: Alignment.centerRight, child: Text('-')),
                                          const ReportAlignedCell.fixed(120, alignment: Alignment.centerRight, child: Text('-')),
                                          ReportAlignedCell.fixed(
                                            160,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(rows[i].profit),
                                              style: TextStyle(
                                                color: rows[i].profit >= 0 ? reportTeal : reportAddRed,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: reportCardBorder)),
                      ),
                      child: Wrap(
                        spacing: AppSpacing.lg,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Total Sale: ${formatReportCurrency(totalSale)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Total Profit (+) / Loss (-): ${formatReportCurrency(totalProfit)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: reportTeal,
                            ),
                          ),
                        ],
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
  }
}
