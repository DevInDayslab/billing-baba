import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllPartiesReportContent extends ConsumerWidget {
  const AllPartiesReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(partyOutstandingReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(partyOutstandingReportProvider.notifier).refresh(),
      data: (report) {
        final parties = report.rows;
        final summary = report;

        List<List<String>> exportRows() => [
          for (var i = 0; i < parties.length; i++)
            _partyExportRow(i, parties[i]),
        ];

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'All Parties',
            filename: 'all-parties',
            headers: const [
              '#',
              'Party Name',
              'Email',
              'Phone No.',
              'Receivable Balance',
              'Payable Balance',
              'Credit Limit',
            ],
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'All Parties',
            headers: const [
              '#',
              'Party Name',
              'Email',
              'Phone No.',
              'Receivable Balance',
              'Payable Balance',
              'Credit Limit',
            ],
            rows: exportRows(),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
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
                              const ReportDisabledDateFilter(),
                              const ReportPartyTypeFilter(),
                              const ReportPartyGroupFilter(),
                              const ReportPartyStatusFilter(),
                              const ReportDisabledBusinessFilter(),
                              const ReportPageSizeFilter(),
                              ReportTextActionButton(
                                label: 'Excel Report',
                                icon: Icons.table_chart_outlined,
                                onTap: exportCsv,
                              ),
                              ReportTextActionButton(
                                label: 'Print',
                                icon: Icons.print_outlined,
                                onTap: printReport,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          child: ReportSearchField(
                            onChanged: ref
                                .read(reportFiltersProvider.notifier)
                                .setSearchQuery,
                          ),
                        ),
                        Expanded(
                          child: ReportTableArea(
                            child: ReportSyncScrollTable(
                              minWidth: 860,
                              emptyState: const SizedBox(
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
                              headerChildren: const [
                                ReportAlignedHeaderCell(label: '#', width: 40),
                                Expanded(
                                  child: ReportAlignedHeaderCell(
                                    label: 'PARTY NAME',
                                  ),
                                ),
                                ReportAlignedHeaderCell(label: 'EMAIL', width: 140),
                                ReportAlignedHeaderCell(
                                  label: 'PHONE NO.',
                                  width: 110,
                                ),
                                ReportAlignedHeaderCell(
                                  label: 'RECEIVABLE BALANCE',
                                  width: 140,
                                  alignment: Alignment.centerRight,
                                ),
                                ReportAlignedHeaderCell(
                                  label: 'PAYABLE BALANCE',
                                  width: 130,
                                  alignment: Alignment.centerRight,
                                ),
                                ReportAlignedHeaderCell(
                                  label: 'CREDIT LIMIT',
                                  width: 110,
                                  alignment: Alignment.centerRight,
                                ),
                              ],
                              rows: [
                                for (var i = 0; i < parties.length; i++)
                                  ReportAlignedRowStrip(
                                    index: i,
                                    child: _PartyRow(index: i, party: parties[i]),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        ReportPaginationBar(
                          page: report.meta.page,
                          totalPages: report.meta.totalPages,
                          onPrevious: report.meta.page > 1
                              ? () => ref
                                    .read(
                                      partyOutstandingReportProvider.notifier,
                                    )
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(
                                      partyOutstandingReportProvider.notifier,
                                    )
                                    .goToPage(report.meta.page + 1)
                              : null,
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
                      'Total Receivable: ${formatReportCurrency(summary.totalReceivable)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: reportTeal,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total Payable: ${formatReportCurrency(summary.totalPayable)}',
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
      },
    );
  }
}

List<String> _partyExportRow(int index, PartyModel party) {
  final email = party.email.isEmpty ? '—' : party.email;
  final receivable = party.balance > 0
      ? formatReportCurrency(party.balance)
      : '—';
  final payable = party.balance < 0
      ? formatReportCurrency(party.balance.abs())
      : '—';
  final creditLimit = party.creditLimit.isEmpty
      ? '—'
      : formatReportCurrency(double.tryParse(party.creditLimit) ?? 0);

  return [
    '${index + 1}',
    party.name,
    email,
    party.phone,
    receivable,
    payable,
    creditLimit,
  ];
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({required this.index, required this.party});

  final int index;
  final PartyModel party;

  @override
  Widget build(BuildContext context) {
    final email = party.email.isEmpty ? '—' : party.email;
    final receivable = party.balance > 0
        ? formatReportCurrency(party.balance)
        : '—';
    final payable = party.balance < 0
        ? formatReportCurrency(party.balance.abs())
        : '—';
    final creditLimit = party.creditLimit.isEmpty
        ? '—'
        : formatReportCurrency(double.tryParse(party.creditLimit) ?? 0);

    return ReportAlignedDataRow(
      cells: [
        ReportAlignedCell.fixed(40, child: Text('${index + 1}')),
        ReportAlignedCell.flex(
          child: Text(
            party.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ReportAlignedCell.fixed(140, child: Text(email)),
        ReportAlignedCell.fixed(110, child: Text(party.phone)),
        ReportAlignedCell.fixed(
          140,
          alignment: Alignment.centerRight,
          child: Text(receivable),
        ),
        ReportAlignedCell.fixed(
          130,
          alignment: Alignment.centerRight,
          child: Text(payable),
        ),
        ReportAlignedCell.fixed(
          110,
          alignment: Alignment.centerRight,
          child: Text(creditLimit),
        ),
      ],
    );
  }
}
