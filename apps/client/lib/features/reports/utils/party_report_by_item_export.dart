import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const partyReportByItemExportHeaders = [
  'Party Name',
  'Sale Quantity',
  'Sale Amount',
  'Purchase Quantity',
  'Purchase Amount',
];

List<String> partyReportByItemExportRow(ReportPartyByItemRow row) {
  return [
    row.partyName,
    _formatQty(row.saleQuantity),
    formatReportCurrency(row.saleAmount),
    _formatQty(row.purchaseQuantity),
    formatReportCurrency(row.purchaseAmount),
  ];
}

String _formatQty(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}
