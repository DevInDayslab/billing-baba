import 'package:flutter/material.dart';

/// Summary metric shown in the three stat cards at the top of a mobile report.
class MobileReportSummaryMetric {
  const MobileReportSummaryMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}

/// A single value column inside a mobile report list card.
class MobileReportRowColumn {
  const MobileReportRowColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}

/// One list row in a mobile report (party / transaction style).
class MobileReportRow {
  const MobileReportRow({
    required this.title,
    required this.reference,
    this.dateTime,
    required this.columns,
  });

  final String title;
  final String reference;
  final DateTime? dateTime;
  final List<MobileReportRowColumn> columns;
}

/// Fully resolved data for rendering a mobile report screen.
class MobileReportViewData {
  const MobileReportViewData({
    required this.summaryMetrics,
    required this.rows,
    required this.totalCount,
    this.usingMock = false,
    this.filterChips = const [],
    this.exportHeaders = const [],
    this.exportRows = const [],
  });

  final List<MobileReportSummaryMetric> summaryMetrics;
  final List<MobileReportRow> rows;
  final int totalCount;
  final bool usingMock;
  final List<String> filterChips;
  final List<String> exportHeaders;
  final List<List<String>> exportRows;

  static const empty = MobileReportViewData(
    summaryMetrics: [
      MobileReportSummaryMetric(label: 'No of Txns', value: '0'),
      MobileReportSummaryMetric(label: 'Total', value: '₹ 0.00'),
      MobileReportSummaryMetric(label: 'Balance Due', value: '₹ 0.00'),
    ],
    rows: [],
    totalCount: 0,
  );
}
