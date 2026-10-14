import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/application/sale_order_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_order_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileAddSaleOrderPage extends ConsumerStatefulWidget {
  const MobileAddSaleOrderPage({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<MobileAddSaleOrderPage> createState() =>
      _MobileAddSaleOrderPageState();
}

class _MobileAddSaleOrderPageState
    extends ConsumerState<MobileAddSaleOrderPage> {
  static const MobileDocumentVisibility _visibility =
      MobileDocumentVisibility.saleOrder;
  late final String _sessionKey;
  late final TextEditingController _descriptionController;
  late final TextEditingController _termsTextController;

  @override
  void initState() {
    super.initState();
    _sessionKey = widget.orderId ?? 'mobile_sale_order_new';
    _descriptionController = TextEditingController();
    _termsTextController = TextEditingController();
    if (widget.orderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(saleOrderFormProvider(sessionKey: _sessionKey).notifier)
            .loadDocument(widget.orderId!);
        if (!mounted) return;
        final form = ref.read(saleOrderFormProvider(sessionKey: _sessionKey));
        _descriptionController.text = form.description;
        _termsTextController.text = form.termsText;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _termsTextController.dispose();
    super.dispose();
  }

  SaleOrderFormState _form() =>
      ref.watch(saleOrderFormProvider(sessionKey: _sessionKey));

  SaleOrderFormNotifier _notifier() =>
      ref.read(saleOrderFormProvider(sessionKey: _sessionKey).notifier);

  Future<bool> _handleClose() async {
    return showCloseFormDialog(context, title: 'Close Sale Order');
  }

  Future<void> _pickParty() async {
    final party = await pickMobileDocumentParty(
      context,
      title: 'Select customer',
    );
    if (party != null) {
      _notifier().updatePartyWithId(partyId: party.id, partyName: party.name);
    }
  }

  Future<void> _addLine() async {
    final result = await pickMobileDocumentItem(context);
    if (result == null) return;
    final items = _form().items;
    final lastEmpty = items.isNotEmpty && items.last.itemName.trim().isEmpty;
    if (!lastEmpty) _notifier().addLineItem();
    final index = _form().items.length - 1;
    _notifier().updateLineItem(
      index,
      SaleLineItem(
        id: _form().items[index].id,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final form = _form();
    final docId = form.documentId;
    if (docId != null && docId.isNotEmpty) {
      await DocumentPrintActions.print(
        context,
        ref,
        PrintRequest.saleOrder(docId),
      );
      if (!mounted) return;
    }
    if (saveAndNew) {
      ref.invalidate(saleOrderFormProvider(sessionKey: _sessionKey));
      _descriptionController.clear();
      _termsTextController.clear();
      return;
    }
    await leaveTransactionFormPage(
      context: context,
      isDirty: false,
      isSaving: false,
      listRoute: AppRoutes.saleOrder,
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
      title: widget.orderId != null ? 'Edit Sale Order' : 'Sale Order',
      visibility: _visibility,
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      onClose: _handleClose,
      onSave: () => unawaited(_save(saveAndNew: false)),
      onSaveAndNew: () => unawaited(_save(saveAndNew: true)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (form.saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                form.saveError!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          MobileDocumentHeader(
            visibility: _visibility,
            documentNumberLabel: 'Order No.',
            documentNumberValue: resolveDocumentNumberDisplay(
              documentId: form.documentId,
              currentNumber: form.orderNo,
              preview: watchDocumentNumberPreview(
                ref,
                SalesConstants.saleOrderSeries,
              ),
            ),
            documentNumberIsPlaceholder: false,
            dateValue: formatSaleSingleDate(form.orderDate),
            dateIsPlaceholder: form.orderDate == null,
            onDateTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.orderDate,
              );
              if (date != null) notifier.updateOrderDate(date);
            },
            timeValue: formatSaleTime(form.orderTime),
            timeIsPlaceholder: form.orderTime == null,
            onTimeTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: form.orderTime ?? TimeOfDay.now(),
              );
              if (picked != null) notifier.updateOrderTime(picked);
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
          MobileDocumentPartySection(
            visibility: _visibility,
            useInlinePartySearch: false,
            partyValue: form.party,
            partyHasError: form.partyHasError,
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
                      '${item.qty} × ${MobileDocumentItemsSection.formatAmount(ref, item.pricePerUnit)}',
                  amountLabel: MobileDocumentItemsSection.formatAmount(ref, 
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
            totalAmount: form.total,
            subtotal: form.subtotal,
            taxAmount: form.taxAmount,
            roundOff: form.roundOff,
            onRoundOffChanged: (v) => notifier.toggleRoundOff(value: v),
          ),
          const SizedBox(height: AppSpacing.xl),
          MobileDocumentNotesAttachmentsSection(
            visibility: _visibility,
            descriptionController: _descriptionController,
            onDescriptionChanged: notifier.updateDescription,
            termsTitle: form.termsTitle,
            termsTextController: _termsTextController,
            onTermsTitleTap: () async {
              final picked = await pickMobileTermsTitle(
                context,
                selected: form.termsTitle,
              );
              if (picked != null) notifier.updateTermsTitle(picked);
            },
            onTermsTextChanged: notifier.updateTermsText,
            images: form.attachedImages,
            documents: form.attachedDocuments,
            onAddImage: () => unawaited(
              transactionAddImage(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.saleOrder.apiValue,
                entityId: form.documentId,
                onAdded: notifier.addImage,
              ),
            ),
            onAddDocument: () => unawaited(
              transactionAddDocument(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.saleOrder.apiValue,
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
