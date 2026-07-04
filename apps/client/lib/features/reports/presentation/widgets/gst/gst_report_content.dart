import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/gst_report_subsection.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GstReportContent extends StatelessWidget {
  const GstReportContent({required this.subSection, super.key});

  final GstReportSubSection subSection;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  String get _title => switch (subSection) {
    GstReportSubSection.gstr1 => 'GSTR-1 Report',
    GstReportSubSection.gstr2 => 'GSTR-2 Report',
    GstReportSubSection.gstr3b => 'GSTR-3B Report',
    GstReportSubSection.gstr9 => 'GSTR-9 Report',
    GstReportSubSection.saleSummaryByHsn => 'Sale Summary By HSN',
    GstReportSubSection.sacReport => 'SAC Report',
  };

  List<_TableColumn> get _columns => switch (subSection) {
    GstReportSubSection.gstr1 => const [
      _TableColumn('INVOICE NO.', 110),
      _TableColumn('DATE', 90),
      _TableColumn('PARTY NAME', null),
      _TableColumn('GSTIN', 120),
      _TableColumn('TAXABLE', 100, right: true),
      _TableColumn('IGST', 80, right: true),
      _TableColumn('CGST', 80, right: true),
      _TableColumn('SGST', 80, right: true),
    ],
    GstReportSubSection.gstr2 => const [
      _TableColumn('BILL NO.', 100),
      _TableColumn('DATE', 90),
      _TableColumn('PARTY NAME', null),
      _TableColumn('GSTIN', 120),
      _TableColumn('TAXABLE', 100, right: true),
      _TableColumn('IGST', 80, right: true),
      _TableColumn('CGST', 80, right: true),
      _TableColumn('SGST', 80, right: true),
    ],
    GstReportSubSection.gstr3b => const [
      _TableColumn('DESCRIPTION', null),
      _TableColumn('TAXABLE VALUE', 120, right: true),
      _TableColumn('IGST', 90, right: true),
      _TableColumn('CGST', 90, right: true),
      _TableColumn('SGST', 90, right: true),
      _TableColumn('CESS', 80, right: true),
    ],
    GstReportSubSection.gstr9 => const [
      _TableColumn('PARTICULARS', null),
      _TableColumn('TAXABLE VALUE', 130, right: true),
      _TableColumn('TAX PAID', 110, right: true),
      _TableColumn('ITC AVAILED', 110, right: true),
    ],
    GstReportSubSection.saleSummaryByHsn => const [
      _TableColumn('HSN CODE', 100),
      _TableColumn('DESCRIPTION', null),
      _TableColumn('UQC', 70),
      _TableColumn('QTY', 80, right: true),
      _TableColumn('TAXABLE VALUE', 120, right: true),
      _TableColumn('IGST', 80, right: true),
      _TableColumn('CGST', 80, right: true),
      _TableColumn('SGST', 80, right: true),
    ],
    GstReportSubSection.sacReport => const [
      _TableColumn('SAC', 90),
      _TableColumn('INVOICE TYPE', 110),
      _TableColumn('TOTAL VALUE', 110, right: true),
      _TableColumn('TAXABLE VALUE', 120, right: true),
      _TableColumn('IGST AMOUNT', 110, right: true),
      _TableColumn('CGST AMOUNT', 110, right: true),
      _TableColumn('SGST AMOUNT', 110, right: true),
      _TableColumn('ADD. CESS', 100, right: true),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (subSection != GstReportSubSection.saleSummaryByHsn &&
                    subSection != GstReportSubSection.sacReport)
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F1FB),
                      foregroundColor: reportActiveBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Generate JSON',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: AppSpacing.sm),
                const ReportXlsChip(),
                const SizedBox(width: AppSpacing.sm),
                const ReportPdfChip(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ReportPeriodFilterBar(showFirmFilter: false),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (subSection == GstReportSubSection.gstr3b ||
                subSection == GstReportSubSection.gstr9) ...[
              const SizedBox(height: AppSpacing.md),
              ReportCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _SummaryChip(
                      label: 'Total Taxable',
                      value: _currencyFormat.format(0),
                    ),
                    _SummaryChip(
                      label: 'Total Tax',
                      value: _currencyFormat.format(0),
                    ),
                    if (subSection == GstReportSubSection.gstr3b)
                      _SummaryChip(
                        label: 'Net Payable',
                        value: _currencyFormat.format(0),
                        highlight: true,
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const ReportSearchField(hintText: 'Search...'),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportTableHeaderRow(
                    children: [
                      for (final col in _columns)
                        if (col.width == null)
                          Expanded(
                            child: ReportTableHeaderCell(
                              label: col.label,
                              alignment: col.right
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                            ),
                          )
                        else
                          ReportTableHeaderCell(
                            label: col.label,
                            width: col.width,
                            alignment: col.right
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                          ),
                    ],
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  const ReportEmptyTableState(
                    message: 'No data available for the selected period.',
                    minHeight: 200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableColumn {
  const _TableColumn(this.label, this.width, {this.right = false});

  final String label;
  final double? width;
  final bool right;
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: highlight ? reportTeal : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
