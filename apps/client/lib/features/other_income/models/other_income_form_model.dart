import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:flutter/material.dart';

class OtherIncomeLineItem {
  const OtherIncomeLineItem({
    required this.id,
    this.incomeItemId,
    this.itemName = '',
    this.description = '',
    this.qty = 0,
    this.pricePerUnit = 0,
    this.priceIsTaxInclusive = false,
    this.taxPercent = 0,
  });

  factory OtherIncomeLineItem.empty({required String id}) =>
      OtherIncomeLineItem(id: id);

  final String id;
  final String? incomeItemId;
  final String itemName;
  final String description;
  final double qty;
  final double pricePerUnit;
  final bool priceIsTaxInclusive;
  final double taxPercent;

  double get lineSubtotal {
    if (priceIsTaxInclusive && taxPercent > 0) {
      return qty * pricePerUnit / (1 + taxPercent / 100);
    }
    return qty * pricePerUnit;
  }

  double get lineTax =>
      priceIsTaxInclusive ? 0 : qty * pricePerUnit * (taxPercent / 100);

  double get amount => lineSubtotal + lineTax;

  OtherIncomeLineItem copyWith({
    String? id,
    String? incomeItemId,
    bool clearIncomeItemId = false,
    String? itemName,
    String? description,
    double? qty,
    double? pricePerUnit,
    bool? priceIsTaxInclusive,
    double? taxPercent,
  }) {
    return OtherIncomeLineItem(
      id: id ?? this.id,
      incomeItemId:
          clearIncomeItemId ? null : (incomeItemId ?? this.incomeItemId),
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      qty: qty ?? this.qty,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      priceIsTaxInclusive: priceIsTaxInclusive ?? this.priceIsTaxInclusive,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }
}

class OtherIncomePaymentEntry {
  const OtherIncomePaymentEntry({
    required this.type,
    this.amount = 0,
    this.referenceNo = '',
    this.bankAccountId,
  });

  final String type;
  final double amount;
  final String referenceNo;
  final String? bankAccountId;

  OtherIncomePaymentEntry copyWith({
    String? type,
    double? amount,
    String? referenceNo,
    String? bankAccountId,
    bool clearBankAccountId = false,
  }) {
    return OtherIncomePaymentEntry(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      referenceNo: referenceNo ?? this.referenceNo,
      bankAccountId:
          clearBankAccountId ? null : (bankAccountId ?? this.bankAccountId),
    );
  }
}

class AddOtherIncomeFormState {
  const AddOtherIncomeFormState({
    this.incomeId,
    this.gstEnabled = false,
    this.category = '',
    this.categoryId = '',
    this.party = '',
    this.partyId,
    this.incomeNumber = '',
    this.incomeDate,
    this.incomeTime,
    this.paymentTerms = 'Due on Receipt',
    this.dueDate,
    this.stateOfSupply = 'Madhya Pradesh',
    this.items = const [],
    this.payments = const [OtherIncomePaymentEntry(type: 'Cash')],
    this.description = '',
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.roundOff = false,
    this.isDirty = false,
    this.showValidationErrors = false,
    this.isLoading = false,
    this.isSaving = false,
    this.saveError,
  });

  final String? incomeId;
  final bool gstEnabled;
  final String category;
  final String categoryId;
  final String party;
  final String? partyId;
  final String incomeNumber;
  final DateTime? incomeDate;
  final DateTime? dueDate;
  final TimeOfDay? incomeTime;
  final String paymentTerms;
  final String stateOfSupply;
  final List<OtherIncomeLineItem> items;
  final List<OtherIncomePaymentEntry> payments;
  final String description;
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool roundOff;
  final bool isDirty;
  final bool showValidationErrors;
  final bool isLoading;
  final bool isSaving;
  final String? saveError;

  bool get categoryHasError => showValidationErrors && category.trim().isEmpty;

  bool get partyHasError =>
      showValidationErrors &&
      gstEnabled &&
      (partyId == null || partyId!.isEmpty);

  bool get lineItemsHasError =>
      showValidationErrors &&
      !items.any((item) => item.itemName.trim().isNotEmpty && item.qty > 0);

  double get totalQty => items.fold<double>(0, (sum, item) => sum + item.qty);

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineSubtotal);

  double get totalTax =>
      items.fold<double>(0, (sum, item) => sum + item.lineTax);

  double get rawTotal => subtotal + totalTax;

  double get roundOffAmount {
    if (!roundOff) return 0;
    return rawTotal.roundToDouble() - rawTotal;
  }

  double get grandTotal => rawTotal + roundOffAmount;

  double get paymentAmount =>
      payments.fold<double>(0, (sum, payment) => sum + payment.amount);

  double get balanceAmount => grandTotal - paymentAmount;

  String get paymentType => payments.isNotEmpty ? payments.first.type : 'Cash';

  bool get isValid =>
      category.trim().isNotEmpty &&
      (!gstEnabled || (partyId != null && partyId!.isNotEmpty)) &&
      items.any((item) => item.itemName.trim().isNotEmpty && item.qty > 0);

  AddOtherIncomeFormState copyWith({
    String? incomeId,
    bool? gstEnabled,
    String? category,
    String? categoryId,
    String? party,
    String? partyId,
    String? incomeNumber,
    DateTime? incomeDate,
    DateTime? dueDate,
    TimeOfDay? incomeTime,
    String? paymentTerms,
    String? stateOfSupply,
    List<OtherIncomeLineItem>? items,
    List<OtherIncomePaymentEntry>? payments,
    String? description,
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? roundOff,
    bool? isDirty,
    bool? showValidationErrors,
    bool? isLoading,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
    bool clearPartyId = false,
  }) {
    return AddOtherIncomeFormState(
      incomeId: incomeId ?? this.incomeId,
      gstEnabled: gstEnabled ?? this.gstEnabled,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      party: party ?? this.party,
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      incomeNumber: incomeNumber ?? this.incomeNumber,
      incomeDate: incomeDate ?? this.incomeDate,
      dueDate: dueDate ?? this.dueDate,
      incomeTime: incomeTime ?? this.incomeTime,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      stateOfSupply: stateOfSupply ?? this.stateOfSupply,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      description: description ?? this.description,
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      roundOff: roundOff ?? this.roundOff,
      isDirty: isDirty ?? this.isDirty,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }
}

String generateNextExpenseNumber(List<String> existingNumbers) {
  var max = 0;
  for (final number in existingNumbers) {
    final parsed = int.tryParse(number.trim());
    if (parsed != null && parsed > max) max = parsed;
  }
  return (max + 1).toString();
}
