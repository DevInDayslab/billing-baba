import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildPurchaseFaExportSheet(WidgetRef ref) async {
  await ref.read(purchaseFaProvider.future);
  final items = ref.read(filteredPurchaseFaRecordsProvider);

  return ExportSheet(
    name: 'Fixed Asset Purchases',
    columns: const [
      ExportColumn(header: 'Party'),
      ExportColumn(header: 'Invoice No'),
      ExportColumn(header: 'Date', type: ExportCellType.date),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
      ExportColumn(header: 'Amount', type: ExportCellType.currency),
      ExportColumn(header: 'Balance', type: ExportCellType.currency),
      ExportColumn(header: 'Payment Type'),
      ExportColumn(header: 'Status'),
    ],
    rows: [
      for (final record in items)
        ExportRow([
          record.partyName,
          record.invoiceNo,
          record.date,
          record.dueDate,
          record.amount,
          record.balanceDue,
          record.paymentType,
          _statusLabel(record.status),
        ]),
    ],
  );
}

String _statusLabel(PurchaseFaStatus status) => switch (status) {
  PurchaseFaStatus.paid => 'Paid',
  PurchaseFaStatus.unpaid => 'Unpaid',
  PurchaseFaStatus.partiallyPaid => 'Partial',
  PurchaseFaStatus.overdue => 'Overdue',
  PurchaseFaStatus.cancelled => 'Cancelled',
};
