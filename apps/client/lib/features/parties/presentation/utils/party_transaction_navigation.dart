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

  final route = switch (transaction.referenceType) {
    'sales_documents' => '${AppRoutes.editSale}/$referenceId',
    'purchase_documents' => transaction.entryType == 'return'
        ? '${AppRoutes.editDebitNote}/$referenceId'
        : '${AppRoutes.editPurchase}/$referenceId',
    'payments' => transaction.direction == 'paid'
        ? AppRoutes.purchasePaymentOut
        : AppRoutes.salePaymentIn,
    'expenses' => '${AppRoutes.editExpense}/$referenceId',
    _ => null,
  };

  if (route != null) {
    context.push(route);
  }
}
