import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/utils/report_table_builders.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/shared/widgets/loan_account_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoanStatementReportContent extends ConsumerWidget {
  const LoanStatementReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final selectedId = filters.loanAccount;
    final loanSelected =
        selectedId != null && selectedId.isNotEmpty;
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
                            width: 240,
                            child: LoanAccountPicker(
                              hint: 'Select loan account',
                              selectedAccountId: selectedId,
                              onChanged: (id) => ref
                                  .read(reportFiltersProvider.notifier)
                                  .setLoanAccount(id),
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
                            child: ReportFilterableSyncTable<ReportLoanStatementRow>(
                              reportScope: loanStatementReportScope,
                              columns: loanStatementColumns(),
                              rows: loanSelected ? rows : const [],
                              emptyState: Center(
                                child: Text(
                                  !loanSelected
                                      ? 'Select a loan account to view the statement.'
                                      : 'No transactions for the selected period.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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
}
