import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/sale_purchase_order/sale_purchase_order_report_filters.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseOrdersReportContent extends ConsumerWidget {
  const SalePurchaseOrdersReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(reportOrdersProvider);
    final totalAmount =
        rows.fold<double>(0, (sum, row) => sum + row.amount);

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SalePurchaseOrderReportFilters(),
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
                    Expanded(
                      child: rows.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  headerChildren: const [
                                    ReportAlignedHeaderCell(
                                      label: 'DATE',
                                      width: 100,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'ORDER NO.',
                                      width: 110,
                                    ),
                                    Expanded(
                                      child: ReportAlignedHeaderCell(
                                        label: 'NAME',
                                      ),
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'DUE DATE',
                                      width: 100,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'STATUS',
                                      width: 90,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'TYPE',
                                      width: 100,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'TOTAL',
                                      width: 100,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'ADVANCE',
                                      width: 100,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'BALANCE',
                                      width: 100,
                                      alignment: Alignment.centerRight,
                                    ),
                                  ],
                                  rows: const [],
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'No orders found for the selected period.',
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
                                    label: 'DATE',
                                    width: 100,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'ORDER NO.',
                                    width: 110,
                                  ),
                                  Expanded(
                                    child: ReportAlignedHeaderCell(
                                      label: 'NAME',
                                    ),
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'DUE DATE',
                                    width: 100,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'STATUS',
                                    width: 90,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'TYPE',
                                    width: 100,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'TOTAL',
                                    width: 100,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'ADVANCE',
                                    width: 100,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'BALANCE',
                                    width: 100,
                                    alignment: Alignment.centerRight,
                                  ),
                                ],
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.fixed(
                                            100,
                                            child: Text(
                                              formatReportDate(rows[i].date),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            110,
                                            child: Text(rows[i].orderNo),
                                          ),
                                          ReportAlignedCell.flex(
                                            child: Text(rows[i].partyName),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            child: Text(
                                              formatReportDate(rows[i].dueDate),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            90,
                                            child: Text(rows[i].status),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            child: Text(rows[i].type),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].amount,
                                              ),
                                            ),
                                          ),
                                          const ReportAlignedCell.fixed(
                                            100,
                                            alignment: Alignment.centerRight,
                                            child: Text('-'),
                                          ),
                                          const ReportAlignedCell.fixed(
                                            100,
                                            alignment: Alignment.centerRight,
                                            child: Text('-'),
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
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              const TextSpan(
                                text: 'Total Amount: ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: formatReportCurrency(totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: reportTeal,
                                ),
                              ),
                            ],
                          ),
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
  }
}
