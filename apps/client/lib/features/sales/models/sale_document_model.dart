import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';

/// Document types that share the estimate/proforma form layout.
enum SaleDocumentType {
  estimate,
  proforma;

  String get saveSuccessMessage => switch (this) {
    SaleDocumentType.estimate => 'Estimate saved',
    SaleDocumentType.proforma => 'Proforma invoice saved',
  };
}

/// Form state for Estimate/Quotation and Proforma Invoice pages.
class SaleDocumentFormState {
  const SaleDocumentFormState({
    this.isFormOpen = false,
    this.party = '',
    this.refNo = '',
    this.invoiceDate,
    this.invoiceTime,
    this.stateOfSupply = '',
    this.godown = 'Main Godown',
    this.items = const [],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.taxOption = 'NONE',
    this.roundOff = false,
    this.showValidationErrors = false,
  });

  final bool isFormOpen;
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
  final bool showValidationErrors;

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineSubtotal);

  double get taxAmount =>
      items.fold<double>(0, (sum, item) => sum + item.lineTax);

  double get rawGrandTotal =>
      items.fold<double>(0, (sum, item) => sum + item.amount);

  double get roundOffAmount {
    if (!roundOff) return 0;
    return rawGrandTotal.roundToDouble() - rawGrandTotal;
  }

  double get total {
    final grand = rawGrandTotal;
    return roundOff ? grand.roundToDouble() : grand;
  }

  bool get partyHasError => showValidationErrors && party.trim().isEmpty;

  bool get hasValidLineItems =>
      items.any((item) => item.itemName.trim().isNotEmpty);

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get isValid => party.trim().isNotEmpty && hasValidLineItems;

  SaleDocumentFormState copyWith({
    bool? isFormOpen,
    String? party,
    String? refNo,
    DateTime? invoiceDate,
    TimeOfDay? invoiceTime,
    String? stateOfSupply,
    String? godown,
    List<SaleLineItem>? items,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    String? taxOption,
    bool? roundOff,
    bool? showValidationErrors,
  }) {
    return SaleDocumentFormState(
      isFormOpen: isFormOpen ?? this.isFormOpen,
      party: party ?? this.party,
      refNo: refNo ?? this.refNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      godown: godown ?? this.godown,
      items: items ?? this.items,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      taxOption: taxOption ?? this.taxOption,
      roundOff: roundOff ?? this.roundOff,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
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
