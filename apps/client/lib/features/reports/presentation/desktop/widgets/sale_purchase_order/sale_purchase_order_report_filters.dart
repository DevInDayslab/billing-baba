import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/utils/report_order_filter_utils.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseOrderReportFilters extends ConsumerWidget {
  const SalePurchaseOrderReportFilters({
    this.onExportExcel,
    this.onPrint,
    super.key,
  });

  final VoidCallback? onExportExcel;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final documentType = salePurchaseOrderTypeLabel(filters.documentType);
    final status = salePurchaseOrderStatusLabel(filters.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportCard(
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
              Tooltip(
                message: 'User filtering is not available.',
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.55,
                    child: SaleFilterDropdown(
                      label: 'ALL USER',
                      options: const ['ALL USER'],
                      selected: 'ALL USER',
                      onSelected: (_) {},
                    ),
                  ),
                ),
              ),
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
        ),
        const SizedBox(height: AppSpacing.md),
        ReportCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'FILTERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(
                width: 180,
                child: ReportSearchField(
                  hintText: 'Party filter',
                  onChanged: notifier.setSearchQuery,
                ),
              ),
              SaleFilterDropdown(
                label: documentType,
                options: salePurchaseOrderTypeOptions,
                selected: documentType,
                onSelected: (value) {
                  notifier.setDocumentType(salePurchaseOrderTypeValue(value));
                },
              ),
              SaleFilterDropdown(
                label: status,
                options: salePurchaseOrderStatusOptions,
                selected: status,
                onSelected: (value) {
                  notifier.setStatus(salePurchaseOrderStatusValue(value));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
