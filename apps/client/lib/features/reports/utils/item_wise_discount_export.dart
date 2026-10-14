import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const itemWiseDiscountExportHeaders = [
  'Item Name',
  'Sale Qty',
  'Total Sale Amount',
  'Discount',
  'Discount %',
];

List<String> itemWiseDiscountExportRow(ReportItemDiscountRow row) {
  return [
    row.itemName,
    row.saleQty.toStringAsFixed(2),
    formatReportCurrency(row.saleAmount),
    formatReportCurrency(row.discountAmount),
    '${row.discountPercent.toStringAsFixed(1)}%',
  ];
}
