import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/application/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_mapper.dart';
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

      // Show whatever has arrived — waiting for all five feed sources to settle
      // left the home screen on a spinner while sync / fetch-all was in flight.
      if (!hasAnyData && stillLoading) {
        return const AsyncValue.loading();
      }

      if (!hasAnyData) {
        for (final state in loadingStates) {
          if (state.hasError) {
            return AsyncValue.error(
              state.error!,
              state.stackTrace ?? StackTrace.current,
            );
          }
        }
        return const AsyncValue.data([]);
      }

      final items = <MobileHomeTransactionItem>[];

      salesAsync.whenData((page) {
        items.addAll(page.items.map(MobileTransactionMapper.homeFromSaleInvoice));
      });
      estimatesAsync.whenData((page) {
        items.addAll(page.items.map(MobileTransactionMapper.homeFromSaleInvoice));
      });
      paymentInAsync.whenData((page) {
        items.addAll(page.items.map(MobileTransactionMapper.homeFromPaymentIn));
      });
      purchasesAsync.whenData((page) {
        items.addAll(page.items.map(MobileTransactionMapper.homeFromPurchaseBill));
      });
      expensesAsync.whenData((expenses) {
        items.addAll(expenses.map(MobileTransactionMapper.homeFromExpense));
      });

      items.sort((a, b) {
        final aDate = _parseHomeDate(a.dateLabel);
        final bDate = _parseHomeDate(b.dateLabel);
        return bDate.compareTo(aDate);
      });

      return AsyncValue.data(items);
    });

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
