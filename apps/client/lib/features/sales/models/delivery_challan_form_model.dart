import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';

class DeliveryChallanFormState {
  const DeliveryChallanFormState({
    this.isFormOpen = false,
    this.party = '',
    this.godown = 'Main Godown',
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
  });

  final bool isFormOpen;
  final String party;
  final String godown;
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

  bool get partyHasError =>
      showValidationErrors && party.trim().isEmpty;

  bool get hasValidLineItems =>
      items.any((item) => item.itemName.trim().isNotEmpty);

  bool get lineItemsHasError =>
      showValidationErrors && !hasValidLineItems;

  bool get isValid => party.trim().isNotEmpty && hasValidLineItems;

  DeliveryChallanFormState copyWith({
    bool? isFormOpen,
    String? party,
    String? godown,
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
  }) {
    return DeliveryChallanFormState(
      isFormOpen: isFormOpen ?? this.isFormOpen,
      party: party ?? this.party,
      godown: godown ?? this.godown,
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
      showValidationErrors:
          showValidationErrors ?? this.showValidationErrors,
    );
  }
}

class SavedDeliveryChallan {
  const SavedDeliveryChallan({
    required this.id,
    required this.party,
    required this.godown,
    required this.challanNo,
    required this.invoiceDate,
    required this.invoiceTime,
    required this.dueDate,
    required this.stateOfSupply,
    required this.items,
    required this.description,
    required this.attachedImages,
    required this.attachedDocuments,
    required this.roundOff,
    required this.total,
    required this.savedAt,
  });

  factory SavedDeliveryChallan.fromFormState({
    required String id,
    required DeliveryChallanFormState form,
  }) {
    return SavedDeliveryChallan(
      id: id,
      party: form.party,
      godown: form.godown,
      challanNo: form.challanNo,
      invoiceDate: form.invoiceDate,
      invoiceTime: form.invoiceTime,
      dueDate: form.dueDate,
      stateOfSupply: form.stateOfSupply,
      items: List<SaleLineItem>.from(form.items),
      description: form.description,
      attachedImages: List<SaleFormAttachment>.from(form.attachedImages),
      attachedDocuments: List<SaleFormAttachment>.from(form.attachedDocuments),
      roundOff: form.roundOff,
      total: form.total,
      savedAt: DateTime.now(),
    );
  }

  final String id;
  final String party;
  final String godown;
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
  final double total;
  final DateTime savedAt;
}

int _savedDeliveryChallanCounter = 0;

String nextSavedDeliveryChallanId() {
  _savedDeliveryChallanCounter += 1;
  return 'delivery_challan_$_savedDeliveryChallanCounter';
}
