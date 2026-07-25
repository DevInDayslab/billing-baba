import 'package:billing_baba/core/layout/dashboard_layout.dart' show DashboardLayout;
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_side_widget.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/parties_selection_providers.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/reports/application/reports_nav_intent_provider.dart';
import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/party_report_subsection.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Dashboard widget → app route mapping (layout lives in [DashboardLayout]).
abstract final class DashboardNavigation {
  static void openReceivables(BuildContext context, WidgetRef ref) {
    _openParties(context, ref, PartyListFilter.toReceive);
  }

  static void openPayables(BuildContext context, WidgetRef ref) {
    _openParties(context, ref, PartyListFilter.toPay);
  }

  static void openTotalSale(BuildContext context, WidgetRef ref) {
    openQuickReport(context, ref, key: 'sale_report');
  }

  static void openQuickReport(
    BuildContext context,
    WidgetRef ref, {
    required String key,
  }) {
    final intent = _intentForQuickReportKey(key);
    if (intent != null) {
      _openReports(context, ref, intent);
      return;
    }
    context.go(AppRoutes.reports);
  }

  static void openSideWidget(
    BuildContext context,
    WidgetRef ref,
    DashboardSideWidget widget,
  ) {
    switch (widget) {
      case DashboardSideWidget.purchases:
        context.go(AppRoutes.purchaseBills);
      case DashboardSideWidget.expenses:
        context.go(AppRoutes.purchaseExpenses);
      case DashboardSideWidget.lowStock:
        context.go(AppRoutes.items);
      case DashboardSideWidget.stockValue:
        _openReports(
          context,
          ref,
          ReportsNavIntent.itemStock(
            ItemStockReportSubSection.stockSummary,
          ),
        );
      case DashboardSideWidget.cashInHand:
        _openReports(
          context,
          ref,
          ReportsNavIntent.transaction(TransactionReportSubSection.cashFlow),
        );
      case DashboardSideWidget.bankBalance:
        _openReports(
          context,
          ref,
          ReportsNavIntent.businessStatus(
            BusinessStatusReportSubSection.bankStatement,
          ),
        );
    }
  }

  static void _openParties(
    BuildContext context,
    WidgetRef ref,
    PartyListFilter filter,
  ) {
    ref.read(partyListFilterProvider.notifier).filter = filter;
    ref.read(partySearchQueryProvider.notifier).query = '';
    ref.read(selectedPartyIdProvider.notifier).selected = null;
    context.go(AppRoutes.partyDetails);
  }

  static void _openReports(
    BuildContext context,
    WidgetRef ref,
    ReportsNavIntent intent,
  ) {
    ref.read(reportsNavIntentProvider.notifier).setIntent(intent);
    context.go(AppRoutes.reports);
  }

  static ReportsNavIntent? _intentForQuickReportKey(String key) {
    return switch (key) {
      'sale_report' => ReportsNavIntent.transaction(
        TransactionReportSubSection.sale,
      ),
      'all_transactions' => ReportsNavIntent.transaction(
        TransactionReportSubSection.allTransaction,
      ),
      'daybook' => ReportsNavIntent.transaction(
        TransactionReportSubSection.dayBook,
      ),
      'party_statement' => ReportsNavIntent.party(
        PartyReportSubSection.partyStatement,
      ),
      _ => null,
    };
  }
}
