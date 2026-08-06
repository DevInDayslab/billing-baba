import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_orders_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_return_provider.dart';
import 'package:billing_baba/features/sales/application/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/application/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/application/job_work_orders_provider.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/application/sale_fa_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/application/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/application/sale_return_provider.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Max rows pulled from each backing list for the home transaction feed.
const homeTransactionsPerSource = 30;

/// Recent transactions for the mobile home feed, aggregated from live providers.
final mobileHomeTransactionsProvider =
    Provider<AsyncValue<List<MobileHomeTransactionItem>>>((ref) {
      final loadingStates = [
        ref.watch(saleInvoicesProvider),
        ref.watch(estimateQuotationsProvider),
        ref.watch(salesDocumentsListProvider(proformaListScope())),
        ref.watch(paymentInRecordsProvider),
        ref.watch(saleOrdersProvider),
        ref.watch(deliveryChallansProvider),
        ref.watch(saleReturnsProvider),
        ref.watch(saleFaProvider),
        ref.watch(jobWorkOrdersListProvider),
        ref.watch(purchaseBillsProvider),
        ref.watch(paymentOutRecordsProvider),
        ref.watch(purchaseOrdersProvider),
        ref.watch(purchaseReturnsProvider),
        ref.watch(purchaseFaProvider),
        ref.watch(expenseTransactionsProvider),
      ];

      final hasAnyData = loadingStates.any((state) => state.hasValue);
      final stillLoading = loadingStates.any(
        (state) => state.isLoading && !state.hasValue,
      );

      if (!hasAnyData && stillLoading) {
        return const AsyncValue.loading();
      }

      final items = <MobileHomeTransactionItem>[];

      ref.watch(saleInvoicesProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromSaleInvoice),
        );
      });
      ref.watch(estimateQuotationsProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromSaleInvoice),
        );
      });
      ref.watch(salesDocumentsListProvider(proformaListScope())).whenData((
        page,
      ) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromSaleInvoice),
        );
      });
      ref.watch(paymentInRecordsProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromPaymentIn),
        );
      });
      ref.watch(saleOrdersProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromSaleInvoice),
        );
      });
      ref.watch(deliveryChallansProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromSaleInvoice),
        );
      });
      ref.watch(saleReturnsProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromSaleInvoice),
        );
      });
      ref.watch(saleFaProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromSaleFa),
        );
      });
      ref.watch(jobWorkOrdersListProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromJobWorkOrder),
        );
      });
      ref.watch(purchaseBillsProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromPurchaseBill),
        );
      });
      ref.watch(paymentOutRecordsProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromPaymentOut),
        );
      });
      ref.watch(purchaseOrdersProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromPurchaseOrder),
        );
      });
      ref.watch(purchaseReturnsProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromPurchaseReturn),
        );
      });
      ref.watch(purchaseFaProvider).whenData((page) {
        items.addAll(
          page.items
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromPurchaseFa),
        );
      });
      ref.watch(expenseTransactionsProvider).whenData((expenses) {
        items.addAll(
          expenses
              .take(homeTransactionsPerSource)
              .map(MobileTransactionMapper.homeFromExpense),
        );
      });

      items.sort((a, b) {
        final aDate = a.transactionDate ?? _parseHomeDate(a.dateLabel);
        final bDate = b.transactionDate ?? _parseHomeDate(b.dateLabel);
        return bDate.compareTo(aDate);
      });

      if (items.isEmpty) {
        final firstError = loadingStates
            .where((state) => state.hasError)
            .map((state) => state.error!)
            .firstOrNull;
        if (firstError != null) {
          return AsyncValue.error(firstError, StackTrace.current);
        }
        return const AsyncValue.data([]);
      }

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
    ref
        .read(salesDocumentsListProvider(proformaListScope()).notifier)
        .refresh(),
    ref.read(paymentInRecordsProvider.notifier).refresh(),
    ref.read(saleOrdersProvider.notifier).refresh(),
    ref.read(deliveryChallansProvider.notifier).refresh(),
    ref.read(saleReturnsProvider.notifier).refresh(),
    ref.read(saleFaProvider.notifier).refresh(),
    ref.read(jobWorkOrdersListProvider.notifier).refresh(),
    ref.read(purchaseBillsProvider.notifier).refresh(),
    ref.read(paymentOutRecordsProvider.notifier).refresh(),
    ref.read(purchaseOrdersProvider.notifier).refresh(),
    ref.read(purchaseReturnsProvider.notifier).refresh(),
    ref.read(purchaseFaProvider.notifier).refresh(),
    ref.read(expenseTransactionsProvider.notifier).refresh(),
  ]);
}
