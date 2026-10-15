import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';

double itemDetailPeriodOpeningQty({
  required double currentClosingQty,
  required double periodPurchaseQty,
  required double periodSaleQty,
}) {
  return currentClosingQty - periodPurchaseQty + periodSaleQty;
}

List<ReportItemDetailTableRow> buildItemDetailLedgerRows(
  List<ReportItemDetailRow> rows, {
  required double openingQty,
  bool newestFirst = true,
}) {
  if (rows.isEmpty) return const [];

  final sorted = [...rows]..sort((a, b) => a.date.compareTo(b.date));
  final withClosing = <ReportItemDetailTableRow>[];
  var balance = openingQty;

  for (final row in sorted) {
    if (row.type == 'Sale') {
      balance -= row.quantity;
    } else {
      balance += row.quantity;
    }
    withClosing.add(
      ReportItemDetailTableRow(row: row, closingQty: balance),
    );
  }

  if (newestFirst) {
    withClosing.sort((a, b) => b.row.date.compareTo(a.row.date));
  }
  return withClosing;
}
