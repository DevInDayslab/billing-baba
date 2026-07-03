import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllPartiesReportContent extends StatefulWidget {
  const AllPartiesReportContent({super.key});

  @override
  State<AllPartiesReportContent> createState() =>
      _AllPartiesReportContentState();
}

class _AllPartiesReportContentState extends State<AllPartiesReportContent> {
  bool _dateFilterEnabled = false;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ReportCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Checkbox(
                            value: _dateFilterEnabled,
                            onChanged: (v) =>
                                setState(() => _dateFilterEnabled = v ?? false),
                            visualDensity: VisualDensity.compact,
                          ),
                          const Text(
                            'Date Filter',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(
                            width: 140,
                            child: SaleFilterDropdown(
                              label: 'All parties',
                              options: const [
                                'All parties',
                                'Customers',
                                'Suppliers',
                              ],
                              selected: 'All parties',
                              onSelected: (_) {},
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            child: SaleFilterDropdown(
                              label: 'All Groups',
                              options: const [
                                'All Groups',
                                'Group A',
                                'Group B',
                              ],
                              selected: 'All Groups',
                              onSelected: (_) {},
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
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: ReportSearchField(),
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    const ReportTableHeaderRow(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Checkbox(
                            value: false,
                            onChanged: null,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        ReportTableHeaderCell(label: '#', width: 40),
                        Expanded(
                          child: ReportTableHeaderCell(label: 'PARTY NAME'),
                        ),
                        ReportTableHeaderCell(label: 'EMAIL', width: 140),
                        ReportTableHeaderCell(
                          label: 'PHONE NO.',
                          width: 110,
                        ),
                        ReportTableHeaderCell(
                          label: 'RECEIVABLE BALANCE',
                          width: 140,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'PAYABLE BALANCE',
                          width: 130,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'CREDIT LIMIT',
                          width: 110,
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    const SizedBox(
                      height: 220,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'No parties to display.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Add parties to see them here.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: reportCardBorder)),
            ),
            child: Row(
              children: [
                Text(
                  'Total Receivable: ${_currencyFormat.format(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: reportTeal,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total Payable: ${_currencyFormat.format(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
