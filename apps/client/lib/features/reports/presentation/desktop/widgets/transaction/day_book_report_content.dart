import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/day_book_transactions_table.dart';
import 'package:billing_baba/features/reports/utils/day_book_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DayBookReportContent extends ConsumerStatefulWidget {
  const DayBookReportContent({super.key});

  @override
  ConsumerState<DayBookReportContent> createState() =>
      _DayBookReportContentState();
}

class _DayBookReportContentState extends ConsumerState<DayBookReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final filters = ref.read(reportFiltersProvider);
      if (filters.selectedDate == null) {
        final now = DateTime.now();
        ref.read(reportFiltersProvider.notifier).setSelectedDate(
              DateTime(now.year, now.month, now.day),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(dayBookReportProvider);
    final selectedDate =
        ref.watch(reportFiltersProvider.select((s) => s.selectedDate)) ??
        DateTime.now();
    final displayDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(dayBookReportProvider.notifier).refresh(),
      data: (report) {
        final exportRows = [
          for (final row in report.rows) dayBookExportRow(row),
        ];

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
                child: Row(
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ReportDateRangePickerAnchor(
                      anchorKey: _datePickerKey,
                      singleDate: true,
                      initialRange: DateTimeRange(
                        start: displayDate,
                        end: displayDate,
                      ),
                      onRangeSelected: (range) {
                        ref
                            .read(reportFiltersProvider.notifier)
                            .setSelectedDate(range.start);
                      },
                      child: SaleFilterChip(
                        label: _dateFormat.format(displayDate),
                        onTap: () => _datePickerKey.currentState?.toggle(),
                      ),
                    ),
                    const Spacer(),
                    ReportTextActionButton(
                      label: 'Excel Report',
                      icon: Icons.table_chart_outlined,
                      onTap: () => reportExportTable(
                        context: context,
                        title: 'Day Book',
                        filename: 'day-book',
                        headers: dayBookExportHeaders,
                        rows: exportRows,
                      ),
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: () => reportPrintTable(
                        context: context,
                        title: 'Day Book',
                        headers: dayBookExportHeaders,
                        rows: exportRows,
                      ),
                    ),
                  ],
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
                  child: const DayBookTransactionsTable(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
