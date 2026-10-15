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

ReportManufacturingRow _toManufacturingRow(JobWorkOrderDto order) {
  final date =
      DateTime.tryParse(order.orderDate) ??
      DateTime.fromMillisecondsSinceEpoch(0);
  return ReportManufacturingRow(
    date: date,
    refNo: order.jobNumber ?? '',
    itemName: order.finishedGoodName,
    quantity: double.tryParse(order.finishedGoodQuantity) ?? 0,
    cost: double.tryParse(order.grandTotal) ?? 0,
  );
}

class ManufacturingReportBuildResult {
  const ManufacturingReportBuildResult({
    required this.rows,
    required this.meta,
    required this.totalQtyManufactured,
    required this.totalAmount,
  });

  final List<ReportManufacturingRow> rows;
  final ReportPaginationMeta meta;
  final double totalQtyManufactured;
  final double totalAmount;
}

Future<ManufacturingReportBuildResult?> buildManufacturingReportFromJobWork({
  required JobWorkRepository? repository,
  required ReportQuery query,
}) async {
  if (repository == null) return null;

  final range = dateRangeForReportQuery(query);
  final q = query.q?.trim().toLowerCase();

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

  final rows = <ReportManufacturingRow>[];
  for (final order in allOrders) {
    if (order.status == 'cancelled') continue;
    final date = DateTime.tryParse(order.orderDate);
    if (date == null || !_inReportDateRange(date, range)) continue;

    final itemName = order.finishedGoodName;
    if (q != null && q.isNotEmpty && !itemName.toLowerCase().contains(q)) {
      continue;
    }

    rows.add(_toManufacturingRow(order));
  }

  rows.sort((a, b) => b.date.compareTo(a.date));

  var totalQty = 0.0;
  var totalAmount = 0.0;
  for (final row in rows) {
    totalQty += row.quantity;
    totalAmount += row.cost;
  }

  final reportPage = query.page < 1 ? 1 : query.page;
  final reportLimit = query.limit < 1 ? 20 : query.limit;
  final start = (reportPage - 1) * reportLimit;
  final pageRows = start >= rows.length
      ? const <ReportManufacturingRow>[]
      : rows.skip(start).take(reportLimit).toList();
  final totalPages = rows.isEmpty ? 1 : (rows.length / reportLimit).ceil();

  return ManufacturingReportBuildResult(
    rows: pageRows,
    totalQtyManufactured: totalQty,
    totalAmount: totalAmount,
    meta: ReportPaginationMeta(
      page: reportPage,
      limit: reportLimit,
      total: rows.length,
      totalPages: totalPages,
    ),
  );
}
