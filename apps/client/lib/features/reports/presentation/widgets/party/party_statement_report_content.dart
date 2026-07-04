import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/providers/party_catalog.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_view_toggle.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyStatementReportContent extends ConsumerStatefulWidget {
  const PartyStatementReportContent({super.key});

  @override
  ConsumerState<PartyStatementReportContent> createState() =>
      _PartyStatementReportContentState();
}

class _PartyStatementReportContentState
    extends ConsumerState<PartyStatementReportContent> {
  String _viewMode = 'Vyapar';
  bool _summaryExpanded = true;

  @override
  Widget build(BuildContext context) {
    final partyId = ref.watch(reportSelectedPartyIdProvider);
    final parties = PartyCatalog.parties;
    final selectedParty = parties
        .where((party) => party.id == partyId)
        .firstOrNull;
    final partyNames = parties.map((party) => party.name).toList();
    final statement = ref.watch(reportPartyStatementProvider(partyId));
    final summary = ref.watch(reportPartyStatementSummaryProvider(partyId));

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
              child: SaleFilterDropdown(
                label: 'Select Party',
                options: partyNames,
                selected: selectedParty?.name ?? partyNames.first,
                showSearchField: true,
                onSelected: (name) {
                  final party =
                      parties.where((p) => p.name == name).firstOrNull;
                  if (party != null) {
                    ref
                        .read(reportSelectedPartyIdProvider.notifier)
                        .select(party.id);
                  }
                },
              ),
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
                  ReportSyncScrollTable(
                    minWidth: 520,
                    emptyState: const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'No statement entries for this party.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    headerChildren: const [
                      ReportAlignedHeaderCell(label: 'DATE', width: 100),
                      ReportAlignedHeaderCell(label: 'TYPE', width: 100),
                      ReportAlignedHeaderCell(label: 'REF NO.', width: 110),
                      Expanded(child: ReportAlignedHeaderCell(label: 'TOTAL')),
                      ReportAlignedHeaderCell(
                        label: 'BALANCE',
                        width: 100,
                        alignment: Alignment.centerRight,
                      ),
                    ],
                    rows: [
                      for (var i = 0; i < statement.length; i++)
                        ReportAlignedRowStrip(
                          index: i,
                          child: ReportAlignedDataRow(
                            cells: [
                              ReportAlignedCell.fixed(
                                100,
                                child: Text(
                                  formatReportDate(statement[i].date),
                                ),
                              ),
                              ReportAlignedCell.fixed(
                                100,
                                child: Text(statement[i].type),
                              ),
                              ReportAlignedCell.fixed(
                                110,
                                child: Text(statement[i].refNo),
                              ),
                              ReportAlignedCell.flex(
                                child: Text(
                                  formatReportCurrency(statement[i].total),
                                ),
                              ),
                              ReportAlignedCell.fixed(
                                100,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatReportCurrency(statement[i].balance),
                                ),
                              ),
                            ],
                          ),
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
                                  amount: formatReportCurrency(summary.totalSale),
                                ),
                                _SummaryMetric(
                                  label: 'Total Purchase',
                                  amount:
                                      formatReportCurrency(summary.totalPurchase),
                                ),
                                _SummaryMetric(
                                  label: 'Total Money-in',
                                  amount:
                                      formatReportCurrency(summary.totalMoneyIn),
                                ),
                                _SummaryMetric(
                                  label: 'Total Money-out',
                                  amount:
                                      formatReportCurrency(summary.totalMoneyOut),
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
                                formatReportCurrency(summary.totalReceivable),
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
