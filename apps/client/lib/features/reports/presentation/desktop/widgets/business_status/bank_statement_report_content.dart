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
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankStatementReportContent extends ConsumerWidget {
  const BankStatementReportContent({super.key});

  static const _selectBankLabel = 'Select bank account';
  static const List<String> _bankOptions = [
    _selectBankLabel,
    'HDFC Bank',
    'ICICI Bank',
    'SBI',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final selectedBank = filters.bankName ?? _selectBankLabel;
    final bankSelected = selectedBank != _selectBankLabel;
    final reportAsync = ref.watch(bankStatementReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(bankStatementReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report?.rows ?? const <ReportBankStatementRow>[];
        final closingBalance = rows.isEmpty ? 0.0 : rows.last.balance;

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Bank Statement',
            filename: 'bank-statement',
            headers: const [
              'Date',
              'Description',
              'Withdrawal Amount',
              'Deposit Amount',
              'Balance Amount',
            ],
            rows: [
              for (final row in rows)
                [
                  formatReportDate(row.date),
                  row.description,
                  if (row.moneyOut > 0)
                    formatReportCurrency(row.moneyOut)
                  else
                    '-',
                  if (row.moneyIn > 0)
                    formatReportCurrency(row.moneyIn)
                  else
                    '-',
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
                  title: 'Bank Statement',
                  actions: [
                    ReportTextActionButton(
                      label: 'Excel',
                      icon: Icons.table_chart_outlined,
                      onTap: bankSelected ? exportCsv : null,
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: bankSelected
                          ? () => ReportExportService.showPrintPreview(
                              context: context,
                              title: 'Bank Statement',
                              content: ReportExportService.toCsv(
                                headers: const [
                                  'Date',
                                  'Description',
                                  'Withdrawal Amount',
                                  'Deposit Amount',
                                  'Balance Amount',
                                ],
                                rows: [
                                  for (final row in rows)
                                    [
                                      formatReportDate(row.date),
                                      row.description,
                                      if (row.moneyOut > 0)
                                        formatReportCurrency(row.moneyOut)
                                      else
                                        '-',
                                      if (row.moneyIn > 0)
                                        formatReportCurrency(row.moneyIn)
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
                            'Bank name',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 200,
                            child: SaleFilterDropdown(
                              label: selectedBank,
                              options: _bankOptions,
                              selected: selectedBank,
                              onSelected: (value) => ref
                                  .read(reportFiltersProvider.notifier)
                                  .setBankName(
                                    value == _selectBankLabel ? null : value,
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
                            child: ReportFilterableSyncTable<ReportBankStatementRow>(
                              reportScope: bankStatementReportScope,
                              columns: bankStatementColumns(),
                              rows: bankSelected ? rows : const [],
                              emptyState: Center(
                                child: Text(
                                  !bankSelected
                                      ? 'Select a bank account to view the statement.'
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
                                    text: 'Balance ',
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
