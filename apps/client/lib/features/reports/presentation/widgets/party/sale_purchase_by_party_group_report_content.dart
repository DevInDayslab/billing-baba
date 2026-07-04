import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseByPartyGroupReportContent extends ConsumerWidget {
  const SalePurchaseByPartyGroupReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(reportSalePurchaseByPartyGroupProvider);
    final totalSale =
        rows.fold<double>(0, (sum, row) => sum + row.saleAmount);
    final totalPurchase =
        rows.fold<double>(0, (sum, row) => sum + row.purchaseAmount);
    final netBalance = totalSale - totalPurchase;

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
                            width: 160,
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
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 160,
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
                    Expanded(
                      child: rows.isEmpty
                          ? const Center(
                              child: Text(
                                'No data available for the selected period.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                minWidth: 700,
                                headerChildren: const [
                                  ReportAlignedHeaderCell(label: '#', width: 40),
                                  ReportAlignedHeaderCell(
                                    label: 'PARTY GROUP',
                                    width: 130,
                                  ),
                                  Expanded(
                                    child: ReportAlignedHeaderCell(
                                      label: 'PARTY NAME',
                                    ),
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'SALE AMOUNT',
                                    width: 120,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'PURCHASE AMOUNT',
                                    width: 130,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'NET BALANCE',
                                    width: 110,
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
                                            40,
                                            child: Text('${i + 1}'),
                                          ),
                                          ReportAlignedCell.fixed(
                                            130,
                                            child: Text(rows[i].partyGroup),
                                          ),
                                          ReportAlignedCell.flex(
                                            child: Text(
                                              rows[i].partyName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].saleAmount,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            130,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].purchaseAmount,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            110,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].saleAmount -
                                                    rows[i].purchaseAmount,
                                              ),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    rows[i].saleAmount -
                                                            rows[i]
                                                                .purchaseAmount >=
                                                        0
                                                    ? reportTeal
                                                    : Colors.red.shade700,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: reportCardBorder)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Total Sale: ${formatReportCurrency(totalSale)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Total Purchase: ${formatReportCurrency(totalPurchase)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Text(
                            'Net Balance: ${formatReportCurrency(netBalance)}',
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
          ),
        ],
      ),
    );
  }
}
