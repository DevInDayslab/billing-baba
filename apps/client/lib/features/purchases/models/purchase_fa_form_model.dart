import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';

class FixedAssetLineItem {
  const FixedAssetLineItem({
    required this.id,
    this.assetName = '',
    this.description = '',
    this.qty = 0,
    this.pricePerUnit = 0,
    this.priceIsTaxInclusive = false,
    this.taxPercent = 0,
  });

  factory FixedAssetLineItem.empty({required String id}) =>
      FixedAssetLineItem(id: id);

  final String id;
  final String assetName;
  final String description;
  final double qty;
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

  FixedAssetLineItem copyWith({
    String? id,
    String? assetName,
    String? description,
    double? qty,
    double? pricePerUnit,
    bool? priceIsTaxInclusive,
    double? taxPercent,
  }) {
    return FixedAssetLineItem(
      id: id ?? this.id,
      assetName: assetName ?? this.assetName,
      description: description ?? this.description,
      qty: qty ?? this.qty,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      priceIsTaxInclusive: priceIsTaxInclusive ?? this.priceIsTaxInclusive,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }
}

class AddPurchaseFaFormState {
  const AddPurchaseFaFormState({
    this.batchId,
    this.partyId,
    this.party = '',
    this.billingName = '',
    this.eWayBillNo = '',
    this.billNumber = '',
    this.billDate,
    this.billTime,
    this.paymentTerms = 'Due on Receipt',
    this.dueDate,
    this.stateOfSupply = 'Madhya Pradesh',
    this.termsTitle = 'Purchase FA',
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

  final String? batchId;
  final String? partyId;
  final String party;
  final String billingName;
  final String eWayBillNo;
  final String billNumber;
  final DateTime? billDate;
  final TimeOfDay? billTime;
  final String paymentTerms;
  final DateTime? dueDate;
  final String stateOfSupply;
  final String termsTitle;
  final String termsNotes;
  final List<FixedAssetLineItem> items;
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
      showValidationErrors && (partyId == null || partyId!.isEmpty);

  bool get hasValidLineItems => items.any(
    (item) => item.assetName.trim().isNotEmpty && item.qty > 0,
  );

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get isValid =>
      (partyId != null && partyId!.isNotEmpty) && hasValidLineItems;

  AddPurchaseFaFormState copyWith({
    String? batchId,
    String? partyId,
    String? party,
    String? billingName,
    String? eWayBillNo,
    String? billNumber,
    DateTime? billDate,
    TimeOfDay? billTime,
    String? paymentTerms,
    DateTime? dueDate,
    String? stateOfSupply,
    String? termsTitle,
    String? termsNotes,
    List<FixedAssetLineItem>? items,
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
    return AddPurchaseFaFormState(
      batchId: batchId ?? this.batchId,
      partyId: partyId ?? this.partyId,
      party: party ?? this.party,
      billingName: billingName ?? this.billingName,
      eWayBillNo: eWayBillNo ?? this.eWayBillNo,
      billNumber: billNumber ?? this.billNumber,
      billDate: billDate ?? this.billDate,
      billTime: billTime ?? this.billTime,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      dueDate: dueDate ?? this.dueDate,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
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

const purchaseFaTermsTitles = [
  'Purchase FA',
  'Purchase Bill',
  'None',
];

String generateNextPurchaseFaNumber(List<String> billNumbers) {
  var maxNumber = 1000;
  for (final billNo in billNumbers) {
    final match = RegExp(r'PFA-(\d+)').firstMatch(billNo);
    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '') ?? 0;
      if (number > maxNumber) maxNumber = number;
    }
  }
  return 'PFA-${maxNumber + 1}';
}

String taxLabelForPurchaseFaPercent(double percent) =>
    taxLabelForPurchasePercent(percent);
