import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';

class PartyReportByItemContent extends StatelessWidget {
  const PartyReportByItemContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReportPeriodFilterBar(
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SaleFilterDropdown(
                          label: 'All Godown',
                          options: const [
                            'All Godown',
                            'Main Location',
                            'Warehouse B',
                          ],
                          selected: 'All Godown',
                          onSelected: (_) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
                    children: [
                      ReportTextActionButton(
                        label: 'Excel Report',
                        icon: Icons.table_chart_outlined,
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      SaleFilterDropdown(
                        label: 'All Categories',
                        options: const [
                          'All Categories',
                          'Category A',
                          'Category B',
                        ],
                        selected: 'All Categories',
                        onSelected: (_) {},
                      ),
                      SaleFilterDropdown(
                        label: 'All Items',
                        options: const ['All Items', 'Item 1', 'Item 2'],
                        selected: 'All Items',
                        onSelected: (_) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const ReportSearchField(hintText: 'Search Party...'),
            const SizedBox(height: AppSpacing.md),
            const ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportTableHeaderRow(
                    children: [
                      ReportTableHeaderCell(label: '#', width: 40),
                      Expanded(
                        child: ReportTableHeaderCell(label: 'PARTY NAME'),
                      ),
                      ReportTableHeaderCell(
                        label: 'SALE QUANTITY',
                        width: 120,
                        alignment: Alignment.centerRight,
                      ),
                      ReportTableHeaderCell(
                        label: 'SALE AMOUNT',
                        width: 120,
                        alignment: Alignment.centerRight,
                      ),
                      ReportTableHeaderCell(
                        label: 'PURCHASE QUANTITY',
                        width: 140,
                        alignment: Alignment.centerRight,
                      ),
                      ReportTableHeaderCell(
                        label: 'PURCHASE AMOUNT',
                        width: 140,
                        alignment: Alignment.centerRight,
                      ),
                    ],
                  ),
                  Divider(height: 1, color: reportCardBorder),
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No data available for the selected period.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
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
