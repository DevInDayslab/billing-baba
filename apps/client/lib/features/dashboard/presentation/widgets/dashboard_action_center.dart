import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/action_center_tasks_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Single right-column panel: Low Stock, Today's Tasks, Quick Reports.
class DashboardActionCenter extends StatelessWidget {
  const DashboardActionCenter({
    required this.inventory,
    required this.reports,
    super.key,
  });

  final DashboardInventoryModel inventory;
  final List<DashboardQuickReportModel> reports;

  static const _sectionPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.md,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: DashboardMetricCard.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: _sectionPadding,
            child: _ActionCenterLowStock(inventory: inventory),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const Expanded(
            child: Padding(
              padding: _sectionPadding,
              child: ActionCenterTasksSection(),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: _sectionPadding,
            child: _ActionCenterQuickReports(reports: reports),
          ),
        ],
      ),
    );
  }
}

class _ActionCenterLowStock extends StatelessWidget {
  const _ActionCenterLowStock({required this.inventory});

  final DashboardInventoryModel inventory;

  @override
  Widget build(BuildContext context) {
    final items = inventory.lowStockItems;
    final isEmpty = items.isEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72, maxHeight: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Low Stock',
                  style: DashboardTypography.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.items),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View Inventory',
                  style: DashboardTypography.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isEmpty)
            const Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: DashboardColors.incoming,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Everything is sufficiently stocked',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else ...[
            Text(
              '${items.length} item${items.length == 1 ? '' : 's'} below reorder level',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: DashboardColors.outgoing,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              items.take(2).map((e) => e.itemName).join(' · '),
              style: DashboardTypography.metadata,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCenterQuickReports extends StatelessWidget {
  const _ActionCenterQuickReports({required this.reports});

  final List<DashboardQuickReportModel> reports;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Quick Reports',
                style: DashboardTypography.cardTitle,
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.reports),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('View All →', style: DashboardTypography.link),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (reports.isEmpty)
          Text(
            'No reports available',
            style: DashboardTypography.metadata,
          )
        else
          for (var i = 0; i < reports.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            _CompactReportRow(report: reports[i]),
          ],
      ],
    );
  }
}

class _CompactReportRow extends StatelessWidget {
  const _CompactReportRow({required this.report});

  final DashboardQuickReportModel report;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconFor(report.key);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(report.route),
        borderRadius: AppRadius.smBorder,
        hoverColor: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _iconFor(String key) => switch (key) {
    'sale_report' => (Icons.bar_chart_outlined, AppColors.primary),
    'all_transactions' => (Icons.receipt_long_outlined, AppColors.secondary),
    'daybook' => (Icons.book_outlined, DashboardColors.incoming),
    'party_statement' => (Icons.people_outline, AppColors.error),
    _ => (Icons.description_outlined, AppColors.primary),
  };
}
