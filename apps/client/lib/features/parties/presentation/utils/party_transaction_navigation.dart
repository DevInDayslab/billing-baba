import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void navigateToPartyLedgerTransaction(
  BuildContext context,
  PartyLedgerTransactionModel transaction,
) {
  final referenceId = transaction.referenceId;
  if (referenceId == null || referenceId.isEmpty) return;

  final source = transaction.source.isNotEmpty
      ? transaction.source
      : (transaction.referenceType ?? '');

  final route = switch (source) {
    'sales_documents' => switch (transaction.sourceType) {
      'estimate' => '${AppRoutes.editEstimate}/$referenceId',
      'sale_order' => '${AppRoutes.editSaleOrder}/$referenceId',
      'delivery_challan' => '${AppRoutes.editDeliveryChallan}/$referenceId',
      'sales_return' => '${AppRoutes.editCreditNote}/$referenceId',
      _ => '${AppRoutes.editSale}/$referenceId',
    },
    'purchase_documents' => switch (transaction.sourceType) {
      'purchase_order' => '${AppRoutes.editPurchaseOrder}/$referenceId',
      'purchase_return' => '${AppRoutes.editDebitNote}/$referenceId',
      _ => '${AppRoutes.editPurchase}/$referenceId',
    },
    'payments' =>
      transaction.direction == 'paid'
          ? AppRoutes.purchasePaymentOut
          : AppRoutes.salePaymentIn,
    'expenses' => '${AppRoutes.editExpense}/$referenceId',
    'sale_fa_batches' => '${AppRoutes.editSaleFa}/$referenceId',
    'purchase_fa_batches' => '${AppRoutes.editPurchaseFa}/$referenceId',
    'job_work_orders' => AppRoutes.saleJobWorkOut,
    _ => null,
  };

  if (route != null) {
    context.push(route);
  }
}
