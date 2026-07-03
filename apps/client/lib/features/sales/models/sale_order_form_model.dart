import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';

class SaleOrderFormState {
  const SaleOrderFormState({
    this.isFormOpen = false,
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
  });

  final bool isFormOpen;
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

  bool get isValid => party.trim().isNotEmpty && hasValidLineItems;

  SaleOrderFormState copyWith({
    bool? isFormOpen,
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
  }) {
    return SaleOrderFormState(
      isFormOpen: isFormOpen ?? this.isFormOpen,
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
    );
  }
}

class SavedSaleOrder {
  const SavedSaleOrder({
    required this.id,
    required this.party,
    required this.orderNo,
    required this.orderDate,
    required this.dueDate,
    required this.stateOfSupply,
    required this.items,
    required this.paymentType,
    required this.advanceAmount,
    required this.total,
    required this.balanceAmount,
    required this.savedAt,
  });

  factory SavedSaleOrder.fromFormState({
    required String id,
    required SaleOrderFormState form,
  }) {
    return SavedSaleOrder(
      id: id,
      party: form.party,
      orderNo: form.orderNo,
      orderDate: form.orderDate,
      dueDate: form.dueDate,
      stateOfSupply: form.stateOfSupply,
      items: List<SaleLineItem>.from(form.items),
      paymentType: form.paymentType,
      advanceAmount: form.advanceAmount,
      total: form.total,
      balanceAmount: form.balanceAmount,
      savedAt: DateTime.now(),
    );
  }

  final String id;
  final String party;
  final String orderNo;
  final DateTime? orderDate;
  final DateTime? dueDate;
  final String stateOfSupply;
  final List<SaleLineItem> items;
  final String paymentType;
  final double advanceAmount;
  final double total;
  final double balanceAmount;
  final DateTime savedAt;
}

int _savedSaleOrderCounter = 0;

String nextSavedSaleOrderId() {
  _savedSaleOrderCounter += 1;
  return 'sale_order_$_savedSaleOrderCounter';
}
