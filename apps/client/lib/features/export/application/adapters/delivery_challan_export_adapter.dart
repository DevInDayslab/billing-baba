import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builds export sheet for delivery challan list using current filters.
Future<ExportSheet> buildDeliveryChallanExportSheet(WidgetRef ref) async {
  final filters = ref.read(deliveryChallanFiltersProvider);
  final search = ref.read(deliveryChallanSearchQueryProvider);
  final service = await ref.read(salesServiceProvider.future);

  final items = await _fetchAllDeliveryChallans(
    service: service,
    filters: filters,
    search: search,
  );

  return _deliveryChallanSheet(items);
}

Future<List<SaleInvoiceModel>> _fetchAllDeliveryChallans({
  required SalesService service,
  required DeliveryChallanFiltersState filters,
  required String search,
}) async {
  final allItems = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
    fetchPage: (page) async {
      final result = await service.fetchInvoicesPage(
        buildChallanListQuery(
          filters,
          search,
          page: page,
          limit: PaginatedFetch.defaultPageSize,
        ),
      );
      return (
        items: filterChallanSeries(result.items),
        totalPages: result.totalPages,
      );
    },
  );

  if (needsChallanClientSideFiltering(filters)) {
    return applyChallanClientFilters(allItems, filters);
  }

  return allItems;
}

ExportSheet _deliveryChallanSheet(List<SaleInvoiceModel> items) {
  return ExportSheet(
    name: 'Delivery Challans',
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.datetime),
      ExportColumn(header: 'Party'),
      ExportColumn(header: 'Challan No.'),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
      ExportColumn(header: 'Total Amount', type: ExportCellType.currency),
      ExportColumn(header: 'Status'),
    ],
    rows: [
      for (final challan in items)
        ExportRow([
          challan.date,
          challan.partyName,
          challan.invoiceNo,
          challan.dueDate,
          challan.amount,
          _challanStatusLabel(challan.documentStatus),
        ]),
    ],
  );
}

String _challanStatusLabel(SalesDocumentStatus status) =>
    status.lifecycleDisplayLabel;
