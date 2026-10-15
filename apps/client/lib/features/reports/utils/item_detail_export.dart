import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';

const itemDetailExportHeaders = [
  'Date',
  'Type',
  'Ref No',
  'Party',
  'Qty',
  'Price',
  'Amount',
  'Closing Qty',
];

List<String> itemDetailExportRow(ReportItemDetailTableRow entry) {
  final row = entry.row;
  return [
    formatReportDate(row.date),
    row.type,
    row.refNo,
    row.partyName,
    row.quantity.toStringAsFixed(2),
    formatReportCurrencyCompact(row.price),
    formatReportCurrencyCompact(row.amount),
    entry.closingQty.toStringAsFixed(2),
  ];
}
