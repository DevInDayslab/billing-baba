import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
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
    ItemStockReportSubSection.itemReportByParty => 'Item Report By Party',
    ItemStockReportSubSection.lowStockSummary => 'Low Stock Summary',
    ItemStockReportSubSection.itemDetail => 'Item Detail',
    ItemStockReportSubSection.salePurchaseReportByItemCategory =>
      'Sale/Purchase Report By Item Category',
    ItemStockReportSubSection.stockSummaryReportByItemCategory =>
      'Stock Summary Report By Item Category',
    ItemStockReportSubSection.itemCategoryWiseProfitLoss =>
      'Item Category Wise Profit And Loss',
    ItemStockReportSubSection.itemWiseDiscount => 'Item Wise Discount',
    ItemStockReportSubSection.manufacturingReport => 'Manufacturing Report',
    ItemStockReportSubSection.consumptionReport => 'Consumption Report',
    ItemStockReportSubSection.stockTransferReport => 'Stock Transfer Report',
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
    ItemStockReportSubSection.itemReportByParty => const [
      _TableColumn('#', 40),
      _TableColumn('PARTY NAME', null),
      _TableColumn('ITEM NAME', 140),
      _TableColumn('SALE QTY', 100, right: true),
      _TableColumn('SALE AMOUNT', 120, right: true),
      _TableColumn('PURCHASE QTY', 120, right: true),
      _TableColumn('PURCHASE AMOUNT', 140, right: true),
    ],
    ItemStockReportSubSection.lowStockSummary => const [
      _TableColumn('ITEM NAME', null),
      _TableColumn('MINIMUM STOCK QTY', 150, right: true),
      _TableColumn('STOCK QTY', 110, right: true),
      _TableColumn('STOCK VALUE', 120, right: true),
    ],
    ItemStockReportSubSection.itemDetail => const [
      _TableColumn('DATE', 100),
      _TableColumn('SALE QUANTITY', 120, right: true),
      _TableColumn('PURCHASE QUANTITY', 140, right: true),
      _TableColumn('ADJUSTMENT QUANTITY', 150, right: true),
      _TableColumn('CLOSING QUANTITY', 130, right: true),
    ],
    ItemStockReportSubSection.salePurchaseReportByItemCategory => const [
      _TableColumn('ITEM CATEGORY', null),
      _TableColumn('SALE QUANTITY', 120, right: true),
      _TableColumn('TOTAL SALE AMOUNT', 140, right: true),
      _TableColumn('PURCHASE QUANTITY', 140, right: true),
      _TableColumn('TOTAL PURCHASE AMOUNT', 150, right: true),
    ],
    ItemStockReportSubSection.stockSummaryReportByItemCategory => const [
      _TableColumn('ITEM CATEGORY', null),
      _TableColumn('NO. OF ITEMS', 110, right: true),
      _TableColumn('STOCK QTY', 100, right: true),
      _TableColumn('PURCHASE VALUE', 130, right: true),
      _TableColumn('SALE VALUE', 110, right: true),
      _TableColumn('LOW STOCK ITEMS', 130, right: true),
    ],
    ItemStockReportSubSection.itemCategoryWiseProfitLoss => const [
      _TableColumn('ITEM CATEGORY', 150),
      _TableColumn('SALE', 100, right: true),
      _TableColumn('CR. NOTE / SALE RETURN', 150, right: true),
      _TableColumn('PURCHASE', 110, right: true),
      _TableColumn('DR. NOTE / PURCHASE RETURN', 170, right: true),
      _TableColumn('OPENING STOCK', 120, right: true),
      _TableColumn('CLOSING STOCK', 120, right: true),
      _TableColumn('NET PROFIT (+) / LOSS (-)', 160, right: true),
    ],
    ItemStockReportSubSection.itemWiseDiscount => const [
      _TableColumn('#', 40),
      _TableColumn('ITEM NAME', null),
      _TableColumn('TOTAL QTY SOLD', 120, right: true),
      _TableColumn('TOTAL SALE AMOUNT', 140, right: true),
      _TableColumn('TOTAL DISC. AMOUNT', 140, right: true),
      _TableColumn('AVG. DISC. (%)', 110, right: true),
      _TableColumn('DETAILS', 80),
    ],
    ItemStockReportSubSection.manufacturingReport => const [
      _TableColumn('#', 40),
      _TableColumn('ITEM NAME', null),
      _TableColumn('DATE', 100),
      _TableColumn('QTY MANUFACTURED', 150, right: true),
      _TableColumn('AMOUNT', 110, right: true),
      _TableColumn('DETAILS', 80),
    ],
    ItemStockReportSubSection.consumptionReport => const [
      _TableColumn('#', 40),
      _TableColumn('ITEM NAME', null),
      _TableColumn('DATE', 100),
      _TableColumn('QTY CONSUMED', 130, right: true),
      _TableColumn('AMOUNT', 110, right: true),
      _TableColumn('DETAILS', 80),
    ],
    ItemStockReportSubSection.stockTransferReport => const [
      _TableColumn('#', 40),
      _TableColumn('TRANSFER NO.', 110),
      _TableColumn('DATE', 100),
      _TableColumn('ITEM NAME', 160),
      _TableColumn('FROM GODOWN', 120),
      _TableColumn('TO GODOWN', 120),
      _TableColumn('QTY TRANSFERRED', 130, right: true),
      _TableColumn('VALUE', 100, right: true),
      _TableColumn('DETAILS', 80),
    ],
  };

  bool get _showCategoryFilter =>
      subSection == ItemStockReportSubSection.stockSummary ||
      subSection == ItemStockReportSubSection.stockDetail;

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
                  const ReportPeriodFilterBar(showFirmFilter: false),
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
            const SizedBox(height: AppSpacing.md),
            ReportSearchField(
              hintText: subSection == ItemStockReportSubSection.itemReportByParty
                  ? 'Search Party or Item...'
                  : 'Search Item...',
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportSyncScrollTable(
                    headerChildren: [
                      for (final col in _columns)
                        if (col.width == null)
                          Expanded(
                            child: ReportAlignedHeaderCell(
                              label: col.label,
                              alignment: col.right
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                            ),
                          )
                        else
                          ReportAlignedHeaderCell(
                            label: col.label,
                            width: col.width,
                            alignment: col.right
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                          ),
                    ],
                    rows: const [],
                  ),
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
                        border: Border(top: BorderSide(color: reportCardBorder)),
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
                              color: subSection ==
                                      ItemStockReportSubSection.itemWiseProfitLoss
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
    ItemStockReportSubSection.lowStockSummary =>
      'No low stock items found based on the selected filters.',
    ItemStockReportSubSection.itemReportByParty =>
      'No item transactions found for parties.',
    ItemStockReportSubSection.itemDetail =>
      'Please enter an item name to see the details.',
    ItemStockReportSubSection.salePurchaseReportByItemCategory =>
      'No data to display.',
    ItemStockReportSubSection.stockSummaryReportByItemCategory =>
      'No stock data found for the selected filters.',
    ItemStockReportSubSection.itemCategoryWiseProfitLoss =>
      'No profit or loss data for the selected period.',
    ItemStockReportSubSection.itemWiseDiscount => 'No Items',
    ItemStockReportSubSection.manufacturingReport =>
      'No manufacturing records found for the selected period.',
    ItemStockReportSubSection.consumptionReport =>
      'No consumption records found for the selected period.',
    ItemStockReportSubSection.stockTransferReport =>
      'No stock transfer records found for the selected period.',
  };

  String get _footerPrimaryLabel => switch (subSection) {
    ItemStockReportSubSection.stockSummary =>
      'Total Stock Value: ${_currencyFormat.format(0)}',
    ItemStockReportSubSection.itemWiseProfitLoss =>
      'Total Sale: ${_currencyFormat.format(0)}',
    _ => '',
  };

  String get _footerSecondaryLabel => switch (subSection) {
    ItemStockReportSubSection.stockSummary =>
      'Total Items: 0',
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
