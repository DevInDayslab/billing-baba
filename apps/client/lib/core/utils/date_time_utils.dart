import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shared date/time helpers for API persistence and local display.
abstract final class DateTimeUtils {
  static final displayDateTime = DateFormat('dd/MM/yyyy, hh:mm a');
  static final displayDate = DateFormat('dd/MM/yyyy');

  /// Combines a calendar date with an optional time-of-day in local time.
  static DateTime mergeDateAndTime({
    required DateTime? date,
    TimeOfDay? time,
  }) {
    final resolvedDate = date ?? DateTime.now();
    final resolvedTime = time ?? TimeOfDay.fromDateTime(DateTime.now());
    return DateTime(
      resolvedDate.year,
      resolvedDate.month,
      resolvedDate.day,
      resolvedTime.hour,
      resolvedTime.minute,
    );
  }

  /// Parses an API ISO-8601 timestamp and normalizes to local time.
  static DateTime parseApiDateTime(String? value, {DateTime? fallback}) {
    if (value == null || value.trim().isEmpty) {
      return fallback ?? DateTime.now();
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return fallback ?? DateTime.now();
    }

    return parsed.toLocal();
  }

  /// Serializes a local [dateTime] to UTC ISO-8601 for API writes.
  static String toApiIso(DateTime dateTime) => dateTime.toUtc().toIso8601String();

  static String formatDisplayDateTime(DateTime dateTime) =>
      displayDateTime.format(dateTime.toLocal());

  static String formatDisplayDate(DateTime dateTime) =>
      displayDate.format(dateTime.toLocal());

  static String? formatDisplayDateTimeOrNull(DateTime? dateTime) =>
      dateTime == null ? null : formatDisplayDateTime(dateTime);

  static String? formatDisplayDateOrNull(DateTime? dateTime) =>
      dateTime == null ? null : formatDisplayDate(dateTime);
}
