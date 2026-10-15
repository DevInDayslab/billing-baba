import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const expenseItemExportHeaders = [
  'Expense Item',
  'Expense Category',
  'Expense Count',
  'Amount',
];

List<String> expenseItemExportRow(ReportExpenseItemRow row) {
  return [
    row.itemName,
    row.category,
    row.count.toString(),
    formatReportCurrency(row.amount),
  ];
}
