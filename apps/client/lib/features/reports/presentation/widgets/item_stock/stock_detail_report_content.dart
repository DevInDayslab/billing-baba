import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StockDetailReportContent extends ConsumerStatefulWidget {
  const StockDetailReportContent({super.key});

  @override
  ConsumerState<StockDetailReportContent> createState() =>
      _StockDetailReportContentState();
}

class _StockDetailReportContentState
    extends ConsumerState<StockDetailReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _category = 'All Categories';
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
    final reportAsync = ref.watch(stockDetailReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(stockDetailReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;

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
                  const ReportIconActionButton(
                    icon: Icons.table_chart_outlined,
                    tooltip: 'Excel',
                  ),
                  const ReportIconActionButton(
                    icon: Icons.print_outlined,
                    tooltip: 'Print',
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SaleFilterDropdown(
                            label: _category,
                            options: const [
                              'All Categories',
                              'Category A',
                              'Category B',
                            ],
                            selected: _category,
                            onSelected: (value) =>
                                setState(() => _category = value),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    Expanded(
                      child: rows.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  headerChildren: const [
                                    Expanded(
                                      child: ReportAlignedHeaderCell(
                                        label: 'ITEM NAME',
                                      ),
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'BEGINNING QUANTITY',
                                      width: 150,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'QUANTITY IN',
                                      width: 110,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'PURCHASE AMOUNT',
                                      width: 140,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'QUANTITY OUT',
                                      width: 110,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'SALE AMOUNT',
                                      width: 120,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'CLOSING QUANTITY',
                                      width: 140,
                                      alignment: Alignment.centerRight,
                                    ),
                                  ],
                                  rows: const [],
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'No data for the selected period.',
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
                                headerChildren: const [
                                  Expanded(
                                    child: ReportAlignedHeaderCell(
                                      label: 'ITEM NAME',
                                    ),
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'BEGINNING QUANTITY',
                                    width: 150,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'QUANTITY IN',
                                    width: 110,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'PURCHASE AMOUNT',
                                    width: 140,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'QUANTITY OUT',
                                    width: 110,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'SALE AMOUNT',
                                    width: 120,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'CLOSING QUANTITY',
                                    width: 140,
                                    alignment: Alignment.centerRight,
                                  ),
                                ],
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.flex(
                                            child: Text(rows[i].itemName),
                                          ),
                                          ReportAlignedCell.fixed(
                                            150,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i]
                                                  .openingQty
                                                  .toStringAsFixed(0),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            110,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i].inQty.toStringAsFixed(0),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            140,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].inQty * 150,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            110,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i].outQty.toStringAsFixed(0),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].outQty * 200,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            140,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i]
                                                  .closingQty
                                                  .toStringAsFixed(0),
                                            ),
                                          ),
                                        ],
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
