import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_transaction_mock_data.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/application/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Recent transactions for the mobile home feed, aggregated from live providers.
final mobileHomeTransactionsProvider =
    Provider<AsyncValue<List<MobileHomeTransactionItem>>>((ref) {
      final salesAsync = ref.watch(saleInvoicesProvider);
      final estimatesAsync = ref.watch(estimateQuotationsProvider);
      final paymentInAsync = ref.watch(paymentInRecordsProvider);
      final purchasesAsync = ref.watch(purchaseBillsProvider);
      final expensesAsync = ref.watch(expenseTransactionsProvider);

      final loadingStates = [
        salesAsync,
        estimatesAsync,
        paymentInAsync,
        purchasesAsync,
        expensesAsync,
      ];

      final hasAnyData = loadingStates.any((state) => state.hasValue);
      final stillLoading = loadingStates.any(
        (state) => state.isLoading && !state.hasValue,
      );

      if (!hasAnyData && stillLoading) {
        return const AsyncValue.loading();
      }

      final items = <MobileHomeTransactionItem>[];

      salesAsync.whenData((page) {
        items.addAll(
          page.items.map(MobileTransactionMapper.homeFromSaleInvoice),
        );
      });
      estimatesAsync.whenData((page) {
        items.addAll(
          page.items.map(MobileTransactionMapper.homeFromSaleInvoice),
        );
      });
      paymentInAsync.whenData((page) {
        items.addAll(page.items.map(MobileTransactionMapper.homeFromPaymentIn));
      });
      purchasesAsync.whenData((page) {
        items.addAll(
          page.items.map(MobileTransactionMapper.homeFromPurchaseBill),
        );
      });
      expensesAsync.whenData((expenses) {
        items.addAll(expenses.map(MobileTransactionMapper.homeFromExpense));
      });

      items.sort((a, b) {
        final aDate = a.transactionDate ?? _parseHomeDate(a.dateLabel);
        final bDate = b.transactionDate ?? _parseHomeDate(b.dateLabel);
        return bDate.compareTo(aDate);
      });

      if (items.isEmpty) {
        return AsyncValue.data(MobileHomeTransactionMockData.transactions());
      }

      return AsyncValue.data(items);
    });

/// Resolves the list shown on the transaction details tab, with mock fallback.
List<MobileHomeTransactionItem> resolveMobileHomeDisplayTransactions({
  required List<MobileHomeTransactionItem> source,
  required String query,
  Set<MobileHomeTransactionFilterType> typeFilters = const {},
  DateTimeRange? dateRange,
}) {
  final filtered = filterHomeTransactions(
    source,
    query,
    typeFilters: typeFilters,
    dateRange: dateRange,
  );
  if (filtered.isNotEmpty) return filtered;

  final mockFiltered = filterHomeTransactions(
    MobileHomeTransactionMockData.transactions(),
    query,
    typeFilters: typeFilters,
    dateRange: dateRange,
  );
  if (mockFiltered.isNotEmpty) return mockFiltered;

  if (query.trim().isEmpty && typeFilters.isEmpty) {
    return MobileHomeTransactionMockData.transactions();
  }

  return const [];
}

DateTime _parseHomeDate(String label) {
  try {
    return DateTime.parse(label);
  } on FormatException {
    return DateTime(2000);
  }
}

/// Refreshes all providers backing the mobile home transaction feed.
Future<void> refreshMobileHomeTransactions(WidgetRef ref) async {
  await Future.wait([
    ref.read(saleInvoicesProvider.notifier).refresh(),
    ref.read(estimateQuotationsProvider.notifier).refresh(),
    ref.read(paymentInRecordsProvider.notifier).refresh(),
    ref.read(purchaseBillsProvider.notifier).refresh(),
    ref.read(expenseTransactionsProvider.notifier).refresh(),
  ]);
}
