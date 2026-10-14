import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const cashFlowExportHeaders = [
  'Date',
  'Ref No',
  'Name',
  'Category',
  'Type',
  'Cash In',
  'Cash Out',
  'Running Balance',
];

List<String> cashFlowExportRow(
  ReportTransactionRow row,
  double runningBalance,
) {
  return [
    formatReportDate(row.date),
    row.refNo,
    row.partyName,
    row.category,
    row.type,
    if (row.moneyIn > 0) formatReportCurrencyCompact(row.moneyIn) else '',
    if (row.moneyOut > 0) formatReportCurrencyCompact(row.moneyOut) else '',
    formatReportCurrencyCompact(runningBalance),
  ];
}
