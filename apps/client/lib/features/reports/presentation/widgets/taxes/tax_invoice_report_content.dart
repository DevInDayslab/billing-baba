import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/taxes_report_subsection.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/taxes/taxes_report_filter_bar.dart';
import 'package:flutter/material.dart';

class TaxInvoiceReportContent extends StatelessWidget {
  const TaxInvoiceReportContent({
    required this.subSection,
    super.key,
  });

  final TaxesReportSubSection subSection;

  static const _minTableWidth = 1180.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  subSection.pageTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ReportCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TaxInvoiceReportFilterBar(),
                    const Divider(height: 1, color: reportCardBorder),
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: ReportSearchField(),
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReportSyncScrollTable(
                            minWidth: _minTableWidth,
                            headerChildren: const [
                              ReportAlignedHeaderCell(
                                label: '#',
                                width: 40,
                                showFilter: false,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'PARTY NAME',
                                width: 140,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'INVOICE NO',
                                width: 110,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'TOTAL VALUE',
                                width: 120,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'AMOUNT RECEIVED',
                                width: 140,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'TOTAL TAX COLLECTED',
                                width: 160,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'DATE OF COLLECTION',
                                width: 150,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'TAX NAME',
                                width: 120,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'TCS RATE',
                                width: 100,
                                alignment: Alignment.centerRight,
                              ),
                            ],
                            rows: const [],
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 48,
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    subSection.emptyMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
