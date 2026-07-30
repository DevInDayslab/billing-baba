import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_orders_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildPurchaseOrderExportSheet(WidgetRef ref) async {
  final filters = ref.read(purchaseOrderFiltersProvider);
  final service = await ref.read(purchaseServiceProvider.future);

  final items = await PaginatedFetch.fetchAll<PurchaseOrderModel>(
    fetchPage: (page) async {
      final dateRange = resolveExportTimeRange(
        filters.timeRangeOption,
        filters.customDateRange,
      );
      final query = PurchaseDocumentListQuery(
        page: page,
        limit: PaginatedFetch.defaultPageSize,
        documentType: PurchaseDocumentType.purchaseOrder.apiValue,
        status: _documentStatusFromFilterLabel(filters.selectedStatus),
        from: dateRange?.start.toUtc().toIso8601String(),
        to: dateRange?.end.toUtc().toIso8601String(),
        q: filters.searchQuery.trim().isEmpty
            ? null
            : filters.searchQuery.trim(),
      );
      final result = await service.fetchOrdersPage(query);
      return (
        items: _applyClientFilters(result.items, filters),
        totalPages: result.totalPages,
      );
    },
  );

  return ExportSheet(
    name: 'Purchase Orders',
    columns: const [
      ExportColumn(header: 'Party'),
      ExportColumn(header: 'Order No'),
      ExportColumn(header: 'Date', type: ExportCellType.date),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
      ExportColumn(header: 'Amount', type: ExportCellType.currency),
      ExportColumn(header: 'Balance', type: ExportCellType.currency),
      ExportColumn(header: 'Type'),
      ExportColumn(header: 'Status'),
    ],
    rows: [
      for (final order in items)
        ExportRow([
          order.partyName,
          order.orderNo,
          order.date,
          order.dueDate,
          order.amount,
          order.balanceDue,
          order.type,
          _statusLabel(order.status),
        ]),
    ],
  );
}

List<PurchaseOrderModel> _applyClientFilters(
  List<PurchaseOrderModel> orders,
  PurchaseOrderFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);

  return orders.where((order) {
    if (statusFilter != null && order.status != statusFilter) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        order.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        order.firm != filters.selectedFirm) {
      return false;
    }
    return true;
  }).toList();
}

PurchaseOrderStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Open' => PurchaseOrderStatus.open,
  'Order Completed' => PurchaseOrderStatus.orderCompleted,
  'Partially Received' => PurchaseOrderStatus.partiallyReceived,
  'Cancelled' => PurchaseOrderStatus.cancelled,
  _ => null,
};

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  'Open' => 'draft',
  'Order Completed' => 'finalized',
  _ => null,
};

String _statusLabel(PurchaseOrderStatus status) => switch (status) {
  PurchaseOrderStatus.open => 'Open',
  PurchaseOrderStatus.orderCompleted => 'Order Completed',
  PurchaseOrderStatus.partiallyReceived => 'Partially Received',
  PurchaseOrderStatus.cancelled => 'Cancelled',
};
