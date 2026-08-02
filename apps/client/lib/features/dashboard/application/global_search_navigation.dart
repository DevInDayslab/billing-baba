import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/dashboard/application/global_search_provider.dart';
import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/parties/application/parties_selection_providers.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Applies list filters and opens the screen for a global search result.
abstract final class GlobalSearchNavigation {
  static void openResult(
    BuildContext context,
    WidgetRef ref,
    GlobalSearchResult result,
  ) {
    final query = ref.read(globalSearchQueryProvider).trim();

    switch (result.type) {
      case GlobalSearchResultType.party:
        ref.read(partyListFilterProvider.notifier).filter = PartyListFilter.all;
        ref.read(partySearchQueryProvider.notifier).query = query;
        ref.read(partyBackendSearchProvider.notifier).query = query;
        ref.read(selectedPartyIdProvider.notifier).selected = result.id;
        unawaited(
          ref.read(partyListProvider.notifier).refresh(searchQuery: query),
        );
        context.go(AppRoutes.partyDetails);
      case GlobalSearchResultType.item:
        ref.read(inventoryLowStockOnlyProvider.notifier).clear();
        ref.read(inventoryItemsTabIndexProvider.notifier).tabIndex =
            inventoryProductsTabIndex;
        ref.read(productSearchQueryProvider.notifier).query = query;
        ref.read(selectedProductIdProvider.notifier).selected = result.id;
        context.go(AppRoutes.items);
      case GlobalSearchResultType.saleInvoice:
        ref.read(saleInvoiceFiltersProvider.notifier).setTimeRange('All Time');
        ref
            .read(saleInvoiceSearchQueryProvider.notifier)
            .setQuery(result.title);
        ref.read(selectedSaleInvoiceIdProvider.notifier).select(result.id);
        context.go(AppRoutes.saleInvoices);
      case GlobalSearchResultType.purchaseBill:
        ref.read(purchaseBillFiltersProvider.notifier).setTimeRange('All Time');
        ref
            .read(purchaseBillSearchQueryProvider.notifier)
            .setQuery(result.title);
        context.go(AppRoutes.purchaseBills);
      case GlobalSearchResultType.expense:
        ref.read(expenseFiltersProvider.notifier).setTimeRange('All Time');
        ref.read(expenseTransactionSearchQueryProvider.notifier).query = query;
        context.go(AppRoutes.purchaseExpenses);
      case GlobalSearchResultType.payment:
        if (result.route == AppRoutes.purchasePaymentOut) {
          ref.read(paymentOutFiltersProvider.notifier).setTimeRange('All Time');
          ref.read(paymentOutSearchQueryProvider.notifier).setQuery(query);
          context.go(AppRoutes.purchasePaymentOut);
        } else {
          ref.read(paymentInFiltersProvider.notifier).setTimeRange('All Time');
          ref.read(paymentInFiltersProvider.notifier).setSearchQuery(query);
          context.go(AppRoutes.salePaymentIn);
        }
    }
  }
}
