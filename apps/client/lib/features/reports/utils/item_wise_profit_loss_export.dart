import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const itemWiseProfitLossExportHeaders = [
  'Item Name',
  'Sale',
  'Purchase',
  'Profit',
];

List<String> itemWiseProfitLossExportRow(ReportItemWiseProfitLossRow row) {
  return [
    row.itemName,
    formatReportCurrency(row.saleAmount),
    formatReportCurrency(row.purchaseAmount),
    formatReportCurrency(row.profit),
  ];
}
