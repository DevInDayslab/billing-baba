import 'package:billing_baba/features/export/application/adapters/sale_export_sheet_builder.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/models/sale_invoice_report_options.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builds export sheet for sale invoice list using current filters.
Future<ExportSheet> buildSaleInvoiceExportSheet(
  WidgetRef ref, {
  SaleInvoiceReportOptions options = const SaleInvoiceReportOptions(),
}) async {
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
    options: options,
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
        items: applySaleInvoiceClientFilters(result.items, filters),
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

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  _ => null,
};
