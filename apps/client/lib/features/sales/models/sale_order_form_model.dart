import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:flutter/material.dart';

class SaleOrderFormState {
  const SaleOrderFormState({
    this.isFormOpen = false,
    this.documentId,
    this.partyId,
    this.party = '',
    this.orderNo = '',
    this.orderDate,
    this.orderTime,
    this.dueDate,
    this.stateOfSupply = '',
    this.items = const [],
    this.paymentType = 'Cash',
    this.advanceAmount = 0,
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.termsTitle = 'Sale Order',
    this.termsText = 'Thanks for doing business with us!',
    this.roundOff = true,
    this.showValidationErrors = false,
    this.isSaving = false,
    this.isLoading = false,
    this.godown = 'Main Location',
    this.phoneNo = '',
    this.saveError,
    this.taxOption = 'NONE',
  });

  final bool isFormOpen;
  final String? documentId;
  final String? partyId;
  final String party;
  final String orderNo;
  final DateTime? orderDate;
  final TimeOfDay? orderTime;
  final DateTime? dueDate;
  final String stateOfSupply;
  final List<SaleLineItem> items;
  final String paymentType;
  final double advanceAmount;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final String termsTitle;
  final String termsText;
  final bool roundOff;
  final bool showValidationErrors;
  final bool isSaving;
  final bool isLoading;
  final String godown;
  final String phoneNo;
  final String? saveError;
  final String taxOption;

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

  double get balanceAmount => (total - advanceAmount).clamp(0, double.infinity);

  bool get partyHasError => transactionPartyHasError(
    showValidationErrors: showValidationErrors,
    partyId: partyId,
    partyName: party,
  );

  bool get phoneHasError => transactionPhoneHasError(
    showValidationErrors: showValidationErrors,
    phone: phoneNo,
  );

  String? get phoneErrorMessage => phoneValidationMessage(phoneNo);

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
      hasValidLineItems &&
      Validators.requiredPhone(phoneNo) == null;

  SaleOrderFormState copyWith({
    bool? isFormOpen,
    String? documentId,
    String? partyId,
    String? party,
    String? orderNo,
    DateTime? orderDate,
    TimeOfDay? orderTime,
    DateTime? dueDate,
    String? stateOfSupply,
    List<SaleLineItem>? items,
    String? paymentType,
    double? advanceAmount,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    String? termsTitle,
    String? termsText,
    bool? roundOff,
    bool? showValidationErrors,
    bool? isSaving,
    bool? isLoading,
    String? godown,
    String? phoneNo,
    String? saveError,
    bool clearSaveError = false,
    bool clearPartyId = false,
    String? taxOption,
  }) {
    return SaleOrderFormState(
      isFormOpen: isFormOpen ?? this.isFormOpen,
      documentId: documentId ?? this.documentId,
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      party: party ?? this.party,
      orderNo: orderNo ?? this.orderNo,
      orderDate: orderDate ?? this.orderDate,
      orderTime: orderTime ?? this.orderTime,
      dueDate: dueDate ?? this.dueDate,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      items: items ?? this.items,
      paymentType: paymentType ?? this.paymentType,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      termsTitle: termsTitle ?? this.termsTitle,
      termsText: termsText ?? this.termsText,
      roundOff: roundOff ?? this.roundOff,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      godown: godown ?? this.godown,
      phoneNo: phoneNo ?? this.phoneNo,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      taxOption: taxOption ?? this.taxOption,
    );
  }
}
