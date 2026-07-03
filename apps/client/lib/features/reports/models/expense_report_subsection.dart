enum ExpenseReportSubSection {
  expense('Expense'),
  expenseCategoryReport('Expense Category Report'),
  expenseItemReport('Expense Item Report');

  const ExpenseReportSubSection(this.label);

  final String label;
}
