import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:flutter/material.dart';

enum SaleType { cash, credit }

enum InvoiceNumberMode { auto, manual }

class SaleLineItem {
  const SaleLineItem({
    required this.id,
    this.itemName = '',
    this.qty = 0,
    this.unit = 'NONE',
    this.pricePerUnit = 0,
    this.discountPercent = 0,
    this.taxPercent = 0,
  });

  final String id;
  final String itemName;
  final double qty;
  final String unit;
  final double pricePerUnit;
  final double discountPercent;
  final double taxPercent;

  double get lineSubtotal => qty * pricePerUnit * (1 - discountPercent / 100);

  double get lineTax => lineSubtotal * (taxPercent / 100);

  double get amount => lineSubtotal * (1 + taxPercent / 100);

  SaleLineItem copyWith({
    String? id,
    String? itemName,
    double? qty,
    String? unit,
    double? pricePerUnit,
    double? discountPercent,
    double? taxPercent,
  }) {
    return SaleLineItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }

  factory SaleLineItem.empty({required String id}) => SaleLineItem(id: id);
}

class SalePaymentEntry {
  const SalePaymentEntry({
    required this.type,
    this.amount = 0,
  });

  final String type;
  final double amount;

  SalePaymentEntry copyWith({String? type, double? amount}) {
    return SalePaymentEntry(
      type: type ?? this.type,
      amount: amount ?? this.amount,
    );
  }
}

class AddSaleFormState {
  const AddSaleFormState({
    this.billingName = '',
    this.phone = '',
    this.billingAddress = '',
    this.shippingAddress = '',
    this.invoiceNumber = '',
    this.invoiceNumberMode = InvoiceNumberMode.auto,
    this.invoiceDate,
    this.dueDate,
    this.invoiceTime,
    this.stateOfSupply = 'Madhya Pradesh',
    this.eWayBillNo = '',
    this.godown = 'Main Location',
    this.items = const [],
    this.payments = const [SalePaymentEntry(type: 'Cash')],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.roundOff = false,
    this.loyaltyPointsUsed = 0,
    this.loyaltyPointsEnabled = false,
    this.receivedAmount = 0,
    this.receivedEnabled = false,
    this.saleType = SaleType.cash,
    this.showValidationErrors = false,
    this.isDirty = false,
  });

  final String billingName;
  final String phone;
  final String billingAddress;
  final String shippingAddress;
  final String invoiceNumber;
  final InvoiceNumberMode invoiceNumberMode;
  final DateTime? invoiceDate;
  final DateTime? dueDate;
  final TimeOfDay? invoiceTime;
  final String stateOfSupply;
  final String eWayBillNo;
  final String godown;
  final List<SaleLineItem> items;
  final List<SalePaymentEntry> payments;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final double loyaltyPointsUsed;
  final bool loyaltyPointsEnabled;
  final double receivedAmount;
  final bool receivedEnabled;
  final SaleType saleType;
  final bool showValidationErrors;
  final bool isDirty;

  String get paymentType => payments.isNotEmpty ? payments.first.type : 'Cash';

  double get paymentAmount => payments.isNotEmpty ? payments.first.amount : 0;

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineSubtotal);

  double get totalTax =>
      items.fold<double>(0, (sum, item) => sum + item.lineTax);

  double get rawGrandTotal =>
      items.fold<double>(0, (sum, item) => sum + item.amount);

  double get roundOffAmount {
    if (!roundOff) return 0;
    return rawGrandTotal.roundToDouble() - rawGrandTotal;
  }

  double get grandTotal {
    final total = rawGrandTotal;
    return roundOff ? total.roundToDouble() : total;
  }

  /// 1 loyalty point = ₹1 (placeholder until loyalty module exists).
  double get loyaltyPointsValue =>
      loyaltyPointsEnabled ? loyaltyPointsUsed : 0;

  double get remainingAmount =>
      (grandTotal - loyaltyPointsValue).clamp(0, double.infinity);

  double get balanceAmount {
    if (saleType == SaleType.cash) {
      return (grandTotal - paymentAmount).clamp(0, double.infinity);
    }
    final received = receivedEnabled ? receivedAmount : 0;
    return (remainingAmount - received).clamp(0, double.infinity);
  }

  double get displayReceivedAmount {
    if (saleType == SaleType.cash) return paymentAmount;
    return receivedEnabled ? receivedAmount : 0;
  }

  int get pointsAwarded => grandTotal.floor();

  bool get billingNameHasError => false;

  bool get hasValidLineItems => items.any(
    (item) => item.itemName.trim().isNotEmpty && item.qty > 0,
  );

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  AddSaleFormState copyWith({
    String? billingName,
    String? phone,
    String? billingAddress,
    String? shippingAddress,
    String? invoiceNumber,
    InvoiceNumberMode? invoiceNumberMode,
    DateTime? invoiceDate,
    DateTime? dueDate,
    TimeOfDay? invoiceTime,
    String? stateOfSupply,
    String? eWayBillNo,
    String? godown,
    List<SaleLineItem>? items,
    List<SalePaymentEntry>? payments,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    double? loyaltyPointsUsed,
    bool? loyaltyPointsEnabled,
    double? receivedAmount,
    bool? receivedEnabled,
    SaleType? saleType,
    bool? showValidationErrors,
    bool? isDirty,
  }) {
    return AddSaleFormState(
      billingName: billingName ?? this.billingName,
      phone: phone ?? this.phone,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceNumberMode: invoiceNumberMode ?? this.invoiceNumberMode,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      eWayBillNo: eWayBillNo ?? this.eWayBillNo,
      godown: godown ?? this.godown,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      roundOff: roundOff ?? this.roundOff,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      loyaltyPointsEnabled: loyaltyPointsEnabled ?? this.loyaltyPointsEnabled,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      receivedEnabled: receivedEnabled ?? this.receivedEnabled,
      saleType: saleType ?? this.saleType,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

const saleLineItemUnits = ['NONE', 'PCS', 'KG', 'GM', 'LTR', 'MTR', 'BOX'];

const saleTaxSlabs = <String, double>{
  'NONE': 0,
  '5%': 5,
  '12%': 12,
  '18%': 18,
  '28%': 28,
};

const salePaymentTypes = ['Cash', 'Credit', 'UPI', 'Cheque'];

const saleBillingParties = [
  'Sharma Traders',
  'Patel Electronics',
  'Gupta General Store',
  'Mehta Hardware',
  'Singh & Sons',
  'Kumar Agencies',
  'Reddy Mart',
  'Joshi Distributors',
  'Verma Enterprises',
  'Agarwal Textiles',
];

const saleIndianStates = [
  'Delhi',
  'Maharashtra',
  'Karnataka',
  'Tamil Nadu',
  'Uttar Pradesh',
  'Gujarat',
  'Rajasthan',
  'West Bengal',
  'Madhya Pradesh',
  'Andhra Pradesh',
  'Telangana',
  'Kerala',
  'Punjab',
  'Haryana',
];

const saleGodowns = ['Main Location', 'Warehouse B'];

String taxLabelForPercent(double percent) {
  if (percent == 0) return 'NONE';
  for (final entry in saleTaxSlabs.entries) {
    if (entry.value == percent) return entry.key;
  }
  return 'NONE';
}

String generateNextInvoiceNumber(List<String> invoiceNumbers) {
  var maxNumber = 1000;
  for (final invoiceNo in invoiceNumbers) {
    final match = RegExp(r'SI-(\d+)').firstMatch(invoiceNo);
    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '') ?? 0;
      if (number > maxNumber) maxNumber = number;
    }
  }
  return 'SI-${maxNumber + 1}';
}
