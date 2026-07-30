import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/models/sale_invoice_report_options.dart';
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
    SaleInvoiceReportOptions options = const SaleInvoiceReportOptions(),
  }) {
    final columns = <ExportColumn>[];
    final columnKeys = <_SaleInvoiceExportColumn>[];

    void addColumn(_SaleInvoiceExportColumn key, ExportColumn column) {
      columnKeys.add(key);
      columns.add(column);
    }

    if (options.includeDate) {
      addColumn(
        _SaleInvoiceExportColumn.date,
        const ExportColumn(header: 'Date', type: ExportCellType.date),
      );
    }
    if (options.includeInvoiceNo) {
      addColumn(
        _SaleInvoiceExportColumn.invoiceNo,
        const ExportColumn(header: 'Invoice No.'),
      );
    }
    if (options.includePartyName) {
      addColumn(
        _SaleInvoiceExportColumn.partyName,
        const ExportColumn(header: 'Party Name'),
      );
    }
    if (options.includeTotal) {
      addColumn(
        _SaleInvoiceExportColumn.total,
        const ExportColumn(header: 'Total', type: ExportCellType.currency),
      );
    }
    if (options.includePaymentType) {
      addColumn(
        _SaleInvoiceExportColumn.paymentType,
        const ExportColumn(header: 'Payment Type'),
      );
    }
    if (options.includeReceivedPaid) {
      addColumn(
        _SaleInvoiceExportColumn.receivedPaid,
        const ExportColumn(
          header: 'Received/Paid',
          type: ExportCellType.currency,
        ),
      );
    }
    if (options.includeBalanceDue) {
      addColumn(
        _SaleInvoiceExportColumn.balanceDue,
        const ExportColumn(
          header: 'Balance Due',
          type: ExportCellType.currency,
        ),
      );
    }
    if (options.includeItemDetails) {
      addColumn(
        _SaleInvoiceExportColumn.itemDetails,
        const ExportColumn(header: 'Item Details'),
      );
    }
    if (options.includeDescription) {
      addColumn(
        _SaleInvoiceExportColumn.description,
        const ExportColumn(header: 'Description'),
      );
    }
    if (options.includePaymentStatus) {
      addColumn(
        _SaleInvoiceExportColumn.paymentStatus,
        const ExportColumn(header: 'Payment Status'),
      );
    }
    if (options.includeOrderNumber) {
      addColumn(
        _SaleInvoiceExportColumn.orderNumber,
        const ExportColumn(header: 'Order Number'),
      );
    }
    if (options.includePartyPhone) {
      addColumn(
        _SaleInvoiceExportColumn.partyPhone,
        const ExportColumn(header: "Party's Phone No."),
      );
    }
    if (options.includePaymentBreakup) {
      addColumn(
        _SaleInvoiceExportColumn.paymentBreakup,
        const ExportColumn(header: 'Payment Breakup'),
      );
    }
    if (options.includePartyGstin) {
      addColumn(
        _SaleInvoiceExportColumn.partyGstin,
        const ExportColumn(header: "Party's GSTIN"),
      );
    }

    return ExportSheet(
      name: sheetName,
      columns: columns,
      rows: [
        for (final item in items)
          ExportRow([
            for (final key in columnKeys) _cellValue(item, key),
          ]),
      ],
    );
  }

  static Object? _cellValue(
    SaleInvoiceModel item,
    _SaleInvoiceExportColumn key,
  ) {
    return switch (key) {
      _SaleInvoiceExportColumn.date => item.date,
      _SaleInvoiceExportColumn.invoiceNo => item.invoiceNo,
      _SaleInvoiceExportColumn.partyName => item.partyName,
      _SaleInvoiceExportColumn.total => item.amount,
      _SaleInvoiceExportColumn.paymentType => item.paymentType,
      _SaleInvoiceExportColumn.receivedPaid =>
        (item.amount - item.balance).clamp(0, double.infinity),
      _SaleInvoiceExportColumn.balanceDue => item.balance,
      _SaleInvoiceExportColumn.itemDetails => '',
      _SaleInvoiceExportColumn.description => '',
      _SaleInvoiceExportColumn.paymentStatus => _saleStatusLabel(item.status),
      _SaleInvoiceExportColumn.orderNumber => '',
      _SaleInvoiceExportColumn.partyPhone => '',
      _SaleInvoiceExportColumn.paymentBreakup => item.paymentType,
      _SaleInvoiceExportColumn.partyGstin => '',
    };
  }

  static String _saleStatusLabel(SaleInvoiceStatus status) => switch (status) {
    SaleInvoiceStatus.paid => 'Paid',
    SaleInvoiceStatus.unpaid => 'Unpaid',
    SaleInvoiceStatus.partiallyPaid => 'Partial',
    SaleInvoiceStatus.overdue => 'Overdue',
    SaleInvoiceStatus.cancelled => 'Cancelled',
  };
}

enum _SaleInvoiceExportColumn {
  date,
  invoiceNo,
  partyName,
  total,
  paymentType,
  receivedPaid,
  balanceDue,
  itemDetails,
  description,
  paymentStatus,
  orderNumber,
  partyPhone,
  paymentBreakup,
  partyGstin,
}
