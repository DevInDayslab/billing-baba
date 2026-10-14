import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const expenseExportHeaders = [
  'Date',
  'Exp No',
  'Party',
  'Category',
  'Payment Type',
  'Amount',
  'Balance Due',
  'Due Date',
  'Status',
];

String expenseReportStatusLabel(ExpenseReportPaymentStatus status) {
  return switch (status) {
    ExpenseReportPaymentStatus.paid => 'Paid',
    ExpenseReportPaymentStatus.partial => 'Partial',
    ExpenseReportPaymentStatus.pending => 'Pending',
  };
}

List<String> expenseExportRow(ReportExpenseRow row) {
  return [
    formatReportDate(row.date),
    row.expenseNo,
    row.partyName,
    row.category,
    row.paymentType ?? '',
    formatReportCurrency(row.amount),
    row.balanceDue > 0 ? formatReportCurrency(row.balanceDue) : '',
    row.dueDate != null ? formatReportDate(row.dueDate!) : '',
    expenseReportStatusLabel(row.status),
  ];
}
