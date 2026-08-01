import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract final class MobileTransactionMapper {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  static final _listDateFormat = DateFormat('dd MMM yyyy');
  static final _homeDateFormat = DateFormat('dd MMM, yy');

  static String formatAmount(double amount) => _currencyFormat.format(amount);

  static String formatHomeAmount(double amount) =>
      '₹ ${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}';

  static MobileTransactionListItem fromSaleInvoice(
    SaleInvoiceModel invoice, {
    IconData? leadingIcon,
    String? statusOverride,
  }) {
    final (statusLabel, statusColor) = _saleInvoiceStatus(invoice.status);
    return MobileTransactionListItem(
      id: invoice.id,
      title: invoice.invoiceNo,
      subtitle: invoice.partyName,
      dateLabel: _listDateFormat.format(invoice.date),
      amountLabel: formatAmount(invoice.amount),
      statusLabel: statusOverride ?? statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: invoice.amount,
      sortDate: invoice.date,
      sortTitle: invoice.invoiceNo,
    );
  }

  static MobileTransactionListItem fromOpenSaleDocument(
    SaleInvoiceModel document, {
    IconData? leadingIcon,
  }) {
    final statusLabel = document.isDraft
        ? 'Draft'
        : document.documentStatus.lifecycleDisplayLabel;
    final statusColor = document.isCancelled
        ? const Color(0xFF9E9E9E)
        : document.documentStatus == SalesDocumentStatus.converted
        ? const Color(0xFF2E7D32)
        : AppColors.primary;
    return MobileTransactionListItem(
      id: document.id,
      title: document.invoiceNo,
      subtitle: document.partyName,
      dateLabel: _listDateFormat.format(document.date),
      amountLabel: formatAmount(document.amount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: document.amount,
      sortDate: document.date,
      sortTitle: document.invoiceNo,
    );
  }

  static MobileTransactionListItem fromPaymentIn(
    PaymentInModel payment, {
    IconData? leadingIcon,
  }) {
    final (statusLabel, statusColor) = switch (payment.status) {
      PaymentInStatus.unused => ('Unused', const Color(0xFFF9A825)),
      PaymentInStatus.partial => ('Partial', const Color(0xFFE65100)),
      PaymentInStatus.paid => ('Recorded', const Color(0xFF2E7D32)),
    };
    return MobileTransactionListItem(
      id: payment.id,
      title: payment.receiptNo,
      subtitle: payment.partyName,
      dateLabel: _listDateFormat.format(payment.date),
      amountLabel: formatAmount(payment.receivedAmount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: payment.receivedAmount,
      sortDate: payment.date,
      sortTitle: payment.receiptNo,
    );
  }

  static MobileTransactionListItem fromPaymentOut(
    PaymentOutModel payment, {
    IconData? leadingIcon,
  }) {
    final (statusLabel, statusColor) = switch (payment.status) {
      PaymentOutStatus.paid => ('Recorded', const Color(0xFF2E7D32)),
      PaymentOutStatus.pending => ('Pending', const Color(0xFFE65100)),
      PaymentOutStatus.cancelled => ('Cancelled', const Color(0xFF9E9E9E)),
    };
    return MobileTransactionListItem(
      id: payment.id,
      title: payment.receiptNo,
      subtitle: payment.partyName,
      dateLabel: _listDateFormat.format(payment.date),
      amountLabel: formatAmount(payment.paidAmount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: payment.paidAmount,
      sortDate: payment.date,
      sortTitle: payment.receiptNo,
    );
  }

  static MobileTransactionListItem fromJobWorkOrder(
    JobWorkOrderListItem order, {
    IconData? leadingIcon,
  }) {
    final date = order.invoiceDate ?? order.deliveryDate ?? DateTime.now();
    final (statusLabel, statusColor) = switch (order.status) {
      JobWorkOutStatus.open => ('Open', AppColors.primary),
      JobWorkOutStatus.closed => ('Closed', const Color(0xFF2E7D32)),
      JobWorkOutStatus.cancelled => ('Cancelled', const Color(0xFF9E9E9E)),
    };
    return MobileTransactionListItem(
      id: order.id,
      title: order.jobId,
      subtitle: order.party,
      dateLabel: _listDateFormat.format(date),
      amountLabel: formatAmount(order.grandTotal),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: order.grandTotal,
      sortDate: date,
      sortTitle: order.jobId,
    );
  }

  static MobileTransactionListItem fromSaleFa(
    SaleFaModel fa, {
    IconData? leadingIcon,
  }) {
    final (statusLabel, statusColor) = _saleFaStatus(fa.status);
    return MobileTransactionListItem(
      id: fa.id,
      title: fa.invoiceNo,
      subtitle: fa.partyName,
      dateLabel: _listDateFormat.format(fa.date),
      amountLabel: formatAmount(fa.amount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: fa.amount,
      sortDate: fa.date,
      sortTitle: fa.invoiceNo,
    );
  }

  static MobileTransactionListItem fromPurchaseBill(
    PurchaseBillModel bill, {
    IconData? leadingIcon,
  }) {
    final (statusLabel, statusColor) = _purchaseBillStatus(bill.status);
    return MobileTransactionListItem(
      id: bill.id,
      title: bill.invoiceNo,
      subtitle: bill.partyName,
      dateLabel: _listDateFormat.format(bill.date),
      amountLabel: formatAmount(bill.amount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: bill.amount,
      sortDate: bill.date,
      sortTitle: bill.invoiceNo,
    );
  }

  static MobileTransactionListItem fromPurchaseOrder(
    PurchaseOrderModel order, {
    IconData? leadingIcon,
  }) {
    final (statusLabel, statusColor) = switch (order.status) {
      PurchaseOrderStatus.open => ('Open', AppColors.primary),
      PurchaseOrderStatus.orderCompleted => ('Completed', const Color(0xFF2E7D32)),
      PurchaseOrderStatus.partiallyReceived => ('Partial', const Color(0xFFE65100)),
      PurchaseOrderStatus.cancelled => ('Cancelled', const Color(0xFF9E9E9E)),
    };
    return MobileTransactionListItem(
      id: order.id,
      title: order.orderNo,
      subtitle: order.partyName,
      dateLabel: _listDateFormat.format(order.date),
      amountLabel: formatAmount(order.amount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: order.amount,
      sortDate: order.date,
      sortTitle: order.orderNo,
    );
  }

  static MobileTransactionListItem fromPurchaseReturn(
    PurchaseReturnModel returnDoc, {
    IconData? leadingIcon,
  }) {
    final (statusLabel, statusColor) = _purchaseBillStatus(returnDoc.status);
    return MobileTransactionListItem(
      id: returnDoc.id,
      title: returnDoc.debitNoteNo,
      subtitle: returnDoc.partyName,
      dateLabel: _listDateFormat.format(returnDoc.date),
      amountLabel: formatAmount(returnDoc.total),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: returnDoc.total,
      sortDate: returnDoc.date,
      sortTitle: returnDoc.debitNoteNo,
    );
  }

  static MobileTransactionListItem fromPurchaseFa(
    PurchaseFaModel fa, {
    IconData? leadingIcon,
  }) {
    final (statusLabel, statusColor) = _purchaseFaStatus(fa.status);
    return MobileTransactionListItem(
      id: fa.id,
      title: fa.invoiceNo,
      subtitle: fa.partyName,
      dateLabel: _listDateFormat.format(fa.date),
      amountLabel: formatAmount(fa.amount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: fa.amount,
      sortDate: fa.date,
      sortTitle: fa.invoiceNo,
    );
  }

  static MobileTransactionListItem fromExpense(
    ExpenseTransactionModel expense, {
    IconData? leadingIcon,
  }) {
    final amount = expense.amount ?? 0;
    final (statusLabel, statusColor) = switch (expense.status) {
      ExpenseStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      ExpenseStatus.partial => ('Partial', const Color(0xFFE65100)),
      ExpenseStatus.pending => ('Pending', const Color(0xFFF9A825)),
      null => ('Recorded', AppColors.textSecondary),
    };
    return MobileTransactionListItem(
      id: expense.id,
      title: expense.transactionNo,
      subtitle: expense.party,
      dateLabel: _listDateFormat.format(expense.date),
      amountLabel: formatAmount(amount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: amount,
      sortDate: expense.date,
      sortTitle: expense.transactionNo,
    );
  }

  static MobileHomeTransactionItem homeFromSaleInvoice(SaleInvoiceModel invoice) {
    final isEstimate = invoice.documentSeries == SalesConstants.estimateSeries;
    final filterType = isEstimate
        ? MobileHomeTransactionFilterType.estimate
        : MobileHomeTransactionFilterType.sale;
    final prefix = isEstimate ? 'EST' : 'SALE';
    final statusLabel = invoice.isDraft
        ? '$prefix : DRAFT'
        : '$prefix : ${_saleInvoiceStatusLabel(invoice.status).toUpperCase()}';
    final statusType = isEstimate
        ? MobileHomeTransactionStatusType.estimateOpen
        : invoice.status == SaleInvoiceStatus.paid
        ? MobileHomeTransactionStatusType.salePaid
        : MobileHomeTransactionStatusType.estimateOpen;
    return MobileHomeTransactionItem(
      id: invoice.id,
      partyName: invoice.partyName,
      documentNumber: invoice.invoiceNo,
      statusLabel: statusLabel,
      statusType: statusType,
      filterType: filterType,
      dateLabel: _homeDateFormat.format(invoice.date),
      dueDateLabel: invoice.dueDate != null
          ? 'Due : ${_homeDateFormat.format(invoice.dueDate!)}'
          : null,
      totalLabel: formatHomeAmount(invoice.amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(invoice.balance),
    );
  }

  static MobileHomeTransactionItem homeFromPaymentIn(PaymentInModel payment) {
    final statusLabel = payment.status == PaymentInStatus.unused
        ? 'PAYIN : UNUSED'
        : 'PAYIN : ${payment.status.name.toUpperCase()}';
    return MobileHomeTransactionItem(
      id: payment.id,
      partyName: payment.partyName,
      documentNumber: payment.receiptNo,
      statusLabel: statusLabel,
      statusType: MobileHomeTransactionStatusType.payinUnused,
      filterType: MobileHomeTransactionFilterType.paymentIn,
      dateLabel: _homeDateFormat.format(payment.date),
      totalLabel: formatHomeAmount(payment.receivedAmount),
      balanceLabel: 'Unused',
      balanceValueLabel: formatHomeAmount(payment.balanceDue),
    );
  }

  static MobileHomeTransactionItem homeFromPurchaseBill(PurchaseBillModel bill) {
    return MobileHomeTransactionItem(
      id: bill.id,
      partyName: bill.partyName,
      documentNumber: bill.invoiceNo,
      statusLabel: 'PURCHASE : ${_purchaseBillStatusLabel(bill.status).toUpperCase()}',
      statusType: MobileHomeTransactionStatusType.estimateOpen,
      filterType: MobileHomeTransactionFilterType.purchase,
      dateLabel: _homeDateFormat.format(bill.date),
      dueDateLabel: 'Due : ${_homeDateFormat.format(bill.dueDate)}',
      totalLabel: formatHomeAmount(bill.amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(bill.balanceDue),
    );
  }

  static MobileHomeTransactionItem homeFromExpense(ExpenseTransactionModel expense) {
    final amount = expense.amount ?? 0;
    return MobileHomeTransactionItem(
      id: expense.id,
      partyName: expense.party,
      documentNumber: expense.transactionNo,
      statusLabel: 'EXPENSE : ${expense.status?.name.toUpperCase() ?? 'RECORDED'}',
      statusType: MobileHomeTransactionStatusType.estimateOpen,
      filterType: MobileHomeTransactionFilterType.purchase,
      dateLabel: _homeDateFormat.format(expense.date),
      totalLabel: formatHomeAmount(amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(expense.balance ?? 0),
    );
  }

  static (String, Color) _saleInvoiceStatus(SaleInvoiceStatus status) {
    return switch (status) {
      SaleInvoiceStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      SaleInvoiceStatus.unpaid => ('Unpaid', const Color(0xFFC62828)),
      SaleInvoiceStatus.partiallyPaid => ('Partial', const Color(0xFFE65100)),
      SaleInvoiceStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      SaleInvoiceStatus.cancelled => ('Cancelled', const Color(0xFF9E9E9E)),
    };
  }

  static String _saleInvoiceStatusLabel(SaleInvoiceStatus status) =>
      _saleInvoiceStatus(status).$1;

  static (String, Color) _saleFaStatus(SaleFaStatus status) {
    return switch (status) {
      SaleFaStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      SaleFaStatus.unpaid => ('Unpaid', const Color(0xFFC62828)),
      SaleFaStatus.partiallyPaid => ('Partial', const Color(0xFFE65100)),
      SaleFaStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      SaleFaStatus.cancelled => ('Cancelled', const Color(0xFF9E9E9E)),
    };
  }

  static (String, Color) _purchaseBillStatus(PurchaseBillStatus status) {
    return switch (status) {
      PurchaseBillStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      PurchaseBillStatus.unpaid => ('Unpaid', const Color(0xFFC62828)),
      PurchaseBillStatus.partiallyPaid => ('Partial', const Color(0xFFE65100)),
      PurchaseBillStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      PurchaseBillStatus.cancelled => ('Cancelled', const Color(0xFF9E9E9E)),
    };
  }

  static String _purchaseBillStatusLabel(PurchaseBillStatus status) =>
      _purchaseBillStatus(status).$1;

  static (String, Color) _purchaseFaStatus(PurchaseFaStatus status) {
    return switch (status) {
      PurchaseFaStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      PurchaseFaStatus.unpaid => ('Unpaid', const Color(0xFFC62828)),
      PurchaseFaStatus.partiallyPaid => ('Partial', const Color(0xFFE65100)),
      PurchaseFaStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      PurchaseFaStatus.cancelled => ('Cancelled', const Color(0xFF9E9E9E)),
    };
  }

  /// Maps a mobile transaction route to the corresponding list route for navigation.
  static String? detailRouteFor(String listRoute, String itemId) {
    return switch (listRoute) {
      AppRoutes.saleInvoices => AppRoutes.addSale,
      AppRoutes.saleEstimateQuotation => AppRoutes.addEstimate,
      AppRoutes.saleOrder => AppRoutes.addSaleOrder,
      AppRoutes.saleDeliveryChallan => AppRoutes.addDeliveryChallan,
      AppRoutes.saleReturnCreditNote => AppRoutes.addCreditNote,
      AppRoutes.saleFa => AppRoutes.addSaleFa,
      AppRoutes.purchaseBills => AppRoutes.addPurchase,
      AppRoutes.purchaseExpenses => AppRoutes.addExpense,
      AppRoutes.purchaseOrder => AppRoutes.addPurchaseOrder,
      AppRoutes.purchaseReturnDebitNote => AppRoutes.addDebitNote,
      AppRoutes.purchaseFa => AppRoutes.addPurchaseFa,
      _ => null,
    };
  }
}
