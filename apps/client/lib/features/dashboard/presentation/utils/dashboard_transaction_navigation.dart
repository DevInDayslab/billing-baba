import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void navigateToDashboardTransaction(
  BuildContext context,
  DashboardRecentTransactionModel transaction,
) {
  final referenceId = transaction.referenceId;
  if (referenceId == null || referenceId.isEmpty) return;

  final route = switch (transaction.referenceType) {
    'sales_documents' => '${AppRoutes.editSale}/$referenceId',
    'purchase_documents' =>
      transaction.type == DashboardTransactionType.purchaseReturn
          ? '${AppRoutes.editDebitNote}/$referenceId'
          : '${AppRoutes.editPurchase}/$referenceId',
    'payments' =>
      transaction.type == DashboardTransactionType.paymentOut
          ? AppRoutes.purchasePaymentOut
          : AppRoutes.salePaymentIn,
    'expenses' => '${AppRoutes.editExpense}/$referenceId',
    _ => null,
  };

  if (route != null) {
    context.push(route);
  }
}

String dashboardTransactionTypeLabel(DashboardTransactionType type) =>
    switch (type) {
      DashboardTransactionType.sale => 'Sale Invoice',
      DashboardTransactionType.purchase => 'Purchase Bill',
      DashboardTransactionType.paymentIn => 'Payment In',
      DashboardTransactionType.paymentOut => 'Payment Out',
      DashboardTransactionType.expense => 'Expense',
      DashboardTransactionType.saleReturn => 'Sale Return',
      DashboardTransactionType.purchaseReturn => 'Purchase Return',
      DashboardTransactionType.opening => 'Opening Balance',
    };

bool dashboardTransactionIsIncoming(DashboardTransactionType type) =>
    switch (type) {
      DashboardTransactionType.sale ||
      DashboardTransactionType.paymentIn => true,
      _ => false,
    };

String dashboardTransactionBadgeLabel(DashboardTransactionType type) =>
    switch (type) {
      DashboardTransactionType.sale => 'S',
      DashboardTransactionType.purchase => 'P',
      DashboardTransactionType.paymentIn => 'In',
      DashboardTransactionType.paymentOut => 'Out',
      DashboardTransactionType.expense => 'E',
      DashboardTransactionType.saleReturn => 'SR',
      DashboardTransactionType.purchaseReturn => 'PR',
      DashboardTransactionType.opening => 'OB',
    };
