import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:flutter/material.dart';

/// Inclusive calendar-day range for dashboard and report aggregations.
DateTimeRange dateRangeForDashboardPeriod(
  DashboardPeriod period, {
  DateTime? from,
  DateTime? to,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return switch (period) {
    DashboardPeriod.today => DateTimeRange(start: today, end: today),
    DashboardPeriod.thisWeek => () {
      final start = today.subtract(Duration(days: today.weekday - 1));
      return DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 6)),
      );
    }(),
    DashboardPeriod.thisMonth => ReportFiltersState.currentMonthDateRange(),
    DashboardPeriod.thisYear => DateTimeRange(
      start: DateTime(now.year),
      end: DateTime(now.year, 12, 31),
    ),
    DashboardPeriod.allTime => DateTimeRange(
      start: DateTime(2000),
      end: today,
    ),
    DashboardPeriod.custom => DateTimeRange(
      start: from ?? today,
      end: to ?? today,
    ),
  };
}

/// Resolves [ReportQuery] to an inclusive calendar-day range.
DateTimeRange dateRangeForReportQuery(ReportQuery query) {
  if (query.period == ReportPeriod.custom && query.from != null && query.to != null) {
    final start = DateTime(
      query.from!.year,
      query.from!.month,
      query.from!.day,
    );
    final end = DateTime(query.to!.year, query.to!.month, query.to!.day);
    return DateTimeRange(start: start, end: end);
  }

  return ReportFiltersState(
    period: query.period,
    customDateRange: query.from != null && query.to != null
        ? DateTimeRange(start: query.from!, end: query.to!)
        : null,
  ).effectiveDateRange;
}

bool isCalendarDayInRange(DateTime day, DateTimeRange range) {
  final normalized = DateTime(day.year, day.month, day.day);
  final start = DateTime(
    range.start.year,
    range.start.month,
    range.start.day,
  );
  final end = DateTime(range.end.year, range.end.month, range.end.day);
  return !normalized.isBefore(start) && !normalized.isAfter(end);
}

DateTime? parseDocumentCalendarDay(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return DateTime.tryParse(trimmed) ??
      DateTime.tryParse('${trimmed}T00:00:00.000');
}
