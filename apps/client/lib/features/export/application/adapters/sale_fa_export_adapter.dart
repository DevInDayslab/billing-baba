import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/sale_fa_service.dart';
import 'package:billing_baba/features/sales/models/requests/sale_fa_requests.dart';
import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:billing_baba/features/sales/providers/sale_fa_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildSaleFaExportSheet(WidgetRef ref) async {
  final filters = ref.read(saleFaFiltersProvider);
  final search = ref.read(saleFaSearchQueryProvider);
  final service = await ref.read(saleFaServiceProvider.future);

  final items = await PaginatedFetch.fetchAll(
    fetchPage: (page) async {
      final dateRange = resolveExportTimeRange(
        filters.timeRangeOption,
        filters.customDateRange,
      );
      final query = SaleFaListQuery(
        page: page,
        limit: PaginatedFetch.defaultPageSize,
        status: _statusFromFilterLabel(filters.selectedStatus),
        from: dateRange?.start.toUtc().toIso8601String().split('T').first,
        to: dateRange?.end.toUtc().toIso8601String().split('T').first,
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
    name: 'Sale FA',
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.date),
      ExportColumn(header: 'Invoice No'),
      ExportColumn(header: 'Party Name'),
      ExportColumn(header: 'Transaction Type'),
      ExportColumn(header: 'Payment Type'),
      ExportColumn(header: 'Amount', type: ExportCellType.currency),
      ExportColumn(header: 'Balance Due', type: ExportCellType.currency),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
      ExportColumn(header: 'Status'),
    ],
    rows: [
      for (final record in items)
        ExportRow([
          record.createdAt,
          record.invoiceNo,
          record.partyName,
          'Sale FA',
          record.paymentType,
          record.amount,
          record.balanceDue,
          record.dueDate,
          _statusLabel(record.status),
        ]),
    ],
  );
}

List<SaleFaModel> _applyClientFilters(
  List<SaleFaModel> records,
  SaleFaFiltersState filters,
) {
  final statusFilter = _paymentStatusFromFilterLabel(filters.selectedStatus);
  return records.where((record) {
    if (statusFilter != null && record.status != statusFilter) return false;
    if (filters.selectedUser != 'All Users' && record.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' && record.firm != filters.selectedFirm) {
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

SaleFaStatus? _paymentStatusFromFilterLabel(String label) =>
    switch (label) {
      'Paid' => SaleFaStatus.paid,
      'Unpaid' => SaleFaStatus.unpaid,
      'Partially Paid' => SaleFaStatus.partiallyPaid,
      'Partial' => SaleFaStatus.partiallyPaid,
      'Overdue' => SaleFaStatus.overdue,
      'Cancelled' => SaleFaStatus.cancelled,
      _ => null,
    };

String _statusLabel(SaleFaStatus status) => switch (status) {
  SaleFaStatus.paid => 'Paid',
  SaleFaStatus.unpaid => 'Unpaid',
  SaleFaStatus.partiallyPaid => 'Partial',
  SaleFaStatus.overdue => 'Overdue',
  SaleFaStatus.cancelled => 'Cancelled',
};
