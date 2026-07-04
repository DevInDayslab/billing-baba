import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';

/// Shared transaction row used across Day Book, All Transactions, Cash Flow.
class ReportTransactionRow {
  const ReportTransactionRow({
    required this.id,
    required this.date,
    required this.refNo,
    required this.partyName,
    required this.category,
    required this.type,
    required this.total,
    this.received = 0,
    this.balance = 0,
    this.moneyIn = 0,
    this.moneyOut = 0,
    this.dueDate,
    this.status = '',
    this.paymentType = '',
  });

  final String id;
  final DateTime date;
  final String refNo;
  final String partyName;
  final String category;
  final String type;
  final double total;
  final double received;
  final double balance;
  final double moneyIn;
  final double moneyOut;
  final DateTime? dueDate;
  final String status;
  final String paymentType;
}

class ReportPurchaseRow {
  const ReportPurchaseRow({
    required this.id,
    required this.date,
    required this.invoiceNo,
    required this.partyName,
    required this.paymentType,
    required this.status,
    required this.amount,
    required this.balance,
  });

  final String id;
  final DateTime date;
  final String invoiceNo;
  final String partyName;
  final String paymentType;
  final SaleInvoiceStatus status;
  final double amount;
  final double balance;
}

class ReportProfitLossItem {
  const ReportProfitLossItem({
    required this.particular,
    required this.amount,
    this.isHeader = false,
    this.indent = 0,
  });

  final String particular;
  final double amount;
  final bool isHeader;
  final int indent;
}

class ReportBillWiseProfitRow {
  const ReportBillWiseProfitRow({
    required this.date,
    required this.invoiceNo,
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.profit,
  });

  final DateTime date;
  final String invoiceNo;
  final String partyName;
  final double saleAmount;
  final double purchaseAmount;
  final double profit;
}

class ReportTrialBalanceRow {
  const ReportTrialBalanceRow({
    required this.accountName,
    required this.opening,
    required this.debit,
    required this.credit,
    required this.closingDebit,
    required this.closingCredit,
  });

  final String accountName;
  final double opening;
  final double debit;
  final double credit;
  final double closingDebit;
  final double closingCredit;
}

class ReportBalanceSheetItem {
  const ReportBalanceSheetItem({
    required this.name,
    required this.amount,
    this.indent = 0,
    this.isHeader = false,
  });

  final String name;
  final double amount;
  final int indent;
  final bool isHeader;
}

class ReportPartyStatementEntry {
  const ReportPartyStatementEntry({
    required this.date,
    required this.type,
    required this.refNo,
    required this.total,
    required this.balance,
  });

  final DateTime date;
  final String type;
  final String refNo;
  final double total;
  final double balance;
}

class ReportPartyStatementSummary {
  const ReportPartyStatementSummary({
    required this.totalSale,
    required this.totalPurchase,
    required this.totalMoneyIn,
    required this.totalMoneyOut,
    required this.totalReceivable,
  });

  final double totalSale;
  final double totalPurchase;
  final double totalMoneyIn;
  final double totalMoneyOut;
  final double totalReceivable;
}

class ReportPartyWiseProfitLossRow {
  const ReportPartyWiseProfitLossRow({
    required this.partyName,
    required this.phone,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.profit,
  });

  final String partyName;
  final String phone;
  final double saleAmount;
  final double purchaseAmount;
  final double profit;
}

class ReportSalePurchaseByPartyRow {
  const ReportSalePurchaseByPartyRow({
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
  });

  final String partyName;
  final double saleAmount;
  final double purchaseAmount;
}

class ReportSalePurchaseByPartyGroupRow {
  const ReportSalePurchaseByPartyGroupRow({
    required this.partyGroup,
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
  });

  final String partyGroup;
  final String partyName;
  final double saleAmount;
  final double purchaseAmount;
}

class ReportPartyByItemRow {
  const ReportPartyByItemRow({
    required this.partyName,
    required this.quantity,
    required this.amount,
  });

  final String partyName;
  final double quantity;
  final double amount;
}

class ReportGstrRow {
  const ReportGstrRow({
    required this.gstin,
    required this.partyName,
    required this.invoiceNo,
    required this.date,
    required this.value,
    required this.taxRate,
    required this.taxableValue,
    required this.integratedTax,
    this.cessRate = 0,
  });

  final String gstin;
  final String partyName;
  final String invoiceNo;
  final DateTime date;
  final double value;
  final double taxRate;
  final double taxableValue;
  final double integratedTax;
  final double cessRate;
}

class ReportSacRow {
  const ReportSacRow({
    required this.sac,
    required this.invoiceType,
    required this.totalValue,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
  });

  final String sac;
  final String invoiceType;
  final double totalValue;
  final double taxableValue;
  final double igst;
  final double cgst;
  final double sgst;
  final double cess;
}

class ReportHsnRow {
  const ReportHsnRow({
    required this.hsn,
    required this.description,
    required this.uqc,
    required this.quantity,
    required this.totalValue,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
  });

  final String hsn;
  final String description;
  final String uqc;
  final double quantity;
  final double totalValue;
  final double taxableValue;
  final double igst;
  final double cgst;
  final double sgst;
}

class ReportGstr3bRow {
  const ReportGstr3bRow({
    required this.nature,
    required this.taxableValue,
    required this.integratedTax,
    required this.centralTax,
    required this.stateTax,
    required this.cess,
  });

  final String nature;
  final double taxableValue;
  final double integratedTax;
  final double centralTax;
  final double stateTax;
  final double cess;
}

class ReportGstr9SupplyRow {
  const ReportGstr9SupplyRow({
    required this.label,
    required this.taxableValue,
    required this.integratedTax,
    required this.centralTax,
    required this.stateTax,
    required this.cess,
  });

  final String label;
  final double taxableValue;
  final double integratedTax;
  final double centralTax;
  final double stateTax;
  final double cess;
}

class ReportStockSummaryRow {
  const ReportStockSummaryRow({
    required this.itemName,
    required this.salePrice,
    required this.purchasePrice,
    required this.stockQty,
    required this.stockValue,
    this.categoryId = '',
  });

  final String itemName;
  final double salePrice;
  final double purchasePrice;
  final double stockQty;
  final double stockValue;
  final String categoryId;
}

class ReportItemByPartyRow {
  const ReportItemByPartyRow({
    required this.itemName,
    required this.partyName,
    required this.quantity,
    required this.amount,
  });

  final String itemName;
  final String partyName;
  final double quantity;
  final double amount;
}

class ReportItemWiseProfitLossRow {
  const ReportItemWiseProfitLossRow({
    required this.itemName,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.profit,
  });

  final String itemName;
  final double saleAmount;
  final double purchaseAmount;
  final double profit;
}

class ReportLowStockRow {
  const ReportLowStockRow({
    required this.itemName,
    required this.minStock,
    required this.currentStock,
    required this.shortage,
  });

  final String itemName;
  final double minStock;
  final double currentStock;
  final double shortage;
}

class ReportStockDetailRow {
  const ReportStockDetailRow({
    required this.itemName,
    required this.openingQty,
    required this.inQty,
    required this.outQty,
    required this.closingQty,
  });

  final String itemName;
  final double openingQty;
  final double inQty;
  final double outQty;
  final double closingQty;
}

class ReportItemDetailRow {
  const ReportItemDetailRow({
    required this.date,
    required this.type,
    required this.refNo,
    required this.partyName,
    required this.quantity,
    required this.price,
    required this.amount,
  });

  final DateTime date;
  final String type;
  final String refNo;
  final String partyName;
  final double quantity;
  final double price;
  final double amount;
}

class ReportCategoryAmountRow {
  const ReportCategoryAmountRow({
    required this.category,
    required this.saleAmount,
    required this.purchaseAmount,
  });

  final String category;
  final double saleAmount;
  final double purchaseAmount;
}

class ReportItemDiscountRow {
  const ReportItemDiscountRow({
    required this.itemName,
    required this.saleQty,
    required this.discountAmount,
    required this.discountPercent,
  });

  final String itemName;
  final double saleQty;
  final double discountAmount;
  final double discountPercent;
}

class ReportManufacturingRow {
  const ReportManufacturingRow({
    required this.date,
    required this.refNo,
    required this.itemName,
    required this.quantity,
    required this.cost,
  });

  final DateTime date;
  final String refNo;
  final String itemName;
  final double quantity;
  final double cost;
}

class ReportConsumptionRow {
  const ReportConsumptionRow({
    required this.date,
    required this.refNo,
    required this.itemName,
    required this.quantity,
    required this.value,
  });

  final DateTime date;
  final String refNo;
  final String itemName;
  final double quantity;
  final double value;
}

class ReportStockTransferRow {
  const ReportStockTransferRow({
    required this.date,
    required this.refNo,
    required this.fromGodown,
    required this.toGodown,
    required this.itemName,
    required this.quantity,
  });

  final DateTime date;
  final String refNo;
  final String fromGodown;
  final String toGodown;
  final String itemName;
  final double quantity;
}

class ReportExpenseRow {
  const ReportExpenseRow({
    required this.date,
    required this.expenseNo,
    required this.partyName,
    required this.category,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  final DateTime date;
  final String expenseNo;
  final String partyName;
  final String category;
  final double amount;
  final DateTime dueDate;
  final String status;
}

class ReportExpenseCategoryRow {
  const ReportExpenseCategoryRow({
    required this.category,
    required this.amount,
    required this.count,
  });

  final String category;
  final double amount;
  final int count;
}

class ReportExpenseItemRow {
  const ReportExpenseItemRow({
    required this.itemName,
    required this.category,
    required this.amount,
    required this.count,
  });

  final String itemName;
  final String category;
  final double amount;
  final int count;
}

class ReportBankStatementRow {
  const ReportBankStatementRow({
    required this.date,
    required this.description,
    required this.refNo,
    required this.moneyIn,
    required this.moneyOut,
    required this.balance,
    this.isOpening = false,
  });

  final DateTime date;
  final String description;
  final String refNo;
  final double moneyIn;
  final double moneyOut;
  final double balance;
  final bool isOpening;
}

class ReportOrderRow {
  const ReportOrderRow({
    required this.date,
    required this.orderNo,
    required this.partyName,
    required this.dueDate,
    required this.status,
    required this.type,
    required this.amount,
  });

  final DateTime date;
  final String orderNo;
  final String partyName;
  final DateTime dueDate;
  final String status;
  final String type;
  final double amount;
}

class ReportOrderItemRow {
  const ReportOrderItemRow({
    required this.itemName,
    required this.orderNo,
    required this.partyName,
    required this.quantity,
    required this.amount,
  });

  final String itemName;
  final String orderNo;
  final String partyName;
  final double quantity;
  final double amount;
}

class ReportGstTaxPartyRow {
  const ReportGstTaxPartyRow({
    required this.partyName,
    required this.saleTax,
    required this.purchaseExpenseTax,
  });

  final String partyName;
  final double saleTax;
  final double purchaseExpenseTax;
}

class ReportGstTaxRateRow {
  const ReportGstTaxRateRow({
    required this.taxName,
    required this.taxPercent,
    required this.taxableSaleAmount,
    required this.taxIn,
    required this.taxablePurchaseExpenseAmount,
    required this.taxOut,
  });

  final String taxName;
  final double taxPercent;
  final double taxableSaleAmount;
  final double taxIn;
  final double taxablePurchaseExpenseAmount;
  final double taxOut;
}

class ReportOtherIncomeRow {
  const ReportOtherIncomeRow({
    required this.date,
    required this.incomeNo,
    required this.partyName,
    required this.category,
    required this.paymentType,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  final DateTime date;
  final String incomeNo;
  final String partyName;
  final String category;
  final String paymentType;
  final double amount;
  final DateTime dueDate;
  final String status;
}

class ReportOtherIncomeCategoryRow {
  const ReportOtherIncomeCategoryRow({
    required this.category,
    required this.amount,
    required this.count,
  });

  final String category;
  final double amount;
  final int count;
}

class ReportOtherIncomeItemRow {
  const ReportOtherIncomeItemRow({
    required this.itemName,
    required this.category,
    required this.amount,
    required this.count,
  });

  final String itemName;
  final String category;
  final double amount;
  final int count;
}

class ReportLoanStatementRow {
  const ReportLoanStatementRow({
    required this.date,
    required this.description,
    required this.refNo,
    required this.debit,
    required this.credit,
    required this.balance,
    this.isOpening = false,
  });

  final DateTime date;
  final String description;
  final String refNo;
  final double debit;
  final double credit;
  final double balance;
  final bool isOpening;
}
