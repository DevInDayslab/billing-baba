import 'package:billing_baba/features/reports/models/dto/report_dto.dart';

class ReportBillWiseProfitRowDto {
  const ReportBillWiseProfitRowDto({
    required this.date,
    required this.invoiceNo,
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.profit,
  });

  factory ReportBillWiseProfitRowDto.fromJson(Map<String, dynamic> json) {
    return ReportBillWiseProfitRowDto(
      date: json['date'] as String? ?? '',
      invoiceNo: json['invoice_no'] as String? ?? '',
      partyName: json['party_name'] as String? ?? '',
      saleAmount: json['sale_amount'] as String? ?? '0',
      purchaseAmount: json['purchase_amount'] as String? ?? '0',
      profit: json['profit'] as String? ?? '0',
    );
  }

  final String date;
  final String invoiceNo;
  final String partyName;
  final String saleAmount;
  final String purchaseAmount;
  final String profit;
}

class BillWiseProfitPayloadDto {
  const BillWiseProfitPayloadDto({required this.rows});

  factory BillWiseProfitPayloadDto.fromJson(Map<String, dynamic> json) {
    return BillWiseProfitPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportBillWiseProfitRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportBillWiseProfitRowDto> rows;
}

class CashFlowPayloadDto {
  const CashFlowPayloadDto({
    required this.period,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalMoneyIn,
    required this.totalMoneyOut,
    required this.rows,
  });

  factory CashFlowPayloadDto.fromJson(Map<String, dynamic> json) {
    return CashFlowPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      openingBalance: json['opening_balance'] as String? ?? '0',
      closingBalance: json['closing_balance'] as String? ?? '0',
      totalMoneyIn: json['total_money_in'] as String? ?? '0',
      totalMoneyOut: json['total_money_out'] as String? ?? '0',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportTransactionRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final String openingBalance;
  final String closingBalance;
  final String totalMoneyIn;
  final String totalMoneyOut;
  final List<ReportTransactionRowDto> rows;
}

class ReportPartyWiseProfitLossRowDto {
  const ReportPartyWiseProfitLossRowDto({
    required this.partyName,
    required this.phone,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.profit,
  });

  factory ReportPartyWiseProfitLossRowDto.fromJson(Map<String, dynamic> json) {
    return ReportPartyWiseProfitLossRowDto(
      partyName: json['party_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      saleAmount: json['sale_amount'] as String? ?? '0',
      purchaseAmount: json['purchase_amount'] as String? ?? '0',
      profit: json['profit'] as String? ?? '0',
    );
  }

  final String partyName;
  final String phone;
  final String saleAmount;
  final String purchaseAmount;
  final String profit;
}

class PartyWiseProfitLossPayloadDto {
  const PartyWiseProfitLossPayloadDto({required this.rows});

  factory PartyWiseProfitLossPayloadDto.fromJson(Map<String, dynamic> json) {
    return PartyWiseProfitLossPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportPartyWiseProfitLossRowDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  final List<ReportPartyWiseProfitLossRowDto> rows;
}

class ReportPartyByItemRowDto {
  const ReportPartyByItemRowDto({
    required this.partyName,
    required this.quantity,
    required this.amount,
  });

  factory ReportPartyByItemRowDto.fromJson(Map<String, dynamic> json) {
    return ReportPartyByItemRowDto(
      partyName: json['party_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
      amount: json['amount'] as String? ?? '0',
    );
  }

  final String partyName;
  final String quantity;
  final String amount;
}

class PartyReportByItemPayloadDto {
  const PartyReportByItemPayloadDto({required this.rows});

  factory PartyReportByItemPayloadDto.fromJson(Map<String, dynamic> json) {
    return PartyReportByItemPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportPartyByItemRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportPartyByItemRowDto> rows;
}

class ReportSalePurchaseByPartyRowDto {
  const ReportSalePurchaseByPartyRowDto({
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
  });

  factory ReportSalePurchaseByPartyRowDto.fromJson(Map<String, dynamic> json) {
    return ReportSalePurchaseByPartyRowDto(
      partyName: json['party_name'] as String? ?? '',
      saleAmount: json['sale_amount'] as String? ?? '0',
      purchaseAmount: json['purchase_amount'] as String? ?? '0',
    );
  }

  final String partyName;
  final String saleAmount;
  final String purchaseAmount;
}

class SalePurchaseByPartyPayloadDto {
  const SalePurchaseByPartyPayloadDto({required this.rows});

  factory SalePurchaseByPartyPayloadDto.fromJson(Map<String, dynamic> json) {
    return SalePurchaseByPartyPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportSalePurchaseByPartyRowDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  final List<ReportSalePurchaseByPartyRowDto> rows;
}

class ReportSalePurchaseByPartyGroupRowDto {
  const ReportSalePurchaseByPartyGroupRowDto({
    required this.partyGroup,
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
  });

  factory ReportSalePurchaseByPartyGroupRowDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportSalePurchaseByPartyGroupRowDto(
      partyGroup: json['party_group'] as String? ?? '',
      partyName: json['party_name'] as String? ?? '',
      saleAmount: json['sale_amount'] as String? ?? '0',
      purchaseAmount: json['purchase_amount'] as String? ?? '0',
    );
  }

  final String partyGroup;
  final String partyName;
  final String saleAmount;
  final String purchaseAmount;
}

class SalePurchaseByPartyGroupPayloadDto {
  const SalePurchaseByPartyGroupPayloadDto({required this.rows});

  factory SalePurchaseByPartyGroupPayloadDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalePurchaseByPartyGroupPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportSalePurchaseByPartyGroupRowDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  final List<ReportSalePurchaseByPartyGroupRowDto> rows;
}

class ReportGstr9SupplyRowDto {
  const ReportGstr9SupplyRowDto({
    required this.label,
    required this.taxableValue,
    required this.integratedTax,
    required this.centralTax,
    required this.stateTax,
    required this.cess,
  });

  factory ReportGstr9SupplyRowDto.fromJson(Map<String, dynamic> json) {
    return ReportGstr9SupplyRowDto(
      label: json['label'] as String? ?? '',
      taxableValue: json['taxable_value'] as String? ?? '0',
      integratedTax: json['integrated_tax'] as String? ?? '0',
      centralTax: json['central_tax'] as String? ?? '0',
      stateTax: json['state_tax'] as String? ?? '0',
      cess: json['cess'] as String? ?? '0',
    );
  }

  final String label;
  final String taxableValue;
  final String integratedTax;
  final String centralTax;
  final String stateTax;
  final String cess;
}

class Gstr9PayloadDto {
  const Gstr9PayloadDto({
    required this.period,
    required this.rows,
  });

  factory Gstr9PayloadDto.fromJson(Map<String, dynamic> json) {
    return Gstr9PayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportGstr9SupplyRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final List<ReportGstr9SupplyRowDto> rows;
}

class ReportSacRowDto {
  const ReportSacRowDto({
    required this.sac,
    required this.invoiceType,
    required this.totalValue,
    required this.taxableValue,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
  });

  factory ReportSacRowDto.fromJson(Map<String, dynamic> json) {
    return ReportSacRowDto(
      sac: json['sac'] as String? ?? '',
      invoiceType: json['invoice_type'] as String? ?? '',
      totalValue: json['total_value'] as String? ?? '0',
      taxableValue: json['taxable_value'] as String? ?? '0',
      igst: json['igst'] as String? ?? '0',
      cgst: json['cgst'] as String? ?? '0',
      sgst: json['sgst'] as String? ?? '0',
      cess: json['cess'] as String? ?? '0',
    );
  }

  final String sac;
  final String invoiceType;
  final String totalValue;
  final String taxableValue;
  final String igst;
  final String cgst;
  final String sgst;
  final String cess;
}

class SacReportPayloadDto {
  const SacReportPayloadDto({
    required this.period,
    required this.rows,
  });

  factory SacReportPayloadDto.fromJson(Map<String, dynamic> json) {
    return SacReportPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportSacRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final List<ReportSacRowDto> rows;
}

class ReportHsnRowDto {
  const ReportHsnRowDto({
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

  factory ReportHsnRowDto.fromJson(Map<String, dynamic> json) {
    return ReportHsnRowDto(
      hsn: json['hsn'] as String? ?? '',
      description: json['description'] as String? ?? '',
      uqc: json['uqc'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
      totalValue: json['total_value'] as String? ?? '0',
      taxableValue: json['taxable_value'] as String? ?? '0',
      igst: json['igst'] as String? ?? '0',
      cgst: json['cgst'] as String? ?? '0',
      sgst: json['sgst'] as String? ?? '0',
    );
  }

  final String hsn;
  final String description;
  final String uqc;
  final String quantity;
  final String totalValue;
  final String taxableValue;
  final String igst;
  final String cgst;
  final String sgst;
}

class SaleSummaryByHsnPayloadDto {
  const SaleSummaryByHsnPayloadDto({
    required this.period,
    required this.rows,
  });

  factory SaleSummaryByHsnPayloadDto.fromJson(Map<String, dynamic> json) {
    return SaleSummaryByHsnPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportHsnRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final List<ReportHsnRowDto> rows;
}

class ReportItemByPartyRowDto {
  const ReportItemByPartyRowDto({
    required this.itemName,
    required this.partyName,
    required this.quantity,
    required this.amount,
  });

  factory ReportItemByPartyRowDto.fromJson(Map<String, dynamic> json) {
    return ReportItemByPartyRowDto(
      itemName: json['item_name'] as String? ?? '',
      partyName: json['party_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
      amount: json['amount'] as String? ?? '0',
    );
  }

  final String itemName;
  final String partyName;
  final String quantity;
  final String amount;
}

class ItemReportByPartyPayloadDto {
  const ItemReportByPartyPayloadDto({required this.rows});

  factory ItemReportByPartyPayloadDto.fromJson(Map<String, dynamic> json) {
    return ItemReportByPartyPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportItemByPartyRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportItemByPartyRowDto> rows;
}

class ReportItemWiseProfitLossRowDto {
  const ReportItemWiseProfitLossRowDto({
    required this.itemName,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.profit,
  });

  factory ReportItemWiseProfitLossRowDto.fromJson(Map<String, dynamic> json) {
    return ReportItemWiseProfitLossRowDto(
      itemName: json['item_name'] as String? ?? '',
      saleAmount: json['sale_amount'] as String? ?? '0',
      purchaseAmount: json['purchase_amount'] as String? ?? '0',
      profit: json['profit'] as String? ?? '0',
    );
  }

  final String itemName;
  final String saleAmount;
  final String purchaseAmount;
  final String profit;
}

class ItemWiseProfitLossPayloadDto {
  const ItemWiseProfitLossPayloadDto({required this.rows});

  factory ItemWiseProfitLossPayloadDto.fromJson(Map<String, dynamic> json) {
    return ItemWiseProfitLossPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportItemWiseProfitLossRowDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  final List<ReportItemWiseProfitLossRowDto> rows;
}

class ReportStockDetailRowDto {
  const ReportStockDetailRowDto({
    required this.itemName,
    required this.openingQty,
    required this.inQty,
    required this.outQty,
    required this.closingQty,
  });

  factory ReportStockDetailRowDto.fromJson(Map<String, dynamic> json) {
    return ReportStockDetailRowDto(
      itemName: json['item_name'] as String? ?? '',
      openingQty: json['opening_qty'] as String? ?? '0',
      inQty: json['in_qty'] as String? ?? '0',
      outQty: json['out_qty'] as String? ?? '0',
      closingQty: json['closing_qty'] as String? ?? '0',
    );
  }

  final String itemName;
  final String openingQty;
  final String inQty;
  final String outQty;
  final String closingQty;
}

class StockDetailPayloadDto {
  const StockDetailPayloadDto({required this.rows});

  factory StockDetailPayloadDto.fromJson(Map<String, dynamic> json) {
    return StockDetailPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportStockDetailRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportStockDetailRowDto> rows;
}

class ReportItemDetailRowDto {
  const ReportItemDetailRowDto({
    required this.date,
    required this.type,
    required this.refNo,
    required this.partyName,
    required this.quantity,
    required this.price,
    required this.amount,
  });

  factory ReportItemDetailRowDto.fromJson(Map<String, dynamic> json) {
    return ReportItemDetailRowDto(
      date: json['date'] as String? ?? '',
      type: json['type'] as String? ?? '',
      refNo: json['ref_no'] as String? ?? '',
      partyName: json['party_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
      price: json['price'] as String? ?? '0',
      amount: json['amount'] as String? ?? '0',
    );
  }

  final String date;
  final String type;
  final String refNo;
  final String partyName;
  final String quantity;
  final String price;
  final String amount;
}

class ItemDetailPayloadDto {
  const ItemDetailPayloadDto({required this.rows});

  factory ItemDetailPayloadDto.fromJson(Map<String, dynamic> json) {
    return ItemDetailPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportItemDetailRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportItemDetailRowDto> rows;
}

class ReportCategoryAmountRowDto {
  const ReportCategoryAmountRowDto({
    required this.category,
    required this.saleAmount,
    required this.purchaseAmount,
  });

  factory ReportCategoryAmountRowDto.fromJson(Map<String, dynamic> json) {
    return ReportCategoryAmountRowDto(
      category: json['category'] as String? ?? '',
      saleAmount: json['sale_amount'] as String? ?? '0',
      purchaseAmount: json['purchase_amount'] as String? ?? '0',
    );
  }

  final String category;
  final String saleAmount;
  final String purchaseAmount;
}

class CategoryRowsPayloadDto {
  const CategoryRowsPayloadDto({required this.rows});

  factory CategoryRowsPayloadDto.fromJson(Map<String, dynamic> json) {
    return CategoryRowsPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportCategoryAmountRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportCategoryAmountRowDto> rows;
}

class ReportItemDiscountRowDto {
  const ReportItemDiscountRowDto({
    required this.itemName,
    required this.saleQty,
    required this.discountAmount,
    required this.discountPercent,
  });

  factory ReportItemDiscountRowDto.fromJson(Map<String, dynamic> json) {
    return ReportItemDiscountRowDto(
      itemName: json['item_name'] as String? ?? '',
      saleQty: json['sale_qty'] as String? ?? '0',
      discountAmount: json['discount_amount'] as String? ?? '0',
      discountPercent: json['discount_percent'] as String? ?? '0',
    );
  }

  final String itemName;
  final String saleQty;
  final String discountAmount;
  final String discountPercent;
}

class ItemWiseDiscountPayloadDto {
  const ItemWiseDiscountPayloadDto({required this.rows});

  factory ItemWiseDiscountPayloadDto.fromJson(Map<String, dynamic> json) {
    return ItemWiseDiscountPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportItemDiscountRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportItemDiscountRowDto> rows;
}

class ReportManufacturingRowDto {
  const ReportManufacturingRowDto({
    required this.date,
    required this.refNo,
    required this.itemName,
    required this.quantity,
    required this.cost,
  });

  factory ReportManufacturingRowDto.fromJson(Map<String, dynamic> json) {
    return ReportManufacturingRowDto(
      date: json['date'] as String? ?? '',
      refNo: json['ref_no'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
      cost: json['cost'] as String? ?? '0',
    );
  }

  final String date;
  final String refNo;
  final String itemName;
  final String quantity;
  final String cost;
}

class ManufacturingPayloadDto {
  const ManufacturingPayloadDto({required this.rows});

  factory ManufacturingPayloadDto.fromJson(Map<String, dynamic> json) {
    return ManufacturingPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportManufacturingRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportManufacturingRowDto> rows;
}

class ReportConsumptionRowDto {
  const ReportConsumptionRowDto({
    required this.date,
    required this.refNo,
    required this.itemName,
    required this.quantity,
    required this.value,
  });

  factory ReportConsumptionRowDto.fromJson(Map<String, dynamic> json) {
    return ReportConsumptionRowDto(
      date: json['date'] as String? ?? '',
      refNo: json['ref_no'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
      value: json['value'] as String? ?? '0',
    );
  }

  final String date;
  final String refNo;
  final String itemName;
  final String quantity;
  final String value;
}

class ConsumptionPayloadDto {
  const ConsumptionPayloadDto({required this.rows});

  factory ConsumptionPayloadDto.fromJson(Map<String, dynamic> json) {
    return ConsumptionPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportConsumptionRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportConsumptionRowDto> rows;
}

class ReportStockTransferRowDto {
  const ReportStockTransferRowDto({
    required this.date,
    required this.refNo,
    required this.fromGodown,
    required this.toGodown,
    required this.itemName,
    required this.quantity,
  });

  factory ReportStockTransferRowDto.fromJson(Map<String, dynamic> json) {
    return ReportStockTransferRowDto(
      date: json['date'] as String? ?? '',
      refNo: json['ref_no'] as String? ?? '',
      fromGodown: json['from_godown'] as String? ?? '',
      toGodown: json['to_godown'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
    );
  }

  final String date;
  final String refNo;
  final String fromGodown;
  final String toGodown;
  final String itemName;
  final String quantity;
}

class StockTransferPayloadDto {
  const StockTransferPayloadDto({required this.rows});

  factory StockTransferPayloadDto.fromJson(Map<String, dynamic> json) {
    return StockTransferPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportStockTransferRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportStockTransferRowDto> rows;
}

class ReportBankStatementRowDto {
  const ReportBankStatementRowDto({
    required this.date,
    required this.description,
    required this.refNo,
    required this.moneyIn,
    required this.moneyOut,
    required this.balance,
    this.isOpening = false,
  });

  factory ReportBankStatementRowDto.fromJson(Map<String, dynamic> json) {
    return ReportBankStatementRowDto(
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
      refNo: json['ref_no'] as String? ?? '',
      moneyIn: json['money_in'] as String? ?? '0',
      moneyOut: json['money_out'] as String? ?? '0',
      balance: json['balance'] as String? ?? '0',
      isOpening: json['is_opening'] as bool? ?? false,
    );
  }

  final String date;
  final String description;
  final String refNo;
  final String moneyIn;
  final String moneyOut;
  final String balance;
  final bool isOpening;
}

class BankStatementPayloadDto {
  const BankStatementPayloadDto({
    required this.period,
    required this.bankName,
    required this.rows,
  });

  factory BankStatementPayloadDto.fromJson(Map<String, dynamic> json) {
    return BankStatementPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      bankName: json['bank_name'] as String? ?? '',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportBankStatementRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final String bankName;
  final List<ReportBankStatementRowDto> rows;
}

class ReportGstTaxPartyRowDto {
  const ReportGstTaxPartyRowDto({
    required this.partyName,
    required this.saleTax,
    required this.purchaseExpenseTax,
  });

  factory ReportGstTaxPartyRowDto.fromJson(Map<String, dynamic> json) {
    return ReportGstTaxPartyRowDto(
      partyName: json['party_name'] as String? ?? '',
      saleTax: json['sale_tax'] as String? ?? '0',
      purchaseExpenseTax: json['purchase_expense_tax'] as String? ?? '0',
    );
  }

  final String partyName;
  final String saleTax;
  final String purchaseExpenseTax;
}

class GstTaxReportPayloadDto {
  const GstTaxReportPayloadDto({required this.rows});

  factory GstTaxReportPayloadDto.fromJson(Map<String, dynamic> json) {
    return GstTaxReportPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportGstTaxPartyRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportGstTaxPartyRowDto> rows;
}

class ReportGstTaxRateRowDto {
  const ReportGstTaxRateRowDto({
    required this.taxName,
    required this.taxPercent,
    required this.taxableSaleAmount,
    required this.taxIn,
    required this.taxablePurchaseExpenseAmount,
    required this.taxOut,
  });

  factory ReportGstTaxRateRowDto.fromJson(Map<String, dynamic> json) {
    return ReportGstTaxRateRowDto(
      taxName: json['tax_name'] as String? ?? '',
      taxPercent: json['tax_percent'] as String? ?? '0',
      taxableSaleAmount: json['taxable_sale_amount'] as String? ?? '0',
      taxIn: json['tax_in'] as String? ?? '0',
      taxablePurchaseExpenseAmount:
          json['taxable_purchase_expense_amount'] as String? ?? '0',
      taxOut: json['tax_out'] as String? ?? '0',
    );
  }

  final String taxName;
  final String taxPercent;
  final String taxableSaleAmount;
  final String taxIn;
  final String taxablePurchaseExpenseAmount;
  final String taxOut;
}

class GstTaxRateReportPayloadDto {
  const GstTaxRateReportPayloadDto({required this.rows});

  factory GstTaxRateReportPayloadDto.fromJson(Map<String, dynamic> json) {
    return GstTaxRateReportPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportGstTaxRateRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportGstTaxRateRowDto> rows;
}

class ReportTaxInvoiceRowDto {
  const ReportTaxInvoiceRowDto({
    required this.partyName,
    required this.invoiceNo,
    required this.totalValue,
    required this.amountReceived,
    required this.totalTaxCollected,
    required this.collectionDate,
    required this.taxName,
    required this.taxRate,
  });

  factory ReportTaxInvoiceRowDto.fromJson(Map<String, dynamic> json) {
    return ReportTaxInvoiceRowDto(
      partyName: json['party_name'] as String? ?? '',
      invoiceNo: json['invoice_no'] as String? ?? '',
      totalValue: json['total_value'] as String? ?? '0',
      amountReceived: json['amount_received'] as String? ?? '0',
      totalTaxCollected: json['total_tax_collected'] as String? ?? '0',
      collectionDate: json['collection_date'] as String? ?? '',
      taxName: json['tax_name'] as String? ?? '',
      taxRate: json['tax_rate'] as String? ?? '0',
    );
  }

  final String partyName;
  final String invoiceNo;
  final String totalValue;
  final String amountReceived;
  final String totalTaxCollected;
  final String collectionDate;
  final String taxName;
  final String taxRate;
}

class TaxInvoiceReportPayloadDto {
  const TaxInvoiceReportPayloadDto({required this.rows});

  factory TaxInvoiceReportPayloadDto.fromJson(Map<String, dynamic> json) {
    return TaxInvoiceReportPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportTaxInvoiceRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportTaxInvoiceRowDto> rows;
}

class ReportExpenseRowDto {
  const ReportExpenseRowDto({
    required this.date,
    required this.expenseNo,
    required this.partyName,
    required this.category,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  factory ReportExpenseRowDto.fromJson(Map<String, dynamic> json) {
    return ReportExpenseRowDto(
      date: json['date'] as String? ?? '',
      expenseNo: json['expense_no'] as String? ?? '',
      partyName: json['party_name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      dueDate: json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  final String date;
  final String expenseNo;
  final String partyName;
  final String category;
  final String amount;
  final String dueDate;
  final String status;
}

class ExpensesPayloadDto {
  const ExpensesPayloadDto({
    required this.period,
    required this.totalAmount,
    required this.rows,
  });

  factory ExpensesPayloadDto.fromJson(Map<String, dynamic> json) {
    return ExpensesPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      totalAmount: json['total_amount'] as String? ?? '0',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportExpenseRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final String totalAmount;
  final List<ReportExpenseRowDto> rows;
}

class ReportExpenseCategoryRowDto {
  const ReportExpenseCategoryRowDto({
    required this.category,
    required this.amount,
    required this.count,
  });

  factory ReportExpenseCategoryRowDto.fromJson(Map<String, dynamic> json) {
    return ReportExpenseCategoryRowDto(
      category: json['category'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  final String category;
  final String amount;
  final int count;
}

class ExpenseByCategoryPayloadDto {
  const ExpenseByCategoryPayloadDto({required this.rows});

  factory ExpenseByCategoryPayloadDto.fromJson(Map<String, dynamic> json) {
    return ExpenseByCategoryPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportExpenseCategoryRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportExpenseCategoryRowDto> rows;
}

class ReportExpenseItemRowDto {
  const ReportExpenseItemRowDto({
    required this.itemName,
    required this.category,
    required this.amount,
    required this.count,
  });

  factory ReportExpenseItemRowDto.fromJson(Map<String, dynamic> json) {
    return ReportExpenseItemRowDto(
      itemName: json['item_name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  final String itemName;
  final String category;
  final String amount;
  final int count;
}

class ExpenseByItemPayloadDto {
  const ExpenseByItemPayloadDto({required this.rows});

  factory ExpenseByItemPayloadDto.fromJson(Map<String, dynamic> json) {
    return ExpenseByItemPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportExpenseItemRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportExpenseItemRowDto> rows;
}

class ReportOrderRowDto {
  const ReportOrderRowDto({
    required this.date,
    required this.orderNo,
    required this.partyName,
    required this.dueDate,
    required this.status,
    required this.type,
    required this.amount,
  });

  factory ReportOrderRowDto.fromJson(Map<String, dynamic> json) {
    return ReportOrderRowDto(
      date: json['date'] as String? ?? '',
      orderNo: json['order_no'] as String? ?? '',
      partyName: json['party_name'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      type: json['type'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
    );
  }

  final String date;
  final String orderNo;
  final String partyName;
  final String dueDate;
  final String status;
  final String type;
  final String amount;
}

class SalePurchaseOrdersPayloadDto {
  const SalePurchaseOrdersPayloadDto({
    required this.period,
    required this.totalAmount,
    required this.rows,
  });

  factory SalePurchaseOrdersPayloadDto.fromJson(Map<String, dynamic> json) {
    return SalePurchaseOrdersPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      totalAmount: json['total_amount'] as String? ?? '0',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => ReportOrderRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final String totalAmount;
  final List<ReportOrderRowDto> rows;
}

class ReportOrderItemRowDto {
  const ReportOrderItemRowDto({
    required this.itemName,
    required this.orderNo,
    required this.partyName,
    required this.quantity,
    required this.amount,
  });

  factory ReportOrderItemRowDto.fromJson(Map<String, dynamic> json) {
    return ReportOrderItemRowDto(
      itemName: json['item_name'] as String? ?? '',
      orderNo: json['order_no'] as String? ?? '',
      partyName: json['party_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '0',
      amount: json['amount'] as String? ?? '0',
    );
  }

  final String itemName;
  final String orderNo;
  final String partyName;
  final String quantity;
  final String amount;
}

class SalePurchaseOrderItemsPayloadDto {
  const SalePurchaseOrderItemsPayloadDto({required this.rows});

  factory SalePurchaseOrderItemsPayloadDto.fromJson(Map<String, dynamic> json) {
    return SalePurchaseOrderItemsPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportOrderItemRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<ReportOrderItemRowDto> rows;
}

class ReportOtherIncomeRowDto {
  const ReportOtherIncomeRowDto({
    required this.date,
    required this.incomeNo,
    required this.partyName,
    required this.category,
    required this.paymentType,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  factory ReportOtherIncomeRowDto.fromJson(Map<String, dynamic> json) {
    return ReportOtherIncomeRowDto(
      date: json['date'] as String? ?? '',
      incomeNo: json['income_no'] as String? ?? '',
      partyName: json['party_name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      paymentType: json['payment_type'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      dueDate: json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  final String date;
  final String incomeNo;
  final String partyName;
  final String category;
  final String paymentType;
  final String amount;
  final String dueDate;
  final String status;
}

class OtherIncomePayloadDto {
  const OtherIncomePayloadDto({
    required this.period,
    required this.totalAmount,
    required this.rows,
  });

  factory OtherIncomePayloadDto.fromJson(Map<String, dynamic> json) {
    return OtherIncomePayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      totalAmount: json['total_amount'] as String? ?? '0',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportOtherIncomeRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final String totalAmount;
  final List<ReportOtherIncomeRowDto> rows;
}

class ReportOtherIncomeCategoryRowDto {
  const ReportOtherIncomeCategoryRowDto({
    required this.category,
    required this.amount,
    required this.count,
  });

  factory ReportOtherIncomeCategoryRowDto.fromJson(Map<String, dynamic> json) {
    return ReportOtherIncomeCategoryRowDto(
      category: json['category'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  final String category;
  final String amount;
  final int count;
}

class OtherIncomeByCategoryPayloadDto {
  const OtherIncomeByCategoryPayloadDto({required this.rows});

  factory OtherIncomeByCategoryPayloadDto.fromJson(Map<String, dynamic> json) {
    return OtherIncomeByCategoryPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportOtherIncomeCategoryRowDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  final List<ReportOtherIncomeCategoryRowDto> rows;
}

class ReportOtherIncomeItemRowDto {
  const ReportOtherIncomeItemRowDto({
    required this.itemName,
    required this.category,
    required this.amount,
    required this.count,
  });

  factory ReportOtherIncomeItemRowDto.fromJson(Map<String, dynamic> json) {
    return ReportOtherIncomeItemRowDto(
      itemName: json['item_name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  final String itemName;
  final String category;
  final String amount;
  final int count;
}

class OtherIncomeByItemPayloadDto {
  const OtherIncomeByItemPayloadDto({required this.rows});

  factory OtherIncomeByItemPayloadDto.fromJson(Map<String, dynamic> json) {
    return OtherIncomeByItemPayloadDto(
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) => ReportOtherIncomeItemRowDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  final List<ReportOtherIncomeItemRowDto> rows;
}

class ReportLoanStatementRowDto {
  const ReportLoanStatementRowDto({
    required this.date,
    required this.description,
    required this.refNo,
    required this.debit,
    required this.credit,
    required this.balance,
    this.isOpening = false,
  });

  factory ReportLoanStatementRowDto.fromJson(Map<String, dynamic> json) {
    return ReportLoanStatementRowDto(
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
      refNo: json['ref_no'] as String? ?? '',
      debit: json['debit'] as String? ?? '0',
      credit: json['credit'] as String? ?? '0',
      balance: json['balance'] as String? ?? '0',
      isOpening: json['is_opening'] as bool? ?? false,
    );
  }

  final String date;
  final String description;
  final String refNo;
  final String debit;
  final String credit;
  final String balance;
  final bool isOpening;
}

class LoanStatementPayloadDto {
  const LoanStatementPayloadDto({
    required this.period,
    required this.loanAccount,
    required this.rows,
  });

  factory LoanStatementPayloadDto.fromJson(Map<String, dynamic> json) {
    return LoanStatementPayloadDto(
      period: ReportPeriodDto.fromJson(
        (json['period'] as Map<String, dynamic>?) ?? {},
      ),
      loanAccount: json['loan_account'] as String? ?? '',
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ReportLoanStatementRowDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final ReportPeriodDto period;
  final String loanAccount;
  final List<ReportLoanStatementRowDto> rows;
}
