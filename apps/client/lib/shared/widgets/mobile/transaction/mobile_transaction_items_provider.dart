import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_fa_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_orders_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_return_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/sales/application/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/application/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/application/job_work_orders_provider.dart';
import 'package:billing_baba/features/sales/application/job_work_service.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/application/sale_fa_provider.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/application/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/application/sale_return_provider.dart';
import 'package:billing_baba/features/sales/application/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_catalog.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_mapper.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/providers/provider.dart';

/// Live transaction rows keyed by [MobileTransactionScopeDefinition.scopeId].
final ProviderFamily<AsyncValue<List<MobileTransactionListItem>>, String>
mobileTransactionItemsProvider =
    Provider.family<AsyncValue<List<MobileTransactionListItem>>, String>((
      ref,
      scopeId,
    ) {
      final definition = MobileTransactionCatalog.all
          .where((item) => item.scopeId == scopeId)
          .firstOrNull;

      if (definition == null) {
        return const AsyncValue.data([]);
      }

      return _itemsForRoute(ref, definition);
    });

AsyncValue<List<MobileTransactionListItem>> _itemsForRoute(
  Ref ref,
  MobileTransactionScopeDefinition definition,
) {
  final icon = definition.leadingIcon;

  return switch (definition.route) {
    AppRoutes.saleInvoices => _mapPaginatedSaleInvoices(
      ref.watch(saleInvoicesProvider),
      icon,
    ),
    AppRoutes.saleEstimateQuotation => _mapPaginatedSaleInvoices(
      ref.watch(estimateQuotationsProvider),
      icon,
      useOpenDocumentMapper: true,
    ),
    AppRoutes.saleProformaInvoice => _mapPaginatedSaleInvoices(
      ref.watch(salesDocumentsListProvider(proformaListScope())),
      icon,
      useOpenDocumentMapper: true,
    ),
    AppRoutes.salePaymentIn => _mapPaymentIn(
      ref.watch(paymentInRecordsProvider),
      icon,
    ),
    AppRoutes.saleOrder => _mapPaginatedSaleInvoices(
      ref.watch(saleOrdersProvider),
      icon,
      useOpenDocumentMapper: true,
    ),
    AppRoutes.saleDeliveryChallan => _mapPaginatedSaleInvoices(
      ref.watch(deliveryChallansProvider),
      icon,
      useOpenDocumentMapper: true,
    ),
    AppRoutes.saleJobWorkOut => _mapJobWorkOrders(
      ref.watch(jobWorkOrdersListProvider),
      icon,
    ),
    AppRoutes.saleReturnCreditNote => _mapPaginatedSaleInvoices(
      ref.watch(saleReturnsProvider),
      icon,
    ),
    AppRoutes.saleFa => _mapSaleFa(
      ref.watch(saleFaProvider),
      icon,
    ),
    AppRoutes.purchaseBills => _mapPurchaseBills(
      ref.watch(purchaseBillsProvider),
      icon,
    ),
    AppRoutes.purchasePaymentOut => _mapPaymentOut(
      ref.watch(paymentOutRecordsProvider),
      icon,
    ),
    AppRoutes.purchaseExpenses => _mapExpenses(
      ref.watch(expenseTransactionsProvider),
      icon,
    ),
    AppRoutes.purchaseOrder => _mapPurchaseOrders(
      ref.watch(purchaseOrdersProvider),
      icon,
    ),
    AppRoutes.purchaseReturnDebitNote => _mapPurchaseReturns(
      ref.watch(purchaseReturnsProvider),
      icon,
    ),
    AppRoutes.purchaseFa => _mapPurchaseFa(
      ref.watch(purchaseFaProvider),
      icon,
    ),
    _ => const AsyncValue.data([]),
  };
}

AsyncValue<List<MobileTransactionListItem>> _mapPaginatedSaleInvoices(
  AsyncValue<PaginatedSaleInvoices> asyncValue,
  IconData? icon, {
  bool useOpenDocumentMapper = false,
}) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) {
      final items = page.items.map((invoice) {
        if (useOpenDocumentMapper) {
          return MobileTransactionMapper.fromOpenSaleDocument(
            invoice,
            leadingIcon: icon,
          );
        }
        return MobileTransactionMapper.fromSaleInvoice(
          invoice,
          leadingIcon: icon,
        );
      }).toList();
      return AsyncValue.data(items);
    },
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapPaymentIn(
  AsyncValue<PaginatedPaymentIn> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) => AsyncValue.data(
      page.items
          .map(
            (payment) => MobileTransactionMapper.fromPaymentIn(
              payment,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapPaymentOut(
  AsyncValue<PaginatedPaymentOut> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) => AsyncValue.data(
      page.items
          .map(
            (payment) => MobileTransactionMapper.fromPaymentOut(
              payment,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapJobWorkOrders(
  AsyncValue<PaginatedJobWorkOrders> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) => AsyncValue.data(
      page.items
          .map(
            (order) => MobileTransactionMapper.fromJobWorkOrder(
              order,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapSaleFa(
  AsyncValue<PaginatedSaleFaRecords> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) => AsyncValue.data(
      page.items
          .map(
            (fa) => MobileTransactionMapper.fromSaleFa(
              fa,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapPurchaseBills(
  AsyncValue<PaginatedPurchaseBills> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) => AsyncValue.data(
      page.items
          .map(
            (bill) => MobileTransactionMapper.fromPurchaseBill(
              bill,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapPurchaseOrders(
  AsyncValue<PaginatedPurchaseOrders> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) => AsyncValue.data(
      page.items
          .map(
            (order) => MobileTransactionMapper.fromPurchaseOrder(
              order,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapPurchaseReturns(
  AsyncValue<PaginatedPurchaseReturns> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) => AsyncValue.data(
      page.items
          .map(
            (returnDoc) => MobileTransactionMapper.fromPurchaseReturn(
              returnDoc,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapPurchaseFa(
  AsyncValue<PaginatedPurchaseFaRecords> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (page) => AsyncValue.data(
      page.items
          .map(
            (fa) => MobileTransactionMapper.fromPurchaseFa(
              fa,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

AsyncValue<List<MobileTransactionListItem>> _mapExpenses(
  AsyncValue<List<ExpenseTransactionModel>> asyncValue,
  IconData? icon,
) {
  return asyncValue.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (expenses) => AsyncValue.data(
      expenses
          .map(
            (expense) => MobileTransactionMapper.fromExpense(
              expense,
              leadingIcon: icon,
            ),
          )
          .toList(),
    ),
  );
}

/// Refreshes the backend provider backing a mobile transaction list scope.
Future<void> refreshMobileTransactionItems(
  WidgetRef ref,
  String scopeId,
) async {
  final definition = MobileTransactionCatalog.all
      .where((item) => item.scopeId == scopeId)
      .firstOrNull;
  if (definition == null) return;

  await _refreshRoute(ref, definition.route);
}

Future<void> _refreshRoute(WidgetRef ref, String route) async {
  switch (route) {
    case AppRoutes.saleInvoices:
      await ref.read(saleInvoicesProvider.notifier).refresh();
    case AppRoutes.saleEstimateQuotation:
      await ref.read(estimateQuotationsProvider.notifier).refresh();
    case AppRoutes.saleProformaInvoice:
      await ref
          .read(salesDocumentsListProvider(proformaListScope()).notifier)
          .refresh();
    case AppRoutes.salePaymentIn:
      await ref.read(paymentInRecordsProvider.notifier).refresh();
    case AppRoutes.saleOrder:
      await ref.read(saleOrdersProvider.notifier).refresh();
    case AppRoutes.saleDeliveryChallan:
      await ref.read(deliveryChallansProvider.notifier).refresh();
    case AppRoutes.saleJobWorkOut:
      await ref.read(jobWorkOrdersListProvider.notifier).refresh();
    case AppRoutes.saleReturnCreditNote:
      await ref.read(saleReturnsProvider.notifier).refresh();
    case AppRoutes.saleFa:
      await ref.read(saleFaProvider.notifier).refresh();
    case AppRoutes.purchaseBills:
      await ref.read(purchaseBillsProvider.notifier).refresh();
    case AppRoutes.purchasePaymentOut:
      await ref.read(paymentOutRecordsProvider.notifier).refresh();
    case AppRoutes.purchaseExpenses:
      await ref.read(expenseTransactionsProvider.notifier).refresh();
    case AppRoutes.purchaseOrder:
      await ref.read(purchaseOrdersProvider.notifier).refresh();
    case AppRoutes.purchaseReturnDebitNote:
      await ref.read(purchaseReturnsProvider.notifier).refresh();
    case AppRoutes.purchaseFa:
      await ref.read(purchaseFaProvider.notifier).refresh();
  }
}
