import 'package:collection/collection.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/application/add_expense_form_provider.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/models/expense_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddExpensePage extends ConsumerStatefulWidget {
  const MobileAddExpensePage({super.key, this.expenseId});

  final String? expenseId;

  @override
  ConsumerState<MobileAddExpensePage> createState() =>
      _MobileAddExpensePageState();
}

class _MobileAddExpensePageState extends ConsumerState<MobileAddExpensePage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory(AddExpenseForm notifier) async {
    final categories = await ref.read(expenseCategoriesProvider.future);
    final manual = categories.where((c) => c.variant.isManual).toList();
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            for (final category in manual)
              ListTile(
                title: Text(category.name),
                onTap: () => Navigator.pop(context, category.name),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    final match = manual.where((c) => c.name == picked).firstOrNull;
    if (match != null) {
      notifier.updateCategory(id: match.id, name: match.name);
    }
  }

  Future<void> _pickParty(AddExpenseForm notifier) async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.supplier,
      title: 'Select supplier',
    );
    if (party != null) {
      notifier.updateParty(party.name, partyId: party.id);
    }
  }

  Future<void> _pickPaymentType(AddExpenseForm notifier) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            for (final type in SaleDropdownOptions.paymentTypes)
              ListTile(
                title: Text(type),
                onTap: () => Navigator.pop(context, type),
              ),
          ],
        ),
      ),
    );
    if (picked != null) notifier.updatePaymentType(picked);
  }

  Future<void> _addLine(AddExpenseForm notifier) async {
    final result = await showMobileItemPickerSheet(context);
    if (result == null) return;
    final items = ref.read(
      addExpenseFormProvider(expenseId: widget.expenseId),
    ).items;
    final index = items.isEmpty ? 0 : items.length - 1;
    final line = items[index];
    notifier.updateLineItem(
      index,
      line.copyWith(
        itemName: result.item.name,
        description: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
      ),
    );
    if (items.length > 1 && items.last.itemName.isEmpty) {
      notifier.removeLineItem(items.length - 1);
    }
  }

  Future<void> _save(AddExpenseForm notifier) async {
    final error = await notifier.saveExpense();
    showMobileFormResult(
      context,
      error: error,
      successMessage: 'Expense saved',
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addExpenseFormProvider(expenseId: widget.expenseId));
    final notifier = ref.read(
      addExpenseFormProvider(expenseId: widget.expenseId).notifier,
    );
    final isEdit = widget.expenseId != null;

    if (_descriptionController.text != form.description) {
      _descriptionController.text = form.description;
    }
    final paymentAmount = form.paymentAmount > 0
        ? form.paymentAmount.toStringAsFixed(2)
        : form.grandTotal.toStringAsFixed(2);
    if (_amountController.text != paymentAmount && !form.isLoading) {
      _amountController.text = paymentAmount;
    }

    final lines = form.items
        .where((item) => item.itemName.trim().isNotEmpty)
        .map(
          (item) => MobileLineItemDisplay(
            title: item.itemName,
            quantity: item.qty,
            unitPrice: item.pricePerUnit,
            total: item.amount,
          ),
        )
        .toList();

    return MobileFormScaffold(
      title: isEdit ? 'Edit expense' : 'Add expense',
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      loadingLabel: isEdit ? 'Updating expense…' : 'Saving expense…',
      primaryActionLabel: 'Save expense',
      onPrimaryAction: () => _save(notifier),
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: form.isDirty,
        isSaving: form.isSaving,
        listRoute: AppRoutes.purchaseExpenses,
      ),
      topBanner: const MobileOfflineBanner(
        message: 'Expense sync needs internet when online-only fields are used.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (form.saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                form.saveError!,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySize,
                  color: AppColors.error,
                ),
              ),
            ),
          MobileFormSection(
            title: 'Details',
            children: [
              MobileFormPickerField(
                label: 'Category',
                value: form.category,
                errorText: form.categoryHasError ? 'Required' : null,
                onTap: () => _pickCategory(notifier),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('GST expense (supplier bill)'),
                value: form.gstEnabled,
                onChanged: (value) => notifier.toggleGst(value: value),
              ),
              if (form.gstEnabled)
                MobileFormPickerField(
                  label: 'Supplier',
                  value: form.party,
                  errorText: form.partyHasError ? 'Required' : null,
                  onTap: () => _pickParty(notifier),
                ),
              MobileFormPickerField(
                label: 'Date',
                value: form.expenseDate != null
                    ? _dateFormat.format(form.expenseDate!)
                    : '',
                onTap: () async {
                  final date = await showMobileDatePicker(
                    context,
                    initialDate: form.expenseDate,
                  );
                  if (date != null) notifier.updateExpenseDate(date);
                },
              ),
              MobileFormTextField(
                label: 'Notes',
                controller: _descriptionController,
                onChanged: notifier.updateDescription,
                maxLines: 3,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileLineItemsEditor(
            lines: lines,
            onAdd: () => _addLine(notifier),
            onRemove: notifier.removeLineItem,
            emptyMessage: form.gstEnabled
                ? 'Add bill line items.'
                : 'Add an item or enter amount below.',
          ),
          if (!form.gstEnabled)
            MobileFormTextField(
              label: 'Amount',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0;
                notifier.updatePaymentAmount(amount);
                if (form.items.isNotEmpty) {
                  notifier.updateLineItem(
                    0,
                    form.items.first.copyWith(
                      itemName: form.category.isNotEmpty
                          ? form.category
                          : 'Expense',
                      qty: 1,
                      pricePerUnit: amount,
                    ),
                  );
                }
              },
            ),
          MobileFormPickerField(
            label: 'Payment mode',
            value: form.paymentType,
            onTap: () => _pickPaymentType(notifier),
          ),
          MobileDocumentSummaryCard(
            subtotal: form.subtotal,
            tax: form.totalTax,
            total: form.grandTotal,
          ),
        ],
      ),
    );
  }
}
