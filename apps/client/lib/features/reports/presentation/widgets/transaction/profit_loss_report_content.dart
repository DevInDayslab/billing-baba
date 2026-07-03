import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';

class ProfitLossReportContent extends StatefulWidget {
  const ProfitLossReportContent({super.key});

  @override
  State<ProfitLossReportContent> createState() =>
      _ProfitLossReportContentState();
}

class _ProfitLossReportContentState extends State<ProfitLossReportContent> {
  String _viewMode = 'Vyapar';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ReportDateRangeBar(
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReportIconActionButton(
                    icon: Icons.picture_as_pdf_outlined,
                    tooltip: 'Export PDF',
                  ),
                  ReportIconActionButton(
                    icon: Icons.print_outlined,
                    tooltip: 'Print',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      'PROFIT AND LOSS REPORT',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: RadioGroup<String>(
                      groupValue: _viewMode,
                      onChanged: (v) {
                        if (v != null) setState(() => _viewMode = v);
                      },
                      child: const Row(
                        children: [
                          Text(
                            'View :',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Radio<String>(
                            value: 'Vyapar',
                            visualDensity: VisualDensity.compact,
                          ),
                          Text('Vyapar', style: TextStyle(fontSize: 13)),
                          SizedBox(width: AppSpacing.sm),
                          Radio<String>(
                            value: 'Accounting',
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            'Accounting',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(height: 1, color: reportCardBorder),
                  const ReportTableHeaderRow(
                    children: [
                      Expanded(
                        child: ReportTableHeaderCell(
                          label: 'Particulars',
                          showFilter: false,
                        ),
                      ),
                      ReportTableHeaderCell(
                        label: 'Amount',
                        width: 120,
                        alignment: Alignment.centerRight,
                        showFilter: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
