import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/providers/payment_in_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildPaymentInExportSheet(WidgetRef ref) async {
  final filters = ref.read(paymentInFiltersProvider);
  final service = await ref.read(salesServiceProvider.future);

  final items = await PaginatedFetch.fetchAll(
    fetchPage: (page) async {
      final dateRange = resolveExportTimeRange(
        filters.timeRangeOption,
        filters.customDateRange,
      );
      final query = PaymentListQuery(
        page: page,
        limit: PaginatedFetch.defaultPageSize,
        direction: 'received',
        from: dateRange?.start.toUtc().toIso8601String(),
        to: dateRange?.end.toUtc().toIso8601String(),
      );
      final result = await service.fetchPaymentsPage(query);
      return (
        items: _applyClientFilters(result.items, filters),
        totalPages: result.totalPages,
      );
    },
  );

  return _paymentInSheet(items);
}

ExportSheet _paymentInSheet(List<PaymentInModel> items) {
  return ExportSheet(
    name: 'Payment In',
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.datetime),
      ExportColumn(header: 'Ref. No.'),
      ExportColumn(header: 'Party Name'),
      ExportColumn(header: 'Payment Type'),
      ExportColumn(header: 'Status'),
      ExportColumn(header: 'Total', type: ExportCellType.currency),
      ExportColumn(header: 'Received', type: ExportCellType.currency),
    ],
    rows: [
      for (final record in items)
        ExportRow([
          record.date,
          record.receiptNo,
          record.partyName,
          record.paymentType,
          if (record.status == PaymentInStatus.paid)
            'Paid'
          else if (record.status == PaymentInStatus.partial)
            'Partial'
          else
            'Unused',
          record.totalAmount,
          record.receivedAmount,
        ]),
    ],
  );
}

List<PaymentInModel> _applyClientFilters(
  List<PaymentInModel> records,
  PaymentInFiltersState filters,
) {
  final statusFilter = switch (filters.selectedStatus) {
    'Paid' => PaymentInStatus.paid,
    'Partial' => PaymentInStatus.partial,
    'Unused' => PaymentInStatus.unused,
    _ => null,
  };

  return records.where((record) {
    if (statusFilter != null && record.status != statusFilter) return false;
    if (filters.selectedFirm != 'All Firms' &&
        record.firm != filters.selectedFirm) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        record.user != filters.selectedUser) {
      return false;
    }
    return true;
  }).toList();
}
