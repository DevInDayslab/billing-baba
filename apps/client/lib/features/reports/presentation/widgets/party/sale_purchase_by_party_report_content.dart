import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalePurchaseByPartyReportContent extends StatelessWidget {
  const SalePurchaseByPartyReportContent({super.key});

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
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: ReportPeriodFilterBar(
              trailing: Row(
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
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 180,
                            child: SaleFilterDropdown(
                              label: 'All Parties',
                              options: const [
                                'All Parties',
                                'Customers',
                                'Suppliers',
                              ],
                              selected: 'All Parties',
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
                        Expanded(
                          child: ReportTableHeaderCell(label: 'PARTY NAME'),
                        ),
                        ReportTableHeaderCell(
                          label: 'SALE AMOUNT',
                          width: 120,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'PURCHASE AMOUNT',
                          width: 140,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'RECEIVABLE',
                          width: 110,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'PAYABLE',
                          width: 100,
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No data available for the selected period.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: reportCardBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Total Sale: ${_currencyFormat.format(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Total Purchase: ${_currencyFormat.format(0)}',
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
          ),
        ],
      ),
    );
  }
}
