import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/application/purchase_documents_list_provider.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildPurchaseDocumentExportSheet(
  WidgetRef ref,
  PurchaseDocumentListScope scope, {
  required String sheetName,
}) async {
  final filters = ref.read(purchaseDocumentFiltersProvider(scope));
  final search = ref.read(purchaseDocumentSearchQueryProvider(scope));
  final service = await ref.read(purchaseServiceProvider.future);

  final items = await PaginatedFetch.fetchAll(
    fetchPage: (page) async {
      final dateRange = resolveExportTimeRange(
        filters.timeRangeOption,
        filters.customDateRange,
      );
      final query = PurchaseDocumentListQuery(
        page: page,
        limit: PaginatedFetch.defaultPageSize,
        documentType: scope.documentType.apiValue,
        status: _documentStatusFromFilterLabel(filters.selectedStatus),
        from: dateRange?.start.toUtc().toIso8601String(),
        to: dateRange?.end.toUtc().toIso8601String(),
        q: search.trim().isEmpty ? null : search.trim(),
      );
      final result = await service.fetchBillsPage(query);
      return (items: result.items, totalPages: result.totalPages);
    },
  );

  return ExportSheet(
    name: sheetName,
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.date),
      ExportColumn(header: 'Invoice No'),
      ExportColumn(header: 'Party'),
      ExportColumn(header: 'Payment Type'),
      ExportColumn(header: 'Status'),
      ExportColumn(header: 'Amount', type: ExportCellType.currency),
      ExportColumn(header: 'Balance', type: ExportCellType.currency),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
    ],
    rows: [
      for (final bill in items)
        ExportRow([
          bill.date,
          bill.invoiceNo,
          bill.partyName,
          bill.paymentType,
          bill.status.name,
          bill.amount,
          bill.balanceDue,
          bill.dueDate,
        ]),
    ],
  );
}

String purchaseDocumentExportFilenameBase(PurchaseDocumentListScope scope) {
  return switch (scope.documentType) {
    PurchaseDocumentType.purchaseOrder => 'Purchase_Orders',
    PurchaseDocumentType.purchaseReturn => 'Debit_Notes',
    _ => 'Purchase',
  };
}

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  'Draft' => 'draft',
  _ => null,
};
