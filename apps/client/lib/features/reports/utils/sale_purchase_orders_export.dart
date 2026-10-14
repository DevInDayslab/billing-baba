import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_order_filter_utils.dart';

const salePurchaseOrdersExportHeaders = [
  'Date',
  'Order No.',
  'Name',
  'Due Date',
  'Status',
  'Type',
  'Total',
  'Advance',
  'Balance',
];

List<String> salePurchaseOrdersExportRow(ReportOrderRow row) => [
  formatReportDate(row.date),
  row.orderNo,
  row.partyName,
  formatReportDate(row.dueDate),
  salePurchaseOrderStatusLabel(row.status),
  salePurchaseOrderRowTypeLabel(row.type),
  formatReportCurrency(row.amount),
  formatReportCurrency(row.advance),
  formatReportCurrency(row.balance),
];
