import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

const expenseCategoryExportHeaders = [
  'Expense Category',
  'Category Type',
  'Expense Count',
  'Amount',
];

List<String> expenseCategoryExportRow(ReportExpenseCategoryRow row) {
  return [
    row.category,
    row.categoryTypeLabel,
    row.count.toString(),
    formatReportCurrency(row.amount),
  ];
}
