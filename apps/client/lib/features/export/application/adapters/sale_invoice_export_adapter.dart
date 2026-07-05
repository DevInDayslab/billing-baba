import 'package:billing_baba/features/export/application/adapters/sale_export_sheet_builder.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builds export sheet for sale invoice list using current filters.
Future<ExportSheet> buildSaleInvoiceExportSheet(WidgetRef ref) async {
  final filters = ref.read(saleInvoiceFiltersProvider);
  final search = ref.read(saleInvoiceSearchQueryProvider);
  final service = await ref.read(salesServiceProvider.future);

  final items = await _fetchAllSaleInvoices(
    service: service,
    filters: filters,
    search: search,
  );

  return SaleExportSheetBuilder.fromSaleInvoices(
    sheetName: 'Sale Invoices',
    items: items,
  );
}

Future<List<SaleInvoiceModel>> _fetchAllSaleInvoices({
  required SalesService service,
  required SaleInvoiceFiltersState filters,
  required String search,
}) async {
  return PaginatedFetch.fetchAll(
    fetchPage: (page) async {
      final query = _buildSaleInvoiceQuery(filters, search, page: page);
      final result = await service.fetchInvoicesPage(query);
      return (
        items: _applySaleInvoiceClientFilters(result.items, filters),
        totalPages: result.totalPages,
      );
    },
  );
}

SalesDocumentListQuery _buildSaleInvoiceQuery(
  SaleInvoiceFiltersState filters,
  String search, {
  required int page,
}) {
  final dateRange = resolveExportTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return SalesDocumentListQuery(
    page: page,
    limit: PaginatedFetch.defaultPageSize,
    documentType: SalesDocumentType.taxInvoice.apiValue,
    status: _documentStatusFromFilterLabel(filters.selectedStatus),
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
    q: search.trim().isEmpty ? null : search.trim(),
  );
}

List<SaleInvoiceModel> _applySaleInvoiceClientFilters(
  List<SaleInvoiceModel> invoices,
  SaleInvoiceFiltersState filters,
) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);

  return invoices.where((invoice) {
    if (paymentStatus != null && invoice.status != paymentStatus) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        invoice.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        invoice.godown != filters.selectedGodown) {
      return false;
    }
    return true;
  }).toList();
}

SaleInvoiceStatus? _paymentStatusFromFilterLabel(String label) =>
    switch (label) {
      'Paid' => SaleInvoiceStatus.paid,
      'Unpaid' => SaleInvoiceStatus.unpaid,
      'Partial' => SaleInvoiceStatus.partiallyPaid,
      'Overdue' => SaleInvoiceStatus.overdue,
      'Cancelled' => SaleInvoiceStatus.cancelled,
      _ => null,
    };

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  _ => null,
};
