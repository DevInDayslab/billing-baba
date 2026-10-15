import 'package:billing_baba/features/reports/models/dto/report_extended_dto.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

abstract final class ReportExtendedMapper {
  static double _parseAmount(String value) => double.tryParse(value) ?? 0;

  static ReportBillWiseProfitRow toBillWiseProfitRow(
    ReportBillWiseProfitRowDto dto,
  ) {
    return ReportBillWiseProfitRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      invoiceNo: dto.invoiceNo,
      partyName: dto.partyName,
      saleAmount: _parseAmount(dto.saleAmount),
      purchaseAmount: _parseAmount(dto.purchaseAmount),
      profit: _parseAmount(dto.profit),
    );
  }

  static ReportPartyWiseProfitLossRow toPartyWiseProfitLossRow(
    ReportPartyWiseProfitLossRowDto dto,
  ) {
    return ReportPartyWiseProfitLossRow(
      partyName: dto.partyName,
      phone: dto.phone,
      saleAmount: _parseAmount(dto.saleAmount),
      purchaseAmount: _parseAmount(dto.purchaseAmount),
      profit: _parseAmount(dto.profit),
    );
  }

  static ReportPartyByItemRow toPartyByItemRow(ReportPartyByItemRowDto dto) {
    return ReportPartyByItemRow(
      partyName: dto.partyName,
      saleQuantity: _parseAmount(dto.saleQuantity),
      saleAmount: _parseAmount(dto.saleAmount),
      purchaseQuantity: _parseAmount(dto.purchaseQuantity),
      purchaseAmount: _parseAmount(dto.purchaseAmount),
    );
  }

  static ReportSalePurchaseByPartyRow toSalePurchaseByPartyRow(
    ReportSalePurchaseByPartyRowDto dto,
  ) {
    return ReportSalePurchaseByPartyRow(
      partyName: dto.partyName,
      saleAmount: _parseAmount(dto.saleAmount),
      purchaseAmount: _parseAmount(dto.purchaseAmount),
    );
  }

  static ReportSalePurchaseByPartyGroupRow toSalePurchaseByPartyGroupRow(
    ReportSalePurchaseByPartyGroupRowDto dto,
  ) {
    return ReportSalePurchaseByPartyGroupRow(
      partyGroup: dto.partyGroup,
      partyName: dto.partyName,
      saleAmount: _parseAmount(dto.saleAmount),
      purchaseAmount: _parseAmount(dto.purchaseAmount),
    );
  }

  static ReportGstr9SupplyRow toGstr9SupplyRow(ReportGstr9SupplyRowDto dto) {
    return ReportGstr9SupplyRow(
      label: dto.label,
      taxableValue: _parseAmount(dto.taxableValue),
      integratedTax: _parseAmount(dto.integratedTax),
      centralTax: _parseAmount(dto.centralTax),
      stateTax: _parseAmount(dto.stateTax),
      cess: _parseAmount(dto.cess),
    );
  }

  static ReportSacRow toSacRow(ReportSacRowDto dto) {
    return ReportSacRow(
      sac: dto.sac,
      invoiceType: dto.invoiceType,
      totalValue: _parseAmount(dto.totalValue),
      taxableValue: _parseAmount(dto.taxableValue),
      igst: _parseAmount(dto.igst),
      cgst: _parseAmount(dto.cgst),
      sgst: _parseAmount(dto.sgst),
      cess: _parseAmount(dto.cess),
    );
  }

  static ReportHsnRow toHsnRow(ReportHsnRowDto dto) {
    return ReportHsnRow(
      hsn: dto.hsn,
      description: dto.description,
      uqc: dto.uqc,
      quantity: _parseAmount(dto.quantity),
      totalValue: _parseAmount(dto.totalValue),
      taxableValue: _parseAmount(dto.taxableValue),
      igst: _parseAmount(dto.igst),
      cgst: _parseAmount(dto.cgst),
      sgst: _parseAmount(dto.sgst),
    );
  }

  static ReportItemByPartyRow toItemByPartyRow(ReportItemByPartyRowDto dto) {
    return ReportItemByPartyRow(
      itemName: dto.itemName,
      partyName: dto.partyName,
      quantity: _parseAmount(dto.quantity),
      amount: _parseAmount(dto.amount),
    );
  }

  static ReportItemWiseProfitLossRow toItemWiseProfitLossRow(
    ReportItemWiseProfitLossRowDto dto,
  ) {
    return ReportItemWiseProfitLossRow(
      itemName: dto.itemName,
      saleAmount: _parseAmount(dto.saleAmount),
      purchaseAmount: _parseAmount(dto.purchaseAmount),
      profit: _parseAmount(dto.profit),
    );
  }

  static ReportStockDetailRow toStockDetailRow(ReportStockDetailRowDto dto) {
    return ReportStockDetailRow(
      itemName: dto.itemName,
      openingQty: _parseAmount(dto.openingQty),
      inQty: _parseAmount(dto.inQty),
      outQty: _parseAmount(dto.outQty),
      closingQty: _parseAmount(dto.closingQty),
    );
  }

  static ReportItemDetailRow toItemDetailRow(ReportItemDetailRowDto dto) {
    return ReportItemDetailRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      type: dto.type,
      refNo: dto.refNo,
      partyName: dto.partyName,
      quantity: _parseAmount(dto.quantity),
      price: _parseAmount(dto.price),
      amount: _parseAmount(dto.amount),
    );
  }

  static ReportCategoryAmountRow toCategoryAmountRow(
    ReportCategoryAmountRowDto dto,
  ) {
    return ReportCategoryAmountRow(
      category: dto.category,
      saleAmount: _parseAmount(dto.saleAmount),
      purchaseAmount: _parseAmount(dto.purchaseAmount),
    );
  }

  static ReportItemDiscountRow toItemDiscountRow(
    ReportItemDiscountRowDto dto,
  ) {
    return ReportItemDiscountRow(
      itemName: dto.itemName,
      saleQty: _parseAmount(dto.saleQty),
      saleAmount: _parseAmount(dto.saleAmount),
      discountAmount: _parseAmount(dto.discountAmount),
      discountPercent: _parseAmount(dto.discountPercent),
    );
  }

  static ReportManufacturingRow toManufacturingRow(
    ReportManufacturingRowDto dto,
  ) {
    return ReportManufacturingRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      refNo: dto.refNo,
      itemName: dto.itemName,
      quantity: _parseAmount(dto.quantity),
      cost: _parseAmount(dto.cost),
    );
  }

  static ReportConsumptionRow toConsumptionRow(ReportConsumptionRowDto dto) {
    return ReportConsumptionRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      refNo: dto.refNo,
      itemName: dto.itemName,
      quantity: _parseAmount(dto.quantity),
      value: _parseAmount(dto.value),
    );
  }

  static ReportStockTransferRow toStockTransferRow(
    ReportStockTransferRowDto dto,
  ) {
    return ReportStockTransferRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      refNo: dto.refNo,
      fromGodown: dto.fromGodown,
      toGodown: dto.toGodown,
      itemName: dto.itemName,
      quantity: _parseAmount(dto.quantity),
      value: _parseAmount(dto.value),
    );
  }

  static ReportBankStatementRow toBankStatementRow(
    ReportBankStatementRowDto dto,
  ) {
    return ReportBankStatementRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      description: dto.description,
      refNo: dto.refNo,
      moneyIn: _parseAmount(dto.moneyIn),
      moneyOut: _parseAmount(dto.moneyOut),
      balance: _parseAmount(dto.balance),
      isOpening: dto.isOpening,
    );
  }

  static ReportGstTaxPartyRow toGstTaxPartyRow(ReportGstTaxPartyRowDto dto) {
    return ReportGstTaxPartyRow(
      partyName: dto.partyName,
      saleTax: _parseAmount(dto.saleTax),
      purchaseExpenseTax: _parseAmount(dto.purchaseExpenseTax),
    );
  }

  static ReportGstTaxRateRow toGstTaxRateRow(ReportGstTaxRateRowDto dto) {
    return ReportGstTaxRateRow(
      taxName: dto.taxName,
      taxPercent: _parseAmount(dto.taxPercent),
      taxableSaleAmount: _parseAmount(dto.taxableSaleAmount),
      taxIn: _parseAmount(dto.taxIn),
      taxablePurchaseExpenseAmount: _parseAmount(
        dto.taxablePurchaseExpenseAmount,
      ),
      taxOut: _parseAmount(dto.taxOut),
    );
  }

  static ReportTaxInvoiceRow toTaxInvoiceRow(ReportTaxInvoiceRowDto dto) {
    return ReportTaxInvoiceRow(
      partyName: dto.partyName,
      invoiceNo: dto.invoiceNo,
      totalValue: _parseAmount(dto.totalValue),
      amountReceived: _parseAmount(dto.amountReceived),
      totalTaxCollected: _parseAmount(dto.totalTaxCollected),
      collectionDate: DateTime.tryParse(dto.collectionDate) ?? DateTime.now(),
      taxName: dto.taxName,
      taxRate: _parseAmount(dto.taxRate),
    );
  }

  static ReportExpenseRow toExpenseRow(ReportExpenseRowDto dto) {
    final paymentMode = dto.paymentMode?.trim();
    return ReportExpenseRow(
      id: dto.id,
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      expenseNo: dto.expenseNo,
      partyName: dto.partyName,
      category: dto.category,
      paymentType: paymentMode != null && paymentMode.isNotEmpty
          ? _expensePaymentTypeLabel(paymentMode)
          : null,
      amount: _parseAmount(dto.amount),
      balanceDue: _parseAmount(dto.balanceDue),
      dueDate: dto.dueDate != null && dto.dueDate!.isNotEmpty
          ? DateTime.tryParse(dto.dueDate!)
          : null,
      status: _expenseReportStatus(dto.status),
    );
  }

  static ExpenseReportPaymentStatus _expenseReportStatus(String raw) {
    return switch (raw.trim().toLowerCase()) {
      'paid' => ExpenseReportPaymentStatus.paid,
      'partial' => ExpenseReportPaymentStatus.partial,
      _ => ExpenseReportPaymentStatus.pending,
    };
  }

  static String _expensePaymentTypeLabel(String apiValue) {
    return switch (apiValue.toLowerCase()) {
      'cash' => 'Cash',
      'upi' => 'UPI',
      'cheque' => 'Cheque',
      'bank_transfer' => 'Bank Transfer',
      'card' => 'Card',
      _ => apiValue,
    };
  }

  static ReportExpenseCategoryRow toExpenseCategoryRow(
    ReportExpenseCategoryRowDto dto,
  ) {
    return ReportExpenseCategoryRow(
      categoryId: dto.categoryId,
      category: dto.category,
      categoryType: dto.categoryType,
      amount: _parseAmount(dto.amount),
      count: dto.count,
    );
  }

  static ReportExpenseItemRow toExpenseItemRow(ReportExpenseItemRowDto dto) {
    return ReportExpenseItemRow(
      itemName: dto.itemName,
      category: dto.category,
      amount: _parseAmount(dto.amount),
      count: dto.count,
      categoryId: dto.categoryId,
    );
  }

  static ReportOrderRow toOrderRow(ReportOrderRowDto dto) {
    return ReportOrderRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      orderNo: dto.orderNo,
      partyName: dto.partyName,
      dueDate: DateTime.tryParse(dto.dueDate) ?? DateTime.now(),
      status: dto.status,
      type: dto.type,
      amount: _parseAmount(dto.amount),
    );
  }

  static ReportOrderItemRow toOrderItemRow(ReportOrderItemRowDto dto) {
    return ReportOrderItemRow(
      itemName: dto.itemName,
      orderNo: dto.orderNo,
      partyName: dto.partyName,
      quantity: _parseAmount(dto.quantity),
      amount: _parseAmount(dto.amount),
    );
  }

  static ReportOtherIncomeRow toOtherIncomeRow(ReportOtherIncomeRowDto dto) {
    return ReportOtherIncomeRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      incomeNo: dto.incomeNo,
      partyName: dto.partyName,
      category: dto.category,
      paymentType: dto.paymentType,
      amount: _parseAmount(dto.amount),
      dueDate: DateTime.tryParse(dto.dueDate) ?? DateTime.now(),
      status: dto.status,
    );
  }

  static ReportOtherIncomeCategoryRow toOtherIncomeCategoryRow(
    ReportOtherIncomeCategoryRowDto dto,
  ) {
    return ReportOtherIncomeCategoryRow(
      category: dto.category,
      amount: _parseAmount(dto.amount),
      count: dto.count,
    );
  }

  static ReportOtherIncomeItemRow toOtherIncomeItemRow(
    ReportOtherIncomeItemRowDto dto,
  ) {
    return ReportOtherIncomeItemRow(
      itemName: dto.itemName,
      category: dto.category,
      amount: _parseAmount(dto.amount),
      count: dto.count,
    );
  }

  static ReportLoanStatementRow toLoanStatementRow(
    ReportLoanStatementRowDto dto,
  ) {
    return ReportLoanStatementRow(
      date: DateTime.tryParse(dto.date) ?? DateTime.now(),
      description: dto.description,
      refNo: dto.refNo,
      debit: _parseAmount(dto.debit),
      credit: _parseAmount(dto.credit),
      balance: _parseAmount(dto.balance),
      isOpening: dto.isOpening,
    );
  }
}

/// Tax invoice row used by TDS/TCS/Form 27EQ reports.
class ReportTaxInvoiceRow {
  const ReportTaxInvoiceRow({
    required this.partyName,
    required this.invoiceNo,
    required this.totalValue,
    required this.amountReceived,
    required this.totalTaxCollected,
    required this.collectionDate,
    required this.taxName,
    required this.taxRate,
  });

  final String partyName;
  final String invoiceNo;
  final double totalValue;
  final double amountReceived;
  final double totalTaxCollected;
  final DateTime collectionDate;
  final String taxName;
  final double taxRate;
}
