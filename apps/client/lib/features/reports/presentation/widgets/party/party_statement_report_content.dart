import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_view_toggle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartyStatementReportContent extends StatefulWidget {
  const PartyStatementReportContent({super.key});

  @override
  State<PartyStatementReportContent> createState() =>
      _PartyStatementReportContentState();
}

class _PartyStatementReportContentState extends State<PartyStatementReportContent> {
  String _viewMode = 'Vyapar';
  bool _summaryExpanded = true;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
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
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ReportPeriodFilterBar(
                showFirmFilter: false,
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
            const SizedBox(height: AppSpacing.sm),
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: const ReportSearchField(hintText: 'Select Party'),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: ReportViewToggle(
                      value: _viewMode,
                      onChanged: (v) => setState(() => _viewMode = v),
                    ),
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  ReportTableHeaderRow(
                    children: const [
                      ReportTableHeaderCell(label: 'DATE', width: 100),
                      ReportTableHeaderCell(label: 'TYPE', width: 100),
                      ReportTableHeaderCell(label: 'REF NO.', width: 110),
                      Expanded(child: ReportTableHeaderCell(label: 'TOTAL')),
                      ReportTableHeaderCell(
                        label: 'BALANCE',
                        width: 100,
                        alignment: Alignment.centerRight,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Select a party to view statement.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () =>
                        setState(() => _summaryExpanded = !_summaryExpanded),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          const Text(
                            'Party Statement Summary',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _summaryExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_summaryExpanded) ...[
                    const Divider(height: 1, color: reportCardBorder),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: AppSpacing.xl,
                              runSpacing: AppSpacing.md,
                              children: [
                                _SummaryMetric(
                                  label: 'Total Sale',
                                  subLabel: '(Sale - Sale Return)',
                                  amount: _currencyFormat.format(0),
                                ),
                                _SummaryMetric(
                                  label: 'Total Purchase',
                                  amount: _currencyFormat.format(0),
                                ),
                                _SummaryMetric(
                                  label: 'Total Money-in',
                                  amount: _currencyFormat.format(0),
                                ),
                                _SummaryMetric(
                                  label: 'Total Money-out',
                                  amount: _currencyFormat.format(0),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 80,
                            color: reportCardBorder,
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total Receivable',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _currencyFormat.format(0),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: reportTeal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.amount,
    this.subLabel,
  });

  final String label;
  final String? subLabel;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        if (subLabel != null)
          Text(
            subLabel!,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
