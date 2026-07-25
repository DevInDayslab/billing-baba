import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/application/sale_return_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builds export sheet for sale return / credit note list using current filters.
Future<ExportSheet> buildSaleReturnExportSheet(WidgetRef ref) async {
  final filters = ref.read(saleReturnFiltersProvider);
  final service = await ref.read(salesServiceProvider.future);

  final items = await _fetchAllSaleReturns(
    service: service,
    filters: filters,
  );

  return _saleReturnSheet(items);
}

Future<List<SaleInvoiceModel>> _fetchAllSaleReturns({
  required SalesService service,
  required SaleReturnFiltersState filters,
}) async {
  final allItems = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
    fetchPage: (page) async {
      final result = await service.fetchInvoicesPage(
        buildSaleReturnListQuery(
          filters,
          page: page,
          limit: PaginatedFetch.defaultPageSize,
        ),
      );
      return (
        items: result.items,
        totalPages: result.totalPages,
      );
    },
  );

  return applySaleReturnClientFilters(allItems, filters);
}

ExportSheet _saleReturnSheet(List<SaleInvoiceModel> items) {
  return ExportSheet(
    name: 'Sale Return',
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.datetime),
      ExportColumn(header: 'Ref. No.'),
      ExportColumn(header: 'Party Name'),
      ExportColumn(header: 'Type'),
      ExportColumn(header: 'Total', type: ExportCellType.currency),
      ExportColumn(header: 'Received/Paid', type: ExportCellType.currency),
      ExportColumn(header: 'Balance', type: ExportCellType.currency),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
      ExportColumn(header: 'Status'),
    ],
    rows: [
      for (final item in items)
        ExportRow([
          item.date,
          item.invoiceNo,
          item.partyName,
          item.transactionType,
          item.amount,
          item.amount - item.balance,
          item.balance,
          item.dueDate ?? item.date,
          _saleReturnStatusLabel(item),
        ]),
    ],
  );
}

String _saleReturnStatusLabel(SaleInvoiceModel item) {
  if (item.isDraft) return 'Draft';
  if (item.isCancelled) return 'Cancelled';

  return switch (item.status) {
    SaleInvoiceStatus.paid => 'Paid',
    SaleInvoiceStatus.unpaid => 'Unpaid',
    SaleInvoiceStatus.partiallyPaid => 'Partial',
    SaleInvoiceStatus.overdue => 'Overdue',
    SaleInvoiceStatus.cancelled => 'Cancelled',
  };
}
