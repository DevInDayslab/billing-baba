import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';

class CreditNoteFormState {
  const CreditNoteFormState({
    this.party = '',
    this.phone = '',
    this.returnNo = '1',
    this.originalInvoiceNo = '',
    this.originalInvoiceDate,
    this.returnDate,
    this.stateOfSupply = '',
    this.items = const [],
    this.payments = const [SalePaymentEntry(type: 'Cash')],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.roundOff = false,
    this.showValidationErrors = false,
    this.isDirty = false,
  });

  final String party;
  final String phone;
  final String returnNo;
  final String originalInvoiceNo;
  final DateTime? originalInvoiceDate;
  final DateTime? returnDate;
  final String stateOfSupply;
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

  bool get partyHasError => showValidationErrors && party.trim().isEmpty;

  bool get hasValidLineItems =>
      items.any((item) => item.itemName.trim().isNotEmpty);

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get isValid => party.trim().isNotEmpty && hasValidLineItems;

  CreditNoteFormState copyWith({
    String? party,
    String? phone,
    String? returnNo,
    String? originalInvoiceNo,
    DateTime? originalInvoiceDate,
    DateTime? returnDate,
    String? stateOfSupply,
    List<SaleLineItem>? items,
    List<SalePaymentEntry>? payments,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    bool? showValidationErrors,
    bool? isDirty,
  }) {
    return CreditNoteFormState(
      party: party ?? this.party,
      phone: phone ?? this.phone,
      returnNo: returnNo ?? this.returnNo,
      originalInvoiceNo: originalInvoiceNo ?? this.originalInvoiceNo,
      originalInvoiceDate: originalInvoiceDate ?? this.originalInvoiceDate,
      returnDate: returnDate ?? this.returnDate,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
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

class SavedCreditNote {
  const SavedCreditNote({
    required this.id,
    required this.party,
    required this.phone,
    required this.returnNo,
    required this.originalInvoiceNo,
    required this.originalInvoiceDate,
    required this.returnDate,
    required this.stateOfSupply,
    required this.items,
    required this.description,
    required this.attachedImages,
    required this.attachedDocuments,
    required this.roundOff,
    required this.paymentType,
    required this.total,
    required this.savedAt,
  });

  factory SavedCreditNote.fromFormState({
    required String id,
    required CreditNoteFormState form,
  }) {
    return SavedCreditNote(
      id: id,
      party: form.party,
      phone: form.phone,
      returnNo: form.returnNo,
      originalInvoiceNo: form.originalInvoiceNo,
      originalInvoiceDate: form.originalInvoiceDate,
      returnDate: form.returnDate,
      stateOfSupply: form.stateOfSupply,
      items: List<SaleLineItem>.from(form.items),
      description: form.description,
      attachedImages: List<SaleFormAttachment>.from(form.attachedImages),
      attachedDocuments: List<SaleFormAttachment>.from(form.attachedDocuments),
      roundOff: form.roundOff,
      paymentType: form.paymentType,
      total: form.total,
      savedAt: DateTime.now(),
    );
  }

  final String id;
  final String party;
  final String phone;
  final String returnNo;
  final String originalInvoiceNo;
  final DateTime? originalInvoiceDate;
  final DateTime? returnDate;
  final String stateOfSupply;
  final List<SaleLineItem> items;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final String paymentType;
  final double total;
  final DateTime savedAt;
}

int _savedCreditNoteCounter = 0;

String nextSavedCreditNoteId() {
  _savedCreditNoteCounter += 1;
  return 'credit_note_$_savedCreditNoteCounter';
}
