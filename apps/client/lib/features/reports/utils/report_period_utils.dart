import 'package:flutter/material.dart';

const reportFinancialYearOptions = [
  '2021-2022',
  '2022-2023',
  '2023-2024',
  '2024-2025',
  '2025-2026',
  '2026-2027',
];

DateTimeRange financialYearToDateRange(String financialYear) {
  final parts = financialYear.split('-');
  final startYear = int.tryParse(parts.first) ?? DateTime.now().year;
  return DateTimeRange(
    start: DateTime(startYear, 4, 1),
    end: DateTime(startYear + 1, 3, 31),
  );
}

String defaultFinancialYearLabel() {
  final now = DateTime.now();
  final startYear = now.month >= 4 ? now.year : now.year - 1;
  final label = '$startYear-${startYear + 1}';
  return reportFinancialYearOptions.contains(label)
      ? label
      : reportFinancialYearOptions.last;
}
