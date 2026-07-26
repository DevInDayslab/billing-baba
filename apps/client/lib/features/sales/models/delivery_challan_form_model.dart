import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:flutter/material.dart';

class DeliveryChallanFormState {
  const DeliveryChallanFormState({
    this.isFormOpen = false,
    this.documentId,
    this.partyId,
    this.party = '',
    this.billingAddress = '',
    this.shippingAddress = '',
    this.godown = 'Main Godown',
    this.godownId,
    this.challanNo = '1',
    this.invoiceDate,
    this.invoiceTime,
    this.dueDate,
    this.stateOfSupply = '',
    this.items = const [],
    this.termsTitle = 'Delivery Challan',
    this.termsText = 'Thanks for doing business with us!',
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.taxOption = 'NONE',
    this.roundOff = false,
    this.showValidationErrors = false,
    this.isLoading = false,
    this.isSaving = false,
    this.saveError,
  });

  final bool isFormOpen;
  final String? documentId;
  final String? partyId;
  final String party;
  final String billingAddress;
  final String shippingAddress;
  final String godown;
  final String? godownId;
  final String challanNo;
  final DateTime? invoiceDate;
  final TimeOfDay? invoiceTime;
  final DateTime? dueDate;
  final String stateOfSupply;
  final List<SaleLineItem> items;
  final String termsTitle;
  final String termsText;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final String taxOption;
  final bool roundOff;
  final bool showValidationErrors;
  final bool isLoading;
  final bool isSaving;
  final String? saveError;

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineSubtotal);

  double get taxAmount => resolveSaleTotalTax(
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

  double get total {
    final grand = rawGrandTotal;
    return roundOff ? grand.roundToDouble() : grand;
  }

  bool get partyHasError =>
      transactionPartyHasError(
        showValidationErrors: showValidationErrors,
        partyId: partyId,
        partyName: party,
      );

  bool get hasValidLineItems => hasValidNamedLineItems<SaleLineItem>(
    items: items,
    nameOf: (item) => item.itemName,
    qtyOf: (item) => item.qty,
  );

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get isValid =>
      party.trim().isNotEmpty &&
      partyId != null &&
      partyId!.isNotEmpty &&
      hasValidLineItems;

  DeliveryChallanFormState copyWith({
    bool? isFormOpen,
    String? documentId,
    String? partyId,
    String? party,
    String? billingAddress,
    String? shippingAddress,
    String? godown,
    String? godownId,
    String? challanNo,
    DateTime? invoiceDate,
    TimeOfDay? invoiceTime,
    DateTime? dueDate,
    String? stateOfSupply,
    List<SaleLineItem>? items,
    String? termsTitle,
    String? termsText,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    String? taxOption,
    bool? roundOff,
    bool? showValidationErrors,
    bool? isLoading,
    bool? isSaving,
    String? saveError,
    bool clearDocumentId = false,
    bool clearSaveError = false,
    bool clearPartyId = false,
  }) {
    return DeliveryChallanFormState(
      isFormOpen: isFormOpen ?? this.isFormOpen,
      documentId: clearDocumentId ? null : (documentId ?? this.documentId),
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      party: party ?? this.party,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      godown: godown ?? this.godown,
      godownId: godownId ?? this.godownId,
      challanNo: challanNo ?? this.challanNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      dueDate: dueDate ?? this.dueDate,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      items: items ?? this.items,
      termsTitle: termsTitle ?? this.termsTitle,
      termsText: termsText ?? this.termsText,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      taxOption: taxOption ?? this.taxOption,
      roundOff: roundOff ?? this.roundOff,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}
