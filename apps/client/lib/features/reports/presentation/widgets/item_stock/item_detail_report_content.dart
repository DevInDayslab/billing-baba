import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ItemDetailReportContent extends ConsumerStatefulWidget {
  const ItemDetailReportContent({super.key});

  @override
  ConsumerState<ItemDetailReportContent> createState() =>
      _ItemDetailReportContentState();
}

class _ItemDetailReportContentState extends ConsumerState<ItemDetailReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  bool _hideInactiveDates = false;
  late DateTimeRange _dateRange;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = ref.watch(reportSelectedItemNameProvider);
    final rows = ref.watch(reportItemDetailProvider(selectedItem));
    final itemNames = InventoryCatalog.items.map((i) => i.name).toList();

    double runningClosing(int index) {
      var balance = 0.0;
      for (var i = 0; i <= index; i++) {
        final row = rows[i];
        balance += row.type == 'Sale' ? -row.quantity : row.quantity;
      }
      return balance;
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
                  Row(
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
                      const SizedBox(width: AppSpacing.md),
                      const Text(
                        'To',
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
                  const ReportIconActionButton(
                    icon: Icons.table_chart_outlined,
                    tooltip: 'Excel',
                  ),
                  const ReportIconActionButton(
                    icon: Icons.print_outlined,
                    tooltip: 'Print',
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
                        'DETAILS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Item name',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              SizedBox(
                                width: 260,
                                child: SaleFilterDropdown(
                                  label: selectedItem,
                                  options: itemNames,
                                  selected: selectedItem,
                                  onSelected: (value) => ref
                                      .read(
                                        reportSelectedItemNameProvider.notifier,
                                      )
                                      .select(value),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _hideInactiveDates,
                                onChanged: (value) => setState(
                                  () => _hideInactiveDates = value ?? false,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              const Text(
                                'Hide inactive dates',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    const Divider(height: 1, color: reportCardBorder),
                    Expanded(
                      child: rows.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  headerChildren: const [
                                    ReportAlignedHeaderCell(
                                      label: 'DATE',
                                      width: 120,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'SALE QUANTITY',
                                      width: 130,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'PURCHASE QUANTITY',
                                      width: 150,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'ADJUSTMENT QUANTITY',
                                      width: 170,
                                      alignment: Alignment.centerRight,
                                    ),
                                    Expanded(
                                      child: ReportAlignedHeaderCell(
                                        label: 'CLOSING QUANTITY',
                                        alignment: Alignment.centerRight,
                                      ),
                                    ),
                                  ],
                                  rows: const [],
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'No data for the selected period.',
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
                                    width: 120,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'SALE QUANTITY',
                                    width: 130,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'PURCHASE QUANTITY',
                                    width: 150,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'ADJUSTMENT QUANTITY',
                                    width: 170,
                                    alignment: Alignment.centerRight,
                                  ),
                                  Expanded(
                                    child: ReportAlignedHeaderCell(
                                      label: 'CLOSING QUANTITY',
                                      alignment: Alignment.centerRight,
                                    ),
                                  ),
                                ],
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.fixed(
                                            120,
                                            child: Text(
                                              formatReportDate(rows[i].date),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            130,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i].type == 'Sale'
                                                  ? rows[i]
                                                      .quantity
                                                      .toStringAsFixed(0)
                                                  : '-',
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            150,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i].type != 'Sale'
                                                  ? rows[i]
                                                      .quantity
                                                      .toStringAsFixed(0)
                                                  : '-',
                                            ),
                                          ),
                                          const ReportAlignedCell.fixed(
                                            170,
                                            alignment: Alignment.centerRight,
                                            child: Text('-'),
                                          ),
                                          ReportAlignedCell.flex(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              runningClosing(i)
                                                  .toStringAsFixed(0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
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
