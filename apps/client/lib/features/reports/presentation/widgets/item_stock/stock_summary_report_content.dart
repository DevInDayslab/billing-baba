import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StockSummaryReportContent extends ConsumerStatefulWidget {
  const StockSummaryReportContent({super.key});

  @override
  ConsumerState<StockSummaryReportContent> createState() =>
      _StockSummaryReportContentState();
}

class _StockSummaryReportContentState
    extends ConsumerState<StockSummaryReportContent> {
  final _datePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  String _category = 'All Categories';
  bool _useDateFilter = true;
  bool _showItemsInStock = false;
  late DateTime _selectedDate;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(reportStockSummaryProvider);
    final totalStockValue =
        rows.fold<double>(0, (sum, row) => sum + row.stockValue);

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
            child: ReportCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'FILTERS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SaleFilterDropdown(
                    label: _category,
                    options: const [
                      'All Categories',
                      'Category A',
                      'Category B',
                    ],
                    selected: _category,
                    onSelected: (value) => setState(() => _category = value),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _useDateFilter,
                        onChanged: (value) => setState(
                          () => _useDateFilter = value ?? false,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text('Date filter', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: AppSpacing.sm),
                      SaleSingleDatePickerAnchor(
                        key: _datePickerKey,
                        selectedDate: _selectedDate,
                        onDateSelected: (date) =>
                            setState(() => _selectedDate = date),
                        child: InkWell(
                          onTap: _useDateFilter
                              ? () => _datePickerKey.currentState?.toggle()
                              : null,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Opacity(
                            opacity: _useDateFilter ? 1 : 0.5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                border: Border.all(color: reportCardBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _dateFormat.format(_selectedDate),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _showItemsInStock,
                        onChanged: (value) => setState(
                          () => _showItemsInStock = value ?? false,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Show items in stock',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
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
                        'STOCK SUMMARY',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    Expanded(
                      child: rows.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  headerChildren: const [
                                    Expanded(
                                      child: ReportAlignedHeaderCell(
                                        label: 'ITEM NAME',
                                      ),
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'SALE PRICE',
                                      width: 110,
                                      alignment: Alignment.center,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'PURCHASE PRICE',
                                      width: 130,
                                      alignment: Alignment.center,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'STOCK QTY',
                                      width: 100,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'STOCK VALUE',
                                      width: 110,
                                      alignment: Alignment.centerRight,
                                    ),
                                  ],
                                  rows: const [],
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'No stock items to display.',
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
                                      label: 'ITEM NAME',
                                    ),
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'SALE PRICE',
                                    width: 110,
                                    alignment: Alignment.center,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'PURCHASE PRICE',
                                    width: 130,
                                    alignment: Alignment.center,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'STOCK QTY',
                                    width: 100,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'STOCK VALUE',
                                    width: 110,
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
                                            110,
                                            alignment: Alignment.center,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].salePrice,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            130,
                                            alignment: Alignment.center,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].purchasePrice,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            100,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i].stockQty
                                                  .toStringAsFixed(0),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            110,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].stockValue,
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
                                text: 'Total Stock Value: ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: formatReportCurrency(totalStockValue),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: reportTeal,
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
