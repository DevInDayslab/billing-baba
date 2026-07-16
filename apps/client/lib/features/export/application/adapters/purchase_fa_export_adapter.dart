import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_service.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_fa_requests.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildPurchaseFaExportSheet(WidgetRef ref) async {
  final filters = ref.read(purchaseFaFiltersProvider);
  final search = ref.read(purchaseFaSearchQueryProvider);
  final service = await ref.read(purchaseFaServiceProvider.future);

  final items = await PaginatedFetch.fetchAll(
    fetchPage: (page) async {
      final dateRange = resolveExportTimeRange(
        filters.timeRangeOption,
        filters.customDateRange,
      );
      final query = PurchaseFaListQuery(
        page: page,
        limit: PaginatedFetch.defaultPageSize,
        status: _statusFromFilterLabel(filters.selectedStatus),
        from: dateRange?.start.toUtc().toIso8601String(),
        to: dateRange?.end.toUtc().toIso8601String(),
        q: search.trim().isEmpty ? null : search.trim(),
      );
      final result = await service.fetchBatchesPage(query);
      return (
        items: _applyClientFilters(result.items, filters),
        totalPages: result.totalPages,
      );
    },
  );

  return ExportSheet(
    name: 'Fixed Asset Purchases',
    columns: const [
      ExportColumn(header: 'Party'),
      ExportColumn(header: 'Invoice No'),
      ExportColumn(header: 'Date', type: ExportCellType.date),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
      ExportColumn(header: 'Amount', type: ExportCellType.currency),
      ExportColumn(header: 'Balance', type: ExportCellType.currency),
      ExportColumn(header: 'Payment Type'),
      ExportColumn(header: 'Status'),
    ],
    rows: [
      for (final record in items)
        ExportRow([
          record.partyName,
          record.invoiceNo,
          record.date,
          record.dueDate,
          record.amount,
          record.balanceDue,
          record.paymentType,
          record.status.name,
        ]),
    ],
  );
}

List<PurchaseFaModel> _applyClientFilters(
  List<PurchaseFaModel> records,
  PurchaseFaFiltersState filters,
) {
  final statusFilter = _paymentStatusFromFilterLabel(filters.selectedStatus);
  return records.where((record) {
    if (statusFilter != null && record.status != statusFilter) return false;
    if (filters.selectedUser != 'All Users' &&
        record.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        record.firm != filters.selectedFirm) {
      return false;
    }
    return true;
  }).toList();
}

String? _statusFromFilterLabel(String label) => switch (label) {
  'Paid' => 'paid',
  'Unpaid' => 'unpaid',
  'Partially Paid' => 'partially_paid',
  'Partial' => 'partially_paid',
  'Overdue' => 'overdue',
  'Cancelled' => 'cancelled',
  _ => null,
};

PurchaseFaStatus? _paymentStatusFromFilterLabel(String label) =>
    switch (label) {
      'Paid' => PurchaseFaStatus.paid,
      'Unpaid' => PurchaseFaStatus.unpaid,
      'Partially Paid' => PurchaseFaStatus.partiallyPaid,
      'Partial' => PurchaseFaStatus.partiallyPaid,
      'Overdue' => PurchaseFaStatus.overdue,
      'Cancelled' => PurchaseFaStatus.cancelled,
      _ => null,
    };
