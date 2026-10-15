import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const stockTransferExportHeaders = [
  'Date',
  'Ref No',
  'From',
  'To',
  'Item',
  'Qty',
  'Value',
];

List<String> stockTransferExportRow(ReportStockTransferRow row) {
  return [
    formatReportDate(row.date),
    row.refNo,
    row.fromGodown,
    row.toGodown,
    row.itemName,
    row.quantity.toStringAsFixed(2),
    formatReportCurrency(row.value),
  ];
}
