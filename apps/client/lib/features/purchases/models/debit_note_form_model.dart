import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter/material.dart';

class DebitNoteFormState {
  const DebitNoteFormState({
    this.documentId,
    this.partyId,
    this.godownId,
    this.party = '',
    this.returnNo = '1',
    this.billNumber = '',
    this.billDate,
    this.returnDate,
    this.returnTime,
    this.stateOfSupply = 'Madhya Pradesh',
    this.godown = 'Main Godown',
    this.items = const [],
    this.payments = const [SalePaymentEntry(type: 'Cash')],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.roundOff = true,
    this.showValidationErrors = false,
    this.isDirty = false,
  });

  final String? documentId;
  final String? partyId;
  final String? godownId;
  final String party;
  final String returnNo;
  final String billNumber;
  final DateTime? billDate;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;
  final String stateOfSupply;
  final String godown;
  final List<SaleLineItem> items;
  final List<SalePaymentEntry> payments;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final bool showValidationErrors;
  final bool isDirty;

  String get paymentType => payments.isNotEmpty ? payments.first.type : 'Cash';

  double get paymentAmount => payments.isNotEmpty ? payments.first.amount : 0;

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
      showValidationErrors && (partyId == null || partyId!.isEmpty);

  bool get hasValidLineItems =>
      items.any((item) => item.itemName.trim().isNotEmpty);

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get isValid =>
      (partyId != null && partyId!.isNotEmpty) && hasValidLineItems;

  DebitNoteFormState copyWith({
    String? documentId,
    String? partyId,
    String? godownId,
    String? party,
    String? returnNo,
    String? billNumber,
    DateTime? billDate,
    DateTime? returnDate,
    TimeOfDay? returnTime,
    String? stateOfSupply,
    String? godown,
    List<SaleLineItem>? items,
    List<SalePaymentEntry>? payments,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    bool? showValidationErrors,
    bool? isDirty,
  }) {
    return DebitNoteFormState(
      documentId: documentId ?? this.documentId,
      partyId: partyId ?? this.partyId,
      godownId: godownId ?? this.godownId,
      party: party ?? this.party,
      returnNo: returnNo ?? this.returnNo,
      billNumber: billNumber ?? this.billNumber,
      billDate: billDate ?? this.billDate,
      returnDate: returnDate ?? this.returnDate,
      returnTime: returnTime ?? this.returnTime,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      godown: godown ?? this.godown,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      roundOff: roundOff ?? this.roundOff,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class SavedDebitNote {
  const SavedDebitNote({
    required this.id,
    required this.party,
    required this.returnNo,
    required this.billNumber,
    required this.billDate,
    required this.returnDate,
    required this.returnTime,
    required this.stateOfSupply,
    required this.godown,
    required this.items,
    required this.description,
    required this.attachedImages,
    required this.attachedDocuments,
    required this.roundOff,
    required this.paymentType,
    required this.total,
    required this.paymentAmount,
    required this.status,
    required this.balance,
    required this.savedAt,
  });

  factory SavedDebitNote.fromFormState({
    required String id,
    required DebitNoteFormState form,
  }) {
    final paid = form.paymentAmount;
    final balance = (form.total - paid).clamp(0.0, double.infinity);
    final status = switch (balance) {
      <= 0 => PurchaseBillStatus.paid,
      _ when paid > 0 => PurchaseBillStatus.partiallyPaid,
      _ => PurchaseBillStatus.unpaid,
    };

    return SavedDebitNote(
      id: id,
      party: form.party,
      returnNo: form.returnNo,
      billNumber: form.billNumber,
      billDate: form.billDate,
      returnDate: form.returnDate,
      returnTime: form.returnTime,
      stateOfSupply: form.stateOfSupply,
      godown: form.godown,
      items: List<SaleLineItem>.from(form.items),
      description: form.description,
      attachedImages: List<SaleFormAttachment>.from(form.attachedImages),
      attachedDocuments: List<SaleFormAttachment>.from(form.attachedDocuments),
      roundOff: form.roundOff,
      paymentType: form.paymentType,
      total: form.total,
      paymentAmount: paid,
      status: status,
      balance: balance,
      savedAt: DateTime.now(),
    );
  }

  final String id;
  final String party;
  final String returnNo;
  final String billNumber;
  final DateTime? billDate;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;
  final String stateOfSupply;
  final String godown;
  final List<SaleLineItem> items;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final String paymentType;
  final double total;
  final double paymentAmount;
  final PurchaseBillStatus status;
  final double balance;
  final DateTime savedAt;
}

int _savedDebitNoteCounter = 0;

String nextSavedDebitNoteId() {
  _savedDebitNoteCounter += 1;
  return 'debit_note_$_savedDebitNoteCounter';
}
