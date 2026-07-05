import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockTransferReportContent extends ConsumerStatefulWidget {
  const StockTransferReportContent({super.key});

  @override
  ConsumerState<StockTransferReportContent> createState() =>
      _StockTransferReportContentState();
}

class _StockTransferReportContentState
    extends ConsumerState<StockTransferReportContent> {
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
    final reportAsync = ref.watch(stockTransferReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(stockTransferReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalQty =
            rows.fold<double>(0, (sum, row) => sum + row.quantity);
        final totalValue = rows.fold<double>(
          0,
          (sum, row) => sum + row.quantity * 150,
        );

        const exportHeaders = [
          '#',
          'Transfer No.',
          'Date',
          'Item Name',
          'From Godown',
          'To Godown',
          'Qty Transferred',
          'Value',
        ];

        List<List<String>> exportRows() => [
              for (var i = 0; i < rows.length; i++)
                [
                  '${i + 1}',
                  rows[i].refNo,
                  formatReportDate(rows[i].date),
                  rows[i].itemName,
                  rows[i].fromGodown,
                  rows[i].toGodown,
                  rows[i].quantity.toStringAsFixed(0),
                  formatReportCurrency(rows[i].quantity * 150),
                ],
            ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Stock Transfer Report',
            filename: 'stock-transfer-report',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Stock Transfer Report',
            headers: exportHeaders,
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
            Expanded(
              child: ReportCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Stock Transfer Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Spacer(),
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
                            width: 240,
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  minWidth: 1040,
                                  headerChildren: [
                                    ReportAlignedHeaderCell(
                                      label: '#',
                                      width: 40,
                                      showFilter: false,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'TRANSFER NO.',
                                      width: 110,
                                      showFilter: false,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'DATE',
                                      width: 100,
                                      showFilter: false,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'ITEM NAME',
                                      width: 160,
                                      showFilter: false,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'FROM GODOWN',
                                      width: 120,
                                      showFilter: false,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'TO GODOWN',
                                      width: 120,
                                      showFilter: false,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'QTY TRANSFERRED',
                                      width: 130,
                                      showFilter: false,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'VALUE',
                                      width: 100,
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
                                      'No stock transfer records found for the selected period.',
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
                                minWidth: 1040,
                                headerChildren: const [
                                  ReportAlignedHeaderCell(
                                    label: '#',
                                    width: 40,
                                    showFilter: false,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'TRANSFER NO.',
                                    width: 110,
                                    showFilter: false,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'DATE',
                                    width: 100,
                                    showFilter: false,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'ITEM NAME',
                                    width: 160,
                                    showFilter: false,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'FROM GODOWN',
                                    width: 120,
                                    showFilter: false,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'TO GODOWN',
                                    width: 120,
                                    showFilter: false,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'QTY TRANSFERRED',
                                    width: 130,
                                    showFilter: false,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'VALUE',
                                    width: 100,
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
                                          ReportAlignedCell.fixed(
                                            110,
                                            child: Text(rows[i].refNo),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            child: Text(
                                              formatReportDate(rows[i].date),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            160,
                                            child: Text(rows[i].itemName),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            child: Text(rows[i].fromGodown),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            child: Text(rows[i].toGodown),
                                          ),
                                          ReportAlignedCell.fixed(
                                            130,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i]
                                                  .quantity
                                                  .toStringAsFixed(0),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].quantity * 150,
                                              ),
                                            ),
                                          ),
                                          const ReportAlignedCell.fixed(
                                            80,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.info_outline,
                                              size: 16,
                                              color: AppColors.textSecondary,
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
                            'Total Qty Transferred: ${totalQty.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Total Value: ${formatReportCurrency(totalValue)}',
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
          ],
        ),
      ),
    );
      },
    );
  }
}
