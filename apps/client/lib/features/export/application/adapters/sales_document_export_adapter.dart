import 'package:billing_baba/features/export/application/adapters/sale_export_sheet_builder.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builds export sheet for any sales document list scope (estimate, proforma, etc.).
Future<ExportSheet> buildSalesDocumentExportSheet(
  WidgetRef ref,
  SalesDocumentListScope scope, {
  required String sheetName,
  required String filenameBase,
}) async {
  final filters = ref.read(salesDocumentFiltersProvider(scope));
  final search = ref.read(salesDocumentSearchQueryProvider(scope));
  final service = await ref.read(salesServiceProvider.future);

  final items = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
    fetchPage: (page) async {
      final dateRange = resolveExportTimeRange(
        filters.timeRangeOption,
        filters.customDateRange,
      );
      final query = SalesDocumentListQuery(
        page: page,
        limit: PaginatedFetch.defaultPageSize,
        documentType: scope.documentType.apiValue,
        status: _documentStatusFromFilterLabel(filters.selectedStatus),
        from: dateRange?.start.toUtc().toIso8601String(),
        to: dateRange?.end.toUtc().toIso8601String(),
        q: search.trim().isEmpty ? null : search.trim(),
      );
      final result = await service.fetchInvoicesPage(query);
      var filtered = result.items;
      if (scope.documentSeries != null) {
        filtered = filtered
            .where(
              (item) => item.documentSeries == scope.documentSeries,
            )
            .toList();
      }
      return (items: filtered, totalPages: result.totalPages);
    },
  );

  return SaleExportSheetBuilder.fromSaleInvoices(
    sheetName: sheetName,
    items: items,
  );
}

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  'Draft' => 'draft',
  'Finalized' => 'finalized',
  _ => null,
};

/// Filename base per sales document scope.
String salesDocumentExportFilenameBase(SalesDocumentListScope scope) {
  return switch (scope.documentType) {
    SalesDocumentType.estimate
        when scope.documentSeries == SalesConstants.proformaSeries =>
      'Proforma',
    SalesDocumentType.estimate => 'Estimates',
    SalesDocumentType.saleOrder => 'Sale_Orders',
    SalesDocumentType.deliveryChallan => 'Delivery_Challans',
    SalesDocumentType.salesReturn => 'Credit_Notes',
    _ => 'Sales',
  };
}

String salesDocumentExportSheetName(SalesDocumentListScope scope) {
  return switch (scope.documentType) {
    SalesDocumentType.estimate
        when scope.documentSeries == SalesConstants.proformaSeries =>
      'Proforma',
    SalesDocumentType.estimate => 'Estimates',
    SalesDocumentType.saleOrder => 'Sale Orders',
    SalesDocumentType.deliveryChallan => 'Delivery Challans',
    SalesDocumentType.salesReturn => 'Credit Notes',
    _ => 'Sales',
  };
}
