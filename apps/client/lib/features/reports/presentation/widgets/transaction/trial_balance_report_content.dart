import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrialBalanceReportContent extends ConsumerWidget {
  const TrialBalanceReportContent({super.key});

  static const _exportHeaders = [
    'Account',
    'Opening',
    'Debit',
    'Credit',
    'Closing Dr',
    'Closing Cr',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(trialBalanceReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(trialBalanceReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;

        List<List<String>> exportRows() => [
          for (final row in rows)
            [
              row.accountName,
              formatReportCurrency(row.opening),
              formatReportCurrency(row.debit),
              formatReportCurrency(row.credit),
              if (row.closingDebit > 0)
                formatReportCurrency(row.closingDebit)
              else
                '—',
              if (row.closingCredit > 0)
                formatReportCurrency(row.closingCredit)
              else
                '—',
            ],
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Trial Balance Report',
            filename: 'trial-balance-report',
            headers: _exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Trial Balance Report',
            headers: _exportHeaders,
            rows: exportRows(),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text(
                      'Trial Balance Report',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const Spacer(),
                    ReportTextActionButton(
                      label: 'Excel Report',
                      icon: Icons.table_chart_outlined,
                      onTap: exportExcel,
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: printReport,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const ReportCard(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReportPeriodFilterBar(),
                      SizedBox(height: AppSpacing.sm),
                      ReportSearchField(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ReportCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: reportTableHeaderBg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ACCOUNT',
                                style: reportTableHeaderStyle,
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                'OPENING',
                                style: reportTableHeaderStyle,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                'DEBIT',
                                style: reportTableHeaderStyle,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                'CREDIT',
                                style: reportTableHeaderStyle,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                'CLOS. DR',
                                style: reportTableHeaderStyle,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                'CLOS. CR',
                                style: reportTableHeaderStyle,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: reportCardBorder),
                      if (report.rows.isEmpty)
                        const ReportEmptyTableState(
                          message: 'No data available for the selected period.',
                          minHeight: 180,
                        )
                      else
                        ...report.rows.map(
                          (row) => _TrialBalanceRowTile(row: row),
                        ),
                      Container(
                        color: const Color(0xFFE8F1FB),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total (Closing)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: reportActiveBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 90),
                            const SizedBox(width: 90),
                            const SizedBox(width: 90),
                            SizedBox(
                              width: 90,
                              child: Text(
                                formatReportCurrencyCompact(report.totalDebit),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: reportActiveBlue,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                formatReportCurrencyCompact(report.totalCredit),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: reportActiveBlue,
                                ),
                                textAlign: TextAlign.right,
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
        );
      },
    );
  }
}

class _TrialBalanceRowTile extends StatelessWidget {
  const _TrialBalanceRowTile({required this.row});

  final ReportTrialBalanceRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: reportCardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.accountName,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              formatReportCurrencyCompact(row.opening),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              formatReportCurrencyCompact(row.debit),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              formatReportCurrencyCompact(row.credit),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              row.closingDebit > 0
                  ? formatReportCurrencyCompact(row.closingDebit)
                  : '—',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              row.closingCredit > 0
                  ? formatReportCurrencyCompact(row.closingCredit)
                  : '—',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
