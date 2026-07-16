import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';

class AddPurchaseOrderFormState {
  const AddPurchaseOrderFormState({
    this.documentId,
    this.partyId,
    this.godownId,
    this.party = '',
    this.billingName = '',
    this.orderNumber = '',
    this.orderDate,
    this.orderTime,
    this.paymentTerms = 'Due on Receipt',
    this.dueDate,
    this.stateOfSupply = 'Madhya Pradesh',
    this.godown = 'Main Location',
    this.termsTitle = 'Purchase Order',
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
  final String orderNumber;
  final DateTime? orderDate;
  final TimeOfDay? orderTime;
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
      showValidationErrors && (partyId == null || partyId!.isEmpty);

  bool get hasValidLineItems => items.any(
    (item) => item.itemName.trim().isNotEmpty && item.qty > 0,
  );

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get isValid =>
      (partyId != null && partyId!.isNotEmpty) && hasValidLineItems;

  AddPurchaseOrderFormState copyWith({
    String? documentId,
    String? partyId,
    String? godownId,
    String? party,
    String? billingName,
    String? orderNumber,
    DateTime? orderDate,
    TimeOfDay? orderTime,
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
    return AddPurchaseOrderFormState(
      documentId: documentId ?? this.documentId,
      partyId: partyId ?? this.partyId,
      godownId: godownId ?? this.godownId,
      party: party ?? this.party,
      billingName: billingName ?? this.billingName,
      orderNumber: orderNumber ?? this.orderNumber,
      orderDate: orderDate ?? this.orderDate,
      orderTime: orderTime ?? this.orderTime,
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

String generateNextPurchaseOrderNumber(List<String> orderNumbers) {
  var maxNumber = 0;
  for (final orderNo in orderNumbers) {
    final numeric = int.tryParse(orderNo);
    if (numeric != null && numeric > maxNumber) maxNumber = numeric;
    final match = RegExp(r'PO-(\d+)').firstMatch(orderNo);
    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '') ?? 0;
      if (number > maxNumber) maxNumber = number;
    }
  }
  return '${maxNumber + 1}';
}
