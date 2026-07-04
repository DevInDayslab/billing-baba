import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OtherIncomeReportContent extends ConsumerStatefulWidget {
  const OtherIncomeReportContent({super.key});

  @override
  ConsumerState<OtherIncomeReportContent> createState() =>
      _OtherIncomeReportContentState();
}

class _OtherIncomeReportContentState
    extends ConsumerState<OtherIncomeReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7, 1),
    end: DateTime(2026, 7, 31),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(reportOtherIncomesProvider);
    final totalAmount =
        rows.fold<double>(0, (sum, row) => sum + row.amount);

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
              title: 'Other Income',
              actions: const [
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
              child: _DateRangeFilter(
                datePickerKey: _datePickerKey,
                dateRange: _dateRange,
                dateFormat: _dateFormat,
                onRangeSelected: (range) => setState(() => _dateRange = range),
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
                      child: Row(
                        children: [
                          Text(
                            'TRANSACTIONS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: ReportSearchField(
                              hintText: 'Search other income...',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: rows.isEmpty
                          ? _emptyTable(
                              message:
                                  'No other income records found for the selected period.',
                            )
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                headerChildren: _incomeHeaders,
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.fixed(
                                            100,
                                            child: Text(
                                              formatReportDate(rows[i].date),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            child: Text(rows[i].incomeNo),
                                          ),
                                          ReportAlignedCell.flex(
                                            child: Text(rows[i].partyName),
                                          ),
                                          ReportAlignedCell.fixed(
                                            130,
                                            child: Text(rows[i].category),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            child: Text(rows[i].paymentType),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].amount,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            child: Text(
                                              formatReportDate(rows[i].dueDate),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            90,
                                            child: Text(rows[i].status),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                    _TotalFooter(
                      label: 'Total Amount: ',
                      amount: formatReportCurrency(totalAmount),
                      amountColor: reportTeal,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _incomeHeaders = [
    ReportAlignedHeaderCell(label: 'DATE', width: 100),
    ReportAlignedHeaderCell(label: 'INC NO', width: 100),
    Expanded(child: ReportAlignedHeaderCell(label: 'PARTY')),
    ReportAlignedHeaderCell(label: 'CATEGORY', width: 130),
    ReportAlignedHeaderCell(label: 'PAYMENT TYPE', width: 120),
    ReportAlignedHeaderCell(
      label: 'AMOUNT',
      width: 100,
      alignment: Alignment.centerRight,
    ),
    ReportAlignedHeaderCell(label: 'DUE DATE', width: 100),
    ReportAlignedHeaderCell(label: 'STATUS', width: 90),
  ];

  Widget _emptyTable({required String message}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportSyncScrollTable(
          headerChildren: _incomeHeaders,
          rows: const [],
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

class OtherIncomeCategoryReportContent extends ConsumerStatefulWidget {
  const OtherIncomeCategoryReportContent({super.key});

  @override
  ConsumerState<OtherIncomeCategoryReportContent> createState() =>
      _OtherIncomeCategoryReportContentState();
}

class _OtherIncomeCategoryReportContentState
    extends ConsumerState<OtherIncomeCategoryReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7, 1),
    end: DateTime(2026, 7, 31),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(reportOtherIncomeByCategoryProvider);
    final totalIncome =
        rows.fold<double>(0, (sum, row) => sum + row.amount);

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
              title: 'Other Income Category Report',
              actions: const [
                ReportTextActionButton(
                  label: 'Excel',
                  icon: Icons.table_chart_outlined,
                ),
                ReportTextActionButton(
                  label: 'Print',
                  icon: Icons.print_outlined,
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
              child: _DateRangeFilter(
                datePickerKey: _datePickerKey,
                dateRange: _dateRange,
                dateFormat: _dateFormat,
                onRangeSelected: (range) => setState(() => _dateRange = range),
                fromLabel: 'From',
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
                        'OTHER INCOME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Expanded(
                      child: rows.isEmpty
                          ? _categoryEmptyTable()
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                headerChildren: _categoryHeaders,
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.flex(
                                            child: Text(rows[i].category),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            alignment: Alignment.centerRight,
                                            child: Text('${rows[i].count}'),
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
                    _TotalFooter(
                      label: 'Total Income: ',
                      amount: formatReportCurrency(totalIncome),
                      amountColor: reportTeal,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _categoryHeaders = [
    Expanded(
      child: ReportAlignedHeaderCell(label: 'INCOME CATEGORY'),
    ),
    ReportAlignedHeaderCell(
      label: 'COUNT',
      width: 120,
      alignment: Alignment.centerRight,
    ),
    ReportAlignedHeaderCell(
      label: 'AMOUNT',
      width: 140,
      alignment: Alignment.centerRight,
    ),
  ];

  Widget _categoryEmptyTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportSyncScrollTable(
          headerChildren: _categoryHeaders,
          rows: const [],
        ),
        const Expanded(
          child: Center(
            child: Text(
              'No other income records found for the selected period.',
              style: TextStyle(
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

class OtherIncomeItemReportContent extends ConsumerStatefulWidget {
  const OtherIncomeItemReportContent({super.key});

  @override
  ConsumerState<OtherIncomeItemReportContent> createState() =>
      _OtherIncomeItemReportContentState();
}

class _OtherIncomeItemReportContentState
    extends ConsumerState<OtherIncomeItemReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7, 1),
    end: DateTime(2026, 7, 31),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(reportOtherIncomeByItemProvider);
    final totalIncome =
        rows.fold<double>(0, (sum, row) => sum + row.amount);

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
              title: 'Other Income Item Report',
              actions: const [
                ReportTextActionButton(
                  label: 'Excel',
                  icon: Icons.table_chart_outlined,
                ),
                ReportTextActionButton(
                  label: 'Print',
                  icon: Icons.print_outlined,
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
              child: _DateRangeFilter(
                datePickerKey: _datePickerKey,
                dateRange: _dateRange,
                dateFormat: _dateFormat,
                onRangeSelected: (range) => setState(() => _dateRange = range),
                fromLabel: 'From',
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
                        'OTHER INCOME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Expanded(
                      child: rows.isEmpty
                          ? _itemEmptyTable()
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                headerChildren: _itemHeaders,
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
                    _TotalFooter(
                      label: 'Total Income: ',
                      amount: formatReportCurrency(totalIncome),
                      amountColor: reportTeal,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _itemHeaders = [
    Expanded(
      child: ReportAlignedHeaderCell(label: 'INCOME ITEM'),
    ),
    ReportAlignedHeaderCell(label: 'CATEGORY', width: 180),
    ReportAlignedHeaderCell(
      label: 'AMOUNT',
      width: 140,
      alignment: Alignment.centerRight,
    ),
  ];

  Widget _itemEmptyTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportSyncScrollTable(
          headerChildren: _itemHeaders,
          rows: const [],
        ),
        const Expanded(
          child: Center(
            child: Text(
              'No other income records found for the selected period.',
              style: TextStyle(
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

class _DateRangeFilter extends StatelessWidget {
  const _DateRangeFilter({
    required this.datePickerKey,
    required this.dateRange,
    required this.dateFormat,
    required this.onRangeSelected,
    this.fromLabel = 'Between',
  });

  final GlobalKey<SaleDateRangePickerAnchorState> datePickerKey;
  final DateTimeRange dateRange;
  final DateFormat dateFormat;
  final ValueChanged<DateTimeRange> onRangeSelected;
  final String fromLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fromLabel,
          style: const TextStyle(
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
          dateFormat.format(dateRange.start),
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
          key: datePickerKey,
          initialRange: dateRange,
          onRangeSelected: onRangeSelected,
          child: InkWell(
            onTap: () => datePickerKey.currentState?.toggle(),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                    dateFormat.format(dateRange.end),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalFooter extends StatelessWidget {
  const _TotalFooter({
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String label;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              TextSpan(
                text: label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              TextSpan(
                text: amount,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
