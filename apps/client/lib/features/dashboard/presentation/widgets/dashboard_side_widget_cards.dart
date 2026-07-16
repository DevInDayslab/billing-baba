import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_empty_state.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

class _SideWidgetBlock extends StatelessWidget {
  const _SideWidgetBlock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = DashboardLayoutScope.of(context).sideWidgetPadding;
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.topLeft,
        child: child,
      ),
    );
  }
}

class DashboardPurchasesSideWidget extends StatelessWidget {
  const DashboardPurchasesSideWidget({
    required this.purchases,
    required this.period,
    super.key,
  });

  final DashboardPurchasesModel purchases;
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    return _SideWidgetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Purchases', style: DashboardTypography.sideWidgetTitle),
          const SizedBox(height: 4),
          Text(period.label, style: DashboardTypography.metadata),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(purchases.totalAmount),
            style: DashboardTypography.sideWidgetValue,
          ),
        ],
      ),
    );
  }
}

class DashboardExpensesSideWidget extends StatelessWidget {
  const DashboardExpensesSideWidget({
    required this.expenses,
    required this.period,
    super.key,
  });

  final double expenses;
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    return _SideWidgetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Expenses', style: DashboardTypography.sideWidgetTitle),
          const SizedBox(height: 4),
          Text(period.label, style: DashboardTypography.metadata),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(expenses),
            style: DashboardTypography.sideWidgetValue,
          ),
        ],
      ),
    );
  }
}

class DashboardLowStockSideWidget extends StatelessWidget {
  const DashboardLowStockSideWidget({required this.inventory, super.key});

  final DashboardInventoryModel inventory;

  @override
  Widget build(BuildContext context) {
    final items = inventory.lowStockItems;

    return _SideWidgetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Low Stocks Items',
                  style: DashboardTypography.sideWidgetTitle,
                  maxLines: 1,
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
                child: const Text('See More', style: DashboardTypography.link),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (items.isEmpty)
            const Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: DashboardColors.incoming,
                ),
                SizedBox(width: AppSpacing.xs + 2),
                Expanded(
                  child: Text(
                    'Everything is sufficiently stocked',
                    style: DashboardTypography.metadata,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            for (var i = 0; i < items.take(3).length; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              _LowStockRow(item: items[i]),
            ],
        ],
      ),
    );
  }
}

class _LowStockRow extends StatelessWidget {
  const _LowStockRow({required this.item});

  final DashboardLowStockItemModel item;

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity;
    final qtyText = qty == qty.roundToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: Text(
            item.itemName,
            style: DashboardTypography.supportingLabel.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          qtyText,
          style: DashboardTypography.supportingLabel.copyWith(
            fontWeight: FontWeight.w600,
            color: item.isNegative
                ? DashboardColors.outgoing
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class DashboardStockValueSideWidget extends StatelessWidget {
  const DashboardStockValueSideWidget({required this.stockValue, super.key});

  final double stockValue;

  @override
  Widget build(BuildContext context) {
    return _SideWidgetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Stock Value', style: DashboardTypography.sideWidgetTitle),
          const SizedBox(height: 4),
          const Text('As of now', style: DashboardTypography.metadata),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(stockValue),
            style: DashboardTypography.sideWidgetValue,
          ),
        ],
      ),
    );
  }
}

class DashboardCashInHandSideWidget extends StatelessWidget {
  const DashboardCashInHandSideWidget({required this.cashIn, super.key});

  final double cashIn;

  @override
  Widget build(BuildContext context) {
    return _SideWidgetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Cash In Hand', style: DashboardTypography.sideWidgetTitle),
          const SizedBox(height: 4),
          const Text('Today', style: DashboardTypography.metadata),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(cashIn),
            style: DashboardTypography.sideWidgetValue,
          ),
        ],
      ),
    );
  }
}

class DashboardBankBalanceSideWidget extends StatelessWidget {
  const DashboardBankBalanceSideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SideWidgetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Bank Balance',
            style: DashboardTypography.sideWidgetTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text('As of Now', style: DashboardTypography.metadata),
          SizedBox(height: 4),
          Text('—', style: DashboardTypography.sideWidgetValue),
        ],
      ),
    );
  }
}

class DashboardSideWidgetsEmptyState extends StatelessWidget {
  const DashboardSideWidgetsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SideWidgetBlock(
      child: DashboardEmptyState(
        icon: Icons.widgets_outlined,
        title: 'It Looks So Empty In Here!',
        subtitle:
            'Add one of our widgets to get started and view your business operations.',
      ),
    );
  }
}
