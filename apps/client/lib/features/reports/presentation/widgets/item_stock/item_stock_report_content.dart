import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemStockReportContent extends StatelessWidget {
  const ItemStockReportContent({required this.subSection, super.key});

  final ItemStockReportSubSection subSection;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  String get _title => switch (subSection) {
    ItemStockReportSubSection.stockSummary => 'Stock Summary Report',
    ItemStockReportSubSection.stockDetail => 'Stock Detail Report',
    ItemStockReportSubSection.itemWiseProfitLoss => 'Item Wise Profit/Loss',
    ItemStockReportSubSection.lowStockDetails => 'Low Stock Details',
    ItemStockReportSubSection.itemReportByParty => 'Item Report By Party',
  };

  List<_TableColumn> get _columns => switch (subSection) {
    ItemStockReportSubSection.stockSummary => const [
      _TableColumn('#', 40),
      _TableColumn('ITEM NAME', null),
      _TableColumn('CATEGORY', 120),
      _TableColumn('QTY', 80, right: true),
      _TableColumn('STOCK VALUE', 120, right: true),
      _TableColumn('SALE QTY', 90, right: true),
      _TableColumn('PURCHASE QTY', 110, right: true),
    ],
    ItemStockReportSubSection.stockDetail => const [
      _TableColumn('DATE', 100),
      _TableColumn('ITEM NAME', null),
      _TableColumn('TYPE', 100),
      _TableColumn('REF NO.', 110),
      _TableColumn('QTY IN', 90, right: true),
      _TableColumn('QTY OUT', 90, right: true),
      _TableColumn('BALANCE', 90, right: true),
    ],
    ItemStockReportSubSection.itemWiseProfitLoss => const [
      _TableColumn('#', 40),
      _TableColumn('ITEM NAME', null),
      _TableColumn('SALE AMOUNT', 120, right: true),
      _TableColumn('PURCHASE AMOUNT', 140, right: true),
      _TableColumn('PROFIT (+) / LOSS (-)', 150, right: true),
    ],
    ItemStockReportSubSection.lowStockDetails => const [
      _TableColumn('#', 40),
      _TableColumn('ITEM NAME', null),
      _TableColumn('CATEGORY', 120),
      _TableColumn('MIN QTY', 90, right: true),
      _TableColumn('CURRENT QTY', 110, right: true),
      _TableColumn('SHORTAGE', 100, right: true),
    ],
    ItemStockReportSubSection.itemReportByParty => const [
      _TableColumn('#', 40),
      _TableColumn('PARTY NAME', null),
      _TableColumn('ITEM NAME', 140),
      _TableColumn('SALE QTY', 100, right: true),
      _TableColumn('SALE AMOUNT', 120, right: true),
      _TableColumn('PURCHASE QTY', 120, right: true),
      _TableColumn('PURCHASE AMOUNT', 140, right: true),
    ],
  };

  bool get _showCategoryFilter =>
      subSection == ItemStockReportSubSection.stockSummary ||
      subSection == ItemStockReportSubSection.stockDetail ||
      subSection == ItemStockReportSubSection.lowStockDetails;

  bool get _showGodownFilter =>
      subSection == ItemStockReportSubSection.stockDetail ||
      subSection == ItemStockReportSubSection.itemReportByParty;

  bool get _showSummaryFooter =>
      subSection == ItemStockReportSubSection.stockSummary ||
      subSection == ItemStockReportSubSection.itemWiseProfitLoss;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                const ReportTextActionButton(
                  label: 'Excel Report',
                  icon: Icons.table_chart_outlined,
                ),
                const ReportTextActionButton(
                  label: 'Print',
                  icon: Icons.print_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportPeriodFilterBar(
                    showFirmFilter: false,
                    trailing: _showGodownFilter
                        ? SaleFilterDropdown(
                            label: 'All Godown',
                            options: const [
                              'All Godown',
                              'Main Location',
                              'Warehouse B',
                            ],
                            selected: 'All Godown',
                            onSelected: (_) {},
                          )
                        : null,
                  ),
                  if (_showCategoryFilter) ...[
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
                        if (subSection !=
                            ItemStockReportSubSection.lowStockDetails)
                          SaleFilterDropdown(
                            label: 'All Items',
                            options: const [
                              'All Items',
                              'Item 1',
                              'Item 2',
                            ],
                            selected: 'All Items',
                            onSelected: (_) {},
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (subSection == ItemStockReportSubSection.lowStockDetails) ...[
              const SizedBox(height: AppSpacing.md),
              ReportCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Items at or below minimum stock level are shown here.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ReportSearchField(
              hintText:
                  subSection == ItemStockReportSubSection.itemReportByParty
                  ? 'Search Party or Item...'
                  : 'Search Item...',
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportTableHeaderRow(
                    children: [
                      for (final col in _columns)
                        if (col.width == null)
                          Expanded(
                            child: ReportTableHeaderCell(
                              label: col.label,
                              alignment: col.right
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                            ),
                          )
                        else
                          ReportTableHeaderCell(
                            label: col.label,
                            width: col.width,
                            alignment: col.right
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                          ),
                    ],
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  ReportEmptyTableState(
                    message: _emptyMessage,
                    minHeight: 220,
                  ),
                  if (_showSummaryFooter)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: reportCardBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _footerPrimaryLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _footerSecondaryLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  subSection ==
                                      ItemStockReportSubSection
                                          .itemWiseProfitLoss
                                  ? reportTeal
                                  : AppColors.textPrimary,
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
  }

  String get _emptyMessage => switch (subSection) {
    ItemStockReportSubSection.stockSummary =>
      'No stock data available for the selected date.',
    ItemStockReportSubSection.stockDetail =>
      'No stock movements found for the selected period.',
    ItemStockReportSubSection.itemWiseProfitLoss =>
      'No profit or loss data for the selected period.',
    ItemStockReportSubSection.lowStockDetails =>
      'No items are below minimum stock level.',
    ItemStockReportSubSection.itemReportByParty =>
      'No item transactions found for parties.',
  };

  String get _footerPrimaryLabel => switch (subSection) {
    ItemStockReportSubSection.stockSummary =>
      'Total Stock Value: ${_currencyFormat.format(0)}',
    ItemStockReportSubSection.itemWiseProfitLoss =>
      'Total Sale: ${_currencyFormat.format(0)}',
    _ => '',
  };

  String get _footerSecondaryLabel => switch (subSection) {
    ItemStockReportSubSection.stockSummary => 'Total Items: 0',
    ItemStockReportSubSection.itemWiseProfitLoss =>
      'Total Profit(+) / Loss (-): ${_currencyFormat.format(0)}',
    _ => '',
  };
}

class _TableColumn {
  const _TableColumn(this.label, this.width, {this.right = false});

  final String label;
  final double? width;
  final bool right;
}
