import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const salePurchaseByItemCategoryExportHeaders = [
  'Category',
  'Sale',
  'Purchase',
];

List<String> salePurchaseByItemCategoryExportRow(ReportCategoryAmountRow row) {
  return [
    row.category,
    formatReportCurrency(row.saleAmount),
    formatReportCurrency(row.purchaseAmount),
  ];
}
