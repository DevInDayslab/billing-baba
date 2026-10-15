import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_formatters.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_subsection_registry.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/mobile_report_view_model.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';

/// Maps tax report envelopes for mobile taxes group.
abstract final class MobileTaxReportDataLoader {
  static double gstRowAmount(Map<String, dynamic> row, String key) =>
      double.tryParse(row[key]?.toString() ?? '') ?? 0;

  static MobileReportViewData mapGstEnvelope(
    GstReportEnvelopeDto envelope,
    MobileReportSubsectionConfig config,
  ) {
    final section = envelope.sections.firstWhere(
      (s) => s.rows.isNotEmpty,
      orElse: () => envelope.sections.isNotEmpty
          ? envelope.sections.first
          : const GstReportSectionDto(key: '', title: '', rows: []),
    );
    final rows = section.rows;
    return _build(
      config: config,
      count: rows.length,
      metrics: _countTotalMetrics(
        rows.length,
        rows,
        (row) {
          final value = gstRowAmount(row, 'value');
          return value != 0
              ? value
              : gstRowAmount(row, 'taxable_value');
        },
        config: config,
      ),
      rows: [
        for (final row in rows)
          _row(
            config,
            title:
                row['party_name']?.toString() ??
                row['document_no']?.toString() ??
                row['tax_name']?.toString() ??
                row['hsn']?.toString() ??
                row['label']?.toString() ??
                '—',
            reference:
                '${config.referencePrefix} ${row['invoice_no'] ?? row['bill_no'] ?? row['document_no'] ?? ''}',
            dateTime: DateTime.tryParse(
              row['invoice_date']?.toString() ??
                  row['bill_date']?.toString() ??
                  row['date']?.toString() ??
                  row['entry_date']?.toString() ??
                  '',
            ),
            values: _valuesForRow(row, config),
          ),
      ],
    );
  }

  static List<String> _valuesForRow(
    Map<String, dynamic> row,
    MobileReportSubsectionConfig config,
  ) {
    if (row.containsKey('taxable_value')) {
      return [
        formatReportCurrency(gstRowAmount(row, 'taxable_value')),
        formatReportCurrency(gstRowAmount(row, 'igst')),
        formatReportCurrency(
          gstRowAmount(row, 'value') != 0
              ? gstRowAmount(row, 'value')
              : gstRowAmount(row, 'total_tax'),
        ),
      ];
    }
    if (row.containsKey('taxable_sale')) {
      return [
        formatReportCurrency(gstRowAmount(row, 'taxable_sale')),
        formatReportCurrency(gstRowAmount(row, 'sale_total_tax')),
        formatReportCurrency(gstRowAmount(row, 'purchase_total_tax')),
      ];
    }
    if (row.containsKey('tax_amount')) {
      return [
        formatReportCurrency(gstRowAmount(row, 'base_amount')),
        formatReportCurrency(gstRowAmount(row, 'tax_amount')),
        formatReportCurrency(gstRowAmount(row, 'pending')),
      ];
    }
    return List.generate(
      config.columnLabels.length,
      (i) => '-',
    );
  }

  static MobileReportViewData _build({
    required MobileReportSubsectionConfig config,
    required int count,
    required List<MobileReportSummaryMetric> metrics,
    required List<MobileReportRow> rows,
  }) {
    return MobileReportViewData(
      summaryMetrics: metrics,
      rows: rows,
      totalCount: count,
    );
  }

  static MobileReportRow _row(
    MobileReportSubsectionConfig config, {
    required String title,
    required String reference,
    required List<String> values,
    DateTime? dateTime,
  }) {
    return MobileReportRow(
      title: title,
      reference: shortenMobileReportReference(reference),
      dateTime: dateTime,
      columns: [
        for (var i = 0; i < config.columnLabels.length; i++)
          MobileReportRowColumn(
            label: config.columnLabels[i],
            value: i < values.length ? values[i] : '-',
          ),
      ],
    );
  }

  static List<MobileReportSummaryMetric> _countTotalMetrics<T>(
    int count,
    List<T> rows,
    double Function(T row) amountSelector, {
    MobileReportSubsectionConfig? config,
  }) {
    final total = rows.fold<double>(0, (sum, row) => sum + amountSelector(row));
    final labels =
        config?.summaryLabels ?? const ['No of Txns', 'Total', 'Balance Due'];
    return [
      MobileReportSummaryMetric(label: labels[0], value: '$count'),
      MobileReportSummaryMetric(
        label: labels[1],
        value: formatReportCurrency(total),
      ),
      MobileReportSummaryMetric(
        label: labels[2],
        value: formatReportCurrency(total),
      ),
    ];
  }
}
