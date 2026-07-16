import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_side_widget.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_side_widget_cards.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_widget_picker.dart';
import 'package:billing_baba/features/dashboard/providers/dashboard_widget_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardSideWidgetColumn extends ConsumerWidget {
  const DashboardSideWidgetColumn({
    required this.dashboard,
    required this.period,
    super.key,
  });

  final DashboardModel dashboard;
  final DashboardPeriod period;

  static const List<DashboardSideWidget> _orderedWidgets =
      DashboardSideWidget.values;

  static const _divider = Divider(
    height: 1,
    thickness: 1,
    color: DashboardColors.divider,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = DashboardLayoutScope.of(context);
    final enabled = ref.watch(dashboardWidgetPreferencesProvider);
    final visible = _orderedWidgets.where(enabled.contains).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: DashboardSideWidgetPanel(
            child: visible.isEmpty
                ? const DashboardSideWidgetsEmptyState()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < visible.length; i++) ...[
                        if (i > 0) _divider,
                        Expanded(
                          child: _buildWidget(visible[i]),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        SizedBox(height: metrics.gap),
        const DashboardWidgetPicker(dashed: true),
      ],
    );
  }

  Widget _buildWidget(DashboardSideWidget widget) {
    return switch (widget) {
      DashboardSideWidget.purchases => DashboardPurchasesSideWidget(
        purchases: dashboard.purchases,
        period: period,
      ),
      DashboardSideWidget.expenses => DashboardExpensesSideWidget(
        expenses: dashboard.finance.expenses,
        period: period,
      ),
      DashboardSideWidget.lowStock => DashboardLowStockSideWidget(
        inventory: dashboard.inventory,
      ),
      DashboardSideWidget.stockValue => DashboardStockValueSideWidget(
        stockValue: dashboard.inventory.totalStockValue,
      ),
      DashboardSideWidget.cashInHand => DashboardCashInHandSideWidget(
        cashIn: dashboard.finance.cashIn,
      ),
      DashboardSideWidget.bankBalance => const DashboardBankBalanceSideWidget(),
    };
  }
}

/// Single bordered panel for all right-column widgets (dividers only, no gutters).
class DashboardSideWidgetPanel extends StatelessWidget {
  const DashboardSideWidgetPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: DashboardDecor.cardRadius,
        border: Border.all(color: DashboardMetricCard.borderColor),
        boxShadow: DashboardDecor.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: DashboardDecor.cardRadius,
        child: child,
      ),
    );
  }
}
