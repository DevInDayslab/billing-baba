import 'package:billing_baba/features/purchases/application/expense_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/models/expense_form_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/providers/expenses_provider.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_expense_form_provider.g.dart';

int _expenseLineItemCounter = 0;

String _nextExpenseLineItemId() {
  _expenseLineItemCounter += 1;
  return 'expense_line_$_expenseLineItemCounter';
}

AddExpenseFormState _defaultFormState({String? expenseId}) {
  final now = DateTime.now();
  return AddExpenseFormState(
    expenseId: expenseId,
    expenseNumber: 'Auto',
    expenseDate: DateTime(now.year, now.month, now.day),
    expenseTime: TimeOfDay.fromDateTime(now),
    dueDate: DateTime(now.year, now.month, now.day),
    items: [ExpenseLineItem.empty(id: _nextExpenseLineItemId())],
    isLoading: expenseId != null,
  );
}

String _formatExpenseDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

@riverpod
class AddExpenseForm extends _$AddExpenseForm {
  @override
  AddExpenseFormState build({String? expenseId}) {
    if (expenseId != null) {
      Future.microtask(() => _loadExpense(expenseId));
    }
    return _defaultFormState(expenseId: expenseId);
  }

  Future<void> _loadExpense(String id) async {
    state = state.copyWith(isLoading: true, clearSaveError: true);
    try {
      final service = await ref.read(expenseServiceProvider.future);
      final dto = await service.fetchExpenseDto(id);
      final transaction = await service.fetchExpense(id);
      final categories = await ref.read(expenseCategoriesProvider.future);
      final category = categories
          .where((item) => item.id == dto.categoryId)
          .firstOrNull;
      final expenseDate = DateTime.tryParse(dto.expenseDate) ?? DateTime.now();
      final amount = double.tryParse(dto.amount) ?? 0;
      final taxAmount = double.tryParse(dto.taxAmount ?? '') ?? 0;
      final taxRate = double.tryParse(dto.taxRate ?? '') ?? 0;

      state = state.copyWith(
        expenseId: id,
        categoryId: dto.categoryId,
        category: dto.categoryName ?? category?.name ?? '',
        party: dto.partyName?.trim() ?? transaction.party,
        partyId: dto.partyId,
        expenseNumber: dto.referenceNumber?.trim().isNotEmpty == true
            ? dto.referenceNumber!.trim()
            : transaction.transactionNo,
        expenseDate: DateTime(
          expenseDate.year,
          expenseDate.month,
          expenseDate.day,
        ),
        expenseTime: TimeOfDay.fromDateTime(expenseDate),
        description: dto.notes ?? '',
        payments: [
          ExpensePaymentEntry(
            type: transaction.paymentType ?? 'Cash',
            amount: amount,
            referenceNo: dto.referenceNumber ?? '',
          ),
        ],
        gstEnabled: taxAmount > 0 || dto.partyId != null,
        items: [
          ExpenseLineItem(
            id: _nextExpenseLineItemId(),
            itemName: dto.description?.trim() ?? '',
            description: dto.description ?? '',
            qty: 1,
            pricePerUnit: amount,
            taxPercent: taxRate,
          ),
        ],
        isLoading: false,
        isDirty: false,
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
    state = state.copyWith(
      party: value,
      partyId: partyId ?? state.partyId,
      isDirty: true,
    );
  }

  void updateExpenseNumber(String value) {
    state = state.copyWith(expenseNumber: value, isDirty: true);
  }

  void updateExpenseDate(DateTime date) {
    state = state.copyWith(expenseDate: date, isDirty: true);
  }

  void updateExpenseTime(TimeOfDay time) {
    state = state.copyWith(expenseTime: time, isDirty: true);
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
      ExpenseLineItem.empty(id: _nextExpenseLineItemId()),
    ];
    state = state.copyWith(items: items, isDirty: true);
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items]..removeAt(index);
    if (items.isEmpty) {
      items.add(ExpenseLineItem.empty(id: _nextExpenseLineItemId()));
    }
    state = state.copyWith(items: items, isDirty: true);
  }

  void updateLineItem(int index, ExpenseLineItem item) {
    if (index < 0 || index >= state.items.length) return;
    final items = [...state.items];
    items[index] = item;
    state = state.copyWith(items: items, isDirty: true);
  }

  void updatePaymentType(String type) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(ExpensePaymentEntry(type: type));
    } else {
      payments[0] = payments[0].copyWith(type: type);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updatePaymentAmount(double amount) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(ExpensePaymentEntry(type: 'Cash', amount: amount));
    } else {
      payments[0] = payments[0].copyWith(amount: amount);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void updatePaymentReference(String reference) {
    final payments = [...state.payments];
    if (payments.isEmpty) {
      payments.add(ExpensePaymentEntry(type: 'Cash', referenceNo: reference));
    } else {
      payments[0] = payments[0].copyWith(referenceNo: reference);
    }
    state = state.copyWith(payments: payments, isDirty: true);
  }

  void addPaymentType() {
    final payments = [
      ...state.payments,
      const ExpensePaymentEntry(type: 'UPI'),
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

  Future<String?> saveExpense() async {
    if (!validate()) return 'Please fill required fields';

    final categoryId = state.categoryId;
    if (categoryId.isEmpty) {
      return 'Category is required';
    }

    try {
      final service = await ref.read(expenseServiceProvider.future);
      final date = state.expenseDate ?? DateTime.now();
      final expenseDate = _formatExpenseDate(date);
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

      final request = CreateExpenseRequest(
        categoryId: categoryId,
        amount: state.grandTotal.toStringAsFixed(4),
        expenseDate: expenseDate,
        partyId: partyId?.isNotEmpty == true ? partyId : null,
        description: description,
        notes: notes.isEmpty ? null : notes,
        referenceNumber: referenceNumber.isEmpty ? null : referenceNumber,
        taxAmount: taxAmount,
        taxRate: taxRate,
        paymentMode: PurchasePaymentModes.toApi(state.paymentType),
      );

      final expenseId = state.expenseId;
      if (expenseId != null && expenseId.isNotEmpty) {
        await service.updateExpense(
          expenseId,
          UpdateExpenseRequest(
            categoryId: request.categoryId,
            amount: request.amount,
            expenseDate: request.expenseDate,
            partyId: request.partyId,
            description: request.description,
            notes: request.notes,
            referenceNumber: request.referenceNumber,
            taxAmount: request.taxAmount,
            taxRate: request.taxRate,
            paymentMode: request.paymentMode,
          ),
        );
      } else {
        await service.createExpense(request);
      }

      ref.invalidate(expenseTransactionsProvider);
      ref.invalidate(expenseCategoriesProvider);
      ref.invalidateSelf();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }
}

@riverpod
double addExpenseGrandTotal(Ref ref, {String? expenseId}) {
  final form = ref.watch(addExpenseFormProvider(expenseId: expenseId));
  return form.grandTotal;
}

@riverpod
double addExpenseTotalTax(Ref ref, {String? expenseId}) {
  final form = ref.watch(addExpenseFormProvider(expenseId: expenseId));
  return form.totalTax;
}

@riverpod
List<String> expenseCategoryOptions(Ref ref) {
  final categoriesAsync = ref.watch(expenseCategoriesProvider);
  return categoriesAsync.maybeWhen(
    data: (categories) => categories.map((c) => c.name).toList(),
    orElse: () => const <String>[],
  );
}
