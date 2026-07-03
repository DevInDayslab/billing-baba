import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';

class AllTransactionsReportContent extends StatelessWidget {
  const AllTransactionsReportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ReportPeriodFilterBar(),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F1FB),
                          foregroundColor: reportActiveBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Share With Accountant',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const ReportTextActionButton(
                        label: 'Excel Report',
                        icon: Icons.table_chart_outlined,
                      ),
                      const ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: SaleFilterDropdown(
                            label: 'All Transaction',
                            options: const [
                              'All Transaction',
                              'Sale',
                              'Purchase',
                              'Payment In',
                              'Payment Out',
                            ],
                            selected: 'All Transaction',
                            onSelected: (_) {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(child: ReportSearchField()),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  const ReportTableHeaderRow(
                    children: [
                      ReportTableHeaderCell(label: '#', width: 40),
                      ReportTableHeaderCell(label: 'DATE', width: 90),
                      ReportTableHeaderCell(label: 'REF NO.', width: 90),
                      Expanded(
                        child: ReportTableHeaderCell(label: 'PARTY NAME'),
                      ),
                      ReportTableHeaderCell(label: 'CATEGORY', width: 90),
                      ReportTableHeaderCell(label: 'TYPE', width: 80),
                      ReportTableHeaderCell(
                        label: 'TOTAL',
                        width: 80,
                        alignment: Alignment.centerRight,
                      ),
                      ReportTableHeaderCell(
                        label: 'RECEIVED',
                        width: 90,
                        alignment: Alignment.centerRight,
                      ),
                      ReportTableHeaderCell(
                        label: 'BALANCE',
                        width: 80,
                        alignment: Alignment.centerRight,
                      ),
                      ReportTableHeaderCell(label: 'DUE DATE', width: 90),
                      ReportTableHeaderCell(label: 'STATUS', width: 80),
                      ReportTableHeaderCell(
                        label: 'PRINT',
                        width: 60,
                        showFilter: false,
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  const ReportEmptyTableState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
