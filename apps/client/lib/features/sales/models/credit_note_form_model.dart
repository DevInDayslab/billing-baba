import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';

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
    this.stateOfSupply = '',
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
  });

  final String? documentId;
  final String? partyId;
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
  final bool isSaving;
  final String? saveError;

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
    String? stateOfSupply,
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
  }) {
    return CreditNoteFormState(
      documentId: documentId ?? this.documentId,
      partyId: partyId ?? this.partyId,
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
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}
