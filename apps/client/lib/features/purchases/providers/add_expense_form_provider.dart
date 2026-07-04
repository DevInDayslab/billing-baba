import 'package:billing_baba/features/purchases/models/expense_form_model.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/providers/expenses_provider.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_expense_form_provider.g.dart';

int _expenseLineItemCounter = 0;

String _nextExpenseLineItemId() {
  _expenseLineItemCounter += 1;
  return 'expense_line_$_expenseLineItemCounter';
}

@riverpod
class AddExpenseForm extends _$AddExpenseForm {
  @override
  AddExpenseFormState build() {
    final transactions = ref.watch(expenseTransactionsProvider);
    final now = DateTime.now();
    final expenseNumber = generateNextExpenseNumber(
      transactions.map((t) => t.transactionNo).toList(),
    );

    return AddExpenseFormState(
      expenseNumber: expenseNumber,
      expenseDate: DateTime(now.year, now.month, now.day),
      expenseTime: TimeOfDay.fromDateTime(now),
      dueDate: DateTime(now.year, now.month, now.day),
      items: [ExpenseLineItem.empty(id: _nextExpenseLineItemId())],
    );
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

  void updateParty(String value) {
    state = state.copyWith(party: value, isDirty: true);
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

  bool save() {
    if (!validate()) return false;

    final categoryId = state.categoryId.isNotEmpty
        ? state.categoryId
        : state.category.trim().toLowerCase().replaceAll(' ', '_');

    final categories = ref.read(expenseCategoriesProvider);
    if (!categories.any((c) => c.id == categoryId)) {
      ref
          .read(expenseCategoriesProvider.notifier)
          .addCategory(
            ExpenseCategoryModel(
              id: categoryId,
              name: state.category.trim(),
              type: ExpenseCategoryType.direct,
              variant: ExpenseCategoryVariant.standard,
              totalAmount: 0,
              balance: 0,
            ),
          );
    }

    final date = state.expenseDate ?? DateTime.now();
    final time = state.expenseTime ?? TimeOfDay.now();
    final expenseDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final grandTotal = state.grandTotal;
    final paid = state.paymentAmount > 0 ? state.paymentAmount : grandTotal;
    final balance = grandTotal - paid;

    final status = balance <= 0
        ? ExpenseStatus.paid
        : paid > 0
        ? ExpenseStatus.partial
        : ExpenseStatus.pending;

    final transaction = ExpenseTransactionModel(
      id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
      categoryId: categoryId,
      date: expenseDateTime,
      transactionNo: state.expenseNumber,
      party: state.party.trim().isNotEmpty ? state.party.trim() : '—',
      paymentType: state.paymentType,
      amount: grandTotal,
      balance: balance,
      dueDate: state.dueDate ?? expenseDateTime,
      status: status,
    );

    ref.read(expenseTransactionsProvider.notifier).addTransaction(transaction);
    ref
        .read(expenseCategoriesProvider.notifier)
        .updateCategoryTotals(categoryId, grandTotal, balance);

    for (final item in state.items) {
      if (item.itemName.trim().isEmpty || item.qty <= 0) continue;
      ref
          .read(expenseItemsProvider.notifier)
          .upsertItem(
            ExpenseItemModel(
              id: item.id,
              name: item.itemName.trim(),
              category: state.category,
              amount: item.amount,
              description: item.description.trim(),
            ),
          );
    }

    ref.invalidateSelf();
    return true;
  }
}

@riverpod
double addExpenseGrandTotal(Ref ref) {
  final form = ref.watch(addExpenseFormProvider);
  return form.grandTotal;
}

@riverpod
double addExpenseTotalTax(Ref ref) {
  final form = ref.watch(addExpenseFormProvider);
  return form.totalTax;
}

@riverpod
List<String> expenseCategoryOptions(Ref ref) {
  final categories = ref.watch(expenseCategoriesProvider);
  return categories.map((c) => c.name).toList();
}
