import 'package:billing_baba/features/inventory/utils/gst_tax_slabs.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:flutter/material.dart';

enum SaleType { cash, credit }

enum InvoiceNumberMode { auto, manual }

class SaleLineItem {
  const SaleLineItem({
    required this.id,
    this.serverLineId,
    this.itemId,
    this.itemName = '',
    this.serialNo = '',
    this.description = '',
    this.batchNo = '',
    this.modelNo = '',
    this.expDate,
    this.mfgDate,
    this.mrp = 0,
    this.size = '',
    this.qty = 0,
    this.freeQty = 0,
    this.packetCount = 0,
    this.unit = 'NONE',
    this.pricePerUnit = 0,
    this.priceIsTaxInclusive = false,
    this.discountPercent = 0,
    this.taxPercent = 0,
    this.isConfirmed = false,
    this.priceManuallyOverridden = false,
    this.catalogUnitPrice = 0,
    this.unitCost = 0,
  });

  factory SaleLineItem.empty({required String id}) => SaleLineItem(id: id);

  final String id;
  final String? serverLineId;
  final String? itemId;
  final String itemName;
  final String serialNo;
  final String description;
  final String batchNo;
  final String modelNo;
  final DateTime? expDate;
  final DateTime? mfgDate;
  final double mrp;
  final String size;
  final double qty;
  final double freeQty;
  final double packetCount;
  final String unit;
  final double pricePerUnit;
  final bool priceIsTaxInclusive;
  final double discountPercent;
  final double taxPercent;
  final bool isConfirmed;
  final bool priceManuallyOverridden;
  final double catalogUnitPrice;
  final double unitCost;

  double get _discountedUnitPrice => pricePerUnit * (1 - discountPercent / 100);

  double get lineCost => unitCost > 0 ? unitCost * qty : 0;

  double get lineProfit => amount - lineCost;

  /// Additional line revenue from a manual price increase above catalog price.
  double get markupAmount {
    if (!priceManuallyOverridden || catalogUnitPrice <= 0) return 0;
    if (pricePerUnit <= catalogUnitPrice) return 0;
    final baseline = copyWith(
      pricePerUnit: catalogUnitPrice,
      priceManuallyOverridden: false,
    );
    return (amount - baseline.amount).clamp(0, double.infinity);
  }

  double get lineSubtotal {
    final base = qty * _discountedUnitPrice;
    if (priceIsTaxInclusive && taxPercent > 0) {
      return base / (1 + taxPercent / 100);
    }
    return base;
  }

  double get lineTax {
    if (priceIsTaxInclusive) {
      return lineSubtotal * (taxPercent / 100);
    }
    return qty * _discountedUnitPrice * (taxPercent / 100);
  }

  double get amount => lineSubtotal + lineTax;

  SaleLineItem copyWith({
    String? id,
    String? serverLineId,
    String? itemId,
    String? itemName,
    String? serialNo,
    String? description,
    String? batchNo,
    String? modelNo,
    DateTime? expDate,
    DateTime? mfgDate,
    double? mrp,
    String? size,
    double? qty,
    double? freeQty,
    double? packetCount,
    String? unit,
    double? pricePerUnit,
    bool? priceIsTaxInclusive,
    double? discountPercent,
    double? taxPercent,
    bool? isConfirmed,
    bool? priceManuallyOverridden,
    double? catalogUnitPrice,
    double? unitCost,
    bool clearExpDate = false,
    bool clearMfgDate = false,
  }) {
    return SaleLineItem(
      id: id ?? this.id,
      serverLineId: serverLineId ?? this.serverLineId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      serialNo: serialNo ?? this.serialNo,
      description: description ?? this.description,
      batchNo: batchNo ?? this.batchNo,
      modelNo: modelNo ?? this.modelNo,
      expDate: clearExpDate ? null : (expDate ?? this.expDate),
      mfgDate: clearMfgDate ? null : (mfgDate ?? this.mfgDate),
      mrp: mrp ?? this.mrp,
      size: size ?? this.size,
      qty: qty ?? this.qty,
      freeQty: freeQty ?? this.freeQty,
      packetCount: packetCount ?? this.packetCount,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      priceIsTaxInclusive: priceIsTaxInclusive ?? this.priceIsTaxInclusive,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      priceManuallyOverridden:
          priceManuallyOverridden ?? this.priceManuallyOverridden,
      catalogUnitPrice: catalogUnitPrice ?? this.catalogUnitPrice,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}

class SalePaymentEntry {
  const SalePaymentEntry({
    required this.type,
    this.amount = 0,
    this.bankAccountId,
  });

  final String type;
  final double amount;
  final String? bankAccountId;

  SalePaymentEntry copyWith({
    String? type,
    double? amount,
    String? bankAccountId,
    bool clearBankAccountId = false,
  }) {
    return SalePaymentEntry(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      bankAccountId:
          clearBankAccountId ? null : (bankAccountId ?? this.bankAccountId),
    );
  }
}

class AddSaleFormState {
  const AddSaleFormState({
    this.documentId,
    this.partyId,
    this.billingName = '',
    this.phone = '',
    this.billingAddress = '',
    this.shippingAddress = '',
    this.gstin = '',
    this.email = '',
    this.businessName = '',
    this.creditLimit = '',
    this.outstanding = '',
    this.invoiceNumber = '',
    this.invoiceNumberMode = InvoiceNumberMode.auto,
    this.invoiceDate,
    this.dueDate,
    this.invoiceTime,
    this.stateOfSupply = 'Madhya Pradesh',
    this.eWayBillNo = '',
    this.customerPoNumber = '',
    this.customerPoDate,
    this.paymentTerms = 'Due on Receipt',
    this.termsTitle = 'Sale Invoice',
    this.termsText = 'Thanks for doing business with us!',
    this.godown = 'Main Location',
    this.godownId,
    this.items = const [],
    this.payments = const [SalePaymentEntry(type: 'Cash')],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.roundOff = true,
    this.loyaltyPointsAvailable = 0,
    this.loyaltyPointsUsed = 0,
    this.loyaltyPointsEnabled = false,
    this.receivedAmount = 0,
    this.receivedEnabled = false,
    this.saleType = SaleType.cash,
    this.showValidationErrors = false,
    this.isDirty = false,
    this.isLoading = false,
    this.saveError,
    this.isSaving = false,
    this.attachedSaleOrderIds = const [],
    this.partyPriceTier,
    this.taxOption = 'NONE',
    this.transactionDiscountPercent = 0,
    this.hiddenLedgerBalance = 0,
    this.repeatInvoiceEnabled = false,
    this.repeatInvoiceFrequency = 'Monthly',
    this.useWholesalePriceOnInvoice = false,
  });

  final String? documentId;
  final String? partyId;
  final String billingName;
  final String phone;
  final String billingAddress;
  final String shippingAddress;
  final String gstin;
  final String email;
  final String businessName;
  final String creditLimit;
  final String outstanding;
  final String invoiceNumber;
  final InvoiceNumberMode invoiceNumberMode;
  final DateTime? invoiceDate;
  final DateTime? dueDate;
  final TimeOfDay? invoiceTime;
  final String stateOfSupply;
  final String eWayBillNo;
  final String customerPoNumber;
  final DateTime? customerPoDate;
  final String paymentTerms;
  final String termsTitle;
  final String termsText;
  final String godown;
  final String? godownId;
  final List<SaleLineItem> items;
  final List<SalePaymentEntry> payments;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final double loyaltyPointsAvailable;
  final double loyaltyPointsUsed;
  final bool loyaltyPointsEnabled;
  final double receivedAmount;
  final bool receivedEnabled;
  final SaleType saleType;
  final bool showValidationErrors;
  final bool isDirty;
  final bool isLoading;
  final String? saveError;
  final bool isSaving;
  final List<String> attachedSaleOrderIds;
  final String? partyPriceTier;
  final String taxOption;
  final double transactionDiscountPercent;
  final double hiddenLedgerBalance;
  final bool repeatInvoiceEnabled;
  final String repeatInvoiceFrequency;
  final bool useWholesalePriceOnInvoice;

  double get estimatedCostTotal =>
      items.fold<double>(0, (sum, line) => sum + line.lineCost);

  double get estimatedProfitTotal => rawGrandTotal - estimatedCostTotal;

  String get paymentType => payments.isNotEmpty ? payments.first.type : 'Cash';

  double get paymentAmount => payments.isNotEmpty ? payments.first.amount : 0;

  double get totalPaymentsAmount =>
      payments.fold<double>(0, (sum, payment) => sum + payment.amount);

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineSubtotal);

  double get totalTax => resolveSaleTotalTax(
    taxOption: taxOption,
    subtotal: subtotal,
    items: items,
  );

  double get rawGrandTotal => resolveSaleRawGrandTotal(
    taxOption: taxOption,
    subtotal: subtotal,
    items: items,
  );

  double get roundOffAmount {
    if (!roundOff) return 0;
    return rawGrandTotal.roundToDouble() - rawGrandTotal;
  }

  double get grandTotal {
    final total = rawGrandTotal;
    return roundOff ? total.roundToDouble() : total;
  }

  /// 1 loyalty point = ₹1 (placeholder until loyalty module exists).
  double get maxRedeemablePoints {
    if (loyaltyPointsAvailable <= 0 || grandTotal <= 0) return 0;
    return loyaltyPointsAvailable < grandTotal
        ? loyaltyPointsAvailable
        : grandTotal;
  }

  double get loyaltyDiscount =>
      loyaltyPointsUsed.clamp(0, maxRedeemablePoints).toDouble();

  double get loyaltyPointsValue => loyaltyDiscount;

  double get invoiceTotal =>
      (grandTotal - loyaltyDiscount).clamp(0, double.infinity);

  double get remainingAmount => invoiceTotal;

  double get balanceAmount {
    if (saleType == SaleType.cash) {
      return (invoiceTotal - totalPaymentsAmount).clamp(0, double.infinity);
    }
    final received = receivedEnabled ? receivedAmount : 0;
    return (invoiceTotal - received).clamp(0, double.infinity);
  }

  bool get hasShortPayment {
    if (invoiceTotal <= 0) return false;
    final paid = displayReceivedAmount;
    if (saleType == SaleType.cash) {
      return paid > 0 && paid < invoiceTotal;
    }
    return receivedEnabled && paid > 0 && paid < invoiceTotal;
  }

  double get markupAmount =>
      items.fold<double>(0, (sum, item) => sum + item.markupAmount);

  bool get hasRecoverableMarkup => hiddenLedgerBalance > 0 && markupAmount > 0;

  double get maxRecoverableAmount {
    if (!hasRecoverableMarkup) return 0;
    return hiddenLedgerBalance < markupAmount
        ? hiddenLedgerBalance
        : markupAmount;
  }

  bool get showLoyaltySection =>
      partyId != null && partyId!.isNotEmpty && loyaltyPointsAvailable > 0;

  double get displayReceivedAmount {
    if (saleType == SaleType.cash) return totalPaymentsAmount;
    return receivedEnabled ? receivedAmount : 0;
  }

  int get pointsAwarded => grandTotal.floor();

  bool get billingNameHasError => false;

  bool get hasValidLineItems => items.any(
    (item) => item.itemName.trim().isNotEmpty && item.qty > 0,
  );

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get partyRequired =>
      saleType == SaleType.credit || billingName.trim().isNotEmpty;

  bool get partyHasError =>
      showValidationErrors &&
      partyRequired &&
      (partyId == null || partyId!.isEmpty);

  bool get phoneHasError =>
      showValidationErrors && Validators.requiredPhone(phone) != null;

  String? get phoneErrorMessage => Validators.requiredPhone(phone);

  bool get hasValidPhone => Validators.requiredPhone(phone) == null;

  AddSaleFormState copyWith({
    String? documentId,
    String? partyId,
    String? billingName,
    String? phone,
    String? billingAddress,
    String? shippingAddress,
    String? gstin,
    String? email,
    String? businessName,
    String? creditLimit,
    String? outstanding,
    String? invoiceNumber,
    InvoiceNumberMode? invoiceNumberMode,
    DateTime? invoiceDate,
    DateTime? dueDate,
    TimeOfDay? invoiceTime,
    String? stateOfSupply,
    String? eWayBillNo,
    String? customerPoNumber,
    DateTime? customerPoDate,
    bool clearCustomerPoDate = false,
    String? paymentTerms,
    String? termsTitle,
    String? termsText,
    String? godown,
    String? godownId,
    List<SaleLineItem>? items,
    List<SalePaymentEntry>? payments,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    double? loyaltyPointsAvailable,
    double? loyaltyPointsUsed,
    bool? loyaltyPointsEnabled,
    double? receivedAmount,
    bool? receivedEnabled,
    SaleType? saleType,
    bool? showValidationErrors,
    bool? isDirty,
    bool? isLoading,
    String? saveError,
    bool clearSaveError = false,
    bool clearDocumentId = false,
    bool? isSaving,
    List<String>? attachedSaleOrderIds,
    bool clearAttachedSaleOrderIds = false,
    String? partyPriceTier,
    bool clearPartyPriceTier = false,
    bool clearPartyId = false,
    String? taxOption,
    double? transactionDiscountPercent,
    double? hiddenLedgerBalance,
    bool clearHiddenLedgerBalance = false,
    bool? repeatInvoiceEnabled,
    String? repeatInvoiceFrequency,
    bool? useWholesalePriceOnInvoice,
  }) {
    return AddSaleFormState(
      documentId: clearDocumentId ? null : (documentId ?? this.documentId),
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      billingName: billingName ?? this.billingName,
      phone: phone ?? this.phone,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      gstin: gstin ?? this.gstin,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      creditLimit: creditLimit ?? this.creditLimit,
      outstanding: outstanding ?? this.outstanding,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceNumberMode: invoiceNumberMode ?? this.invoiceNumberMode,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      eWayBillNo: eWayBillNo ?? this.eWayBillNo,
      customerPoNumber: customerPoNumber ?? this.customerPoNumber,
      customerPoDate:
          clearCustomerPoDate ? null : (customerPoDate ?? this.customerPoDate),
      paymentTerms: paymentTerms ?? this.paymentTerms,
      termsTitle: termsTitle ?? this.termsTitle,
      termsText: termsText ?? this.termsText,
      godown: godown ?? this.godown,
      godownId: godownId ?? this.godownId,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      roundOff: roundOff ?? this.roundOff,
      loyaltyPointsAvailable:
          loyaltyPointsAvailable ?? this.loyaltyPointsAvailable,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      loyaltyPointsEnabled: loyaltyPointsEnabled ?? this.loyaltyPointsEnabled,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      receivedEnabled: receivedEnabled ?? this.receivedEnabled,
      saleType: saleType ?? this.saleType,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isDirty: isDirty ?? this.isDirty,
      isLoading: isLoading ?? this.isLoading,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      isSaving: isSaving ?? this.isSaving,
      attachedSaleOrderIds: clearAttachedSaleOrderIds
          ? const []
          : (attachedSaleOrderIds ?? this.attachedSaleOrderIds),
      partyPriceTier: clearPartyPriceTier
          ? null
          : (partyPriceTier ?? this.partyPriceTier),
      taxOption: taxOption ?? this.taxOption,
      transactionDiscountPercent:
          transactionDiscountPercent ?? this.transactionDiscountPercent,
      hiddenLedgerBalance: clearHiddenLedgerBalance
          ? 0
          : (hiddenLedgerBalance ?? this.hiddenLedgerBalance),
      repeatInvoiceEnabled:
          repeatInvoiceEnabled ?? this.repeatInvoiceEnabled,
      repeatInvoiceFrequency:
          repeatInvoiceFrequency ?? this.repeatInvoiceFrequency,
      useWholesalePriceOnInvoice:
          useWholesalePriceOnInvoice ?? this.useWholesalePriceOnInvoice,
    );
  }
}

const saleLineItemUnits = ['NONE', 'PCS', 'KG', 'GM', 'LTR', 'MTR', 'BOX'];

Map<String, double> get saleTaxSlabs => GstTaxSlabs.saleDropdownToPercent();

const salePaymentTypes = ['Cash', 'Credit', 'UPI', 'Cheque'];

const salePriceTaxModes = ['Without Tax', 'With Tax'];

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
  if (GstTaxSlabs.samePercent(percent, 0)) return 'NONE';
  for (final entry in saleTaxSlabs.entries) {
    if (entry.key == 'NONE') continue;
    if (GstTaxSlabs.samePercent(entry.value, percent)) return entry.key;
  }
  final slab = GstTaxSlabs.definitionForPercent(percent);
  if (slab != null) return slab.saleDropdownLabel;
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
