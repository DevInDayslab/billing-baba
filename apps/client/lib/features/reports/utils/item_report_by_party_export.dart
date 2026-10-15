import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const itemReportByPartyExportHeaders = [
  'Item Name',
  'Party Name',
  'Quantity',
  'Amount',
];

List<String> itemReportByPartyExportRow(ReportItemByPartyRow row) {
  return [
    row.itemName,
    row.partyName,
    _formatQty(row.quantity),
    formatReportCurrency(row.amount),
  ];
}

String _formatQty(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}
