import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BankStatementReportContent extends ConsumerStatefulWidget {
  const BankStatementReportContent({super.key});

  @override
  ConsumerState<BankStatementReportContent> createState() =>
      _BankStatementReportContentState();
}

class _BankStatementReportContentState
    extends ConsumerState<BankStatementReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _selectedBank = 'Select bank account';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7, 1),
    end: DateTime(2026, 7, 31),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final bankSelected = _selectedBank != 'Select bank account';
    final rows = bankSelected
        ? ref.watch(reportBankStatementProvider(_selectedBank))
        : const <ReportBankStatementRow>[];
    final closingBalance =
        rows.isEmpty ? 0.0 : rows.last.balance;

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
                const ReportTextActionButton(
                  label: 'Excel',
                  icon: Icons.table_chart_outlined,
                ),
                const ReportTextActionButton(
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
                          label: _selectedBank,
                          options: const [
                            'Select bank account',
                            'HDFC Bank',
                            'ICICI Bank',
                            'SBI',
                          ],
                          selected: _selectedBank,
                          onSelected: (value) =>
                              setState(() => _selectedBank = value),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      child: !bankSelected
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  headerChildren: const [
                                    ReportAlignedHeaderCell(
                                      label: 'DATE',
                                      width: 110,
                                    ),
                                    Expanded(
                                      child: ReportAlignedHeaderCell(
                                        label: 'DESCRIPTION',
                                      ),
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'WITHDRAWAL AMOUNT',
                                      width: 150,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'DEPOSIT AMOUNT',
                                      width: 130,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'BALANCE AMOUNT',
                                      width: 130,
                                      alignment: Alignment.centerRight,
                                    ),
                                  ],
                                  rows: const [],
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'Select a bank account to view the statement.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : rows.isEmpty
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ReportSyncScrollTable(
                                      headerChildren: const [
                                        ReportAlignedHeaderCell(
                                          label: 'DATE',
                                          width: 110,
                                        ),
                                        Expanded(
                                          child: ReportAlignedHeaderCell(
                                            label: 'DESCRIPTION',
                                          ),
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'WITHDRAWAL AMOUNT',
                                          width: 150,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'DEPOSIT AMOUNT',
                                          width: 130,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'BALANCE AMOUNT',
                                          width: 130,
                                          alignment: Alignment.centerRight,
                                        ),
                                      ],
                                      rows: const [],
                                    ),
                                    const Expanded(
                                      child: Center(
                                        child: Text(
                                          'No transactions for the selected period.',
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
                                      ReportAlignedHeaderCell(
                                        label: 'DATE',
                                        width: 110,
                                      ),
                                      Expanded(
                                        child: ReportAlignedHeaderCell(
                                          label: 'DESCRIPTION',
                                        ),
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'WITHDRAWAL AMOUNT',
                                        width: 150,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'DEPOSIT AMOUNT',
                                        width: 130,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'BALANCE AMOUNT',
                                        width: 130,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ],
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
                                              ReportAlignedCell.flex(
                                                child: Text(
                                                  rows[i].description,
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                150,
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  rows[i].moneyOut > 0
                                                      ? formatReportCurrency(
                                                          rows[i].moneyOut,
                                                        )
                                                      : '-',
                                                  style: TextStyle(
                                                    color: rows[i].moneyOut > 0
                                                        ? const Color(
                                                            0xFFE53935,
                                                          )
                                                        : AppColors
                                                            .textPrimary,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                130,
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  rows[i].moneyIn > 0
                                                      ? formatReportCurrency(
                                                          rows[i].moneyIn,
                                                        )
                                                      : '-',
                                                  style: TextStyle(
                                                    color: rows[i].moneyIn > 0
                                                        ? reportTeal
                                                        : AppColors
                                                            .textPrimary,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                130,
                                                alignment: Alignment.centerRight,
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
                        border: Border(top: BorderSide(color: reportCardBorder)),
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
  }
}
