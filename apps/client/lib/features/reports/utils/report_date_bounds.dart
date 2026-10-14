import 'package:flutter/material.dart';

/// Latest calendar day users may select in report filters (today, local time).
DateTime reportLastSelectableDay() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Clamps a report range so neither bound is after [reportLastSelectableDay].
DateTimeRange clampReportDateRange(DateTimeRange range) {
  final last = reportLastSelectableDay();
  var start = _dateOnly(range.start);
  var end = _dateOnly(range.end);

  if (end.isAfter(last)) end = last;
  if (start.isAfter(last)) start = last;
  if (start.isAfter(end)) start = end;

  return DateTimeRange(start: start, end: end);
}

/// Inclusive UI range → API bounds (`from` < `to`, exclusive end day).
(DateTime from, DateTime to) apiDateBoundsFromInclusiveRange(DateTimeRange range) {
  final clamped = clampReportDateRange(range);
  final start = _dateOnly(clamped.start);
  final endExclusive = _dateOnly(clamped.end).add(const Duration(days: 1));
  if (!start.isBefore(endExclusive)) {
    return (start, start.add(const Duration(days: 1)));
  }
  return (start, endExclusive);
}
