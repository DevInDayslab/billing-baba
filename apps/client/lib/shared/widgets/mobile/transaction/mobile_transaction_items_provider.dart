import 'package:billing_baba/core/router/app_routes.dart';
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
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_catalog.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_live_mapper.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live transaction rows keyed by [MobileTransactionScopeDefinition.scopeId].
///
/// Backed by the same desktop list providers so mobile and desktop stay in sync.
final mobileTransactionItemsProvider =
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

      return _watchLiveItems(ref, definition);
    });

AsyncValue<List<MobileTransactionListItem>> _watchLiveItems(
  Ref ref,
  MobileTransactionScopeDefinition definition,
) {
  final icon = definition.leadingIcon ?? Icons.receipt_long_outlined;

  return switch (definition.route) {
    AppRoutes.saleInvoices => ref
        .watch(saleInvoicesProvider)
        .whenData(
          (page) => page.items
              .map(
                (item) => MobileTransactionLiveMapper.fromSaleInvoice(
                  item,
                  leadingIcon: icon,
                ),
              )
              .toList(),
        ),
    AppRoutes.saleEstimateQuotation => ref
        .watch(estimateQuotationsProvider)
        .whenData(
          (page) => page.items
              .map(
                (item) => MobileTransactionLiveMapper.fromSaleInvoice(
                  item,
                  leadingIcon: icon,
                ),
              )
              .toList(),
        ),
    AppRoutes.saleProformaInvoice => ref
        .watch(salesDocumentsListProvider(proformaListScope()))
        .whenData(
          (page) => page.items
              .map(
                (item) => MobileTransactionLiveMapper.fromSaleInvoice(
                  item,
                  leadingIcon: icon,
                ),
              )
              .toList(),
        ),
    AppRoutes.salePaymentIn => ref
        .watch(paymentInRecordsProvider)
        .whenData(
          (page) => page.items
              .map(MobileTransactionLiveMapper.fromPaymentIn)
              .toList(),
        ),
    AppRoutes.saleOrder => ref
        .watch(saleOrdersProvider)
        .whenData(
          (page) => page.items
              .map(
                (item) => MobileTransactionLiveMapper.fromSaleInvoice(
                  item,
                  leadingIcon: icon,
                  useSaleOrderStatus: true,
                ),
              )
              .toList(),
        ),
    AppRoutes.saleDeliveryChallan => ref
        .watch(deliveryChallansProvider)
        .whenData(
          (page) => page.items
              .map(
                (item) => MobileTransactionLiveMapper.fromSaleInvoice(
                  item,
                  leadingIcon: icon,
                ),
              )
              .toList(),
        ),
    AppRoutes.saleJobWorkOut => ref
        .watch(jobWorkOrdersListProvider)
        .whenData(
          (page) => page.items
              .map(MobileTransactionLiveMapper.fromJobWork)
              .toList(),
        ),
    AppRoutes.saleReturnCreditNote => ref
        .watch(saleReturnsProvider)
        .whenData(
          (page) => page.items
              .map(
                (item) => MobileTransactionLiveMapper.fromSaleInvoice(
                  item,
                  leadingIcon: icon,
                ),
              )
              .toList(),
        ),
    AppRoutes.saleFa => ref
        .watch(saleFaProvider)
        .whenData(
          (page) =>
              page.items.map(MobileTransactionLiveMapper.fromSaleFa).toList(),
        ),
    AppRoutes.purchaseBills => ref
        .watch(purchaseBillsProvider)
        .whenData(
          (page) => page.items
              .map(MobileTransactionLiveMapper.fromPurchaseBill)
              .toList(),
        ),
    AppRoutes.purchasePaymentOut => ref
        .watch(paymentOutRecordsProvider)
        .whenData(
          (page) => page.items
              .map(MobileTransactionLiveMapper.fromPaymentOut)
              .toList(),
        ),
    AppRoutes.purchaseExpenses => ref
        .watch(expenseTransactionsProvider)
        .whenData(
          (items) =>
              items.map(MobileTransactionLiveMapper.fromExpense).toList(),
        ),
    AppRoutes.purchaseOrder => ref
        .watch(purchaseOrdersProvider)
        .whenData(
          (page) => page.items
              .map(MobileTransactionLiveMapper.fromPurchaseOrder)
              .toList(),
        ),
    AppRoutes.purchaseReturnDebitNote => ref
        .watch(purchaseReturnsProvider)
        .whenData(
          (page) => page.items
              .map(MobileTransactionLiveMapper.fromPurchaseReturn)
              .toList(),
        ),
    AppRoutes.purchaseFa => ref
        .watch(purchaseFaProvider)
        .whenData(
          (page) => page.items
              .map(MobileTransactionLiveMapper.fromPurchaseFa)
              .toList(),
        ),
    _ => const AsyncValue.data([]),
  };
}

/// Pull-to-refresh for a mobile transaction list route.
Future<void> refreshMobileTransactionItems(WidgetRef ref, String route) async {
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
