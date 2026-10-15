import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/routing/mobile_document_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/other_income/models/other_income_model.dart';
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
  static final _homeTimeFormat = DateFormat('h:mm a');

  static String formatAmount(double amount) => _currencyFormat.format(amount);

  static String formatHomeAmount(double amount) =>
      formatHomeAmountIndian(amount);

  /// Compact Indian notation for the mobile home transaction feed (L / Cr).
  static String formatHomeAmountIndian(double amount) {
    final abs = amount.abs();
    if (abs >= 10000000) {
      return _compactIndianAmount(amount, 10000000, 'Cr');
    }
    if (abs >= 100000) {
      return _compactIndianAmount(amount, 100000, 'L');
    }

    final digits = amount == amount.roundToDouble() ? 0 : 2;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: digits,
    ).format(amount);
  }

  static String _compactIndianAmount(
    double amount,
    double divisor,
    String suffix,
  ) {
    final scaled = amount / divisor;
    final text = scaled == scaled.roundToDouble()
        ? scaled.toInt().toString()
        : scaled.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '₹$text$suffix';
  }

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
      PurchaseOrderStatus.orderCompleted => (
        'Completed',
        const Color(0xFF2E7D32),
      ),
      PurchaseOrderStatus.partiallyReceived => (
        'Partial',
        const Color(0xFFE65100),
      ),
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

  static MobileTransactionListItem fromOtherIncome(
    OtherIncomeTransactionModel income, {
    IconData? leadingIcon,
  }) {
    final amount = income.amount ?? 0;
    final (statusLabel, statusColor) = switch (income.status) {
      OtherIncomeStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      OtherIncomeStatus.partial => ('Partial', const Color(0xFFE65100)),
      OtherIncomeStatus.pending => ('Pending', const Color(0xFFF9A825)),
      null => ('Recorded', AppColors.textSecondary),
    };
    return MobileTransactionListItem(
      id: income.id,
      title: income.transactionNo,
      subtitle: income.party,
      dateLabel: _listDateFormat.format(income.date),
      amountLabel: formatAmount(amount),
      statusLabel: statusLabel,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
      sortAmount: amount,
      sortDate: income.date,
      sortTitle: income.transactionNo,
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

  static MobileHomeTransactionItem homeFromSaleInvoice(
    SaleInvoiceModel invoice,
  ) {
    final meta = _homeSaleDocumentMeta(invoice);
    final statusLabel = invoice.isDraft
        ? '${meta.prefix} : DRAFT'
        : '${meta.prefix} : ${_saleInvoiceStatusLabel(invoice.status).toUpperCase()}';
    return MobileHomeTransactionItem(
      id: invoice.id,
      partyName: invoice.partyName,
      documentNumber: invoice.invoiceNo,
      title: meta.title,
      statusLabel: statusLabel,
      statusType: meta.statusType,
      filterType: meta.filterType,
      dateLabel: _homeDateFormat.format(invoice.date),
      timeLabel: _homeTimeFormat.format(invoice.date),
      transactionDate: invoice.date,
      dueDateLabel: invoice.dueDate != null
          ? 'Due : ${_homeDateFormat.format(invoice.dueDate!)}'
          : null,
      totalLabel: formatHomeAmount(invoice.amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(invoice.balance),
      paymentMethod: invoice.paymentType,
      ledgerTransaction: _ledgerFromSaleDocument(
        invoice,
        sourceType: meta.sourceType,
      ),
    );
  }

  static MobileHomeTransactionItem homeFromPaymentOut(PaymentOutModel payment) {
    final statusLabel = switch (payment.status) {
      PaymentOutStatus.paid => 'PAYOUT : RECORDED',
      PaymentOutStatus.pending => 'PAYOUT : PENDING',
      PaymentOutStatus.cancelled => 'PAYOUT : CANCELLED',
    };
    return MobileHomeTransactionItem(
      id: payment.id,
      partyName: payment.partyName,
      documentNumber: payment.receiptNo,
      title: 'Payment Out to ${payment.partyName}',
      statusLabel: statusLabel,
      statusType: MobileHomeTransactionStatusType.paymentOut,
      filterType: MobileHomeTransactionFilterType.paymentOut,
      dateLabel: _homeDateFormat.format(payment.date),
      timeLabel: _homeTimeFormat.format(payment.date),
      transactionDate: payment.date,
      totalLabel: formatHomeAmount(payment.paidAmount),
      balanceLabel: 'Total',
      balanceValueLabel: formatHomeAmount(payment.totalAmount),
      paymentMethod: payment.paymentType,
      ledgerTransaction: _ledgerFromPaymentOut(payment),
    );
  }

  static MobileHomeTransactionItem homeFromPurchaseOrder(
    PurchaseOrderModel order,
  ) {
    return MobileHomeTransactionItem(
      id: order.id,
      partyName: order.partyName,
      documentNumber: order.orderNo,
      title: 'Purchase Order',
      statusLabel: 'PO : ${order.status.name.toUpperCase()}',
      statusType: MobileHomeTransactionStatusType.purchase,
      filterType: MobileHomeTransactionFilterType.purchaseOrder,
      dateLabel: _homeDateFormat.format(order.date),
      timeLabel: _homeTimeFormat.format(order.date),
      transactionDate: order.date,
      totalLabel: formatHomeAmount(order.amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(order.balanceDue),
      ledgerTransaction: _ledgerFromPurchaseOrder(order),
    );
  }

  static MobileHomeTransactionItem homeFromPurchaseReturn(
    PurchaseReturnModel returnDoc,
  ) {
    return MobileHomeTransactionItem(
      id: returnDoc.id,
      partyName: returnDoc.partyName,
      documentNumber: returnDoc.debitNoteNo,
      title: 'Purchase Return',
      statusLabel:
          'DR NOTE : ${_purchaseBillStatusLabel(returnDoc.status).toUpperCase()}',
      statusType: MobileHomeTransactionStatusType.purchase,
      filterType: MobileHomeTransactionFilterType.debitNote,
      dateLabel: _homeDateFormat.format(returnDoc.date),
      timeLabel: _homeTimeFormat.format(returnDoc.date),
      transactionDate: returnDoc.date,
      totalLabel: formatHomeAmount(returnDoc.total),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(returnDoc.balance),
      paymentMethod: returnDoc.paymentType,
      ledgerTransaction: _ledgerFromPurchaseReturn(returnDoc),
    );
  }

  static MobileHomeTransactionItem homeFromSaleFa(SaleFaModel fa) {
    return MobileHomeTransactionItem(
      id: fa.id,
      partyName: fa.partyName,
      documentNumber: fa.invoiceNo,
      title: 'Sale Assets',
      statusLabel: 'SALE FA : ${_saleFaStatus(fa.status).$1.toUpperCase()}',
      statusType: MobileHomeTransactionStatusType.salePaid,
      filterType: MobileHomeTransactionFilterType.sale,
      dateLabel: _homeDateFormat.format(fa.date),
      timeLabel: _homeTimeFormat.format(fa.date),
      transactionDate: fa.date,
      dueDateLabel: 'Due : ${_homeDateFormat.format(fa.dueDate)}',
      totalLabel: formatHomeAmount(fa.amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(fa.balanceDue),
      paymentMethod: fa.paymentType,
      ledgerTransaction: _ledgerFromSaleFa(fa),
    );
  }

  static MobileHomeTransactionItem homeFromPurchaseFa(PurchaseFaModel fa) {
    return MobileHomeTransactionItem(
      id: fa.id,
      partyName: fa.partyName,
      documentNumber: fa.invoiceNo,
      title: 'Purchase Assets',
      statusLabel:
          'PURCHASE FA : ${_purchaseFaStatus(fa.status).$1.toUpperCase()}',
      statusType: MobileHomeTransactionStatusType.purchase,
      filterType: MobileHomeTransactionFilterType.purchase,
      dateLabel: _homeDateFormat.format(fa.date),
      timeLabel: _homeTimeFormat.format(fa.date),
      transactionDate: fa.date,
      dueDateLabel: 'Due : ${_homeDateFormat.format(fa.dueDate)}',
      totalLabel: formatHomeAmount(fa.amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(fa.balanceDue),
      paymentMethod: fa.paymentType,
      ledgerTransaction: _ledgerFromPurchaseFa(fa),
    );
  }

  static MobileHomeTransactionItem homeFromJobWorkOrder(
    JobWorkOrderListItem order,
  ) {
    final date = order.invoiceDate ?? order.deliveryDate ?? DateTime.now();
    return MobileHomeTransactionItem(
      id: order.id,
      partyName: order.party,
      documentNumber: order.jobId,
      title: 'Job Work',
      statusLabel: 'JOB : ${order.status.name.toUpperCase()}',
      statusType: MobileHomeTransactionStatusType.salePaid,
      filterType: MobileHomeTransactionFilterType.sale,
      dateLabel: _homeDateFormat.format(date),
      timeLabel: _homeTimeFormat.format(date),
      transactionDate: date,
      totalLabel: formatHomeAmount(order.grandTotal),
      balanceLabel: 'Total',
      balanceValueLabel: formatHomeAmount(order.grandTotal),
      ledgerTransaction: _ledgerFromJobWorkOrder(order, date),
    );
  }

  static String? homeDetailRouteFor(MobileHomeTransactionItem item) {
    return switch (item.filterType) {
      MobileHomeTransactionFilterType.sale =>
        '${AppRoutes.editSale}/${item.id}',
      MobileHomeTransactionFilterType.saleOrder =>
        '${AppRoutes.editSaleOrder}/${item.id}',
      MobileHomeTransactionFilterType.creditNote =>
        '${AppRoutes.editCreditNote}/${item.id}',
      MobileHomeTransactionFilterType.estimate =>
        '${AppRoutes.editEstimate}/${item.id}',
      MobileHomeTransactionFilterType.purchase =>
        '${AppRoutes.editPurchase}/${item.id}',
      MobileHomeTransactionFilterType.purchaseOrder =>
        '${AppRoutes.editPurchaseOrder}/${item.id}',
      MobileHomeTransactionFilterType.debitNote =>
        '${AppRoutes.editDebitNote}/${item.id}',
      MobileHomeTransactionFilterType.paymentIn =>
        MobileDocumentRoutes.addPaymentIn(paymentId: item.id),
      MobileHomeTransactionFilterType.paymentOut =>
        MobileDocumentRoutes.addPaymentOut(paymentId: item.id),
      MobileHomeTransactionFilterType.expense =>
        '${AppRoutes.editExpense}/${item.id}',
    };
  }

  static ({
    MobileHomeTransactionFilterType filterType,
    String title,
    String prefix,
    String sourceType,
    MobileHomeTransactionStatusType statusType,
  })
  _homeSaleDocumentMeta(SaleInvoiceModel invoice) {
    final series = invoice.documentSeries;
    final paidStatus = invoice.status == SaleInvoiceStatus.paid
        ? MobileHomeTransactionStatusType.salePaid
        : MobileHomeTransactionStatusType.estimateOpen;

    if (series == SalesConstants.estimateSeries) {
      return (
        filterType: MobileHomeTransactionFilterType.estimate,
        title: 'Estimate',
        prefix: 'EST',
        sourceType: 'estimate',
        statusType: MobileHomeTransactionStatusType.estimateOpen,
      );
    }
    if (series == SalesConstants.proformaSeries) {
      return (
        filterType: MobileHomeTransactionFilterType.estimate,
        title: 'Proforma Invoice',
        prefix: 'PI',
        sourceType: 'proforma',
        statusType: MobileHomeTransactionStatusType.estimateOpen,
      );
    }
    if (series == SalesConstants.saleOrderSeries) {
      return (
        filterType: MobileHomeTransactionFilterType.saleOrder,
        title: 'Sale Order',
        prefix: 'SO',
        sourceType: 'sale_order',
        statusType: paidStatus,
      );
    }
    if (series == SalesConstants.creditNoteSeries) {
      return (
        filterType: MobileHomeTransactionFilterType.creditNote,
        title: 'Sale Return',
        prefix: 'CN',
        sourceType: 'sales_return',
        statusType: paidStatus,
      );
    }
    if (series == SalesConstants.challanSeries) {
      return (
        filterType: MobileHomeTransactionFilterType.sale,
        title: 'Delivery Challan',
        prefix: 'DC',
        sourceType: 'delivery_challan',
        statusType: paidStatus,
      );
    }
    return (
      filterType: MobileHomeTransactionFilterType.sale,
      title: 'Cash Sale',
      prefix: 'SALE',
      sourceType: 'tax_invoice',
      statusType: paidStatus,
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
      title: 'Payment In',
      statusLabel: statusLabel,
      statusType: MobileHomeTransactionStatusType.paymentIn,
      filterType: MobileHomeTransactionFilterType.paymentIn,
      dateLabel: _homeDateFormat.format(payment.date),
      timeLabel: _homeTimeFormat.format(payment.date),
      transactionDate: payment.date,
      totalLabel: formatHomeAmount(payment.receivedAmount),
      balanceLabel: 'Unused',
      balanceValueLabel: formatHomeAmount(payment.balanceDue),
      paymentMethod: payment.paymentType,
      ledgerTransaction: _ledgerFromPaymentIn(payment),
    );
  }

  static MobileHomeTransactionItem homeFromPurchaseBill(
    PurchaseBillModel bill,
  ) {
    return MobileHomeTransactionItem(
      id: bill.id,
      partyName: bill.partyName,
      documentNumber: bill.invoiceNo,
      title: 'Purchase from ${bill.partyName}',
      statusLabel:
          'PURCHASE : ${_purchaseBillStatusLabel(bill.status).toUpperCase()}',
      statusType: MobileHomeTransactionStatusType.purchase,
      filterType: MobileHomeTransactionFilterType.purchase,
      dateLabel: _homeDateFormat.format(bill.date),
      timeLabel: _homeTimeFormat.format(bill.date),
      transactionDate: bill.date,
      dueDateLabel: 'Due : ${_homeDateFormat.format(bill.dueDate)}',
      totalLabel: formatHomeAmount(bill.amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(bill.balanceDue),
      paymentMethod: bill.paymentType,
      ledgerTransaction: _ledgerFromPurchaseBill(bill),
    );
  }

  static MobileHomeTransactionItem homeFromExpense(
    ExpenseTransactionModel expense,
  ) {
    final amount = expense.amount ?? 0;
    return MobileHomeTransactionItem(
      id: expense.id,
      partyName: expense.party,
      documentNumber: expense.transactionNo,
      title: 'Expense',
      statusLabel:
          'EXPENSE : ${expense.status?.name.toUpperCase() ?? 'RECORDED'}',
      statusType: MobileHomeTransactionStatusType.expense,
      filterType: MobileHomeTransactionFilterType.expense,
      dateLabel: _homeDateFormat.format(expense.date),
      timeLabel: _homeTimeFormat.format(expense.date),
      transactionDate: expense.date,
      totalLabel: formatHomeAmount(amount),
      balanceLabel: 'Balance',
      balanceValueLabel: formatHomeAmount(expense.balance ?? 0),
      paymentMethod: expense.paymentType,
      ledgerTransaction: _ledgerFromExpense(expense),
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

  static PartyLedgerTransactionModel _ledgerFromSaleDocument(
    SaleInvoiceModel invoice, {
    required String sourceType,
  }) {
    final isEstimate = sourceType == 'estimate' || sourceType == 'proforma';
    return PartyLedgerTransactionModel(
      id: invoice.id,
      date: invoice.date,
      createdAt: invoice.date,
      type: isEstimate ? 'Estimate' : 'Sale',
      entryType: 'debit',
      source: 'sales_documents',
      sourceType: sourceType,
      referenceId: invoice.id,
      referenceNumber: invoice.invoiceNo,
      documentDate: invoice.date,
      dueDate: invoice.dueDate,
      total: invoice.amount,
      balance: invoice.balance,
      status: invoice.status.name,
      debit: invoice.amount,
      credit: 0,
      balanceAfter: invoice.balance,
    );
  }

  static PartyLedgerTransactionModel _ledgerFromPaymentOut(
    PaymentOutModel payment,
  ) {
    return PartyLedgerTransactionModel(
      id: payment.id,
      date: payment.date,
      createdAt: payment.date,
      type: 'Payment-Out',
      entryType: 'debit',
      source: 'payments',
      sourceType: 'payment_out',
      referenceId: payment.id,
      referenceNumber: payment.receiptNo,
      documentDate: payment.date,
      total: payment.paidAmount,
      balance: 0,
      status: payment.status.name,
      debit: payment.paidAmount,
      credit: 0,
      balanceAfter: 0,
      direction: 'paid',
    );
  }

  static PartyLedgerTransactionModel _ledgerFromPurchaseOrder(
    PurchaseOrderModel order,
  ) {
    return PartyLedgerTransactionModel(
      id: order.id,
      date: order.date,
      createdAt: order.date,
      type: 'Purchase Order',
      entryType: 'credit',
      source: 'purchase_documents',
      sourceType: 'purchase_order',
      referenceId: order.id,
      referenceNumber: order.orderNo,
      documentDate: order.date,
      total: order.amount,
      balance: order.balanceDue,
      status: order.status.name,
      debit: 0,
      credit: order.amount,
      balanceAfter: order.balanceDue,
    );
  }

  static PartyLedgerTransactionModel _ledgerFromPurchaseReturn(
    PurchaseReturnModel returnDoc,
  ) {
    return PartyLedgerTransactionModel(
      id: returnDoc.id,
      date: returnDoc.date,
      createdAt: returnDoc.date,
      type: 'Purchase Return',
      entryType: 'debit',
      source: 'purchase_documents',
      sourceType: 'purchase_return',
      referenceId: returnDoc.id,
      referenceNumber: returnDoc.debitNoteNo,
      documentDate: returnDoc.date,
      total: returnDoc.total,
      balance: returnDoc.balance,
      status: returnDoc.status.name,
      debit: returnDoc.total,
      credit: 0,
      balanceAfter: returnDoc.balance,
    );
  }

  static PartyLedgerTransactionModel _ledgerFromSaleFa(SaleFaModel fa) {
    return PartyLedgerTransactionModel(
      id: fa.id,
      date: fa.date,
      createdAt: fa.createdAt,
      type: 'Sale Assets',
      entryType: 'debit',
      source: 'sale_fa_batches',
      sourceType: 'sale_fa',
      referenceId: fa.id,
      referenceNumber: fa.invoiceNo,
      documentDate: fa.date,
      dueDate: fa.dueDate,
      total: fa.amount,
      balance: fa.balanceDue,
      status: fa.status.name,
      debit: fa.amount,
      credit: 0,
      balanceAfter: fa.balanceDue,
    );
  }

  static PartyLedgerTransactionModel _ledgerFromPurchaseFa(PurchaseFaModel fa) {
    return PartyLedgerTransactionModel(
      id: fa.id,
      date: fa.date,
      createdAt: fa.date,
      type: 'Purchase Assets',
      entryType: 'credit',
      source: 'purchase_fa_batches',
      sourceType: 'purchase_fa',
      referenceId: fa.id,
      referenceNumber: fa.invoiceNo,
      documentDate: fa.date,
      dueDate: fa.dueDate,
      total: fa.amount,
      balance: fa.balanceDue,
      status: fa.status.name,
      debit: 0,
      credit: fa.amount,
      balanceAfter: fa.balanceDue,
    );
  }

  static PartyLedgerTransactionModel _ledgerFromJobWorkOrder(
    JobWorkOrderListItem order,
    DateTime date,
  ) {
    return PartyLedgerTransactionModel(
      id: order.id,
      date: date,
      createdAt: date,
      type: 'Job Work',
      entryType: 'debit',
      source: 'job_work_orders',
      sourceType: 'job_work',
      referenceId: order.id,
      referenceNumber: order.jobId,
      documentDate: date,
      total: order.grandTotal,
      balance: 0,
      status: order.status.name,
      debit: order.grandTotal,
      credit: 0,
      balanceAfter: 0,
    );
  }

  static PartyLedgerTransactionModel _ledgerFromPaymentIn(
    PaymentInModel payment,
  ) {
    return PartyLedgerTransactionModel(
      id: payment.id,
      date: payment.date,
      createdAt: payment.date,
      type: 'Payment-In',
      entryType: 'credit',
      source: 'payments',
      sourceType: 'payment_in',
      referenceId: payment.id,
      referenceNumber: payment.receiptNo,
      documentDate: payment.date,
      total: payment.receivedAmount,
      balance: payment.balanceDue,
      status: payment.status.name,
      debit: 0,
      credit: payment.receivedAmount,
      balanceAfter: payment.balanceDue,
      direction: 'received',
    );
  }

  static PartyLedgerTransactionModel _ledgerFromPurchaseBill(
    PurchaseBillModel bill,
  ) {
    return PartyLedgerTransactionModel(
      id: bill.id,
      date: bill.date,
      createdAt: bill.date,
      type: 'Purchase',
      entryType: 'credit',
      source: 'purchase_documents',
      sourceType: 'purchase_bill',
      referenceId: bill.id,
      referenceNumber: bill.invoiceNo,
      documentDate: bill.date,
      dueDate: bill.dueDate,
      total: bill.amount,
      balance: bill.balanceDue,
      status: bill.status.name,
      debit: 0,
      credit: bill.amount,
      balanceAfter: bill.balanceDue,
    );
  }

  static PartyLedgerTransactionModel _ledgerFromExpense(
    ExpenseTransactionModel expense,
  ) {
    final amount = expense.amount ?? 0;
    return PartyLedgerTransactionModel(
      id: expense.id,
      date: expense.date,
      createdAt: expense.date,
      type: 'Expense',
      entryType: 'credit',
      source: 'expenses',
      sourceType: 'expense',
      referenceId: expense.id,
      referenceNumber: expense.transactionNo,
      documentDate: expense.date,
      dueDate: expense.dueDate,
      total: amount,
      balance: expense.balance ?? 0,
      status: expense.status?.name,
      debit: 0,
      credit: amount,
      balanceAfter: expense.balance ?? 0,
    );
  }

  /// Maps a mobile transaction route to the corresponding edit route.
  static String? detailRouteFor(String listRoute, String itemId) {
    return switch (listRoute) {
      AppRoutes.saleInvoices => '${AppRoutes.editSale}/$itemId',
      AppRoutes.saleEstimateQuotation => '${AppRoutes.editEstimate}/$itemId',
      AppRoutes.saleOrder => '${AppRoutes.editSaleOrder}/$itemId',
      AppRoutes.saleDeliveryChallan =>
        '${AppRoutes.editDeliveryChallan}/$itemId',
      AppRoutes.saleReturnCreditNote => '${AppRoutes.editCreditNote}/$itemId',
      AppRoutes.saleFa => '${AppRoutes.editSaleFa}/$itemId',
      AppRoutes.salePaymentIn => '${AppRoutes.addPaymentIn}?paymentId=$itemId',
      AppRoutes.saleJobWorkOut => '${AppRoutes.editJobWork}/$itemId',
      AppRoutes.purchaseBills => '${AppRoutes.editPurchase}/$itemId',
      AppRoutes.purchaseExpenses => '${AppRoutes.editExpense}/$itemId',
      AppRoutes.otherIncome => '${AppRoutes.editOtherIncome}/$itemId',
      AppRoutes.purchaseOrder => '${AppRoutes.editPurchaseOrder}/$itemId',
      AppRoutes.purchaseReturnDebitNote => '${AppRoutes.editDebitNote}/$itemId',
      AppRoutes.purchaseFa => '${AppRoutes.editPurchaseFa}/$itemId',
      AppRoutes.purchasePaymentOut =>
        '${AppRoutes.addPaymentOut}?paymentId=$itemId',
      _ => null,
    };
  }
}
