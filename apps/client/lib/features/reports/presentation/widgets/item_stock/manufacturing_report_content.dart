import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManufacturingReportContent extends ConsumerStatefulWidget {
  const ManufacturingReportContent({super.key});

  @override
  ConsumerState<ManufacturingReportContent> createState() =>
      _ManufacturingReportContentState();
}

class _ManufacturingReportContentState
    extends ConsumerState<ManufacturingReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(manufacturingReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(manufacturingReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalQty = rows.fold<double>(0, (sum, row) => sum + row.quantity);
        final totalAmount = rows.fold<double>(0, (sum, row) => sum + row.cost);

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Manufacturing Report',
            filename: 'manufacturing-report',
            headers: const [
              '#',
              'Item Name',
              'Date',
              'Qty Manufactured',
              'Amount',
            ],
            rows: [
              for (var i = 0; i < rows.length; i++)
                [
                  '${i + 1}',
                  rows[i].itemName,
                  formatReportDate(rows[i].date),
                  rows[i].quantity.toStringAsFixed(0),
                  formatReportCurrency(rows[i].cost),
                ],
            ],
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Manufacturing Report',
            headers: const [
              '#',
              'Item Name',
              'Date',
              'Qty Manufactured',
              'Amount',
            ],
            rows: [
              for (var i = 0; i < rows.length; i++)
                [
                  '${i + 1}',
                  rows[i].itemName,
                  formatReportDate(rows[i].date),
                  rows[i].quantity.toStringAsFixed(0),
                  formatReportCurrency(rows[i].cost),
                ],
            ],
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ReportCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Manufacturing Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              ReportTextActionButton(
                                label: 'Excel Report',
                                icon: Icons.table_chart_outlined,
                                onTap: exportExcel,
                              ),
                              ReportTextActionButton(
                                label: 'Print',
                                icon: Icons.print_outlined,
                                onTap: printReport,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: reportTableHeaderBg,
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
                                'Between',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SaleDateRangePickerAnchor(
                                key: _datePickerKey,
                                initialRange: _dateRange,
                                onRangeSelected: (range) =>
                                    setState(() => _dateRange = range),
                                child: SaleFilterChip(
                                  label: formatSaleDateRangeLabel(_dateRange),
                                  onTap: () =>
                                      _datePickerKey.currentState?.toggle(),
                                ),
                              ),
                              const SizedBox(
                                width: 260,
                                child: ReportSearchField(
                                  hintText: 'Search by item name...',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: rows.isEmpty
                              ? const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ReportSyncScrollTable(
                                      headerChildren: [
                                        ReportAlignedHeaderCell(
                                          label: '#',
                                          width: 40,
                                          showFilter: false,
                                        ),
                                        Expanded(
                                          child: ReportAlignedHeaderCell(
                                            label: 'ITEM NAME',
                                            showFilter: false,
                                          ),
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'DATE',
                                          width: 100,
                                          showFilter: false,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'QTY MANUFACTURED',
                                          width: 150,
                                          showFilter: false,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'AMOUNT',
                                          width: 110,
                                          showFilter: false,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'DETAILS',
                                          width: 80,
                                          showFilter: false,
                                          alignment: Alignment.center,
                                        ),
                                      ],
                                      rows: [],
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'No manufacturing records found for the selected period.',
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
                                      ReportAlignedHeaderCell(
                                        label: '#',
                                        width: 40,
                                        showFilter: false,
                                      ),
                                      Expanded(
                                        child: ReportAlignedHeaderCell(
                                          label: 'ITEM NAME',
                                          showFilter: false,
                                        ),
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'DATE',
                                        width: 100,
                                        showFilter: false,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'QTY MANUFACTURED',
                                        width: 150,
                                        showFilter: false,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'AMOUNT',
                                        width: 110,
                                        showFilter: false,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'DETAILS',
                                        width: 80,
                                        showFilter: false,
                                        alignment: Alignment.center,
                                      ),
                                    ],
                                    rows: [
                                      for (var i = 0; i < rows.length; i++)
                                        ReportAlignedRowStrip(
                                          index: i,
                                          child: ReportAlignedDataRow(
                                            cells: [
                                              ReportAlignedCell.fixed(
                                                40,
                                                child: Text('${i + 1}'),
                                              ),
                                              ReportAlignedCell.flex(
                                                child: Text(rows[i].itemName),
                                              ),
                                              ReportAlignedCell.fixed(
                                                100,
                                                child: Text(
                                                  formatReportDate(
                                                    rows[i].date,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                150,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  rows[i].quantity
                                                      .toStringAsFixed(0),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].cost,
                                                  ),
                                                ),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                80,
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.info_outline,
                                                  size: 16,
                                                  color:
                                                      AppColors.textSecondary,
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
                            vertical: AppSpacing.sm,
                          ),
                          decoration: const BoxDecoration(
                            color: reportTableHeaderBg,
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          child: Wrap(
                            spacing: AppSpacing.lg,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Total Qty Manufactured: ${totalQty.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Total Amount: ${formatReportCurrency(totalAmount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
        );
      },
    );
  }
}
