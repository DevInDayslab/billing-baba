import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_subsection_registry.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/mobile_report_view_model.dart';
import 'package:flutter/material.dart';

/// Demo rows for mobile report previews when the API is unreachable / empty.
///
/// Values are shaped to match each subsection's [MobileReportSubsectionConfig]
/// column labels so Sale, Day Book, GST, etc. don't all look identical.
abstract final class MobileReportMockData {
  static const saleReport = MobileReportViewData(
    summaryMetrics: [
      MobileReportSummaryMetric(label: 'No of Txns', value: '20'),
      MobileReportSummaryMetric(label: 'Total Sale', value: '₹ 27,503.00'),
      MobileReportSummaryMetric(
        label: 'Balance Due',
        value: '₹ 25,256.00',
        valueColor: Color(0xFF2E7D32),
      ),
    ],
    rows: [
      MobileReportRow(
        title: 'Arpit',
        reference: 'SALE 51',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 295.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 0.00'),
          MobileReportRowColumn(label: 'Due Date', value: '28 JUL, 26'),
        ],
      ),
      MobileReportRow(
        title: 'Saksham',
        reference: 'SALE 50',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 1,180.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 0.00'),
          MobileReportRowColumn(label: 'Due Date', value: '28 JUL, 26'),
        ],
      ),
      MobileReportRow(
        title: 'Cash Sale',
        reference: 'SALE 49',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 1,180.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 0.00'),
          MobileReportRowColumn(label: 'Due Date', value: '28 JUL, 26'),
        ],
      ),
      MobileReportRow(
        title: 'Cash Sale',
        reference: 'SALE 48',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 1,180.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 0.00'),
          MobileReportRowColumn(label: 'Due Date', value: '28 JUL, 26'),
        ],
      ),
      MobileReportRow(
        title: 'Cash Sale',
        reference: 'SALE 47',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 1,180.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 0.00'),
          MobileReportRowColumn(label: 'Due Date', value: '28 JUL, 26'),
        ],
      ),
    ],
    totalCount: 20,
    usingMock: true,
    filterChips: [
      'Txns Type - Sale',
    ],
    exportHeaders: ['Party', 'Reference', 'Amount', 'Balance', 'Due Date'],
    exportRows: [
      ['Arpit', 'SALE 51', '295.00', '0.00', '28 JUL, 26'],
      ['Saksham', 'SALE 50', '1180.00', '0.00', '28 JUL, 26'],
    ],
  );

  static const purchaseReport = MobileReportViewData(
    summaryMetrics: [
      MobileReportSummaryMetric(label: 'No of Txns', value: '12'),
      MobileReportSummaryMetric(label: 'Total Purchase', value: '₹ 48,720.00'),
      MobileReportSummaryMetric(
        label: 'Balance Due',
        value: '₹ 12,450.00',
        valueColor: Color(0xFFC62828),
      ),
    ],
    rows: [
      MobileReportRow(
        title: 'Sharma Traders',
        reference: 'PURCHASE 18',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 8,260.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 2,000.00'),
          MobileReportRowColumn(label: 'Date', value: '30 JUL, 26'),
        ],
      ),
      MobileReportRow(
        title: 'Local Wholesaler',
        reference: 'PURCHASE 17',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 4,720.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 0.00'),
          MobileReportRowColumn(label: 'Date', value: '28 JUL, 26'),
        ],
      ),
      MobileReportRow(
        title: 'Metro Supplies',
        reference: 'PURCHASE 16',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 15,980.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 5,450.00'),
          MobileReportRowColumn(label: 'Date', value: '25 JUL, 26'),
        ],
      ),
      MobileReportRow(
        title: 'Cash Purchase',
        reference: 'PURCHASE 15',
        columns: [
          MobileReportRowColumn(label: 'Amount', value: '₹ 1,180.00'),
          MobileReportRowColumn(label: 'Balance', value: '₹ 0.00'),
          MobileReportRowColumn(label: 'Date', value: '24 JUL, 26'),
        ],
      ),
    ],
    totalCount: 12,
    usingMock: true,
    filterChips: [
      'Txns Type - Purchase',
    ],
    exportHeaders: ['Party', 'Reference', 'Amount', 'Balance', 'Date'],
    exportRows: [
      ['Sharma Traders', 'PURCHASE 18', '8260.00', '2000.00', '30 JUL, 26'],
      ['Local Wholesaler', 'PURCHASE 17', '4720.00', '0.00', '28 JUL, 26'],
    ],
  );

  /// Builds demo rows tailored to a report subsection config.
  static MobileReportViewData forConfig(MobileReportSubsectionConfig config) {
    if (config.title == 'Sale Report') return saleReport;
    if (config.title == 'Purchase Report') return purchaseReport;

    final sampleTitles = [
      'Arpit',
      'Saksham',
      'Cash Sale',
      'Sharma Traders',
      'Metro Supplies',
    ];

    final rows = <MobileReportRow>[
      for (var i = 0; i < sampleTitles.length; i++)
        MobileReportRow(
          title: sampleTitles[i],
          reference: '${config.referencePrefix} ${50 - i}',
          columns: [
            for (var c = 0; c < config.columnLabels.length; c++)
              MobileReportRowColumn(
                label: config.columnLabels[c],
                value: _sampleValue(config.columnLabels[c], i),
              ),
          ],
        ),
    ];

    return MobileReportViewData(
      summaryMetrics: [
        for (var i = 0; i < config.summaryLabels.length; i++)
          MobileReportSummaryMetric(
            label: config.summaryLabels[i],
            value: i == 0 ? '${rows.length}' : _sampleSummaryValue(i),
            valueColor: i == 2 ? const Color(0xFF2E7D32) : null,
          ),
      ],
      rows: rows,
      totalCount: rows.length,
      usingMock: true,
      exportHeaders: [
        'Name',
        'Reference',
        ...config.columnLabels,
      ],
      exportRows: [
        for (final row in rows)
          [
            row.title,
            row.reference,
            ...row.columns.map((column) => column.value),
          ],
      ],
    );
  }

  static String _sampleSummaryValue(int index) {
    return switch (index) {
      1 => '₹ 25,080.00',
      2 => '₹ 4,590.00',
      _ => '0',
    };
  }

  static String _sampleValue(String label, int index) {
    final lower = label.toLowerCase();
    final moneySamples = [
      '₹ 1,180.00',
      '₹ 2,950.00',
      '₹ 4,720.00',
      '₹ 890.00',
      '₹ 15,340.00',
    ];
    final qtySamples = ['12', '5', '28', '3', '40'];
    final dateSamples = [
      '28 JUL, 26',
      '27 JUL, 26',
      '26 JUL, 26',
      '25 JUL, 26',
      '24 JUL, 26',
    ];
    final statusSamples = ['Paid', 'Unpaid', 'Partial', 'Paid', 'Unpaid'];
    final typeSamples = ['Line', 'Header', 'Line', 'Line', 'Header'];
    final placeSamples = [
      'Main Godown',
      'Store A',
      'Store B',
      'Warehouse',
      'Counter',
    ];

    if (lower == '—' || lower == '-') return '—';
    if (lower.contains('date') || lower.contains('level')) {
      return lower.contains('level') ? '$index' : dateSamples[index];
    }
    if (lower.contains('status') || lower.contains('type')) {
      return lower.contains('type') ? typeSamples[index] : statusSamples[index];
    }
    if (lower.contains('%') || lower.contains('disc %')) {
      return '${5 + index * 2}%';
    }
    if (lower.contains('qty') ||
        lower.contains('count') ||
        lower.contains('opening') ||
        lower.contains('closing') ||
        lower == 'in' ||
        lower.contains('qty in')) {
      return qtySamples[index];
    }
    if (lower.contains('from') || lower.contains('to')) {
      return placeSamples[index];
    }
    if (lower.contains('party')) {
      return [
        'Arpit',
        'Saksham',
        'Cash Sale',
        'Sharma Traders',
        'Metro Supplies',
      ][index];
    }
    return moneySamples[index];
  }
}
