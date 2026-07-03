import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillWiseProfitReportContent extends StatelessWidget {
  const BillWiseProfitReportContent({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportDateRangeBar(
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReportIconActionButton(
                    icon: Icons.table_chart_outlined,
                    tooltip: 'Excel',
                  ),
                  ReportIconActionButton(
                    icon: Icons.print_outlined,
                    tooltip: 'Print',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
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
                      'PROFIT ON SALE INVOICES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'FILTERS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Party filter',
                              hintStyle: const TextStyle(fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(height: 1, color: reportCardBorder),
                  ReportTableHeaderRow(
                    children: const [
                      ReportTableHeaderCell(label: 'DATE', width: 90),
                      ReportTableHeaderCell(label: 'INVOICE NO', width: 110),
                      Expanded(child: ReportTableHeaderCell(label: 'PARTY')),
                      ReportTableHeaderCell(
                        label: 'TOTAL SALE AMOUNT',
                        width: 140,
                        alignment: Alignment.centerRight,
                      ),
                      ReportTableHeaderCell(
                        label: 'PROFIT (+) / LOSS (-)',
                        width: 140,
                        alignment: Alignment.centerRight,
                      ),
                      ReportTableHeaderCell(
                        label: 'DETAILS',
                        width: 80,
                        showFilter: false,
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  const SizedBox(
                    height: 160,
                    child: Center(
                      child: Text(
                        'No data for selected period',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Text(
                              'Total Sale Amount: ${_currencyFormat.format(0)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: AppSpacing.xl),
                            Text(
                              'Total Profit(+)/Loss(-): '
                              '${_currencyFormat.format(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: reportTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
