import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';

/// Resolves time range filters for export queries (mirrors list providers).
DateTimeRange? resolveExportTimeRange(
  TimeRangeOption option,
  DateTimeRange? custom,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

  return switch (option) {
    TimeRangeOption.allTime => null,
    TimeRangeOption.today => DateTimeRange(start: today, end: endOfDay),
    TimeRangeOption.thisWeek => DateTimeRange(
      start: today.subtract(Duration(days: today.weekday % 7)),
      end: endOfDay,
    ),
    TimeRangeOption.thisMonth => DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999),
    ),
    TimeRangeOption.thisYear => DateTimeRange(
      start: DateTime(now.year),
      end: DateTime(now.year, 12, 31, 23, 59, 59, 999),
    ),
    TimeRangeOption.custom => custom,
  };
}
