import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/application/purchase_return_provider.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildPurchaseReturnExportSheet(WidgetRef ref) async {
  final filters = ref.read(purchaseReturnFiltersProvider);
  final service = await ref.read(purchaseServiceProvider.future);

  final items = await PaginatedFetch.fetchAll<PurchaseReturnModel>(
    fetchPage: (page) async {
      final dateRange = resolveExportTimeRange(
        filters.timeRangeOption,
        filters.customDateRange,
      );
      final query = PurchaseDocumentListQuery(
        page: page,
        limit: PaginatedFetch.defaultPageSize,
        documentType: PurchaseDocumentType.purchaseReturn.apiValue,
        status: _documentStatusFromFilterLabel(filters.selectedStatus),
        from: dateRange?.start.toUtc().toIso8601String(),
        to: dateRange?.end.toUtc().toIso8601String(),
        q: filters.searchQuery.trim().isEmpty
            ? null
            : filters.searchQuery.trim(),
      );
      final result = await service.fetchReturnsPage(query);
      return (
        items: _applyClientFilters(result.items, filters),
        totalPages: result.totalPages,
      );
    },
  );

  return ExportSheet(
    name: 'Debit Notes',
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.datetime),
      ExportColumn(header: 'Debit Note No'),
      ExportColumn(header: 'Party'),
      ExportColumn(header: 'Category'),
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
          item.debitNoteNo,
          item.partyName,
          item.categoryName,
          item.type,
          item.total,
          item.receivedPaid,
          item.balance,
          item.dueDate,
          _statusLabel(item.status),
        ]),
    ],
  );
}

List<PurchaseReturnModel> _applyClientFilters(
  List<PurchaseReturnModel> returns,
  PurchaseReturnFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);

  return returns.where((item) {
    if (statusFilter != null && item.status != statusFilter) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        item.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        item.firm != filters.selectedFirm) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        item.godown != filters.selectedGodown) {
      return false;
    }
    if (filters.selectedPayment != 'All Payment' &&
        item.paymentType != filters.selectedPayment) {
      return false;
    }
    return true;
  }).toList();
}

PurchaseBillStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Paid' => PurchaseBillStatus.paid,
  'Unpaid' => PurchaseBillStatus.unpaid,
  'Partial' => PurchaseBillStatus.partiallyPaid,
  'Overdue' => PurchaseBillStatus.overdue,
  'Cancelled' => PurchaseBillStatus.cancelled,
  _ => null,
};

String? _documentStatusFromFilterLabel(String label) => switch (label) {
  'Cancelled' => 'cancelled',
  'Draft' => 'draft',
  _ => null,
};

String _statusLabel(PurchaseBillStatus status) => switch (status) {
  PurchaseBillStatus.paid => 'Paid',
  PurchaseBillStatus.unpaid => 'Unpaid',
  PurchaseBillStatus.partiallyPaid => 'Partial',
  PurchaseBillStatus.overdue => 'Overdue',
  PurchaseBillStatus.cancelled => 'Cancelled',
};
