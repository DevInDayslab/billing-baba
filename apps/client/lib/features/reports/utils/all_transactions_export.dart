import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const allTransactionsExportHeaders = [
  '#',
  'Date',
  'Ref No.',
  'Party Name',
  'Category',
  'Type',
  'Total',
  'Received',
  'Balance',
  'Due Date',
  'Status',
];

List<String> allTransactionsExportRow(
  ReportTransactionRow row,
  int index,
) {
  return [
    '$index',
    formatReportDate(row.date),
    row.refNo,
    row.partyName,
    row.category,
    row.type,
    formatReportCurrencyCompact(row.total),
    if (row.received > 0) formatReportCurrencyCompact(row.received) else '',
    if (row.balance > 0) formatReportCurrencyCompact(row.balance) else '',
    if (row.dueDate != null) formatReportDate(row.dueDate!) else '',
    row.status,
  ];
}
