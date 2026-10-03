import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/add_purchase_order_form_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileAddPurchaseOrderPage extends ConsumerStatefulWidget {
  const MobileAddPurchaseOrderPage({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<MobileAddPurchaseOrderPage> createState() =>
      _MobileAddPurchaseOrderPageState();
}

class _MobileAddPurchaseOrderPageState
    extends ConsumerState<MobileAddPurchaseOrderPage> {
  static const MobileDocumentVisibility _visibility =
      MobileDocumentVisibility.purchaseOrder;
  late final TextEditingController _descriptionController;
  late final TextEditingController _termsTextController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _termsTextController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(
        addPurchaseOrderFormProvider(orderId: widget.orderId),
      );
      _descriptionController.text = form.description;
      _termsTextController.text = form.termsNotes;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _termsTextController.dispose();
    super.dispose();
  }

  AddPurchaseOrderFormState _form() =>
      ref.watch(addPurchaseOrderFormProvider(orderId: widget.orderId));

  AddPurchaseOrderForm _notifier() => ref.read(
    addPurchaseOrderFormProvider(orderId: widget.orderId).notifier,
  );

  Future<bool> _handleClose() async {
    if (_form().isSaving) return false;
    return showCloseFormDialog(context, title: 'Close Purchase Order');
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
      PurchaseLineItem(
        id: _form().items[i].id,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
        unit: result.item.baseUnitShortName ?? 'NONE',
        taxPercent: result.item.defaultTaxRate ?? 0,
      ),
    );
  }

  Future<void> _save({required bool saveAndNew}) async {
    final error = await _notifier().saveOrder();
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
        PrintRequest.purchaseOrder(docId),
      );
      if (!mounted) return;
    }
    if (saveAndNew) {
      ref.invalidate(addPurchaseOrderFormProvider(orderId: widget.orderId));
      _descriptionController.clear();
      _termsTextController.clear();
      return;
    }
    await leaveTransactionFormPage(
      context: context,
      isDirty: false,
      isSaving: false,
      listRoute: AppRoutes.purchaseOrder,
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
      title: widget.orderId != null ? 'Edit Purchase Order' : 'Purchase Order',
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
            Text(
              form.saveError!,
              style: const TextStyle(color: AppColors.error),
            ),
          MobileDocumentHeader(
            visibility: _visibility,
            documentNumberLabel: 'Order No.',
            documentNumberValue: resolveDocumentNumberDisplay(
              documentId: form.documentId,
              currentNumber: form.orderNumber,
              preview: watchDocumentNumberPreview(
                ref,
                PurchaseConstants.purchaseOrderSeries,
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
            totalAmount: form.grandTotal,
            subtotal: form.subtotal,
            taxAmount: form.totalTax,
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
            onTermsTextChanged: notifier.updateTermsNotes,
            images: form.attachedImages,
            documents: form.attachedDocuments,
            onAddImage: () => unawaited(
              transactionAddImage(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.purchaseOrder.apiValue,
                entityId: form.documentId,
                onAdded: notifier.addImage,
              ),
            ),
            onAddDocument: () => unawaited(
              transactionAddDocument(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.purchaseOrder.apiValue,
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
