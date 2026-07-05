import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';

/// Shared column builders for sales document list exports.
abstract final class SaleExportSheetBuilder {
  static const saleInvoiceColumns = [
    ExportColumn(header: 'Date', type: ExportCellType.date),
    ExportColumn(header: 'Invoice No'),
    ExportColumn(header: 'Party Name'),
    ExportColumn(header: 'Transaction'),
    ExportColumn(header: 'Payment Type'),
    ExportColumn(header: 'Status'),
    ExportColumn(header: 'Amount', type: ExportCellType.currency),
    ExportColumn(header: 'Balance', type: ExportCellType.currency),
  ];

  static ExportSheet fromSaleInvoices({
    required String sheetName,
    required List<SaleInvoiceModel> items,
  }) {
    return ExportSheet(
      name: sheetName,
      columns: saleInvoiceColumns,
      rows: [
        for (final item in items)
          ExportRow([
            item.date,
            item.invoiceNo,
            item.partyName,
            item.transactionType,
            item.paymentType,
            _saleStatusLabel(item.status),
            item.amount,
            item.balance,
          ]),
      ],
    );
  }

  static String _saleStatusLabel(SaleInvoiceStatus status) => switch (status) {
    SaleInvoiceStatus.paid => 'Paid',
    SaleInvoiceStatus.unpaid => 'Unpaid',
    SaleInvoiceStatus.partiallyPaid => 'Partial',
    SaleInvoiceStatus.overdue => 'Overdue',
    SaleInvoiceStatus.cancelled => 'Cancelled',
  };
}
