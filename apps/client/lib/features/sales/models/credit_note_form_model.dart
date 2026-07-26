import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:flutter/material.dart';

class CreditNoteFormState {
  const CreditNoteFormState({
    this.documentId,
    this.partyId,
    this.party = '',
    this.phone = '',
    this.returnNo = '1',
    this.originalInvoiceNo = '',
    this.originalInvoiceDate,
    this.returnDate,
    this.returnTime,
    this.stateOfSupply = '',
    this.godown = 'Main Godown',
    this.godownId,
    this.items = const [],
    this.payments = const [SalePaymentEntry(type: 'Cash')],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.roundOff = false,
    this.showValidationErrors = false,
    this.isDirty = false,
    this.isSaving = false,
    this.saveError,
    this.taxOption = 'NONE',
  });

  final String? documentId;
  final String? partyId;
  final String party;
  final String phone;
  final String returnNo;
  final String originalInvoiceNo;
  final DateTime? originalInvoiceDate;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;
  final String stateOfSupply;
  final String godown;
  final String? godownId;
  final List<SaleLineItem> items;
  final List<SalePaymentEntry> payments;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final bool showValidationErrors;
  final bool isDirty;
  final bool isSaving;
  final String? saveError;
  final String taxOption;

  String get paymentType => payments.isNotEmpty ? payments.first.type : 'Cash';

  double get paymentAmount => payments.isNotEmpty ? payments.first.amount : 0;

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

  CreditNoteFormState copyWith({
    String? documentId,
    String? partyId,
    String? party,
    String? phone,
    String? returnNo,
    String? originalInvoiceNo,
    DateTime? originalInvoiceDate,
    DateTime? returnDate,
    TimeOfDay? returnTime,
    String? stateOfSupply,
    String? godown,
    String? godownId,
    List<SaleLineItem>? items,
    List<SalePaymentEntry>? payments,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    bool? showValidationErrors,
    bool? isDirty,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
    bool clearPartyId = false,
    String? taxOption,
  }) {
    return CreditNoteFormState(
      documentId: documentId ?? this.documentId,
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      party: party ?? this.party,
      phone: phone ?? this.phone,
      returnNo: returnNo ?? this.returnNo,
      originalInvoiceNo: originalInvoiceNo ?? this.originalInvoiceNo,
      originalInvoiceDate: originalInvoiceDate ?? this.originalInvoiceDate,
      returnDate: returnDate ?? this.returnDate,
      returnTime: returnTime ?? this.returnTime,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      godown: godown ?? this.godown,
      godownId: godownId ?? this.godownId,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      roundOff: roundOff ?? this.roundOff,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      taxOption: taxOption ?? this.taxOption,
    );
  }
}
