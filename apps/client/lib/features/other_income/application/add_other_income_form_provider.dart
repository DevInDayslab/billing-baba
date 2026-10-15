import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/other_income/application/other_income_service.dart';
import 'package:billing_baba/features/other_income/application/other_incomes_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/other_income/models/other_income_form_model.dart';
import 'package:billing_baba/features/other_income/models/other_income_model.dart';
import 'package:billing_baba/features/other_income/models/requests/other_income_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/documents/document_line_id.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/shared/forms/transaction_party_link.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_other_income_form_provider.g.dart';

String _nextOtherIncomeLineItemId() => newDocumentLineId();

AddOtherIncomeFormState _defaultFormState({String? incomeId}) {
  final now = DateTime.now();
  return AddOtherIncomeFormState(
    incomeId: incomeId,
    incomeNumber: 'Auto',
    incomeDate: DateTime(now.year, now.month, now.day),
    incomeTime: TimeOfDay.fromDateTime(now),
    dueDate: DateTime(now.year, now.month, now.day),
    items: [OtherIncomeLineItem.empty(id: _nextOtherIncomeLineItemId())],
    isLoading: incomeId != null,
  );
}

String _formatExpenseDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

@riverpod
class AddOtherIncomeForm extends _$AddOtherIncomeForm {
  @override
  AddOtherIncomeFormState build({String? incomeId}) {
    if (incomeId != null) {
      Future.microtask(() => _loadOtherIncome(incomeId));
    }
    return _defaultFormState(incomeId: incomeId);
  }

  Future<void> _loadOtherIncome(String id) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(otherIncomeServiceProvider.future);
      final dto = await service.fetchOtherIncomeDto(id);
      final transaction = await service.fetchOtherIncome(id);
      final categories = await ref.read(incomeCategoriesProvider.future);
      final category = categories
          .where((item) => item.id == dto.categoryId)
          .firstOrNull;
      final incomeDate = DateTime.tryParse(dto.incomeDate) ?? DateTime.now();
      final amount = double.tryParse(dto.amount) ?? 0;
      final taxAmount = double.tryParse(dto.taxAmount ?? '') ?? 0;
      final taxRate = double.tryParse(dto.taxRate ?? '') ?? 0;

      final attachments = await loadTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.otherIncome.apiValue,
        entityId: id,
      );

      state = state.copyWith(
        incomeId: id,
        categoryId: dto.categoryId,
        category: dto.categoryName ?? category?.name ?? '',
        party: dto.partyName?.trim() ?? transaction.party,
        partyId: dto.partyId,
        incomeNumber: dto.referenceNumber?.trim().isNotEmpty == true
            ? dto.referenceNumber!.trim()
            : transaction.transactionNo,
        incomeDate: DateTime(
          incomeDate.year,
          incomeDate.month,
          incomeDate.day,
        ),
        incomeTime: TimeOfDay.fromDateTime(incomeDate),
        description: dto.notes ?? '',
        payments: [
          OtherIncomePaymentEntry(
            type: transaction.paymentType ?? 'Cash',
            amount: amount,
            referenceNo: dto.referenceNumber ?? '',
          ),
        ],
        gstEnabled: taxAmount > 0 || dto.partyId != null,
        items: [
          OtherIncomeLineItem(
            id: _nextOtherIncomeLineItemId(),
            itemName: dto.description?.trim() ?? '',
            description: dto.description ?? '',
            qty: 1,
            pricePerUnit: amount,
            taxPercent: taxRate,
          ),
        ],
        attachedImages: attachments.images,
        attachedDocuments: attachments.documents,
        isLoading: false,
        isDirty: false,
        showValidationErrors: kResetValidationOnLoad,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        saveError: PurchaseErrorMapper.messageFor(error),
      );
    }
  }

  void toggleGst({required bool value}) {
    state = state.copyWith(gstEnabled: value, isDirty: true);
  }

  void updateCategory({required String id, required String name}) {
    state = state.copyWith(
      categoryId: id,
      category: name,
      isDirty: true,
    );
  }

  void updateParty(String value, {String? partyId}) {
    final change = unlinkedPartyNameChange(
      newName: value,
      previousName: state.party,
      currentPartyId: state.partyId,
    );
    state = state.copyWith(
      party: change.partyName,
      partyId: partyId,
      clearPartyId: partyId == null && change.clearPartyId,
      isDirty: true,
    );
  }

  void updateOtherIncomeNumber(String value) {
    state = state.copyWith(incomeNumber: value, isDirty: true);
  }

  void updateOtherIncomeDate(DateTime date) {
    state = state.copyWith(incomeDate: date, isDirty: true);
  }

  void updateOtherIncomeTime(TimeOfDay time) {
    state = state.copyWith(incomeTime: time, isDirty: true);
  }

  void updatePaymentTerms(String value) {
    state = state.copyWith(paymentTerms: value, isDirty: true);
  }

  void updateDueDate(DateTime? date) {
    state = state.copyWith(dueDate: date, isDirty: true);
  }

  void updateStateOfSupply(String value) {
    state = state.copyWith(stateOfSupply: value, isDirty: true);
  }

  void addLineItem() {
    final items = [
      ...state.items,
      OtherIncomeLineItem.empty(id: _nextOtherIncomeLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(OtherIncomeLineItem.empty(id: _nextOtherIncomeLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, OtherIncomeLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, isDirty: true);
  }

  void updatePaymentType(String type) {
    final isCash = type.toLowerCase() == 'cash';
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(OtherIncomePaymentEntry(type: type));
    } else {
      payments[0] = payments[0].copyWith(
        type: type,
        clearBankAccountId: isCash,
      );
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updatePaymentBankAccountId(String? id) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(OtherIncomePaymentEntry(type: 'Cash', bankAccountId: id));
    } else {
      payments[0] = payments[0].copyWith(
        bankAccountId: id,
        clearBankAccountId: id == null || id.isEmpty,
      );
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updatePaymentAmount(double amount) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(OtherIncomePaymentEntry(type: 'Cash', amount: amount));
    } else {
      payments[0] = payments[0].copyWith(amount: amount);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updatePaymentReference(String reference) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(OtherIncomePaymentEntry(type: 'Cash', referenceNo: reference));
    } else {
      payments[0] = payments[0].copyWith(referenceNo: reference);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void addPaymentType() {
    final payments = [
      ...state.payments,
      const OtherIncomePaymentEntry(type: 'UPI'),
    ];
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value, isDirty: true);
  }

  void addImage(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedImages: [...state.attachedImages, attachment],
      isDirty: true,
    );
  }

  void removeImage(String id) {
    state = state.copyWith(
      attachedImages: state.attachedImages
          .where((image) => image.id != id)
          .toList(),
      isDirty: true,
    );
  }

  void updateImage(String id, String name) {
    state = state.copyWith(
      attachedImages: [
        for (final image in state.attachedImages)
          if (image.id == id) image.copyWith(name: name) else image,
      ],
      isDirty: true,
    );
  }

  void addDocument(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedDocuments: [...state.attachedDocuments, attachment],
      isDirty: true,
    );
  }

  void removeDocument(String id) {
    state = state.copyWith(
      attachedDocuments: state.attachedDocuments
          .where((document) => document.id != id)
          .toList(),
      isDirty: true,
    );
  }

  void updateDocument(String id, String name) {
    state = state.copyWith(
      attachedDocuments: [
        for (final document in state.attachedDocuments)
          if (document.id == id) document.copyWith(name: name) else document,
      ],
      isDirty: true,
    );
  }

  void toggleRoundOff({required bool value}) {
    state = state.copyWith(roundOff: value, isDirty: true);
  }

  String? _validationError() {
    return buildTransactionValidationError(
      hasValidLineItems: state.items.any(
        (item) => item.itemName.trim().isNotEmpty && item.qty > 0,
      ),
      hasValidCategory: state.category.trim().isNotEmpty,
      hasValidParty: state.partyId != null && state.partyId!.isNotEmpty,
      requireCategory: true,
      requireParty: state.gstEnabled,
      fieldMessages: state.gstEnabled
          ? {TransactionValidationField.party: 'Please select a supplier'}
          : null,
    );
  }

  bool validate() {
    final isValid = state.isValid;
    if (!isValid) {
      state = state.copyWith(showValidationErrors: true);
    }
    return isValid;
  }

  String? _lineItemDescription() {
    final descriptions = state.items
        .map((item) => item.description.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (descriptions.isNotEmpty) return descriptions.join(', ');

    final names = state.items
        .map((item) => item.itemName.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return names.isEmpty ? null : names.join(', ');
  }

  String? _effectiveTaxRate() {
    final taxableItems = state.items.where((item) => item.taxPercent > 0);
    if (taxableItems.isEmpty) return null;
    return taxableItems.first.taxPercent.toStringAsFixed(4);
  }

  String? _primaryIncomeItemId() {
    for (final item in state.items) {
      final id = item.incomeItemId;
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  Future<String?> saveOtherIncome() async {
    if (state.isSaving) return null;
    if (!validate()) return _validationError();

    final categoryId = state.categoryId;
    if (categoryId.isEmpty) {
      return 'Category is required';
    }

    final categories = await ref.read(incomeCategoriesProvider.future);
    final selectedCategory = categories
        .where((category) => category.id == categoryId)
        .firstOrNull;
    if (selectedCategory?.variant.isSyncOnly == true) {
      return 'Loyalty redeemed and payment-in discount expenses are '
          'created automatically';
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final service = await ref.read(otherIncomeServiceProvider.future);
      final date = state.incomeDate ?? DateTime.now();
      final incomeDate = _formatExpenseDate(date);
      final referenceNumber = state.payments.isNotEmpty
          ? state.payments.first.referenceNo.trim()
          : '';
      final notes = state.description.trim();
      final description = _lineItemDescription();
      final taxAmount = state.totalTax > 0
          ? state.totalTax.toStringAsFixed(4)
          : null;
      final taxRate = _effectiveTaxRate();
      final partyId = state.partyId;

      final request = CreateOtherIncomeRequest(
        categoryId: categoryId,
        amount: state.grandTotal.toStringAsFixed(4),
        incomeDate: incomeDate,
        incomeItemId: _primaryIncomeItemId(),
        partyId: partyId?.isNotEmpty == true ? partyId : null,
        description: description,
        notes: notes.isEmpty ? null : notes,
        referenceNumber: referenceNumber.isEmpty ? null : referenceNumber,
        taxAmount: taxAmount,
        taxRate: taxRate,
        paymentMode: PurchasePaymentModes.toApi(state.paymentType),
        bankAccountId: state.payments.isNotEmpty
            ? state.payments.first.bankAccountId
            : null,
      );

      final incomeId = state.incomeId;
      late final String savedExpenseId;
      if (incomeId != null && incomeId.isNotEmpty) {
        await service.updateOtherIncome(
          incomeId,
          UpdateOtherIncomeRequest(
            categoryId: request.categoryId,
            amount: request.amount,
            incomeDate: request.incomeDate,
            incomeItemId: request.incomeItemId,
            partyId: request.partyId,
            description: request.description,
            notes: request.notes,
            referenceNumber: request.referenceNumber,
            taxAmount: request.taxAmount,
            taxRate: request.taxRate,
            paymentMode: request.paymentMode,
            bankAccountId: request.bankAccountId,
          ),
        );
        savedExpenseId = incomeId;
      } else {
        final created = await service.createOtherIncome(request);
        savedExpenseId = created.id;
      }

      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.otherIncome.apiValue,
        entityId: savedExpenseId,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );

      refreshAfterExpense(
        ref,
        context: (partyId: partyId, itemIds: const []),
      );
      await ref.read(otherIncomeTransactionsProvider.notifier).refresh();
      await ref.read(incomeCategoriesProvider.notifier).refresh();
      await ref.read(incomeCatalogItemsProvider.notifier).refresh();
      ref
          .read(otherIncomeSaveSuccessMessageProvider.notifier)
          .setMessage('Other income saved successfully');
      state = state.copyWith(
        isSaving: false,
        isDirty: false,
        incomeId: savedExpenseId,
        attachedImages: synced?.images ?? state.attachedImages,
        attachedDocuments: synced?.documents ?? state.attachedDocuments,
      );
      ref.invalidateSelf();
      return null;
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return message;
    }
  }
}

@riverpod
double addOtherIncomeGrandTotal(Ref ref, {String? incomeId}) {
  final form = ref.watch(addOtherIncomeFormProvider(incomeId: incomeId));
  return form.grandTotal;
}

@riverpod
double addOtherIncomeTotalTax(Ref ref, {String? incomeId}) {
  final form = ref.watch(addOtherIncomeFormProvider(incomeId: incomeId));
  return form.totalTax;
}

@riverpod
List<String> expenseCategoryOptions(Ref ref) {
  final categoriesAsync = ref.watch(incomeCategoriesProvider);
  return categoriesAsync.maybeWhen(
    data: (categories) => categories
        .where((category) => category.variant.isManual)
        .map((c) => c.name)
        .toList(),
    orElse: () => const <String>[],
  );
}
