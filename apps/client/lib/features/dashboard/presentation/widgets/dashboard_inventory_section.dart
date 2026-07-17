import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_empty_state.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardInventorySection extends StatelessWidget {
  const DashboardInventorySection({required this.inventory, super.key});

  final DashboardInventoryModel inventory;

  static final _qtyFormat = NumberFormat.decimalPattern('en_IN');

  @override
  Widget build(BuildContext context) {

    return DashboardMetricCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Low Stock Items',
                  style: DashboardTypography.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('As of Now', style: DashboardTypography.metadata),
            ],
          ),
          const SizedBox(height: DashboardSpacing.headerGap),
          if (inventory.lowStockItems.isEmpty)
            const DashboardEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'All items are sufficiently stocked',
              subtitle:
                  'Items that reach their reorder level will appear here.',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        const TableRow(
                          children: [
                            _TableHeader('Item'),
                            _TableHeader('Current Qty'),
                            _TableHeader('Reorder Level'),
                          ],
                        ),
                        for (final item in inventory.lowStockItems)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.md,
                                ),
                                child: Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.md,
                                ),
                                child: Text(
                                  _qtyFormat.format(item.quantity),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.isNegative
                                        ? DashboardColors.outgoing
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.md,
                                ),
                                child: Text(
                                  _qtyFormat.format(item.reorderLevel),
                                  style: DashboardTypography.metadata,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (inventory.lowStockItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.items),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'See More →',
                  style: DashboardTypography.link,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: DashboardTypography.metadata.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
