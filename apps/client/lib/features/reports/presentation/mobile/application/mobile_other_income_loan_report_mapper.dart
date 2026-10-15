import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_formatters.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_subsection_registry.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/mobile_report_view_model.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';

/// Maps other-income and loan statement API payloads for mobile report screens.
abstract final class MobileOtherIncomeLoanReportMapper {
  static MobileReportViewData fromOtherIncome(
    OtherIncomeReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return MobileReportViewData(
      summaryMetrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.meta.total}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(data.totalAmount),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(data.totalAmount),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.partyName.isEmpty ? row.category : row.partyName,
            reference: '${config.referencePrefix} ${row.incomeNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.amount),
              row.status,
              formatMobileReportDueDate(row.dueDate),
            ],
          ),
      ],
      totalCount: data.meta.total,
    );
  }

  static MobileReportViewData fromOtherIncomeCategories(
    OtherIncomeByCategoryReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return MobileReportViewData(
      summaryMetrics: _countTotalMetrics<ReportOtherIncomeCategoryRow>(
        data.rows.length,
        data.rows,
        (row) => row.amount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.category,
            reference: config.referencePrefix,
            values: [
              formatReportCurrency(row.amount),
              '${row.count}',
              '-',
            ],
          ),
      ],
      totalCount: data.rows.length,
    );
  }

  static MobileReportViewData fromOtherIncomeItems(
    OtherIncomeByItemReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return MobileReportViewData(
      summaryMetrics: _countTotalMetrics<ReportOtherIncomeItemRow>(
        data.rows.length,
        data.rows,
        (row) => row.amount,
        config: config,
      ),
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.itemName,
            reference: row.category,
            values: [
              formatReportCurrency(row.amount),
              '${row.count}',
              '-',
            ],
          ),
      ],
      totalCount: data.rows.length,
    );
  }

  static MobileReportViewData fromLoanStatement(
    LoanStatementReportData data,
    MobileReportSubsectionConfig config,
  ) {
    return MobileReportViewData(
      summaryMetrics: [
        MobileReportSummaryMetric(
          label: config.summaryLabels[0],
          value: '${data.rows.length}',
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[1],
          value: formatReportCurrency(
            data.rows.fold<double>(0, (sum, row) => sum + row.debit),
          ),
        ),
        MobileReportSummaryMetric(
          label: config.summaryLabels[2],
          value: formatReportCurrency(
            data.rows.fold<double>(0, (sum, row) => sum + row.credit),
          ),
        ),
      ],
      rows: [
        for (final row in data.rows)
          _row(
            config,
            title: row.description,
            reference: '${config.referencePrefix} ${row.refNo}',
            dateTime: row.date,
            values: [
              formatReportCurrency(row.debit),
              formatReportCurrency(row.credit),
              formatReportCurrency(row.balance),
            ],
          ),
      ],
      totalCount: data.rows.length,
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
