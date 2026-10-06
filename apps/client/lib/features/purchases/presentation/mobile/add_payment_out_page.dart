import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileAddPaymentOutPage extends ConsumerStatefulWidget {
  const MobileAddPaymentOutPage({
    super.key,
    this.paymentId,
    this.initialPartyId,
    this.initialPartyName,
  });

  final String? paymentId;
  final String? initialPartyId;
  final String? initialPartyName;

  @override
  ConsumerState<MobileAddPaymentOutPage> createState() =>
      _MobileAddPaymentOutPageState();
}

class _MobileAddPaymentOutPageState
    extends ConsumerState<MobileAddPaymentOutPage> {
  static const MobileDocumentVisibility _visibility =
      MobileDocumentVisibility.payment;

  final _paidController = TextEditingController();
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _savedPaymentId;

  @override
  void dispose() {
    _paidController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(paymentOutFormProvider.notifier);
      notifier.reset();
      final partyId = widget.initialPartyId?.trim();
      final partyName = widget.initialPartyName?.trim();
      if (partyId != null &&
          partyId.isNotEmpty &&
          partyName != null &&
          partyName.isNotEmpty) {
        unawaited(notifier.updateParty(partyName, partyId: partyId));
      }
      final form = ref.read(paymentOutFormProvider);
      _descriptionController.text = form.description;
      if (form.discount > 0) {
        _discountController.text = form.discount.toStringAsFixed(2);
      }
      if (form.paidAmount > 0) {
        _paidController.text = form.paidAmount.toStringAsFixed(2);
      }
    });
  }

  Future<void> _pickParty(PaymentOutForm notifier) async {
    final party = await pickMobileDocumentParty(
      context,
      typeFilter: PartyTypeFilter.supplier,
      title: 'Select supplier',
    );
    if (party != null) {
      await notifier.updateParty(party.name, partyId: party.id);
    }
  }

  Future<void> _save(PaymentOutForm notifier) async {
    final receiptNo = ref.read(paymentOutFormProvider).receiptNo;
    final result = await notifier.savePayment(showSuccessMessage: false);
    if (!mounted) return;

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }

    final paymentId = result.paymentId;
    if (paymentId != null) {
      _savedPaymentId = paymentId;
      await VoucherPrintActions.previewPaymentOut(
        context,
        ref,
        paymentId,
        filename: VoucherPrintActions.filenameFor(receiptNo),
      );
      if (!mounted) return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment $receiptNo saved successfully')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(paymentOutFormProvider);
    final notifier = ref.read(paymentOutFormProvider.notifier);

    if (_paidController.text != form.paidAmount.toStringAsFixed(2) &&
        !form.isSaving) {
      _paidController.text = form.paidAmount > 0
          ? form.paidAmount.toStringAsFixed(2)
          : '';
    }
    if (_descriptionController.text != form.description && !form.isSaving) {
      _descriptionController.text = form.description;
    }

    return MobileDocumentFormScaffold(
      title: 'Payment Out',
      visibility: _visibility,
      isSaving: form.isSaving,
      onClose: () => showCloseFormDialog(context, title: 'Close Payment Out'),
      onSave: () => unawaited(_save(notifier)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MobileOfflineBanner(),
          if (form.saveError != null)
            Text(
              form.saveError!,
              style: const TextStyle(color: AppColors.error),
            ),
          MobileDocumentPartySection(
            visibility: _visibility,
            useInlinePartySearch: false,
            partyLabel: 'Supplier',
            partyValue: form.party,
            partyHasError: form.partyHasError,
            partyTypeFilter: PartyTypeFilter.supplier,
            onPickParty: () => unawaited(_pickParty(notifier)),
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Balance due',
            hintText: '₹ ${form.balanceDue.toStringAsFixed(2)}',
            readOnly: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Paid amount',
            controller: _paidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            hasError: form.amountHasError,
            errorText: form.amountHasError ? 'Required' : null,
            onChanged: (value) {
              notifier.updatePaidAmount(double.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Discount',
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            onChanged: (value) {
              notifier.updateDiscount(double.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileDocumentHeader(
            visibility: _visibility,
            documentNumberLabel: 'Receipt No',
            documentNumberValue: resolveDocumentNumberDisplay(
              documentId: null,
              currentNumber: form.receiptNo,
              preview: watchDocumentNumberPreview(
                ref,
                paymentOutDocumentSeries,
              ),
              forceAuto: isUnsetDocumentNumber(form.receiptNo),
            ),
            documentNumberIsPlaceholder: false,
            dateValue: formatSaleSingleDate(form.date),
            dateIsPlaceholder: form.date == null,
            onDateTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.date,
              );
              if (date != null) notifier.updateDate(date);
            },
            timeValue: formatSaleTime(form.time),
            timeIsPlaceholder: form.time == null,
            onTimeTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: form.time ?? TimeOfDay.now(),
              );
              if (picked != null) notifier.updateTime(picked);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileDocumentTotalsSection(
            visibility: _visibility,
            totalAmount: form.total,
            paymentType: form.paymentType,
            onPaymentTypeTap: () async {
              final picked = await pickMobilePaymentType(
                context,
                selected: form.paymentType,
              );
              if (picked != null) notifier.updatePaymentType(picked);
            },
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
                entityType: DocumentAttachmentEntityType.paymentOut.apiValue,
                entityId: _savedPaymentId,
                onAdded: notifier.addImage,
              ),
            ),
            onAddDocument: () => unawaited(
              transactionAddDocument(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.paymentOut.apiValue,
                entityId: _savedPaymentId,
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
