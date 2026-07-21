import 'package:billing_baba/core/forms/transaction_form_validation.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart' as api;
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:flutter/material.dart';

/// Document types that share the estimate/proforma form layout.
enum SaleDocumentType {
  estimate,
  proforma;

  String get saveSuccessMessage => switch (this) {
    SaleDocumentType.estimate => 'Estimate saved',
    SaleDocumentType.proforma => 'Proforma invoice saved',
  };

  api.SalesDocumentType get backendType => api.SalesDocumentType.estimate;

  String get documentSeries => switch (this) {
    SaleDocumentType.estimate => api.SalesConstants.estimateSeries,
    SaleDocumentType.proforma => api.SalesConstants.proformaSeries,
  };

  String get defaultTermsTitle => switch (this) {
    SaleDocumentType.estimate => 'Estimate Quotation',
    SaleDocumentType.proforma => 'Proforma Invoice',
  };
}

/// Form state for Estimate/Quotation and Proforma Invoice pages.
class SaleDocumentFormState {
  const SaleDocumentFormState({
    this.isFormOpen = false,
    this.documentId,
    this.partyId,
    this.party = '',
    this.refNo = '',
    this.invoiceDate,
    this.invoiceTime,
    this.stateOfSupply = '',
    this.godown = 'Main Location',
    this.godownId,
    this.items = const [],
    this.termsTitle = 'Estimate Quotation',
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
  final String refNo;
  final DateTime? invoiceDate;
  final TimeOfDay? invoiceTime;
  final String stateOfSupply;
  final String godown;
  final String? godownId;
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

  SaleDocumentFormState copyWith({
    bool? isFormOpen,
    String? documentId,
    bool clearDocumentId = false,
    String? partyId,
    String? party,
    String? refNo,
    DateTime? invoiceDate,
    TimeOfDay? invoiceTime,
    String? stateOfSupply,
    String? godown,
    String? godownId,
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
    bool clearSaveError = false,
    bool clearPartyId = false,
  }) {
    return SaleDocumentFormState(
      isFormOpen: isFormOpen ?? this.isFormOpen,
      documentId: clearDocumentId ? null : (documentId ?? this.documentId),
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      party: party ?? this.party,
      refNo: refNo ?? this.refNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      godown: godown ?? this.godown,
      godownId: godownId ?? this.godownId,
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

/// Snapshot of a saved estimate or proforma invoice held in memory.
class SavedSaleDocument {
  const SavedSaleDocument({
    required this.id,
    required this.documentType,
    required this.party,
    required this.refNo,
    required this.invoiceDate,
    required this.invoiceTime,
    required this.stateOfSupply,
    required this.godown,
    required this.items,
    required this.description,
    required this.attachedImages,
    required this.attachedDocuments,
    required this.taxOption,
    required this.roundOff,
    required this.total,
    required this.savedAt,
  });

  factory SavedSaleDocument.fromFormState({
    required String id,
    required SaleDocumentType documentType,
    required SaleDocumentFormState form,
    required double total,
  }) {
    return SavedSaleDocument(
      id: id,
      documentType: documentType,
      party: form.party,
      refNo: form.refNo,
      invoiceDate: form.invoiceDate,
      invoiceTime: form.invoiceTime,
      stateOfSupply: form.stateOfSupply,
      godown: form.godown,
      items: List<SaleLineItem>.from(form.items),
      description: form.description,
      attachedImages: List<SaleFormAttachment>.from(form.attachedImages),
      attachedDocuments: List<SaleFormAttachment>.from(form.attachedDocuments),
      taxOption: form.taxOption,
      roundOff: form.roundOff,
      total: total,
      savedAt: DateTime.now(),
    );
  }

  final String id;
  final SaleDocumentType documentType;
  final String party;
  final String refNo;
  final DateTime? invoiceDate;
  final TimeOfDay? invoiceTime;
  final String stateOfSupply;
  final String godown;
  final List<SaleLineItem> items;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final String taxOption;
  final bool roundOff;
  final double total;
  final DateTime savedAt;
}

const saleDocumentGodowns = ['Main Godown', 'Warehouse B'];
