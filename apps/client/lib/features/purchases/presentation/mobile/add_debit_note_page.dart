import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/debit_note_form_provider.dart';
import 'package:billing_baba/features/purchases/models/debit_note_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class MobileAddDebitNotePage extends ConsumerStatefulWidget {
  const MobileAddDebitNotePage({super.key, this.debitNoteId});

  final String? debitNoteId;

  @override
  ConsumerState<MobileAddDebitNotePage> createState() =>
      _MobileAddDebitNotePageState();
}

class _MobileAddDebitNotePageState
    extends ConsumerState<MobileAddDebitNotePage> {
  static const MobileDocumentVisibility _visibility =
      MobileDocumentVisibility.debitNote;
  late final TextEditingController _descriptionController;
  late final TextEditingController _billNumberController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _billNumberController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(
        debitNoteFormProvider(debitNoteId: widget.debitNoteId),
      );
      _descriptionController.text = form.description;
      _billNumberController.text = form.billNumber;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _billNumberController.dispose();
    super.dispose();
  }

  DebitNoteFormState _form() =>
      ref.watch(debitNoteFormProvider(debitNoteId: widget.debitNoteId));

  DebitNoteForm _notifier() =>
      ref.read(debitNoteFormProvider(debitNoteId: widget.debitNoteId).notifier);

  Future<bool> _handleClose() async {
    if (_form().isSaving) return false;
    return showCloseFormDialog(context, title: 'Close Purchase Return');
  }

  Future<void> _pickParty() async {
    final party = await pickMobileDocumentParty(
      context,
      typeFilter: PartyTypeFilter.supplier,
      title: 'Select supplier',
    );
    if (party != null) {
      _notifier().updateParty(party.name, partyId: party.id);
    }
  }

  Future<void> _addLine() async {
    final result = await pickMobileDocumentItem(context);
    if (result == null) return;
    final notifier = _notifier();
    final items = _form().items;
    final lastEmpty = items.isNotEmpty && items.last.itemName.trim().isEmpty;
    if (!lastEmpty) notifier.addLineItem();
    final i = _form().items.length - 1;
    notifier.updateLineItem(
      i,
      SaleLineItem(
        id: _form().items[i].id,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
        unit: result.item.baseUnitShortName ?? 'NONE',
        taxPercent: result.item.defaultTaxRate ?? 0,
        mrp: result.item.mrp ?? 0,
        isConfirmed: true,
      ),
    );
  }

  Future<void> _save({required bool saveAndNew}) async {
    final error = await _notifier().saveDebitNote();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final docId = _form().documentId;
    if (docId != null && docId.isNotEmpty) {
      await DocumentPrintActions.print(
        context,
        ref,
        PrintRequest.debitNote(docId),
      );
      if (!mounted) return;
    }
    if (saveAndNew) {
      ref.invalidate(debitNoteFormProvider(debitNoteId: widget.debitNoteId));
      _descriptionController.clear();
      return;
    }
    await leaveTransactionFormPage(
      context: context,
      isDirty: false,
      isSaving: false,
      listRoute: AppRoutes.purchaseReturnDebitNote,
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = _form();
    final notifier = _notifier();
    final confirmed = form.items
        .where((item) => item.itemName.trim().isNotEmpty)
        .toList();

    return MobileDocumentFormScaffold(
      title: widget.debitNoteId != null
          ? 'Edit Purchase Return'
          : 'Purchase Return',
      visibility: _visibility,
      isSaving: form.isSaving,
      onClose: _handleClose,
      onSave: () => unawaited(_save(saveAndNew: false)),
      onSaveAndNew: () => unawaited(_save(saveAndNew: true)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (form.saveError != null)
            Text(
              form.saveError!,
              style: const TextStyle(color: AppColors.error),
            ),
          MobileDocumentHeader(
            visibility: _visibility,
            documentNumberLabel: 'Return No.',
            documentNumberValue: form.returnNo.isEmpty ? 'Auto' : form.returnNo,
            documentNumberIsPlaceholder: form.returnNo.isEmpty,
            dateValue: formatSaleSingleDate(form.returnDate),
            dateIsPlaceholder: form.returnDate == null,
            onDateTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.returnDate,
              );
              if (date != null) notifier.updateReturnDate(date);
            },
            timeValue: formatSaleTime(form.returnTime),
            timeIsPlaceholder: form.returnTime == null,
            onTimeTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: form.returnTime ?? TimeOfDay.now(),
              );
              if (picked != null) notifier.updateReturnTime(picked);
            },
            stateOfSupplyValue: form.stateOfSupply,
            onStateOfSupplyTap: () async {
              final selected = await showMobileOptionSheet<String>(
                context: context,
                title: 'State of supply',
                selected: form.stateOfSupply,
                options: [
                  for (final state in SaleDropdownOptions.indianStates)
                    MobileOption(value: state, label: state),
                ],
              );
              if (selected != null) notifier.updateStateOfSupply(selected);
            },
            godownValue: form.godown,
            onGodownTap: () async {
              final godowns = ref.read(inventoryGodownsProvider).value ?? [];
              final options = godowns.isNotEmpty
                  ? godowns.map((g) => g.name).toList()
                  : SaleDropdownOptions.godowns;
              final selected = await showMobileOptionSheet<String>(
                context: context,
                title: 'Godown',
                selected: form.godown,
                options: [
                  for (final name in options)
                    MobileOption(value: name, label: name),
                ],
              );
              if (selected == null) return;
              final match = godowns
                  .where((g) => g.name == selected)
                  .firstOrNull;
              notifier.updateGodown(selected, godownId: match?.id);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Bill Number',
            controller: _billNumberController,
            hintText: 'Original bill number',
            onChanged: notifier.updateBillNumber,
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileSalePickerField(
            label: 'Bill Date',
            value: form.billDate != null
                ? formatSaleSingleDate(form.billDate)
                : 'Select date',
            isPlaceholder: form.billDate == null,
            trailingIcon: LucideIcons.calendar,
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.billDate ?? form.returnDate,
              );
              if (date != null) notifier.updateBillDate(date);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileDocumentPartySection(
            visibility: _visibility,
            useInlinePartySearch: false,
            partyLabel: 'Supplier',
            partyValue: form.party,
            partyHasError: form.partyHasError,
            partyTypeFilter: PartyTypeFilter.supplier,
            onPickParty: () => unawaited(_pickParty()),
          ),
          const SizedBox(height: AppSpacing.xl),
          MobileDocumentItemsSection(
            visibility: _visibility,
            lines: [
              for (final item in confirmed)
                MobileDocumentLineDisplay(
                  name: item.itemName,
                  qtyLabel:
                      '${item.qty} × ₹${MobileDocumentItemsSection.formatAmount(item.pricePerUnit)}',
                  amountLabel: MobileDocumentItemsSection.formatAmount(
                    item.amount,
                  ),
                ),
            ],
            onAddItems: () => unawaited(_addLine()),
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
                fields: MobileDocumentLineEditFields.purchase,
                initial: MobileDocumentLineEditDraft(
                  qty: item.qty,
                  unit: item.unit,
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
                  unit: draft.unit,
                  pricePerUnit: draft.pricePerUnit,
                  taxPercent: draft.taxPercent,
                  description: draft.description,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          MobileDocumentTotalsSection(
            visibility: _visibility,
            totalAmount: form.total,
            roundOff: form.roundOff,
            onRoundOffChanged: (v) => notifier.toggleRoundOff(value: v),
            payments: [
              for (final payment in form.payments)
                (type: payment.type, amount: payment.amount),
            ],
            onPaymentTypeTap: () async {
              final picked = await pickMobilePaymentType(
                context,
                selected: form.payments.isNotEmpty
                    ? form.payments.first.type
                    : 'Cash',
              );
              if (picked != null) notifier.updatePaymentType(picked);
            },
            onPaymentAmountChanged: notifier.updatePaymentAmount,
            onAddPaymentType: notifier.addPaymentType,
          ),
          const SizedBox(height: AppSpacing.xl),
          MobileDocumentNotesAttachmentsSection(
            visibility: _visibility,
            descriptionController: _descriptionController,
            onDescriptionChanged: notifier.updateDescription,
            images: form.attachedImages,
            documents: form.attachedDocuments,
            onAddImage: () => unawaited(
              transactionAddImage(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.purchase.apiValue,
                entityId: form.documentId,
                onAdded: notifier.addImage,
              ),
            ),
            onAddDocument: () => unawaited(
              transactionAddDocument(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.purchase.apiValue,
                entityId: form.documentId,
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
