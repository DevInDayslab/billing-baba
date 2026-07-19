import 'dart:async';

import 'package:billing_baba/features/dashboard/providers/dashboard_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/purchases/providers/expenses_provider.dart';
import 'package:billing_baba/features/purchases/providers/payment_out_provider.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:billing_baba/features/reports/providers/report_refresh_provider.dart';
import 'package:billing_baba/features/sales/providers/delivery_challan_provider.dart';
import 'package:billing_baba/features/sales/providers/estimate_quotation_provider.dart';
import 'package:billing_baba/features/sales/providers/job_work_orders_provider.dart';
import 'package:billing_baba/features/sales/providers/payment_in_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_fa_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_return_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void invalidateDashboard(Ref ref) {
  ref.invalidate(dashboardProvider);
}

void invalidatePartyBalances(Ref ref) {
  ref.invalidate(partyListProvider);
}

void invalidatePartyTimeline(Ref ref, String partyId) {
  ref.invalidate(partyTimelineProvider(partyId));
  ref.invalidate(partyLedgerProvider(partyId));
}

void invalidatePartyLedger(Ref ref, String partyId) {
  invalidatePartyTimeline(ref, partyId);
}

void _schedulePartyLedgerRefresh(
  Ref ref,
  String partyId,
  List<Future<void>> refreshTasks,
) {
  final timeline = partyTimelineProvider(partyId);
  final ledger = partyLedgerProvider(partyId);

  // Auto-dispose providers must not be invalidated then refreshed, and must
  // only be refreshed while a listener still holds them alive.
  if (ref.exists(timeline)) {
    refreshTasks.add(ref.read(timeline.notifier).refresh());
  } else {
    ref.invalidate(timeline);
  }

  if (ref.exists(ledger)) {
    refreshTasks.add(ref.read(ledger.notifier).refresh());
  } else {
    ref.invalidate(ledger);
  }
}

/// Refetches dashboard and party timeline so dependent screens update immediately.
///
/// Inventory refresh is intentionally deferred — it paginates the full catalog and
/// was blocking dashboard/party timeline invalidation for several seconds.
Future<void> _refreshDependentViews(
  Ref ref,
  MutationRefreshContext? context,
) async {
  if (!ref.mounted) return;

  invalidateDashboard(ref);

  final partyId = context?.partyId?.trim();
  final refreshTasks = <Future<void>>[
    ref.read(dashboardProvider.notifier).refresh(),
  ];

  if (partyId != null && partyId.isNotEmpty) {
    _schedulePartyLedgerRefresh(ref, partyId, refreshTasks);
  } else {
    invalidatePartyBalances(ref);
  }

  await Future.wait(refreshTasks);
  if (!ref.mounted) return;
}

void _refreshStockContextInBackground(
  Ref ref,
  MutationRefreshContext? context,
) {
  unawaited(() async {
    if (!ref.mounted) return;
    await _refreshStockContext(ref, context);
  }());
}

void invalidatePurchaseFaLists(Ref ref) {
  ref.invalidate(purchaseFaProvider);
}

void invalidateJobWorkLists(Ref ref) {
  ref.invalidate(jobWorkOrdersListProvider);
}

void invalidateSaleLists(Ref ref) {
  ref.invalidate(saleInvoicesProvider);
  ref.invalidate(saleOrdersProvider);
  ref.invalidate(saleReturnsProvider);
  ref.invalidate(estimateQuotationsProvider);
  ref.invalidate(deliveryChallansProvider);
  ref.invalidate(salesDocumentsListProvider(saleOrderListScope()));
  ref.invalidate(salesDocumentsListProvider(deliveryChallanListScope()));
  ref.invalidate(salesDocumentsListProvider(salesReturnListScope()));
  ref.invalidate(salesDocumentsListProvider(estimateListScope()));
  ref.invalidate(salesDocumentsListProvider(proformaListScope()));
}

void invalidateSaleFaLists(Ref ref) {
  ref.invalidate(saleFaProvider);
}

void invalidatePurchaseLists(Ref ref) {
  ref.invalidate(purchaseBillsProvider);
}

void invalidatePaymentInLists(Ref ref) {
  ref.invalidate(paymentInRecordsProvider);
}

void invalidatePaymentOutLists(Ref ref) {
  ref.invalidate(paymentOutRecordsProvider);
}

void invalidateExpenseLists(Ref ref) {
  ref.invalidate(expenseTransactionsProvider);
}

void invalidateInventoryLists(Ref ref) {
  ref.invalidate(inventoryItemsProvider);
}

void invalidateItemStock(Ref ref, Iterable<String> itemIds) {
  for (final itemId in itemIds) {
    invalidateItemCaches(ref, itemId);
  }
}

void invalidateReports(Ref ref) {
  bumpReportDataEpoch(ref);
}

typedef MutationRefreshContext = ({
  String? partyId,
  Iterable<String> itemIds,
});

void _refreshPartyContext(Ref ref, MutationRefreshContext? context) {
  final partyId = context?.partyId;
  if (partyId != null && partyId.isNotEmpty) {
    invalidatePartyTimeline(ref, partyId);
    return;
  }
  invalidatePartyBalances(ref);
}

/// Refetches the master item list without invalidating first.
///
/// Invalidating before [InventoryItems.refresh] races with [InventoryItems.build]
/// and can overwrite fresh stock with stale list data.
Future<void> refreshInventoryLists(Ref ref) {
  return ref.read(inventoryItemsProvider.notifier).refresh();
}

Future<void> _refreshStockContext(
  Ref ref,
  MutationRefreshContext? context,
) async {
  await refreshInventoryLists(ref);
  if (!ref.mounted) return;

  final itemIds = context?.itemIds;
  if (itemIds != null && itemIds.isNotEmpty) {
    invalidateItemStock(ref, itemIds);
  }
}

/// After sale invoice create/edit/delete/finalize or sale return.
Future<void> refreshAfterSaleMutation(
  Ref ref, {
  MutationRefreshContext? context,
}) async {
  if (!ref.mounted) return;
  invalidateSaleLists(ref);
  invalidatePaymentInLists(ref);
  await _refreshDependentViews(ref, context);
  if (!ref.mounted) return;
  _refreshStockContextInBackground(ref, context);
}

/// After purchase bill create/edit/delete.
Future<void> refreshAfterPurchaseMutation(
  Ref ref, {
  MutationRefreshContext? context,
}) async {
  if (!ref.mounted) return;
  invalidatePurchaseLists(ref);
  invalidatePaymentOutLists(ref);
  await _refreshDependentViews(ref, context);
  if (!ref.mounted) return;
  _refreshStockContextInBackground(ref, context);
}

/// After payment in create/edit/delete.
void refreshAfterPaymentIn(
  Ref ref, {
  MutationRefreshContext? context,
}) {
  invalidatePaymentInLists(ref);
  invalidateSaleLists(ref);
  invalidateDashboard(ref);
  _refreshPartyContext(ref, context);
}

/// After payment out create/edit/delete.
void refreshAfterPaymentOut(
  Ref ref, {
  MutationRefreshContext? context,
}) {
  invalidatePaymentOutLists(ref);
  invalidatePurchaseLists(ref);
  invalidateDashboard(ref);
  _refreshPartyContext(ref, context);
}

/// After expense create/edit/delete.
void refreshAfterExpense(
  Ref ref, {
  MutationRefreshContext? context,
}) {
  invalidateExpenseLists(ref);
  invalidateDashboard(ref);
  _refreshPartyContext(ref, context);
}

/// After sale return / credit note affecting receivables.
Future<void> refreshAfterSaleReturn(
  Ref ref, {
  MutationRefreshContext? context,
}) async {
  if (!ref.mounted) return;
  invalidateSaleLists(ref);
  await _refreshDependentViews(ref, context);
  if (!ref.mounted) return;
  _refreshStockContextInBackground(ref, context);
}

/// After purchase return / debit note.
Future<void> refreshAfterPurchaseReturn(
  Ref ref, {
  MutationRefreshContext? context,
}) async {
  if (!ref.mounted) return;
  invalidatePurchaseLists(ref);
  await _refreshDependentViews(ref, context);
  if (!ref.mounted) return;
  _refreshStockContextInBackground(ref, context);
}

/// After party create/edit.
void refreshAfterPartyMutation(Ref ref) {
  invalidatePartyBalances(ref);
  invalidateDashboard(ref);
}

/// After sale fixed-asset create/edit/delete.
void refreshAfterSaleFaMutation(
  Ref ref, {
  MutationRefreshContext? context,
}) {
  invalidateSaleFaLists(ref);
  invalidatePaymentInLists(ref);
  invalidateDashboard(ref);
  _refreshPartyContext(ref, context);
}

/// After purchase fixed-asset create/edit/delete.
void refreshAfterPurchaseFaMutation(
  Ref ref, {
  MutationRefreshContext? context,
}) {
  invalidatePurchaseFaLists(ref);
  invalidatePaymentOutLists(ref);
  invalidateDashboard(ref);
  _refreshPartyContext(ref, context);
}

/// After job work order create/edit/delete.
void refreshAfterJobWorkMutation(
  Ref ref, {
  MutationRefreshContext? context,
}) {
  invalidateJobWorkLists(ref);
  invalidateDashboard(ref);
  _refreshPartyContext(ref, context);
}

/// After item create/edit affecting inventory dashboard widgets.
Future<void> refreshAfterItemMutation(
  Ref ref, {
  MutationRefreshContext? context,
}) async {
  await refreshInventoryLists(ref);
  invalidateDashboard(ref);
  final itemIds = context?.itemIds;
  if (itemIds != null && itemIds.isNotEmpty) {
    invalidateItemStock(ref, itemIds);
  }
}
