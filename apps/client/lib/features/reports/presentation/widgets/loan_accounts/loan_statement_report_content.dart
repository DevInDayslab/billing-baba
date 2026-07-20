import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoanStatementReportContent extends ConsumerWidget {
  const LoanStatementReportContent({super.key});

  static const _selectLoanLabel = 'Select loan account';
  static const List<String> _loanOptions = [
    _selectLoanLabel,
    'Business Term Loan',
    'Working Capital Loan',
    'Vehicle Loan',
  ];

  static const List<Widget> _headers = [
    ReportAlignedHeaderCell(label: 'DATE', width: 110),
    ReportAlignedHeaderCell(label: 'REF NO.', width: 100),
    Expanded(child: ReportAlignedHeaderCell(label: 'PARTICULARS')),
    ReportAlignedHeaderCell(
      label: 'DEBIT',
      width: 130,
      alignment: Alignment.centerRight,
    ),
    ReportAlignedHeaderCell(
      label: 'CREDIT',
      width: 130,
      alignment: Alignment.centerRight,
    ),
    ReportAlignedHeaderCell(
      label: 'OUTSTANDING',
      width: 140,
      alignment: Alignment.centerRight,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final selectedLoan = filters.loanAccount ?? _selectLoanLabel;
    final loanSelected = selectedLoan != _selectLoanLabel;
    final reportAsync = ref.watch(loanStatementReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(loanStatementReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report?.rows ?? const <ReportLoanStatementRow>[];
        final closingBalance = rows.isEmpty ? 0.0 : rows.last.balance;

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Loan Statement',
            filename: 'loan-statement',
            headers: const [
              'Date',
              'Ref No',
              'Particulars',
              'Debit',
              'Credit',
              'Outstanding',
            ],
            rows: [
              for (final row in rows)
                [
                  formatReportDate(row.date),
                  row.refNo,
                  row.description,
                  if (row.debit > 0) formatReportCurrency(row.debit) else '-',
                  if (row.credit > 0) formatReportCurrency(row.credit) else '-',
                  formatReportCurrency(row.balance),
                ],
            ],
          );
        }

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
                child: ReportTitleActionsRow(
                  title: 'Loan Statement',
                  actions: [
                    ReportTextActionButton(
                      label: 'Excel',
                      icon: Icons.table_chart_outlined,
                      onTap: loanSelected ? exportCsv : null,
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: loanSelected
                          ? () => ReportExportService.showPrintPreview(
                              context: context,
                              title: 'Loan Statement',
                              content: ReportExportService.toCsv(
                                headers: const [
                                  'Date',
                                  'Ref No',
                                  'Particulars',
                                  'Debit',
                                  'Credit',
                                  'Outstanding',
                                ],
                                rows: [
                                  for (final row in rows)
                                    [
                                      formatReportDate(row.date),
                                      row.refNo,
                                      row.description,
                                      if (row.debit > 0)
                                        formatReportCurrency(row.debit)
                                      else
                                        '-',
                                      if (row.credit > 0)
                                        formatReportCurrency(row.credit)
                                      else
                                        '-',
                                      formatReportCurrency(row.balance),
                                    ],
                                ],
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ReportCard(
                  backgroundColor: const Color(0xFFF5F7FA),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Loan account',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 220,
                            child: SaleFilterDropdown(
                              label: selectedLoan,
                              options: _loanOptions,
                              selected: selectedLoan,
                              onSelected: (value) => ref
                                  .read(reportFiltersProvider.notifier)
                                  .setLoanAccount(
                                    value == _selectLoanLabel ? null : value,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const ReportFromToDateFilter(betweenLabel: ''),
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
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'TRANSACTIONS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ReportTableArea(
                            child: !loanSelected
                              ? _emptyState(
                                  message:
                                      'Select a loan account to view the statement.',
                                )
                              : rows.isEmpty
                              ? _emptyState(
                                  message:
                                      'No transactions for the selected period.',
                                )
                              : ReportSyncScrollTable(
                                    headerChildren: _headers,
                                    rows: [
                                      for (var i = 0; i < rows.length; i++)
                                        ReportAlignedRowStrip(
                                          index: i,
                                          child: ReportAlignedDataRow(
                                            cells: [
                                              ReportAlignedCell.fixed(
                                                110,
                                                child: Text(
                                                  formatReportDate(
                                                    rows[i].date,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                100,
                                                child: Text(rows[i].refNo),
                                              ),
                                              ReportAlignedCell.flex(
                                                child: Text(
                                                  rows[i].description,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        rows[i].isOpening
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                130,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  rows[i].debit > 0
                                                      ? formatReportCurrency(
                                                          rows[i].debit,
                                                        )
                                                      : '-',
                                                  style: TextStyle(
                                                    color: rows[i].debit > 0
                                                        ? const Color(
                                                            0xFFE53935,
                                                          )
                                                        : AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                130,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  rows[i].credit > 0
                                                      ? formatReportCurrency(
                                                          rows[i].credit,
                                                        )
                                                      : '-',
                                                  style: TextStyle(
                                                    color: rows[i].credit > 0
                                                        ? reportTeal
                                                        : AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                140,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].balance,
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
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
                            vertical: AppSpacing.md,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(fontSize: 14),
                                children: [
                                  const TextSpan(
                                    text: 'Outstanding Balance: ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatReportCurrency(closingBalance),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      },
    );
  }

  Widget _emptyState({required String message}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ReportSyncScrollTable(
          headerChildren: _headers,
          rows: [],
        ),
        Expanded(
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
