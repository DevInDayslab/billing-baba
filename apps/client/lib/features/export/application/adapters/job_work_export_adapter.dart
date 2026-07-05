import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/sales/application/job_work_service.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/models/requests/job_work_requests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ExportSheet> buildJobWorkExportSheet(WidgetRef ref) async {
  final service = await ref.read(jobWorkServiceProvider.future);

  final items = await PaginatedFetch.fetchAll(
    fetchPage: (page) async {
      final result = await service.fetchOrdersPage(
        JobWorkOrderListQuery(page: page, limit: PaginatedFetch.defaultPageSize),
      );
      return (items: result.items, totalPages: result.totalPages);
    },
  );

  return ExportSheet(
    name: 'Job Work Orders',
    columns: const [
      ExportColumn(header: 'Date', type: ExportCellType.date),
      ExportColumn(header: 'Party'),
      ExportColumn(header: 'Job No'),
      ExportColumn(header: 'Delivery Date', type: ExportCellType.date),
      ExportColumn(header: 'Status'),
      ExportColumn(header: 'Grand Total', type: ExportCellType.currency),
    ],
    rows: [
      for (final item in items)
        ExportRow([
          item.invoiceDate,
          item.party,
          item.jobId,
          item.deliveryDate,
          _statusLabel(item.status),
          item.grandTotal,
        ]),
    ],
  );
}

String _statusLabel(JobWorkOutStatus status) => switch (status) {
  JobWorkOutStatus.open => 'Open',
  JobWorkOutStatus.closed => 'Closed',
  JobWorkOutStatus.cancelled => 'Cancelled',
};
