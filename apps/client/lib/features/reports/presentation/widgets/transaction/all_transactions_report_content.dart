import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllTransactionsReportContent extends ConsumerWidget {
  const AllTransactionsReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(allTransactionsReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(allTransactionsReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ReportCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportPeriodFilterBar(),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
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
                            label: 'All Transaction',
                            options: const [
                              'All Transaction',
                              'Sale',
                              'Purchase',
                              'Payment In',
                              'Payment Out',
                            ],
                            selected: 'All Transaction',
                            onSelected: (_) {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(child: ReportSearchField()),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  ReportSyncScrollTable(
                    headerChildren: const [
                      ReportAlignedHeaderCell(label: '#', width: 40),
                      ReportAlignedHeaderCell(label: 'DATE', width: 90),
                      ReportAlignedHeaderCell(label: 'REF NO.', width: 90),
                      Expanded(
                        child: ReportAlignedHeaderCell(label: 'PARTY NAME'),
                      ),
                      ReportAlignedHeaderCell(label: 'CATEGORY', width: 90),
                      ReportAlignedHeaderCell(label: 'TYPE', width: 80),
                      ReportAlignedHeaderCell(
                        label: 'TOTAL',
                        width: 80,
                        alignment: Alignment.centerRight,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'RECEIVED',
                        width: 90,
                        alignment: Alignment.centerRight,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'BALANCE',
                        width: 80,
                        alignment: Alignment.centerRight,
                      ),
                      ReportAlignedHeaderCell(label: 'DUE DATE', width: 90),
                      ReportAlignedHeaderCell(label: 'STATUS', width: 80),
                      ReportAlignedHeaderCell(
                        label: 'PRINT',
                        width: 60,
                        showFilter: false,
                      ),
                    ],
                    rows: [
                      for (var i = 0; i < rows.length; i++)
                        _AllTransactionsRow(row: rows[i], index: i),
                    ],
                    emptyState: const ReportEmptyTableState(
                      
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

class _AllTransactionsRow extends StatelessWidget {
  const _AllTransactionsRow({required this.row, required this.index});

  final ReportTransactionRow row;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedRowStrip(
      index: index,
      child: ReportAlignedDataRow(
        cells: [
          ReportAlignedCell.fixed(40, child: Text('${index + 1}')),
          ReportAlignedCell.fixed(
            90,
            child: Text(formatReportDate(row.date)),
          ),
          ReportAlignedCell.fixed(90, child: Text(row.refNo)),
          ReportAlignedCell.flex(child: Text(row.partyName)),
          ReportAlignedCell.fixed(90, child: Text(row.category)),
          ReportAlignedCell.fixed(80, child: Text(row.type)),
          ReportAlignedCell.fixed(
            80,
            alignment: Alignment.centerRight,
            child: Text(formatReportCurrencyCompact(row.total)),
          ),
          ReportAlignedCell.fixed(
            90,
            alignment: Alignment.centerRight,
            child: Text(
              row.received > 0
                  ? formatReportCurrencyCompact(row.received)
                  : '',
            ),
          ),
          ReportAlignedCell.fixed(
            80,
            alignment: Alignment.centerRight,
            child: Text(
              row.balance > 0
                  ? formatReportCurrencyCompact(row.balance)
                  : '',
            ),
          ),
          ReportAlignedCell.fixed(
            90,
            child: Text(
              row.dueDate != null ? formatReportDate(row.dueDate!) : '',
            ),
          ),
          ReportAlignedCell.fixed(80, child: Text(row.status)),
          ReportAlignedCell.fixed(
            60,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.print_outlined, size: 18),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ),
    );
  }
}
