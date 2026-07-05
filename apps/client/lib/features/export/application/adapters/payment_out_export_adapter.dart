import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_time_range.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/providers/payment_out_provider.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildPaymentOutExportSheet(WidgetRef ref) async {
  final filters = ref.read(paymentOutFiltersProvider);
  final service = await ref.read(purchaseServiceProvider.future);

  final items = await PaginatedFetch.fetchAll(
    fetchPage: (page) async {
      final dateRange = resolveExportTimeRange(
        filters.timeRangeOption,
        filters.customDateRange,
      );
      final query = PaymentListQuery(
        page: page,
        limit: PaginatedFetch.defaultPageSize,
        direction: 'paid',
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

  return ExportSheet(
    name: 'Payment Out',
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.datetime),
      ExportColumn(header: 'Ref. No.'),
      ExportColumn(header: 'Party Name'),
      ExportColumn(header: 'Payment Type'),
      ExportColumn(header: 'Status'),
      ExportColumn(header: 'Total', type: ExportCellType.currency),
      ExportColumn(header: 'Paid', type: ExportCellType.currency),
    ],
    rows: [
      for (final record in items)
        ExportRow([
          record.date,
          record.receiptNo,
          record.partyName,
          record.paymentType,
          _statusLabel(record.status),
          record.totalAmount,
          record.paidAmount,
        ]),
    ],
  );
}

List<PaymentOutModel> _applyClientFilters(
  List<PaymentOutModel> records,
  PaymentOutFiltersState filters,
) {
  return records.where((record) {
    if (filters.selectedUser != 'All Users' && record.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' && record.firm != filters.selectedFirm) {
      return false;
    }
    return true;
  }).toList();
}

String _statusLabel(PaymentOutStatus status) => switch (status) {
  PaymentOutStatus.paid => 'Paid',
  PaymentOutStatus.pending => 'Pending',
  PaymentOutStatus.cancelled => 'Cancelled',
};
