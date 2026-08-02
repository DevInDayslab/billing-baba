import 'package:billing_baba/features/reports/application/sale_report_column_filters_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';

String saleReportStatusLabel(SaleInvoiceStatus status) => switch (status) {
  SaleInvoiceStatus.paid => 'Paid',
  SaleInvoiceStatus.unpaid => 'Unpaid',
  SaleInvoiceStatus.partiallyPaid => 'Partial',
  SaleInvoiceStatus.overdue => 'Overdue',
  SaleInvoiceStatus.cancelled => 'Cancelled',
};

List<SaleInvoiceModel> applySaleReportColumnFilters(
  List<SaleInvoiceModel> rows,
  SaleReportColumnFiltersState filters,
) {
  return rows.where((invoice) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(invoice.date)) {
      return false;
    }
    if (filters.invoiceNoColumnFilter != null &&
        !filters.invoiceNoColumnFilter!.matches(invoice.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(invoice.partyName)) {
      return false;
    }
    if (filters.transactionTypeColumnFilter != null &&
        !filters.transactionTypeColumnFilter!.matches(
          invoice.transactionType,
        )) {
      return false;
    }
    if (filters.paymentTypeColumnFilter != null &&
        !filters.paymentTypeColumnFilter!.matches(invoice.paymentType)) {
      return false;
    }
    if (filters.statusColumnFilter != null &&
        !filters.statusColumnFilter!.matches(
          saleReportStatusLabel(invoice.status),
        )) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(invoice.amount)) {
      return false;
    }
    if (filters.balanceColumnFilter != null &&
        !filters.balanceColumnFilter!.matches(invoice.balance)) {
      return false;
    }
    return true;
  }).toList();
}
