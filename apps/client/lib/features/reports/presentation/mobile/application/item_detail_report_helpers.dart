import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/item_detail_display_row.dart';
import 'package:flutter/material.dart';

typedef _DayAggregate = ({double sale, double purchase});

List<ItemDetailDisplayRow> buildItemDetailDisplayRows({
  required List<ReportItemDetailRow> apiRows,
  required DateTimeRange range,
  required bool hideInactiveDates,
}) {
  final byDate = <DateTime, _DayAggregate>{};

  for (final row in apiRows) {
    final day = DateTime(row.date.year, row.date.month, row.date.day);
    final current = byDate[day] ?? (sale: 0, purchase: 0);
    if (row.type == 'Sale') {
      byDate[day] = (
        sale: current.sale + row.quantity,
        purchase: current.purchase,
      );
    } else {
      byDate[day] = (
        sale: current.sale,
        purchase: current.purchase + row.quantity,
      );
    }
  }

  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(range.end.year, range.end.month, range.end.day);

  final days = <DateTime>[];
  if (hideInactiveDates) {
    days.addAll(
      byDate.keys.where((day) => !day.isBefore(start) && !day.isAfter(end)),
    );
    days.sort();
  } else {
    var current = start;
    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
  }

  final rows = <ItemDetailDisplayRow>[];
  var closing = 0.0;
  for (final day in days) {
    final aggregate = byDate[day] ?? (sale: 0, purchase: 0);
    closing += aggregate.purchase - aggregate.sale;
    rows.add(
      ItemDetailDisplayRow(
        date: day,
        saleQty: aggregate.sale,
        purchaseQty: aggregate.purchase,
        adjustQty: 0,
        closingQty: closing,
      ),
    );
  }

  return rows;
}
