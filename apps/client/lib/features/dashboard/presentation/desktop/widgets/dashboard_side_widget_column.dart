import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_widget_preferences_provider.dart';
import 'package:billing_baba/features/dashboard/dashboard_navigation.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_side_widget.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_side_widget_cards.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_widget_picker.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_accountant_module_entry.dart';
import 'package:billing_baba/shared/layout/dashboard_layout.dart';
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

  static const _divider = Divider(
    height: 1,
    thickness: 1,
    color: DashboardColors.divider,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = DashboardLayoutScope.of(context);
    final visible = DashboardSideWidget.pinLowStockFirst(
      ref.watch(dashboardWidgetPreferencesProvider),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardAccountantModuleEntry(),
        Expanded(
          child: DashboardSideWidgetPanel(
            child: visible.isEmpty
                ? const DashboardSideWidgetsEmptyState()
                : Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < visible.length; i++) ...[
                            if (i > 0) _divider,
                            SizedBox(
                              height: _heightFor(visible[i], metrics),
                              child: _TappableSideWidget(
                                widget: visible[i],
                                child: _buildWidget(visible[i]),
                              ),
                            ),
                          ],
                          if (visible.isNotEmpty) _divider,
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        SizedBox(height: metrics.gap),
        DashboardWidgetPicker(dashboard: dashboard, dashed: true),
      ],
    );
  }

  double _heightFor(DashboardSideWidget widget, DashboardMetrics metrics) {
    return switch (widget) {
      DashboardSideWidget.lowStock => metrics.sideWidgetLowStockHeight(
        dashboard.inventory.lowStockItems.length,
      ),
      _ => metrics.sideWidgetMetricHeight,
    };
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

class _TappableSideWidget extends ConsumerWidget {
  const _TappableSideWidget({required this.widget, required this.child});

  final DashboardSideWidget widget;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => DashboardNavigation.openSideWidget(context, ref, widget),
        hoverColor: AppColors.background,
        child: child,
      ),
    );
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
