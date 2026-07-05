import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ExpenseItemReportContent extends ConsumerStatefulWidget {
  const ExpenseItemReportContent({super.key});

  @override
  ConsumerState<ExpenseItemReportContent> createState() =>
      _ExpenseItemReportContentState();
}

class _ExpenseItemReportContentState extends ConsumerState<ExpenseItemReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7),
    end: DateTime(2026, 7, 31),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(expenseByItemReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(expenseByItemReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalExpense =
            rows.fold<double>(0, (sum, row) => sum + row.amount);

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Expense Item Report',
            filename: 'expense-item-report',
            headers: const ['Expense Item', 'Category Type', 'Amount'],
            rows: [
              for (final row in rows)
                [
                  row.itemName,
                  row.category,
                  formatReportCurrency(row.amount),
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
              title: 'Expense Item Report',
              actions: [
                ReportTextActionButton(
                  label: 'Excel',
                  icon: Icons.table_chart_outlined,
                  onTap: exportCsv,
                ),
                ReportTextActionButton(
                  label: 'Print',
                  icon: Icons.print_outlined,
                  onTap: () => ReportExportService.showPrintPreview(
                    context: context,
                    title: 'Expense Item Report',
                    content: ReportExportService.toCsv(
                      headers: const [
                        'Expense Item',
                        'Category Type',
                        'Amount',
                      ],
                      rows: [
                        for (final row in rows)
                          [
                            row.itemName,
                            row.category,
                            formatReportCurrency(row.amount),
                          ],
                      ],
                    ),
                  ),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  const Text(
                    'From',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _dateFormat.format(_dateRange.start),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'to',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SaleDateRangePickerAnchor(
                    key: _datePickerKey,
                    initialRange: _dateRange,
                    onRangeSelected: (range) =>
                        setState(() => _dateRange = range),
                    child: InkWell(
                      onTap: () => _datePickerKey.currentState?.toggle(),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _dateFormat.format(_dateRange.end),
                              style: const TextStyle(fontSize: 13),
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
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'EXPENSE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () => context.push(AppRoutes.purchaseExpenses),
                            style: FilledButton.styleFrom(
                              backgroundColor: reportActiveBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(
                              'Add Expense',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: rows.isEmpty
                          ? const Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  headerChildren: [
                                    Expanded(
                                      child: ReportAlignedHeaderCell(
                                        label: 'EXPENSE ITEM',
                                      ),
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'CATEGORY TYPE',
                                      width: 180,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'AMOUNT',
                                      width: 140,
                                      alignment: Alignment.centerRight,
                                    ),
                                  ],
                                  rows: [],
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'No expense records found for the selected period.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                headerChildren: const [
                                  Expanded(
                                    child: ReportAlignedHeaderCell(
                                      label: 'EXPENSE ITEM',
                                    ),
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'CATEGORY TYPE',
                                    width: 180,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'AMOUNT',
                                    width: 140,
                                    alignment: Alignment.centerRight,
                                  ),
                                ],
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.flex(
                                            child: Text(rows[i].itemName),
                                          ),
                                          ReportAlignedCell.fixed(
                                            180,
                                            child: Text(rows[i].category),
                                          ),
                                          ReportAlignedCell.fixed(
                                            140,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].amount,
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
                        border: Border(top: BorderSide(color: reportCardBorder)),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              const TextSpan(
                                text: 'Total Expense: ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: formatReportCurrency(totalExpense),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: reportAddRed,
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
