import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/application/credit_note_form_provider.dart';
import 'package:billing_baba/features/sales/models/credit_note_form_model.dart';
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

class MobileAddCreditNotePage extends ConsumerStatefulWidget {
  const MobileAddCreditNotePage({
    super.key,
    this.creditNoteId,
    this.fromInvoiceId,
  });

  final String? creditNoteId;
  final String? fromInvoiceId;

  @override
  ConsumerState<MobileAddCreditNotePage> createState() =>
      _MobileAddCreditNotePageState();
}

class _MobileAddCreditNotePageState
    extends ConsumerState<MobileAddCreditNotePage> {
  static const MobileDocumentVisibility _visibility = MobileDocumentVisibility.creditNote;
  late final String _sessionKey;
  late final TextEditingController _phoneController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _originalInvoiceController;

  @override
  void initState() {
    super.initState();
    _sessionKey = widget.fromInvoiceId != null
        ? 'from_invoice_${widget.fromInvoiceId}'
        : widget.creditNoteId ?? 'mobile_credit_new';
    _phoneController = TextEditingController();
    _descriptionController = TextEditingController();
    _originalInvoiceController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.fromInvoiceId != null) {
        await ref
            .read(creditNoteFormProvider(sessionKey: _sessionKey).notifier)
            .loadFromInvoice(widget.fromInvoiceId!);
      } else if (widget.creditNoteId != null) {
        await ref
            .read(creditNoteFormProvider(sessionKey: _sessionKey).notifier)
            .loadDocument(widget.creditNoteId!);
      }
      if (!mounted) return;
      final form = ref.read(creditNoteFormProvider(sessionKey: _sessionKey));
      _phoneController.text = form.phone;
      _descriptionController.text = form.description;
      _originalInvoiceController.text = form.originalInvoiceNo;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _descriptionController.dispose();
    _originalInvoiceController.dispose();
    super.dispose();
  }

  CreditNoteFormState _form() =>
      ref.watch(creditNoteFormProvider(sessionKey: _sessionKey));

  CreditNoteForm _notifier() =>
      ref.read(creditNoteFormProvider(sessionKey: _sessionKey).notifier);

  Future<bool> _handleClose() async {
    if (_form().isSaving) return false;
    return showCloseFormDialog(context, title: 'Close Credit Note');
  }

  Future<void> _pickParty() async {
    final party = await pickMobileDocumentParty(
      context,
      title: 'Select customer',
    );
    if (party != null) {
      _notifier().updatePartyWithId(partyId: party.id, partyName: party.name);
      _phoneController.text = _form().phone;
    }
  }

  Future<void> _addLine() async {
    final result = await pickMobileDocumentItem(context);
    if (result == null) return;
    final notifier = _notifier();
    final items = _form().items;
    final lastEmpty = items.isNotEmpty && items.last.itemName.trim().isEmpty;
    if (!lastEmpty) notifier.addLineItem();
    final targetIndex = _form().items.length - 1;
    notifier.updateLineItem(
      targetIndex,
      SaleLineItem(
        id: _form().items[targetIndex].id,
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
    final error = await _notifier().save();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final form = _form();
    final docId = form.documentId;
    if (docId != null && docId.isNotEmpty) {
      await DocumentPrintActions.print(
        context,
        ref,
        PrintRequest.creditNote(docId),
      );
      if (!mounted) return;
    }
    if (saveAndNew) {
      ref.invalidate(creditNoteFormProvider(sessionKey: _sessionKey));
      _phoneController.clear();
      _descriptionController.clear();
      return;
    }
    await leaveTransactionFormPage(
      context: context,
      isDirty: false,
      isSaving: false,
      listRoute: AppRoutes.saleReturnCreditNote,
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
      title: widget.creditNoteId != null ? 'Edit Credit Note' : 'Sale Return',
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
            documentNumberValue:
                form.returnNo.isEmpty ? 'Auto' : form.returnNo,
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
              final match =
                  godowns.where((g) => g.name == selected).firstOrNull;
              notifier.updateGodown(selected, godownId: match?.id);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Invoice Number',
            controller: _originalInvoiceController,
            hintText: 'Original invoice number',
            onChanged: notifier.updateOriginalInvoiceNo,
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileSalePickerField(
            label: 'Invoice Date',
            value: form.originalInvoiceDate != null
                ? formatSaleSingleDate(form.originalInvoiceDate)
                : 'Select date',
            isPlaceholder: form.originalInvoiceDate == null,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.originalInvoiceDate ?? form.returnDate,
              );
              if (date != null) notifier.updateOriginalInvoiceDate(date);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileDocumentPartySection(
            visibility: _visibility,
            useInlinePartySearch: false,
            partyValue: form.party,
            partyHasError: form.partyHasError,
            onPickParty: () => unawaited(_pickParty()),
            phoneController: _phoneController,
            onPhoneChanged: notifier.updatePhone,
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
                fields: MobileDocumentLineEditFields.sale,
                initial: MobileDocumentLineEditDraft(
                  qty: item.qty,
                  unit: item.unit,
                  pricePerUnit: item.pricePerUnit,
                  discountPercent: item.discountPercent,
                  taxPercent: item.taxPercent,
                  serialNo: item.serialNo,
                  batchNo: item.batchNo,
                  mrp: item.mrp,
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
                  discountPercent: draft.discountPercent,
                  taxPercent: draft.taxPercent,
                  serialNo: draft.serialNo,
                  batchNo: draft.batchNo,
                  mrp: draft.mrp,
                  description: draft.description,
                  priceManuallyOverridden: true,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          MobileDocumentTotalsSection(
            visibility: _visibility,
            totalAmount: form.rawGrandTotal,
            subtotal: form.subtotal,
            taxAmount: form.totalTax,
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
                entityType: DocumentAttachmentEntityType.sale.apiValue,
                entityId: form.documentId,
                onAdded: notifier.addImage,
              ),
            ),
            onAddDocument: () => unawaited(
              transactionAddDocument(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.sale.apiValue,
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
