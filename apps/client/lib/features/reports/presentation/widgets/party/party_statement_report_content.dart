import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_view_toggle.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePartySelected());
  }

  void _ensurePartySelected() {
    if (!mounted) return;
    final partyId = ref.read(reportFiltersProvider).partyId;
    if (partyId != null) return;

    final parties = ref.read(partiesListProvider);
    if (parties.isNotEmpty) {
      ref.read(reportFiltersProvider.notifier).setPartyId(parties.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final partyId = ref.watch(reportFiltersProvider.select((s) => s.partyId));
    final parties = ref.watch(partiesListProvider);
    final partyListAsync = ref.watch(partyListProvider);
    final selectedParty = parties.where((party) => party.id == partyId).firstOrNull;
    final partyNames = parties.map((party) => party.name).toList();
    final statementAsync = ref.watch(partyStatementReportProvider);

    ref.listen(partyListProvider, (previous, next) {
      if (!next.hasValue || next.requireValue.isEmpty) return;
      if (ref.read(reportFiltersProvider).partyId == null) {
        ref
            .read(reportFiltersProvider.notifier)
            .setPartyId(next.requireValue.first.id);
      }
    });

    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ReportPeriodFilterBar(
                showFirmFilter: false,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReportTextActionButton(
                      label: 'Excel Report',
                      icon: Icons.table_chart_outlined,
                      onTap: partyId == null
                          ? null
                          : () => _exportExcel(context, statementAsync.value),
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: partyId == null
                          ? null
                          : () => _printReport(context, statementAsync.value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: partyListAsync.isLoading && parties.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : parties.isEmpty
                  ? const Text(
                      'No parties found. Add a party to view their statement.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : SaleFilterDropdown(
                      label: 'Select Party',
                      options: partyNames,
                      selected: selectedParty?.name ?? partyNames.first,
                      showSearchField: true,
                      onSelected: (name) {
                        final party =
                            parties.where((p) => p.name == name).firstOrNull;
                        if (party != null) {
                          ref
                              .read(reportFiltersProvider.notifier)
                              .setPartyId(party.id);
                        }
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: partyId == null
                  ? const Center(
                      child: Text(
                        'Select a party to view statement',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ReportAsyncBody(
                      value: statementAsync,
                      onRetry: () => ref
                          .read(partyStatementReportProvider.notifier)
                          .refresh(),
                      data: (data) {
                        if (data == null) {
                          return const Center(
                            child: Text(
                              'No statement data available.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ReportCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      child: ReportViewToggle(
                                        value: _viewMode,
                                        onChanged: (v) =>
                                            setState(() => _viewMode = v),
                                      ),
                                    ),
                                    Expanded(
                                      child: ReportTableArea(
                                        child: _PartyStatementTable(
                                          entries: data.entries,
                                          viewMode: _viewMode,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _PartyStatementSummaryCard(
                              summary: data.summary,
                              expanded: _summaryExpanded,
                              onToggle: () => setState(
                                () => _summaryExpanded = !_summaryExpanded,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportExcel(
    BuildContext context,
    PartyStatementReportData? data,
  ) {
    if (data == null) return;
    final headers = _exportHeaders(_viewMode);
    reportExportTable(
      context: context,
      title: 'Party Statement',
      filename: 'party-statement',
      headers: headers,
      rows: [
        for (final row in data.entries) _exportRow(row, _viewMode),
      ],
    );
  }

  void _printReport(
    BuildContext context,
    PartyStatementReportData? data,
  ) {
    if (data == null) return;
    final headers = _exportHeaders(_viewMode);
    ReportExportService.showPrintPreview(
      context: context,
      title: 'Party Statement',
      content: ReportExportService.toCsv(
        headers: headers,
        rows: [
          for (final row in data.entries) _exportRow(row, _viewMode),
        ],
      ),
    );
  }

  static List<String> _exportHeaders(String viewMode) {
    if (viewMode == 'Accounting') {
      return const ['Date', 'Type', 'Ref No', 'Debit', 'Credit', 'Balance'];
    }
    return const ['Date', 'Type', 'Ref No', 'Total', 'Balance'];
  }

  static List<String> _exportRow(
    ReportPartyStatementEntry row,
    String viewMode,
  ) {
    if (viewMode == 'Accounting') {
      return [
        formatReportDate(row.date),
        row.type,
        row.refNo,
        row.debit > 0 ? formatReportCurrency(row.debit) : '',
        row.credit > 0 ? formatReportCurrency(row.credit) : '',
        formatReportCurrency(row.balance),
      ];
    }
    return [
      formatReportDate(row.date),
      row.type,
      row.refNo,
      formatReportCurrency(row.total),
      formatReportCurrency(row.balance),
    ];
  }
}

class _PartyStatementTable extends StatelessWidget {
  const _PartyStatementTable({
    required this.entries,
    required this.viewMode,
  });

  final List<ReportPartyStatementEntry> entries;
  final String viewMode;

  bool get _isAccounting => viewMode == 'Accounting';

  @override
  Widget build(BuildContext context) {
    return ReportSyncScrollTable(
      minWidth: _isAccounting ? 640 : 520,
      emptyState: const Center(
        child: Text(
          'No statement entries for this party.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      headerChildren: _isAccounting
          ? const [
              ReportAlignedHeaderCell(label: 'DATE', width: 100),
              ReportAlignedHeaderCell(label: 'TYPE', width: 100),
              ReportAlignedHeaderCell(label: 'REF NO.', width: 110),
              ReportAlignedHeaderCell(
                label: 'DEBIT',
                width: 100,
                alignment: Alignment.centerRight,
              ),
              ReportAlignedHeaderCell(
                label: 'CREDIT',
                width: 100,
                alignment: Alignment.centerRight,
              ),
              Expanded(
                child: ReportAlignedHeaderCell(
                  label: 'BALANCE',
                  alignment: Alignment.centerRight,
                ),
              ),
            ]
          : const [
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
        for (var i = 0; i < entries.length; i++)
          ReportAlignedRowStrip(
            index: i,
            child: ReportAlignedDataRow(
              cells: _isAccounting
                  ? [
                      ReportAlignedCell.fixed(
                        100,
                        child: Text(formatReportDate(entries[i].date)),
                      ),
                      ReportAlignedCell.fixed(
                        100,
                        child: Text(entries[i].type),
                      ),
                      ReportAlignedCell.fixed(
                        110,
                        child: Text(entries[i].refNo),
                      ),
                      ReportAlignedCell.fixed(
                        100,
                        alignment: Alignment.centerRight,
                        child: Text(
                          entries[i].debit > 0
                              ? formatReportCurrency(entries[i].debit)
                              : '',
                        ),
                      ),
                      ReportAlignedCell.fixed(
                        100,
                        alignment: Alignment.centerRight,
                        child: Text(
                          entries[i].credit > 0
                              ? formatReportCurrency(entries[i].credit)
                              : '',
                        ),
                      ),
                      ReportAlignedCell.flex(
                        alignment: Alignment.centerRight,
                        child: Text(formatReportCurrency(entries[i].balance)),
                      ),
                    ]
                  : [
                      ReportAlignedCell.fixed(
                        100,
                        child: Text(formatReportDate(entries[i].date)),
                      ),
                      ReportAlignedCell.fixed(
                        100,
                        child: Text(entries[i].type),
                      ),
                      ReportAlignedCell.fixed(
                        110,
                        child: Text(entries[i].refNo),
                      ),
                      ReportAlignedCell.flex(
                        child: Text(formatReportCurrency(entries[i].total)),
                      ),
                      ReportAlignedCell.fixed(
                        100,
                        alignment: Alignment.centerRight,
                        child: Text(formatReportCurrency(entries[i].balance)),
                      ),
                    ],
            ),
          ),
      ],
    );
  }
}

class _PartyStatementSummaryCard extends StatelessWidget {
  const _PartyStatementSummaryCard({
    required this.summary,
    required this.expanded,
    required this.onToggle,
  });

  final ReportPartyStatementSummary summary;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
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
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
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
                          amount: formatReportCurrency(summary.totalPurchase),
                        ),
                        _SummaryMetric(
                          label: 'Total Money-in',
                          amount: formatReportCurrency(summary.totalMoneyIn),
                        ),
                        _SummaryMetric(
                          label: 'Total Money-out',
                          amount: formatReportCurrency(summary.totalMoneyOut),
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
