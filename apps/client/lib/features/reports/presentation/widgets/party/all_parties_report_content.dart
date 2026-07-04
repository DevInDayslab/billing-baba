import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllPartiesReportContent extends ConsumerStatefulWidget {
  const AllPartiesReportContent({super.key});

  @override
  ConsumerState<AllPartiesReportContent> createState() =>
      _AllPartiesReportContentState();
}

class _AllPartiesReportContentState
    extends ConsumerState<AllPartiesReportContent> {
  bool _dateFilterEnabled = false;

  @override
  Widget build(BuildContext context) {
    final parties = ref.watch(reportAllPartiesProvider);
    final summary = ref.watch(reportPartyBalanceSummaryProvider);

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
                    ReportSyncScrollTable(
                      minWidth: 900,
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
                      headerChildren: [
                        SizedBox(
                          width: 48,
                          child: Checkbox(
                            value: false,
                            onChanged: null,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const ReportAlignedHeaderCell(label: '#', width: 40),
                        const Expanded(
                          child: ReportAlignedHeaderCell(label: 'PARTY NAME'),
                        ),
                        const ReportAlignedHeaderCell(label: 'EMAIL', width: 140),
                        const ReportAlignedHeaderCell(
                          label: 'PHONE NO.',
                          width: 110,
                        ),
                        const ReportAlignedHeaderCell(
                          label: 'RECEIVABLE BALANCE',
                          width: 140,
                          alignment: Alignment.centerRight,
                        ),
                        const ReportAlignedHeaderCell(
                          label: 'PAYABLE BALANCE',
                          width: 130,
                          alignment: Alignment.centerRight,
                        ),
                        const ReportAlignedHeaderCell(
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
  }
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({required this.index, required this.party});

  final int index;
  final PartyModel party;

  @override
  Widget build(BuildContext context) {
    final email = party.email.isEmpty ? '—' : party.email;
    final receivable =
        party.balance > 0 ? formatReportCurrency(party.balance) : '—';
    final payable =
        party.balance < 0 ? formatReportCurrency(party.balance.abs()) : '—';
    final creditLimit = party.creditLimit.isEmpty
        ? '—'
        : formatReportCurrency(double.tryParse(party.creditLimit) ?? 0);

    return ReportAlignedDataRow(
      cells: [
        ReportAlignedCell.fixed(
          48,
          child: Checkbox(
            value: false,
            onChanged: null,
            visualDensity: VisualDensity.compact,
          ),
        ),
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
