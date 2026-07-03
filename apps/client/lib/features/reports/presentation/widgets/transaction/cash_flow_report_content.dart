import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';

class CashFlowReportContent extends StatefulWidget {
  const CashFlowReportContent({super.key});

  @override
  State<CashFlowReportContent> createState() => _CashFlowReportContentState();
}

class _CashFlowReportContentState extends State<CashFlowReportContent> {
  bool _showZeroAmount = false;

  @override
  Widget build(BuildContext context) {
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
            child: ReportPeriodFilterBar(
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ReportTextActionButton(
                    label: 'Excel Report',
                    icon: Icons.table_chart_outlined,
                  ),
                  ReportTextActionButton(
                    label: 'Print',
                    icon: Icons.print_outlined,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                const Text(
                  'Opening Cash-in Hand: ₹ 0.00',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: reportTeal,
                  ),
                ),
                const Spacer(),
                Checkbox(
                  value: _showZeroAmount,
                  onChanged: (v) =>
                      setState(() => _showZeroAmount = v ?? false),
                  visualDensity: VisualDensity.compact,
                ),
                const Text(
                  'Show zero amount transaction',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: ReportSearchField(),
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    ReportTableHeaderRow(
                      children: const [
                        ReportTableHeaderCell(label: 'DATE', width: 90),
                        ReportTableHeaderCell(label: 'REF NO.', width: 90),
                        Expanded(child: ReportTableHeaderCell(label: 'NAME')),
                        ReportTableHeaderCell(label: 'CATEGORY', width: 90),
                        ReportTableHeaderCell(label: 'TYPE', width: 80),
                        ReportTableHeaderCell(
                          label: 'CASH IN',
                          width: 90,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'CASH OUT',
                          width: 90,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'RUNNING BAL.',
                          width: 100,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'PRINT/SHARE',
                          width: 100,
                          showFilter: false,
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No transactions to show',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    ReportMoneySummaryFooter(
                      items: [
                        ReportMoneySummaryItem(
                          label: 'Total Cash-in',
                          amount: '₹ 0.00',
                          color: reportTeal,
                        ),
                        ReportMoneySummaryItem(
                          label: 'Total Cash-out',
                          amount: '₹ 0.00',
                          color: reportAddRed,
                        ),
                        ReportMoneySummaryItem(
                          label: 'Closing Cash-in Hand',
                          amount: '₹ 0.00',
                          color: reportTeal,
                          bold: true,
                        ),
                      ],
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
