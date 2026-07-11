import 'package:billing_baba/features/dashboard/providers/dashboard_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/purchases/providers/expenses_provider.dart';
import 'package:billing_baba/features/purchases/providers/payment_out_provider.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/providers/payment_in_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_fa_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void invalidateDashboard(Ref ref) {
  ref.invalidate(dashboardProvider);
}

void invalidatePartyBalances(Ref ref) {
  ref.invalidate(partyListProvider);
}

void invalidateSaleLists(Ref ref) {
  ref.invalidate(saleInvoicesProvider);
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

/// After sale invoice create/edit/delete/finalize or sale return.
void refreshAfterSaleMutation(Ref ref) {
  invalidateSaleLists(ref);
  invalidatePaymentInLists(ref);
  invalidateDashboard(ref);
  invalidatePartyBalances(ref);
}

/// After purchase bill create/edit/delete.
void refreshAfterPurchaseMutation(Ref ref) {
  invalidatePurchaseLists(ref);
  invalidatePaymentOutLists(ref);
  invalidateDashboard(ref);
  invalidatePartyBalances(ref);
}

/// After payment in create/edit/delete.
void refreshAfterPaymentIn(Ref ref) {
  invalidatePaymentInLists(ref);
  invalidateSaleLists(ref);
  invalidateDashboard(ref);
  invalidatePartyBalances(ref);
}

/// After payment out create/edit/delete.
void refreshAfterPaymentOut(Ref ref) {
  invalidatePaymentOutLists(ref);
  invalidatePurchaseLists(ref);
  invalidateDashboard(ref);
  invalidatePartyBalances(ref);
}

/// After expense create/edit/delete.
void refreshAfterExpense(Ref ref) {
  invalidateExpenseLists(ref);
  invalidateDashboard(ref);
}

/// After sale return / credit note affecting receivables.
void refreshAfterSaleReturn(Ref ref) {
  invalidateSaleLists(ref);
  invalidateDashboard(ref);
  invalidatePartyBalances(ref);
}

/// After purchase return / debit note.
void refreshAfterPurchaseReturn(Ref ref) {
  invalidatePurchaseLists(ref);
  invalidateDashboard(ref);
  invalidatePartyBalances(ref);
}

/// After party create/edit.
void refreshAfterPartyMutation(Ref ref) {
  invalidatePartyBalances(ref);
  invalidateDashboard(ref);
}

/// After sale fixed-asset create/edit/delete.
void refreshAfterSaleFaMutation(Ref ref) {
  invalidateSaleFaLists(ref);
  invalidatePaymentInLists(ref);
  invalidateDashboard(ref);
  invalidatePartyBalances(ref);
}

/// After item create/edit affecting inventory dashboard widgets.
void refreshAfterItemMutation(Ref ref) {
  invalidateInventoryLists(ref);
  invalidateDashboard(ref);
}
