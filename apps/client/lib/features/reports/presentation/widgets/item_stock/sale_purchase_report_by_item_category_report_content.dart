import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SalePurchaseReportByItemCategoryReportContent
    extends ConsumerStatefulWidget {
  const SalePurchaseReportByItemCategoryReportContent({super.key});

  @override
  ConsumerState<SalePurchaseReportByItemCategoryReportContent> createState() =>
      _SalePurchaseReportByItemCategoryReportContentState();
}

class _SalePurchaseReportByItemCategoryReportContentState
    extends ConsumerState<SalePurchaseReportByItemCategoryReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _partyNameController = TextEditingController();
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
  void dispose() {
    _partyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(salePurchaseByItemCategoryReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(salePurchaseByItemCategoryReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalSaleAmount = rows.fold<double>(
          0,
          (sum, row) => sum + row.saleAmount,
        );
        final totalPurchaseAmount = rows.fold<double>(
          0,
          (sum, row) => sum + row.purchaseAmount,
        );

        const exportHeaders = [
          'Item Category',
          'Sale Quantity',
          'Total Sale Amount',
          'Purchase Quantity',
          'Total Purchase Amount',
        ];

        List<List<String>> exportRows() => [
          for (final row in rows)
            [
              row.category,
              (row.saleAmount / 1000).toStringAsFixed(0),
              formatReportCurrency(row.saleAmount),
              (row.purchaseAmount / 1000).toStringAsFixed(0),
              formatReportCurrency(row.purchaseAmount),
            ],
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Sale/Purchase Report By Item Category',
            filename: 'sale-purchase-by-item-category',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Sale/Purchase Report By Item Category',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

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
                            'Party name',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _partyNameController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Party name',
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                  borderSide: const BorderSide(
                                    color: reportCardBorder,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                  borderSide: const BorderSide(
                                    color: reportCardBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                  borderSide: const BorderSide(
                                    color: reportTeal,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                              ),
                            ),
                          ),
                        ],
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
                              onTap: () =>
                                  _datePickerKey.currentState?.toggle(),
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
                      ReportIconActionButton(
                        icon: Icons.table_chart_outlined,
                        tooltip: 'Excel',
                        onTap: exportExcel,
                      ),
                      ReportIconActionButton(
                        icon: Icons.print_outlined,
                        tooltip: 'Print',
                        onTap: printReport,
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
                            'SALE/PURCHASE REPORT BY ITEM CATEGORY',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: rows.isEmpty
                              ? const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ReportSyncScrollTable(
                                      headerChildren: [
                                        Expanded(
                                          child: ReportAlignedHeaderCell(
                                            label: 'ITEM CATEGORY',
                                            showFilter: false,
                                          ),
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'SALE QUANTITY',
                                          width: 130,
                                          showFilter: false,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'TOTAL SALE AMOUNT',
                                          width: 150,
                                          showFilter: false,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'PURCHASE QUANTITY',
                                          width: 150,
                                          showFilter: false,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'TOTAL PURCHASE AMOUNT',
                                          width: 170,
                                          showFilter: false,
                                          alignment: Alignment.centerRight,
                                        ),
                                      ],
                                      rows: [],
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'No data to display.',
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
                                          label: 'ITEM CATEGORY',
                                          showFilter: false,
                                        ),
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'SALE QUANTITY',
                                        width: 130,
                                        showFilter: false,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'TOTAL SALE AMOUNT',
                                        width: 150,
                                        showFilter: false,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'PURCHASE QUANTITY',
                                        width: 150,
                                        showFilter: false,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'TOTAL PURCHASE AMOUNT',
                                        width: 170,
                                        showFilter: false,
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
                                                child: Text(rows[i].category),
                                              ),
                                              ReportAlignedCell.fixed(
                                                130,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  (rows[i].saleAmount / 1000)
                                                      .toStringAsFixed(0),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                150,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].saleAmount,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                150,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  (rows[i].purchaseAmount /
                                                          1000)
                                                      .toStringAsFixed(0),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                170,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].purchaseAmount,
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
                          decoration: const BoxDecoration(
                            color: reportTableHeaderBg,
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: ReportHorizontalScroll(
                            minWidth: 730,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 150,
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      (totalSaleAmount / 1000).toStringAsFixed(
                                        0,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      formatReportCurrency(totalSaleAmount),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      (totalPurchaseAmount / 1000)
                                          .toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 170,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      formatReportCurrency(totalPurchaseAmount),
                                      style: const TextStyle(
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
