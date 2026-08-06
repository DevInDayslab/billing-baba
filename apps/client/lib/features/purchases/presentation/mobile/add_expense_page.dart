import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/application/add_expense_form_provider.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _expenseNumberController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _expenseNumberController.dispose();
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
    final party = await pickMobileDocumentParty(
      context,
      typeFilter: PartyTypeFilter.supplier,
      title: 'Select supplier',
    );
    if (party != null) {
      notifier.updateParty(party.name, partyId: party.id);
    }
  }

  Future<void> _pickPaymentType(AddExpenseForm notifier) async {
    final picked = await pickMobilePaymentType(
      context,
      selected: ref
          .read(addExpenseFormProvider(expenseId: widget.expenseId))
          .paymentType,
    );
    if (picked != null) notifier.updatePaymentType(picked);
  }

  Future<void> _addLine(AddExpenseForm notifier) async {
    final result = await pickMobileDocumentItem(context);
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
    if (_expenseNumberController.text != form.expenseNumber) {
      _expenseNumberController.text = form.expenseNumber;
    }
    final paymentAmount = form.paymentAmount > 0
        ? form.paymentAmount.toStringAsFixed(2)
        : form.grandTotal.toStringAsFixed(2);
    if (_amountController.text != paymentAmount && !form.isLoading) {
      _amountController.text = paymentAmount;
    }

    final visibility = MobileDocumentVisibility(
      showDueDate: form.gstEnabled,
      showPaymentTerms: form.gstEnabled,
      showStateOfSupply: form.gstEnabled,
      showParty: form.gstEnabled,
      showPaymentSection: true,
      showDescription: true,
      showAttachments: true,
      showSaveAndNew: false,
    );

    final confirmed = form.items
        .where((item) => item.itemName.trim().isNotEmpty)
        .toList();

    return MobileDocumentFormScaffold(
      title: isEdit ? 'Edit Expense' : 'Expense',
      visibility: visibility,
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      onClose: () => showCloseFormDialog(context, title: 'Close Expense'),
      onSave: () => unawaited(_save(notifier)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MobileOfflineBanner(
            message:
                'Expense sync needs internet when online-only fields are used.',
          ),
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
              MobileSaleFormField(
                label: 'Expense No',
                controller: _expenseNumberController,
                hintText: 'Expense number',
                onChanged: notifier.updateExpenseNumber,
              ),
              MobileFormPickerField(
                label: form.gstEnabled ? 'Bill Date' : 'Date',
                value: form.expenseDate != null
                    ? formatSaleSingleDate(form.expenseDate)
                    : '',
                onTap: () async {
                  final date = await showMobileDatePicker(
                    context,
                    initialDate: form.expenseDate,
                  );
                  if (date != null) notifier.updateExpenseDate(date);
                },
              ),
              MobileSalePickerField(
                label: 'Time',
                value: formatSaleTime(form.expenseTime),
                isPlaceholder: form.expenseTime == null,
                trailingIcon: Icons.schedule_outlined,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: form.expenseTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) notifier.updateExpenseTime(picked);
                },
              ),
              if (form.gstEnabled) ...[
                MobileFormPickerField(
                  label: 'Payment Terms',
                  value: form.paymentTerms,
                  onTap: () async {
                    final selected = await showMobileOptionSheet<String>(
                      context: context,
                      title: 'Payment Terms',
                      selected: form.paymentTerms,
                      options: [
                        for (final term in SaleDropdownOptions.paymentTerms)
                          MobileOption(value: term, label: term),
                      ],
                    );
                    if (selected != null) {
                      notifier.updatePaymentTerms(selected);
                    }
                  },
                ),
                MobileFormPickerField(
                  label: 'Due Date',
                  value: form.dueDate != null
                      ? formatSaleSingleDate(form.dueDate)
                      : 'Select date',
                  onTap: () async {
                    final date = await showMobileDatePicker(
                      context,
                      initialDate: form.dueDate ?? form.expenseDate,
                    );
                    if (date != null) notifier.updateDueDate(date);
                  },
                ),
                MobileFormPickerField(
                  label: 'State of supply',
                  value: form.stateOfSupply,
                  onTap: () async {
                    final selected = await showMobileOptionSheet<String>(
                      context: context,
                      title: 'State of supply',
                      selected: form.stateOfSupply,
                      options: [
                        for (final state in SaleDropdownOptions.indianStates)
                          MobileOption(value: state, label: state),
                      ],
                    );
                    if (selected != null) {
                      notifier.updateStateOfSupply(selected);
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileDocumentItemsSection(
            visibility: visibility,
            lines: [
              for (final item in confirmed)
                MobileDocumentLineDisplay(
                  name: item.itemName,
                  qtyLabel:
                      '${item.qty} × ₹${MobileDocumentItemsSection.formatAmount(item.pricePerUnit)}',
                  amountLabel:
                      MobileDocumentItemsSection.formatAmount(item.amount),
                ),
            ],
            onAddItems: () => unawaited(_addLine(notifier)),
            onRemoveLine: (i) {
              final index = form.items.indexWhere(
                (item) => item.id == confirmed[i].id,
              );
              if (index >= 0) notifier.removeLineItem(index);
            },
            onLineTap: (i) async {
              final item = confirmed[i];
              final index = form.items.indexWhere((e) => e.id == item.id);
              if (index < 0) return;
              final draft = await showMobileDocumentLineEditSheet(
                context: context,
                itemName: item.itemName,
                fields: MobileDocumentLineEditFields.expense,
                initial: MobileDocumentLineEditDraft(
                  qty: item.qty,
                  unit: 'NONE',
                  pricePerUnit: item.pricePerUnit,
                  taxPercent: item.taxPercent,
                  description: item.description,
                ),
              );
              if (draft == null || !mounted) return;
              notifier.updateLineItem(
                index,
                item.copyWith(
                  qty: draft.qty,
                  pricePerUnit: draft.pricePerUnit,
                  taxPercent: draft.taxPercent,
                  description: draft.description,
                ),
              );
            },
          ),
          if (!form.gstEnabled) ...[
            const SizedBox(height: AppSpacing.lg),
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
          ],
          const SizedBox(height: AppSpacing.lg),
          MobileDocumentTotalsSection(
            visibility: visibility,
            totalAmount: form.grandTotal,
            subtotal: form.subtotal,
            taxAmount: form.totalTax,
            paymentType: form.paymentType,
            onPaymentTypeTap: () => _pickPaymentType(notifier),
          ),
          const SizedBox(height: AppSpacing.xl),
          MobileDocumentNotesAttachmentsSection(
            visibility: visibility,
            descriptionController: _descriptionController,
            onDescriptionChanged: notifier.updateDescription,
            images: form.attachedImages,
            documents: form.attachedDocuments,
            onAddImage: () => unawaited(
              transactionAddImage(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.expense.apiValue,
                entityId: form.expenseId,
                onAdded: notifier.addImage,
              ),
            ),
            onAddDocument: () => unawaited(
              transactionAddDocument(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.expense.apiValue,
                entityId: form.expenseId,
                onAdded: notifier.addDocument,
              ),
            ),
            onRemoveImage: notifier.removeImage,
            onRemoveDocument: notifier.removeDocument,
          ),
        ],
      ),
    );
  }
}
