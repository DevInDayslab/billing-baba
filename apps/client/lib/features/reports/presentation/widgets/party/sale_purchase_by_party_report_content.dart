import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
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

class SalePurchaseByPartyReportContent extends ConsumerWidget {
  const SalePurchaseByPartyReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(reportSalePurchaseByPartyProvider);
    final parties = ref.watch(reportAllPartiesProvider);
    final partyByName = {
      for (final party in parties) party.name: party,
    };
    final totalSale =
        rows.fold<double>(0, (sum, row) => sum + row.saleAmount);
    final totalPurchase =
        rows.fold<double>(0, (sum, row) => sum + row.purchaseAmount);

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
                                minWidth: 650,
                                headerChildren: const [
                                  ReportAlignedHeaderCell(label: '#', width: 40),
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
                                    width: 140,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'RECEIVABLE',
                                    width: 110,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'PAYABLE',
                                    width: 100,
                                    alignment: Alignment.centerRight,
                                  ),
                                ],
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: _SalePurchaseRow(
                                        index: i,
                                        partyName: rows[i].partyName,
                                        saleAmount: rows[i].saleAmount,
                                        purchaseAmount: rows[i].purchaseAmount,
                                        party: partyByName[rows[i].partyName],
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

class _SalePurchaseRow extends StatelessWidget {
  const _SalePurchaseRow({
    required this.index,
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.party,
  });

  final int index;
  final String partyName;
  final double saleAmount;
  final double purchaseAmount;
  final PartyModel? party;

  @override
  Widget build(BuildContext context) {
    final balance = party?.balance ?? 0;
    final receivable =
        balance > 0 ? formatReportCurrency(balance) : '—';
    final payable =
        balance < 0 ? formatReportCurrency(balance.abs()) : '—';

    return ReportAlignedDataRow(
      cells: [
        ReportAlignedCell.fixed(40, child: Text('${index + 1}')),
        ReportAlignedCell.flex(
          child: Text(
            partyName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ReportAlignedCell.fixed(
          120,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrency(saleAmount)),
        ),
        ReportAlignedCell.fixed(
          140,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrency(purchaseAmount)),
        ),
        ReportAlignedCell.fixed(
          110,
          alignment: Alignment.centerRight,
          child: Text(receivable),
        ),
        ReportAlignedCell.fixed(
          100,
          alignment: Alignment.centerRight,
          child: Text(payable),
        ),
      ],
    );
  }
}
