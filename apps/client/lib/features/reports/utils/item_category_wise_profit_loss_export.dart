import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/item_category_wise_profit_loss_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const itemCategoryWiseProfitLossExportHeaders = [
  'Item Category',
  'Sale',
  'Purchase',
  'Net Profit (+) / Loss (-)',
];

List<String> itemCategoryWiseProfitLossExportRow(ReportCategoryAmountRow row) {
  return [
    row.category,
    formatReportCurrency(row.saleAmount),
    formatReportCurrency(row.purchaseAmount),
    formatReportCurrency(categoryWiseProfitLoss(row)),
  ];
}
