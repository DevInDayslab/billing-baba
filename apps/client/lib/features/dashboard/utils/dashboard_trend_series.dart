import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/shared/utils/reporting_period_range.dart';
import 'package:flutter/material.dart';

/// Builds dense dashboard trend series for charts (including zero-filled empty states).
abstract final class DashboardTrendSeries {
  static const _todayHours = [6, 9, 12, 15, 18, 21];
  static const _maxDailyBuckets = 366;
  static const _allTimeMonthCount = 24;

  /// Ordered bucket dates for [period] (and optional custom range).
  static List<DateTime> buildTrendBuckets(
    DashboardPeriod period, {
    DateTime? from,
    DateTime? to,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final today = DateTime(clock.year, clock.month, clock.day);

    return switch (period) {
      DashboardPeriod.today => _todayHours
          .map(
            (hour) => DateTime(today.year, today.month, today.day, hour),
          )
          .toList(),
      DashboardPeriod.thisWeek => _dailyBuckets(
        dateRangeForDashboardPeriod(period, from: from, to: to),
      ),
      DashboardPeriod.thisMonth => _dailyBuckets(
        dateRangeForDashboardPeriod(period, from: from, to: to),
      ),
      DashboardPeriod.thisYear => _monthlyBucketsForYear(clock.year),
      DashboardPeriod.allTime => _recentMonthlyBuckets(clock, _allTimeMonthCount),
      DashboardPeriod.custom => _customBuckets(from ?? today, to ?? today),
    };
  }

  /// Maps [sparse] amounts onto [buckets]; missing buckets default to 0.
  static List<DashboardTrendPointModel> mergeTrendPoints(
    List<DateTime> buckets,
    List<DashboardTrendPointModel> sparse,
    DashboardPeriod period,
  ) {
    if (buckets.isEmpty) return const [];

    final amountsByKey = <DateTime, double>{};
    for (final point in sparse) {
      final key = _bucketKey(point.date, period);
      amountsByKey[key] = (amountsByKey[key] ?? 0) + point.amount;
    }

    return buckets
        .map(
          (bucket) => DashboardTrendPointModel(
            date: bucket,
            amount: amountsByKey[_bucketKey(bucket, period)] ?? 0,
          ),
        )
        .toList();
  }

  /// Later sources override earlier ones for the same bucket (offline-first: pass local last).
  static List<DashboardTrendPointModel> combineSparseTrendSources(
    List<List<DashboardTrendPointModel>> sources,
    DashboardPeriod period,
  ) {
    final merged = <DateTime, double>{};
    for (final source in sources) {
      for (final point in source) {
        final key = _bucketKey(point.date, period);
        merged[key] = point.amount;
      }
    }
    return merged.entries
        .map(
          (entry) => DashboardTrendPointModel(
            date: entry.key,
            amount: entry.value,
          ),
        )
        .toList();
  }

  /// Dense trend for charts: full period buckets with merged sparse amounts.
  static List<DashboardTrendPointModel> normalizeDashboardTrend(
    List<DashboardTrendPointModel> sparse,
    DashboardQuery query, {
    DateTime? now,
  }) {
    final buckets = buildTrendBuckets(
      query.period,
      from: query.from,
      to: query.to,
      now: now,
    );
    return mergeTrendPoints(buckets, sparse, query.period);
  }

  static List<DateTime> _dailyBuckets(DateTimeRange range) {
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (index) => start.add(Duration(days: index)));
  }

  static List<DateTime> _monthlyBucketsForYear(int year) {
    return List.generate(
      12,
      (index) => DateTime(year, index + 1),
    );
  }

  static List<DateTime> _recentMonthlyBuckets(DateTime now, int monthCount) {
    final anchor = DateTime(now.year, now.month);
    return List.generate(monthCount, (index) {
      final offset = monthCount - 1 - index;
      return DateTime(anchor.year, anchor.month - offset);
    });
  }

  static List<DateTime> _customBuckets(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (end.isBefore(start)) return [start];

    final dayCount = end.difference(start).inDays + 1;
    if (dayCount <= _maxDailyBuckets) {
      return List.generate(dayCount, (index) => start.add(Duration(days: index)));
    }

    final months = <DateTime>[];
    var cursor = DateTime(start.year, start.month);
    final endMonth = DateTime(end.year, end.month);
    while (!cursor.isAfter(endMonth)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return months;
  }

  static DateTime _bucketKey(DateTime date, DashboardPeriod period) {
    return switch (period) {
      DashboardPeriod.today => DateTime(
        date.year,
        date.month,
        date.day,
        date.hour,
      ),
      DashboardPeriod.thisYear || DashboardPeriod.allTime => DateTime(
        date.year,
        date.month,
      ),
      _ => DateTime(date.year, date.month, date.day),
    };
  }
}
