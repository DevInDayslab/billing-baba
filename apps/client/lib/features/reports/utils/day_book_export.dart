import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const dayBookExportHeaders = [
  'Name',
  'Ref No.',
  'Type',
  'Total',
  'Money In',
  'Money Out',
];

List<String> dayBookExportRow(ReportTransactionRow row) {
  return [
    row.partyName,
    row.refNo,
    row.type,
    formatReportCurrencyCompact(row.total),
    if (row.moneyIn > 0) formatReportCurrencyCompact(row.moneyIn) else '',
    if (row.moneyOut > 0) formatReportCurrencyCompact(row.moneyOut) else '',
  ];
}
