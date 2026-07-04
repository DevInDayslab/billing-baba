import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';

class PurchaseLineItem {
  const PurchaseLineItem({
    required this.id,
    this.serverLineId,
    this.itemId,
    this.itemName = '',
    this.description = '',
    this.qty = 0,
    this.unit = 'NONE',
    this.pricePerUnit = 0,
    this.priceIsTaxInclusive = false,
    this.taxPercent = 0,
  });

  factory PurchaseLineItem.empty({required String id}) =>
      PurchaseLineItem(id: id);

  final String id;
  final String? serverLineId;
  final String? itemId;
  final String itemName;
  final String description;
  final double qty;
  final String unit;
  final double pricePerUnit;
  final bool priceIsTaxInclusive;
  final double taxPercent;

  double get lineSubtotal {
    if (priceIsTaxInclusive && taxPercent > 0) {
      return qty * pricePerUnit / (1 + taxPercent / 100);
    }
    return qty * pricePerUnit;
  }

  double get lineTax =>
      priceIsTaxInclusive ? lineSubtotal * (taxPercent / 100) : 0;

  double get amount => lineSubtotal + lineTax;

  PurchaseLineItem copyWith({
    String? id,
    String? serverLineId,
    String? itemId,
    String? itemName,
    String? description,
    double? qty,
    String? unit,
    double? pricePerUnit,
    bool? priceIsTaxInclusive,
    double? taxPercent,
  }) {
    return PurchaseLineItem(
      id: id ?? this.id,
      serverLineId: serverLineId ?? this.serverLineId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      priceIsTaxInclusive: priceIsTaxInclusive ?? this.priceIsTaxInclusive,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }
}

class AddPurchaseFormState {
  const AddPurchaseFormState({
    this.documentId,
    this.partyId,
    this.godownId,
    this.party = '',
    this.billingName = '',
    this.eWayBillNo = '',
    this.billNumber = '',
    this.billDate,
    this.billTime,
    this.paymentTerms = 'Due on Receipt',
    this.dueDate,
    this.stateOfSupply = 'Madhya Pradesh',
    this.godown = 'Main Location',
    this.termsTitle = 'Purchase Bill',
    this.termsNotes = 'Thanks for doing business with us!',
    this.items = const [],
    this.payments = const [SalePaymentEntry(type: 'Cash')],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.roundOff = true,
    this.showValidationErrors = false,
    this.isDirty = false,
    this.isLoading = false,
    this.isSaving = false,
    this.saveError,
  });

  final String? documentId;
  final String? partyId;
  final String? godownId;
  final String party;
  final String billingName;
  final String eWayBillNo;
  final String billNumber;
  final DateTime? billDate;
  final TimeOfDay? billTime;
  final String paymentTerms;
  final DateTime? dueDate;
  final String stateOfSupply;
  final String godown;
  final String termsTitle;
  final String termsNotes;
  final List<PurchaseLineItem> items;
  final List<SalePaymentEntry> payments;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final bool showValidationErrors;
  final bool isDirty;
  final bool isLoading;
  final bool isSaving;
  final String? saveError;

  String get paymentType => payments.isNotEmpty ? payments.first.type : 'Cash';

  double get paymentAmount => payments.isNotEmpty ? payments.first.amount : 0;

  double get totalQty => items.fold<double>(0, (sum, item) => sum + item.qty);

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

  double get balanceAmount =>
      (grandTotal - paymentAmount).clamp(0, double.infinity);

  bool get partyHasError =>
      showValidationErrors &&
      (partyId == null || partyId!.isEmpty) &&
      party.trim().isEmpty;

  bool get hasValidLineItems => items.any(
    (item) => item.itemName.trim().isNotEmpty && item.qty > 0,
  );

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get isValid =>
      ((partyId != null && partyId!.isNotEmpty) || party.trim().isNotEmpty) &&
      hasValidLineItems;

  AddPurchaseFormState copyWith({
    String? documentId,
    String? partyId,
    String? godownId,
    String? party,
    String? billingName,
    String? eWayBillNo,
    String? billNumber,
    DateTime? billDate,
    TimeOfDay? billTime,
    String? paymentTerms,
    DateTime? dueDate,
    String? stateOfSupply,
    String? godown,
    String? termsTitle,
    String? termsNotes,
    List<PurchaseLineItem>? items,
    List<SalePaymentEntry>? payments,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    bool? showValidationErrors,
    bool? isDirty,
    bool? isLoading,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return AddPurchaseFormState(
      documentId: documentId ?? this.documentId,
      partyId: partyId ?? this.partyId,
      godownId: godownId ?? this.godownId,
      party: party ?? this.party,
      billingName: billingName ?? this.billingName,
      eWayBillNo: eWayBillNo ?? this.eWayBillNo,
      billNumber: billNumber ?? this.billNumber,
      billDate: billDate ?? this.billDate,
      billTime: billTime ?? this.billTime,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      dueDate: dueDate ?? this.dueDate,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      godown: godown ?? this.godown,
      termsTitle: termsTitle ?? this.termsTitle,
      termsNotes: termsNotes ?? this.termsNotes,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      roundOff: roundOff ?? this.roundOff,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isDirty: isDirty ?? this.isDirty,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}

const purchasePaymentTerms = [
  'Due on Receipt',
  'Net 15',
  'Net 30',
  'Net 45',
  'Net 60',
];

const purchaseTermsTitles = [
  'Purchase Bill',
  'Purchase Order',
  'Debit Note',
];

const purchasePriceTaxModes = ['Without Tax', 'With Tax'];

String generateNextPurchaseBillNumber(List<String> billNumbers) {
  var maxNumber = 1000;
  for (final billNo in billNumbers) {
    final match = RegExp(r'PB-(\d+)').firstMatch(billNo);
    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '') ?? 0;
      if (number > maxNumber) maxNumber = number;
    }
  }
  return 'PB-${maxNumber + 1}';
}

String taxLabelForPurchasePercent(double percent) {
  if (percent == 0) return 'NONE';
  for (final entry in saleTaxSlabs.entries) {
    if (entry.value == percent) return entry.key;
  }
  return 'NONE';
}
