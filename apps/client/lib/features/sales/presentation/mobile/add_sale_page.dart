import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/sales/application/add_sale_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddSalePage extends ConsumerStatefulWidget {
  const MobileAddSalePage({
    super.key,
    this.invoiceId,
    this.duplicateFromId,
    this.attachOrderIds,
    this.readOnly = false,
  });

  final String? invoiceId;
  final String? duplicateFromId;
  final List<String>? attachOrderIds;
  final bool readOnly;

  @override
  ConsumerState<MobileAddSalePage> createState() => _MobileAddSalePageState();
}

class _MobileAddSalePageState extends ConsumerState<MobileAddSalePage> {
  final _phoneController = TextEditingController();
  final _dateFormat = DateFormat('dd MMM yyyy');
  late final String _sessionKey;

  @override
  void initState() {
    super.initState();
    _sessionKey = widget.invoiceId ?? 'mobile_sale_new';
    if (widget.invoiceId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addSaleFormProvider(sessionKey: _sessionKey).notifier)
            .loadDocument(widget.invoiceId!);
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  AddSaleFormState _form() =>
      ref.watch(addSaleFormProvider(sessionKey: _sessionKey));

  AddSaleForm _notifier() =>
      ref.read(addSaleFormProvider(sessionKey: _sessionKey).notifier);

  Future<void> _pickParty() async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.customer,
      title: 'Select customer',
    );
    if (party != null) {
      _notifier().updateParty(partyId: party.id, partyName: party.name);
      if (party.phone != null && party.phone!.isNotEmpty) {
        _notifier().updatePhone(party.phone!);
      }
    }
  }

  Future<void> _pickPaymentType() async {
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
    if (picked != null) _notifier().updatePaymentType(picked);
  }

  Future<void> _addLine() async {
    final result = await showMobileItemPickerSheet(context);
    if (result == null) return;
    final notifier = _notifier();
    final items = _form().items;
    final lastEmpty =
        items.isNotEmpty && items.last.itemName.trim().isEmpty;
    int targetIndex;
    if (lastEmpty) {
      targetIndex = items.length - 1;
    } else {
      notifier.addLineItem();
      targetIndex = _form().items.length - 1;
    }
    final lineId = _form().items[targetIndex].id;
    notifier.updateLineItem(
      targetIndex,
      SaleLineItem(
        id: lineId,
        itemId: result.item.id,
        itemName: result.item.name,
        qty: result.quantity,
        pricePerUnit: result.pricePerUnit,
      ),
    );
  }

  Future<void> _saveDraft() async {
    final error = await _notifier().saveDraft();
    showMobileFormResult(context, error: error, successMessage: 'Draft saved');
  }

  Future<void> _finalize() async {
    final result = await _notifier().saveInvoice(finalize: true);
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale finalized')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final form = _form();
    final isEdit = widget.invoiceId != null;

    if (form.phone != _phoneController.text && !form.isLoading) {
      _phoneController.text = form.phone;
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
      title: isEdit ? 'Edit sale' : 'Add sale',
      readOnly: widget.readOnly,
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      loadingLabel: form.isSaving ? 'Saving sale…' : 'Loading…',
      primaryActionLabel: 'Finalize',
      secondaryActionLabel: 'Save draft',
      onPrimaryAction: widget.readOnly ? null : _finalize,
      onSecondaryAction: widget.readOnly ? null : _saveDraft,
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: form.isDirty,
        isSaving: form.isSaving,
        listRoute: AppRoutes.saleInvoices,
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
            title: 'Customer',
            children: [
              MobileFormPickerField(
                label: 'Party',
                value: form.billingName,
                errorText: form.partyHasError ? 'Required to finalize' : null,
                onTap: widget.readOnly ? () {} : _pickParty,
              ),
              MobileFormTextField(
                label: 'Phone',
                controller: _phoneController,
                readOnly: widget.readOnly,
                keyboardType: TextInputType.phone,
                onChanged: _notifier().updatePhone,
              ),
              MobileFormPickerField(
                label: 'Invoice date',
                value: form.invoiceDate != null
                    ? _dateFormat.format(form.invoiceDate!)
                    : '',
                onTap: widget.readOnly
                    ? () {}
                    : () async {
                        final date = await showMobileDatePicker(
                          context,
                          initialDate: form.invoiceDate,
                        );
                        if (date != null) _notifier().updateInvoiceDate(date);
                      },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileLineItemsEditor(
            lines: lines,
            onAdd: widget.readOnly ? () {} : _addLine,
            onRemove: widget.readOnly ? (_) {} : _notifier().removeLineItem,
          ),
          if (!widget.readOnly)
            MobileFormPickerField(
              label: 'Payment mode',
              value: form.paymentType,
              onTap: _pickPaymentType,
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
