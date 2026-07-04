import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyReportByItemContent extends ConsumerStatefulWidget {
  const PartyReportByItemContent({super.key});

  @override
  ConsumerState<PartyReportByItemContent> createState() =>
      _PartyReportByItemContentState();
}

class _PartyReportByItemContentState
    extends ConsumerState<PartyReportByItemContent> {
  String _selectedItem = 'caty';

  List<String> get _itemNames =>
      InventoryCatalog.items.map((item) => item.name).toList();

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(reportPartyByItemProvider(_selectedItem));

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReportPeriodFilterBar(),
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
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
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      SaleFilterDropdown(
                        label: 'All Categories',
                        options: const [
                          'All Categories',
                          'Category A',
                          'Category B',
                        ],
                        selected: 'All Categories',
                        onSelected: (_) {},
                      ),
                      SaleFilterDropdown(
                        label: 'All Items',
                        options: ['All Items', ..._itemNames],
                        selected: _selectedItem,
                        onSelected: (value) {
                          if (value != 'All Items') {
                            setState(() => _selectedItem = value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const ReportSearchField(hintText: 'Search Party...'),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportSyncScrollTable(
                    minWidth: 700,
                    emptyState: const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'No data available for the selected period.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    headerChildren: const [
                      ReportAlignedHeaderCell(label: '#', width: 40),
                      Expanded(
                        child: ReportAlignedHeaderCell(label: 'PARTY NAME'),
                      ),
                      ReportAlignedHeaderCell(
                        label: 'SALE QUANTITY',
                        width: 120,
                        alignment: Alignment.centerRight,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'SALE AMOUNT',
                        width: 120,
                        alignment: Alignment.centerRight,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'PURCHASE QUANTITY',
                        width: 140,
                        alignment: Alignment.centerRight,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'PURCHASE AMOUNT',
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
                              ReportAlignedCell.fixed(
                                40,
                                child: Text('${i + 1}'),
                              ),
                              ReportAlignedCell.flex(
                                child: Text(
                                  rows[i].partyName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ReportAlignedCell.fixed(
                                120,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  rows[i].quantity.toStringAsFixed(0),
                                ),
                              ),
                              ReportAlignedCell.fixed(
                                120,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatReportCurrency(rows[i].amount),
                                ),
                              ),
                              ReportAlignedCell.fixed(
                                140,
                                alignment: Alignment.centerRight,
                                child: const Text('—'),
                              ),
                              ReportAlignedCell.fixed(
                                140,
                                alignment: Alignment.centerRight,
                                child: const Text('—'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
