import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/models/dto/report_dto.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';

abstract final class ReportMapper {
  static double _parseAmount(String value) => double.tryParse(value) ?? 0;

  static SaleInvoiceStatus _mapPaymentStatus(String status) => switch (status) {
    'paid' => SaleInvoiceStatus.paid,
    'partial' => SaleInvoiceStatus.partiallyPaid,
    'unpaid' => SaleInvoiceStatus.unpaid,
    'overdue' => SaleInvoiceStatus.overdue,
    'cancelled' => SaleInvoiceStatus.cancelled,
    _ => SaleInvoiceStatus.unpaid,
  };

  static SaleInvoiceModel toSaleInvoice(ReportSaleRowDto dto) {
    return SaleInvoiceModel(
      id: dto.id,
      invoiceNo: dto.documentNumber,
      date: DateTime.tryParse(dto.documentDate) ?? DateTime.now(),
      partyName: dto.partyName ?? '—',
      partyId: dto.partyId,
      transactionType: dto.documentType,
      paymentType: dto.paymentMode ?? '—',
      status: _mapPaymentStatus(dto.status),
      amount: _parseAmount(dto.totalAmount),
      balance: _parseAmount(dto.balanceAmount),
    );
  }

  static ReportPurchaseRow toPurchaseRow(ReportPurchaseRowDto dto) {
    return ReportPurchaseRow(
      id: dto.id,
      date: DateTime.tryParse(dto.documentDate) ?? DateTime.now(),
      invoiceNo: dto.documentNumber,
      partyName: dto.partyName,
      paymentType: dto.paymentMode ?? '—',
      status: _mapPaymentStatus(dto.status),
      amount: _parseAmount(dto.totalAmount),
      balance: _parseAmount(dto.balanceAmount),
    );
  }

  static ReportStockSummaryRow toStockSummaryRow(ReportStockSummaryRowDto dto) {
    return ReportStockSummaryRow(
      itemName: dto.itemName,
      salePrice: _parseAmount(dto.salePrice ?? '0'),
      purchasePrice: _parseAmount(dto.averageCost),
      stockQty: _parseAmount(dto.stockQty),
      stockValue: _parseAmount(dto.stockValue),
      categoryId: dto.categoryId ?? '',
    );
  }

  static ReportLowStockRow toLowStockRow(ReportLowStockRowDto dto) {
    return ReportLowStockRow(
      itemName: dto.itemName,
      minStock: _parseAmount(dto.minStock),
      currentStock: _parseAmount(dto.currentStock),
      shortage: _parseAmount(dto.shortage),
    );
  }

  static PartyModel toPartyModel(ReportPartyOutstandingRowDto dto) {
    final balance = _parseAmount(dto.balance);
    final signedBalance = dto.balanceType == 'payable' ? -balance : balance;
    return PartyModel(
      id: dto.partyId,
      name: dto.partyName,
      phone: dto.phone ?? '',
      email: dto.email ?? '',
      balance: signedBalance,
      partyType: dto.balanceType == 'payable' ? 'supplier' : 'customer',
    );
  }

  static ReportPartyStatementEntry toPartyStatementEntry(
    ReportPartyStatementEntryDto dto,
  ) {
    final amount = _parseAmount(dto.debit) > 0
        ? _parseAmount(dto.debit)
        : _parseAmount(dto.credit);
    return ReportPartyStatementEntry(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      type: dto.type,
      refNo: dto.refNo,
      total: amount,
      balance: _parseAmount(dto.balance),
    );
  }

  static ReportPartyStatementSummary toPartyStatementSummary(
    ReportPartyStatementSummaryDto dto,
  ) {
    return ReportPartyStatementSummary(
      totalSale: _parseAmount(dto.totalSale),
      totalPurchase: _parseAmount(dto.totalPurchase),
      totalMoneyIn: _parseAmount(dto.totalMoneyIn),
      totalMoneyOut: _parseAmount(dto.totalMoneyOut),
      totalReceivable: _parseAmount(dto.totalReceivable),
    );
  }

  static ReportTransactionRow toTransactionRow(ReportTransactionRowDto dto) {
    return ReportTransactionRow(
      id: dto.id,
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      refNo: dto.refNo,
      partyName: dto.partyName ?? '—',
      category: dto.category,
      type: dto.type,
      total: _parseAmount(dto.total),
      received: _parseAmount(dto.received),
      balance: _parseAmount(dto.balance),
      moneyIn: _parseAmount(dto.moneyIn),
      moneyOut: _parseAmount(dto.moneyOut),
      status: dto.status,
      paymentType: dto.paymentType ?? '',
    );
  }

  static ReportProfitLossItem toProfitLossItem(ReportProfitLossItemDto dto) {
    return ReportProfitLossItem(
      particular: dto.particular,
      amount: _parseAmount(dto.amount),
      isHeader: dto.isHeader,
      indent: dto.indent,
    );
  }

  static ReportGstrRow toGstrRow(ReportGstrRowDto dto) {
    return ReportGstrRow(
      gstin: dto.gstin ?? '',
      partyName: dto.partyName ?? '',
      invoiceNo: dto.invoiceNo,
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      value: _parseAmount(dto.value),
      taxRate: _parseAmount(dto.taxRate),
      taxableValue: _parseAmount(dto.taxableValue),
      integratedTax: _parseAmount(dto.integratedTax),
      cessRate: _parseAmount(dto.cess),
    );
  }

  static ReportGstr3bRow toGstr3bRow(ReportGstr3bRowDto dto) {
    return ReportGstr3bRow(
      nature: dto.nature,
      taxableValue: _parseAmount(dto.taxableValue),
      integratedTax: _parseAmount(dto.integratedTax),
      centralTax: _parseAmount(dto.centralTax),
      stateTax: _parseAmount(dto.stateTax),
      cess: _parseAmount(dto.cess),
    );
  }

  static ReportTrialBalanceRow toTrialBalanceRow(ReportTrialBalanceRowDto dto) {
    final closing = _parseAmount(dto.closing);
    final isDebit = dto.balanceType == 'debit';
    return ReportTrialBalanceRow(
      accountName: dto.accountName,
      opening: _parseAmount(dto.opening),
      debit: _parseAmount(dto.debit),
      credit: _parseAmount(dto.credit),
      closingDebit: isDebit ? closing : 0,
      closingCredit: isDebit ? 0 : closing,
    );
  }

  static ReportBalanceSheetItem toBalanceSheetItem(
    ReportBalanceSheetItemDto dto,
  ) {
    return ReportBalanceSheetItem(
      name: dto.name,
      amount: _parseAmount(dto.amount),
      indent: dto.indent,
      isHeader: dto.isHeader,
    );
  }
}
