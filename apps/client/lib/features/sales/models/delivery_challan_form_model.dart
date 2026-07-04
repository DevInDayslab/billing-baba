import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';

class DeliveryChallanFormState {
  const DeliveryChallanFormState({
    this.isFormOpen = false,
    this.documentId,
    this.partyId,
    this.party = '',
    this.godown = 'Main Godown',
    this.godownId,
    this.challanNo = '1',
    this.invoiceDate,
    this.invoiceTime,
    this.dueDate,
    this.stateOfSupply = '',
    this.items = const [],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.roundOff = false,
    this.showValidationErrors = false,
    this.isSaving = false,
    this.saveError,
  });

  final bool isFormOpen;
  final String? documentId;
  final String? partyId;
  final String party;
  final String godown;
  final String? godownId;
  final String challanNo;
  final DateTime? invoiceDate;
  final TimeOfDay? invoiceTime;
  final DateTime? dueDate;
  final String stateOfSupply;
  final List<SaleLineItem> items;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final bool showValidationErrors;
  final bool isSaving;
  final String? saveError;

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
    String? godown,
    String? godownId,
    String? challanNo,
    DateTime? invoiceDate,
    TimeOfDay? invoiceTime,
    DateTime? dueDate,
    String? stateOfSupply,
    List<SaleLineItem>? items,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    bool? showValidationErrors,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return DeliveryChallanFormState(
      isFormOpen: isFormOpen ?? this.isFormOpen,
      documentId: documentId ?? this.documentId,
      partyId: partyId ?? this.partyId,
      party: party ?? this.party,
      godown: godown ?? this.godown,
      godownId: godownId ?? this.godownId,
      challanNo: challanNo ?? this.challanNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      dueDate: dueDate ?? this.dueDate,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      items: items ?? this.items,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      roundOff: roundOff ?? this.roundOff,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}
