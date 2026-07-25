import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildPurchaseBillExportSheet(WidgetRef ref) async {
  final filters = ref.read(purchaseBillFiltersProvider);
  final search = ref.read(purchaseBillSearchQueryProvider);
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
        documentType: PurchaseDocumentType.purchaseBill.apiValue,
        status: _documentStatusFromFilterLabel(filters.selectedStatus),
        from: dateRange?.start.toUtc().toIso8601String(),
        to: dateRange?.end.toUtc().toIso8601String(),
        q: search.trim().isEmpty ? null : search.trim(),
      );
      final result = await service.fetchBillsPage(query);
      return (
        items: _applyClientFilters(result.items, filters),
        totalPages: result.totalPages,
      );
    },
  );

  return ExportSheet(
    name: 'Purchase Bills',
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
          _statusLabel(bill.status),
          bill.amount,
          bill.balanceDue,
          bill.dueDate,
        ]),
    ],
  );
}

List<PurchaseBillModel> _applyClientFilters(
  List<PurchaseBillModel> bills,
  PurchaseBillFiltersState filters,
) {
  final paymentStatus = _paymentStatusFromFilterLabel(filters.selectedStatus);
  return bills.where((bill) {
    if (paymentStatus != null && bill.status != paymentStatus) return false;
    if (filters.selectedUser != 'All Users' &&
        bill.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        bill.firm != filters.selectedFirm) {
      return false;
    }
    return true;
  }).toList();
}

PurchaseBillStatus? _paymentStatusFromFilterLabel(String label) =>
    switch (label) {
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
