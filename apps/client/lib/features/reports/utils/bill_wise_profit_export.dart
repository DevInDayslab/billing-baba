import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const billWiseProfitExportHeaders = [
  'Date',
  'Invoice No',
  'Party',
  'Total Sale Amount',
  'Profit/Loss',
];

List<String> billWiseProfitExportRow(ReportBillWiseProfitRow row) {
  return [
    formatReportDate(row.date),
    row.invoiceNo,
    row.partyName,
    formatReportCurrency(row.saleAmount),
    formatReportCurrency(row.profit),
  ];
}
