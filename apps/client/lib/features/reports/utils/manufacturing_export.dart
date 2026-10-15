import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const manufacturingExportHeaders = [
  'Date',
  'Ref No',
  'Item',
  'Qty',
  'Cost',
];

List<String> manufacturingExportRow(ReportManufacturingRow row) {
  return [
    formatReportDate(row.date),
    row.refNo,
    row.itemName,
    row.quantity.toStringAsFixed(2),
    formatReportCurrency(row.cost),
  ];
}
