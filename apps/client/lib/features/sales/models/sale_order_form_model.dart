import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';

class SaleOrderFormState {
  const SaleOrderFormState({
    this.isFormOpen = false,
    this.documentId,
    this.partyId,
    this.party = '',
    this.orderNo = '',
    this.orderDate,
    this.dueDate,
    this.stateOfSupply = '',
    this.items = const [],
    this.paymentType = 'Cash',
    this.advanceAmount = 0,
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
  final String orderNo;
  final DateTime? orderDate;
  final DateTime? dueDate;
  final String stateOfSupply;
  final List<SaleLineItem> items;
  final String paymentType;
  final double advanceAmount;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final bool showValidationErrors;
  final bool isSaving;
  final String? saveError;

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

  double get balanceAmount => (total - advanceAmount).clamp(0, double.infinity);

  bool get partyHasError => showValidationErrors && party.trim().isEmpty;

  bool get hasValidLineItems =>
      items.any((item) => item.itemName.trim().isNotEmpty);

  bool get lineItemsHasError => showValidationErrors && !hasValidLineItems;

  bool get isValid =>
      party.trim().isNotEmpty &&
      partyId != null &&
      partyId!.isNotEmpty &&
      hasValidLineItems;

  SaleOrderFormState copyWith({
    bool? isFormOpen,
    String? documentId,
    String? partyId,
    String? party,
    String? orderNo,
    DateTime? orderDate,
    DateTime? dueDate,
    String? stateOfSupply,
    List<SaleLineItem>? items,
    String? paymentType,
    double? advanceAmount,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    bool? showValidationErrors,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) {
    return SaleOrderFormState(
      isFormOpen: isFormOpen ?? this.isFormOpen,
      documentId: documentId ?? this.documentId,
      partyId: partyId ?? this.partyId,
      party: party ?? this.party,
      orderNo: orderNo ?? this.orderNo,
      orderDate: orderDate ?? this.orderDate,
      dueDate: dueDate ?? this.dueDate,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      items: items ?? this.items,
      paymentType: paymentType ?? this.paymentType,
      advanceAmount: advanceAmount ?? this.advanceAmount,
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
