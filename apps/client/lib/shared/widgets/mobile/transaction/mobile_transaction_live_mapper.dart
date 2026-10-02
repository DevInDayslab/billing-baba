import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/sales/application/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Maps desktop/live domain models into [MobileTransactionListItem] rows.
abstract final class MobileTransactionLiveMapper {
  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  static final _date = DateFormat('dd MMM yyyy');

  static String formatAmount(double amount) => _currency.format(amount);

  static String formatDate(DateTime date) => _date.format(date);

  static MobileTransactionListItem fromSaleInvoice(
    SaleInvoiceModel invoice, {
    IconData leadingIcon = Icons.receipt_long_outlined,
    bool useSaleOrderStatus = false,
  }) {
    final (statusLabel, statusColor) = useSaleOrderStatus
        ? _saleOrderStatus(invoice)
        : _saleInvoiceStatus(invoice.status);
    return MobileTransactionListItem(
      id: invoice.id,
      title: invoice.invoiceNo,
      subtitle: invoice.partyName,
      dateLabel: formatDate(invoice.date),
      amountLabel: formatAmount(invoice.amount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: invoice.amount,
      sortDate: invoice.date,
      sortTitle: invoice.invoiceNo,
    );
  }

  static MobileTransactionListItem fromPaymentIn(PaymentInModel payment) {
    final (label, color) = switch (payment.status) {
      PaymentInStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      PaymentInStatus.partial => ('Partial', const Color(0xFFE65100)),
      PaymentInStatus.unused => ('Unused', AppColors.textSecondary),
    };
    return MobileTransactionListItem(
      id: payment.id,
      title: payment.receiptNo,
      subtitle: payment.partyName,
      dateLabel: formatDate(payment.date),
      amountLabel: formatAmount(payment.receivedAmount),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.payments_outlined,
      sortAmount: payment.receivedAmount,
      sortDate: payment.date,
      sortTitle: payment.receiptNo,
    );
  }

  static MobileTransactionListItem fromJobWork(JobWorkOrderListItem order) {
    final (label, color) = switch (order.status) {
      JobWorkOutStatus.open => ('Open', AppColors.primary),
      JobWorkOutStatus.closed => ('Closed', const Color(0xFF2E7D32)),
      JobWorkOutStatus.cancelled => ('Cancelled', AppColors.textSecondary),
    };
    final date = order.invoiceDate ?? order.deliveryDate ?? DateTime.now();
    return MobileTransactionListItem(
      id: order.id,
      title: order.jobId.isEmpty ? 'Job Work' : order.jobId,
      subtitle: order.party,
      dateLabel: formatDate(date),
      amountLabel: formatAmount(order.grandTotal),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.precision_manufacturing_outlined,
      sortAmount: order.grandTotal,
      sortDate: date,
      sortTitle: order.jobId,
    );
  }

  static MobileTransactionListItem fromSaleFa(SaleFaModel record) {
    final (label, color) = _saleFaStatus(record.status);
    return MobileTransactionListItem(
      id: record.id,
      title: record.invoiceNo,
      subtitle: record.partyName,
      dateLabel: formatDate(record.date),
      amountLabel: formatAmount(record.amount),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.account_balance_outlined,
      sortAmount: record.amount,
      sortDate: record.date,
      sortTitle: record.invoiceNo,
    );
  }

  static MobileTransactionListItem fromPurchaseBill(PurchaseBillModel bill) {
    final (label, color) = _purchaseBillStatus(bill.status);
    return MobileTransactionListItem(
      id: bill.id,
      title: bill.invoiceNo,
      subtitle: bill.partyName,
      dateLabel: formatDate(bill.date),
      amountLabel: formatAmount(bill.amount),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.shopping_cart_outlined,
      sortAmount: bill.amount,
      sortDate: bill.date,
      sortTitle: bill.invoiceNo,
    );
  }

  static MobileTransactionListItem fromPaymentOut(PaymentOutModel payment) {
    final (label, color) = switch (payment.status) {
      PaymentOutStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      PaymentOutStatus.pending => ('Pending', const Color(0xFFE65100)),
      PaymentOutStatus.cancelled => ('Cancelled', AppColors.textSecondary),
    };
    return MobileTransactionListItem(
      id: payment.id,
      title: payment.receiptNo,
      subtitle: payment.partyName,
      dateLabel: formatDate(payment.date),
      amountLabel: formatAmount(payment.paidAmount),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.payments_outlined,
      sortAmount: payment.paidAmount,
      sortDate: payment.date,
      sortTitle: payment.receiptNo,
    );
  }

  static MobileTransactionListItem fromExpense(
    ExpenseTransactionModel expense,
  ) {
    final amount = expense.amount ?? 0;
    final (label, color) = switch (expense.status) {
      ExpenseStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      ExpenseStatus.partial => ('Partial', const Color(0xFFE65100)),
      ExpenseStatus.pending => ('Pending', const Color(0xFFC62828)),
      null => ('Open', AppColors.primary),
    };
    return MobileTransactionListItem(
      id: expense.id,
      title: expense.transactionNo,
      subtitle: expense.party,
      dateLabel: formatDate(expense.date),
      amountLabel: formatAmount(amount),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.money_off_outlined,
      sortAmount: amount,
      sortDate: expense.date,
      sortTitle: expense.transactionNo,
    );
  }

  static MobileTransactionListItem fromPurchaseOrder(PurchaseOrderModel order) {
    final (label, color) = switch (order.status) {
      PurchaseOrderStatus.open => ('Open', AppColors.primary),
      PurchaseOrderStatus.orderCompleted => (
        'Completed',
        const Color(0xFF2E7D32),
      ),
      PurchaseOrderStatus.partiallyReceived => (
        'Partial',
        const Color(0xFFE65100),
      ),
      PurchaseOrderStatus.cancelled => ('Cancelled', AppColors.textSecondary),
    };
    return MobileTransactionListItem(
      id: order.id,
      title: order.orderNo,
      subtitle: order.partyName,
      dateLabel: formatDate(order.date),
      amountLabel: formatAmount(order.amount),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.assignment_outlined,
      sortAmount: order.amount,
      sortDate: order.date,
      sortTitle: order.orderNo,
    );
  }

  static MobileTransactionListItem fromPurchaseReturn(
    PurchaseReturnModel note,
  ) {
    final (label, color) = _purchaseBillStatus(note.status);
    return MobileTransactionListItem(
      id: note.id,
      title: note.debitNoteNo,
      subtitle: note.partyName,
      dateLabel: formatDate(note.date),
      amountLabel: formatAmount(note.total),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.undo_rounded,
      sortAmount: note.total,
      sortDate: note.date,
      sortTitle: note.debitNoteNo,
    );
  }

  static MobileTransactionListItem fromPurchaseFa(PurchaseFaModel record) {
    final (label, color) = switch (record.status) {
      PurchaseFaStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      PurchaseFaStatus.unpaid => ('Unpaid', const Color(0xFFC62828)),
      PurchaseFaStatus.partiallyPaid => ('Partial', const Color(0xFFE65100)),
      PurchaseFaStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      PurchaseFaStatus.cancelled => ('Cancelled', AppColors.textSecondary),
    };
    return MobileTransactionListItem(
      id: record.id,
      title: record.invoiceNo,
      subtitle: record.partyName,
      dateLabel: formatDate(record.date),
      amountLabel: formatAmount(record.amount),
      statusLabel: label,
      statusColor: color,
      leadingIcon: Icons.account_balance_outlined,
      sortAmount: record.amount,
      sortDate: record.date,
      sortTitle: record.invoiceNo,
    );
  }

  static (String, Color) _saleInvoiceStatus(SaleInvoiceStatus status) {
    return switch (status) {
      SaleInvoiceStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      SaleInvoiceStatus.unpaid => ('Unpaid', const Color(0xFFC62828)),
      SaleInvoiceStatus.partiallyPaid => ('Partial', const Color(0xFFE65100)),
      SaleInvoiceStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      SaleInvoiceStatus.cancelled => ('Cancelled', AppColors.textSecondary),
    };
  }

  static (String, Color) _saleOrderStatus(SaleInvoiceModel order) {
    return switch (saleOrderDisplayStatus(order)) {
      SaleOrderDisplayStatus.open => ('Open', AppColors.primary),
      SaleOrderDisplayStatus.completed => (
        'Completed',
        const Color(0xFF2E7D32),
      ),
      SaleOrderDisplayStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      SaleOrderDisplayStatus.draft => ('Draft', AppColors.textSecondary),
      SaleOrderDisplayStatus.cancelled => (
        'Cancelled',
        AppColors.textSecondary,
      ),
    };
  }

  static (String, Color) _saleFaStatus(SaleFaStatus status) {
    return switch (status) {
      SaleFaStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      SaleFaStatus.unpaid => ('Unpaid', const Color(0xFFC62828)),
      SaleFaStatus.partiallyPaid => ('Partial', const Color(0xFFE65100)),
      SaleFaStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      SaleFaStatus.cancelled => ('Cancelled', AppColors.textSecondary),
    };
  }

  static (String, Color) _purchaseBillStatus(PurchaseBillStatus status) {
    return switch (status) {
      PurchaseBillStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      PurchaseBillStatus.unpaid => ('Unpaid', const Color(0xFFC62828)),
      PurchaseBillStatus.partiallyPaid => ('Partial', const Color(0xFFE65100)),
      PurchaseBillStatus.overdue => ('Overdue', const Color(0xFFB71C1C)),
      PurchaseBillStatus.cancelled => ('Cancelled', AppColors.textSecondary),
    };
  }
}
