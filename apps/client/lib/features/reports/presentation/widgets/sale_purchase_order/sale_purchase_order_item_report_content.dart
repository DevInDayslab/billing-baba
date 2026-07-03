import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/sale_purchase_order/sale_purchase_order_report_filters.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalePurchaseOrderItemReportContent extends StatelessWidget {
  const SalePurchaseOrderItemReportContent({super.key});

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
                    ReportTableHeaderRow(
                      children: const [
                        Expanded(
                          child: ReportTableHeaderCell(label: 'ITEM NAME'),
                        ),
                        ReportTableHeaderCell(
                          label: 'QUANTITY',
                          width: 140,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'AMOUNT',
                          width: 140,
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No order items for the selected period.',
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
                        vertical: AppSpacing.md,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: reportCardBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(fontSize: 14),
                              children: const [
                                TextSpan(
                                  text: 'Total Quantity: ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: '0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: reportTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text.rich(
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
                                  text: _currencyFormat.format(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: reportTeal,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}
