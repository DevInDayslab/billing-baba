import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const stockSummaryByItemCategoryExportHeaders = [
  'Item Category',
  'Stock Value',
  'Sale Value',
];

List<String> stockSummaryByItemCategoryExportRow(ReportCategoryAmountRow row) {
  return [
    row.category,
    formatReportCurrency(row.purchaseAmount),
    formatReportCurrency(row.saleAmount),
  ];
}
