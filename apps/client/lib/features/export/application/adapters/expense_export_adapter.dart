import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildExpenseExportSheet(WidgetRef ref) async {
  final transactions = await ref.read(expenseTransactionsProvider.future);

  return ExportSheet(
    name: 'Expenses',
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.datetime),
      ExportColumn(header: 'Transaction No'),
      ExportColumn(header: 'Party'),
      ExportColumn(header: 'Payment Type'),
      ExportColumn(header: 'Amount', type: ExportCellType.currency),
      ExportColumn(header: 'Balance', type: ExportCellType.currency),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
      ExportColumn(header: 'Status'),
    ],
    rows: [
      for (final tx in transactions)
        ExportRow([
          tx.date,
          tx.transactionNo,
          tx.party,
          tx.paymentType ?? '',
          tx.amount ?? 0,
          tx.balance ?? 0,
          tx.dueDate,
          tx.status?.name ?? '',
        ]),
    ],
  );
}
