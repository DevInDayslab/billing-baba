import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/sales/data/job_work_repository.dart';
import 'package:billing_baba/features/sales/models/dto/job_work_order_dto.dart';
import 'package:billing_baba/features/sales/models/requests/job_work_requests.dart';
import 'package:billing_baba/shared/utils/reporting_period_range.dart';
import 'package:flutter/material.dart';

bool _inReportDateRange(DateTime date, DateTimeRange range) {
  final normalized = DateTime(date.year, date.month, date.day);
  final start = DateTime(
    range.start.year,
    range.start.month,
    range.start.day,
  );
  final end = DateTime(range.end.year, range.end.month, range.end.day);
  return !normalized.isBefore(start) && !normalized.isAfter(end);
}

class ConsumptionReportBuildResult {
  const ConsumptionReportBuildResult({
    required this.rows,
    required this.meta,
    required this.totalQtyConsumed,
    required this.totalAmount,
  });

  final List<ReportConsumptionRow> rows;
  final ReportPaginationMeta meta;
  final double totalQtyConsumed;
  final double totalAmount;
}

Future<ConsumptionReportBuildResult?> buildConsumptionReportFromJobWork({
  required JobWorkRepository? repository,
  required ReportQuery query,
  required Future<Map<String, String>> Function() itemNameById,
}) async {
  if (repository == null) return null;

  final range = dateRangeForReportQuery(query);
  final q = query.q?.trim().toLowerCase();
  final itemNames = await itemNameById();

  final allOrders = <JobWorkOrderDto>[];
  var page = 1;
  const limit = 100;

  while (true) {
    final response = await repository.listOrders(
      JobWorkOrderListQuery(page: page, limit: limit),
    );
    if (response.orders.isEmpty) break;
    allOrders.addAll(response.orders);
    final total = response.meta.total;
    if (response.orders.length < limit || page * limit >= total) break;
    page++;
  }

  final rows = <ReportConsumptionRow>[];

  for (final order in allOrders) {
    if (order.status == 'cancelled') continue;
    final date = DateTime.tryParse(order.orderDate);
    if (date == null || !_inReportDateRange(date, range)) continue;

    final refNo = order.jobNumber ?? '';
    final detailed = order.rawMaterials.isNotEmpty
        ? order
        : await repository.getOrder(order.id);

    for (final material in detailed.rawMaterials) {
      final itemName = itemNames[material.itemId] ?? 'Unknown item';
      if (q != null && q.isNotEmpty && !itemName.toLowerCase().contains(q)) {
        continue;
      }

      rows.add(
        ReportConsumptionRow(
          date: date,
          refNo: refNo,
          itemName: itemName,
          quantity: double.tryParse(material.quantity) ?? 0,
          value: double.tryParse(material.lineTotal) ?? 0,
        ),
      );
    }
  }

  rows.sort((a, b) => b.date.compareTo(a.date));

  var totalQty = 0.0;
  var totalAmount = 0.0;
  for (final row in rows) {
    totalQty += row.quantity;
    totalAmount += row.value;
  }

  final reportPage = query.page < 1 ? 1 : query.page;
  final reportLimit = query.limit < 1 ? 20 : query.limit;
  final start = (reportPage - 1) * reportLimit;
  final pageRows = start >= rows.length
      ? const <ReportConsumptionRow>[]
      : rows.skip(start).take(reportLimit).toList();
  final totalPages = rows.isEmpty ? 1 : (rows.length / reportLimit).ceil();

  return ConsumptionReportBuildResult(
    rows: pageRows,
    totalQtyConsumed: totalQty,
    totalAmount: totalAmount,
    meta: ReportPaginationMeta(
      page: reportPage,
      limit: reportLimit,
      total: rows.length,
      totalPages: totalPages,
    ),
  );
}
