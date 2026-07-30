import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaxesReportFilterBar extends ConsumerWidget {
  const TaxesReportFilterBar({
    this.onExportExcel,
    this.onPrint,
    super.key,
  });

  final VoidCallback? onExportExcel;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReportCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Tooltip(
            message: 'Multi-firm filtering is not available.',
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.55,
                child: SaleFilterDropdown(
                  label: 'ALL FIRMS',
                  options: const ['ALL FIRMS'],
                  selected: 'ALL FIRMS',
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
          const ReportFromToDateFilter(fromLabel: '', toLabel: ''),
          ReportTextActionButton(
            label: 'Excel',
            icon: Icons.table_chart_outlined,
            onTap: onExportExcel,
          ),
          ReportTextActionButton(
            label: 'Print',
            icon: Icons.print_outlined,
            onTap: onPrint,
          ),
        ],
      ),
    );
  }
}

class TaxInvoiceReportFilterBar extends ConsumerWidget {
  const TaxInvoiceReportFilterBar({
    this.onExportExcel,
    this.onPrint,
    super.key,
  });

  final VoidCallback? onExportExcel;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: reportTableHeaderBg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const ReportFromToDateFilter(),
          Tooltip(
            message: 'Multi-firm filtering is not available.',
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.55,
                child: SaleFilterDropdown(
                  label: 'ALL FIRMS',
                  options: const ['ALL FIRMS'],
                  selected: 'ALL FIRMS',
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
          ReportTextActionButton(
            label: 'Excel Report',
            icon: Icons.table_chart_outlined,
            onTap: onExportExcel,
          ),
          ReportTextActionButton(
            label: 'Print',
            icon: Icons.print_outlined,
            onTap: onPrint,
          ),
        ],
      ),
    );
  }
}
