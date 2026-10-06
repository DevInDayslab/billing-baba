import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:billing_baba/features/hidden_ledger/models/short_payment_handling.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/short_payment_handling_dialog.dart';
import 'package:billing_baba/features/payments/presentation/mobile/widgets/payment_recovery_banner.dart';
import 'package:billing_baba/features/payments/presentation/shared/payment_flow_launcher.dart';
import 'package:billing_baba/features/payments/presentation/shared/payment_intent_builder.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
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

import 'package:lucide_icons_flutter/lucide_icons.dart';

class MobileAddPaymentInPage extends ConsumerStatefulWidget {
  const MobileAddPaymentInPage({
    super.key,
    this.paymentId,
    this.initialPartyId,
    this.initialPartyName,
  });

  final String? paymentId;
  final String? initialPartyId;
  final String? initialPartyName;

  @override
  ConsumerState<MobileAddPaymentInPage> createState() =>
      _MobileAddPaymentInPageState();
}

class _MobileAddPaymentInPageState
    extends ConsumerState<MobileAddPaymentInPage> {
  static const MobileDocumentVisibility _visibility =
      MobileDocumentVisibility.payment;

  final _receivedController = TextEditingController();
  final _discountController = TextEditingController();
  final _receiptController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _savedPaymentId;

  @override
  void dispose() {
    _receivedController.dispose();
    _discountController.dispose();
    _receiptController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(paymentInFormProvider.notifier);
      notifier.reset();
      final partyId = widget.initialPartyId?.trim();
      final partyName = widget.initialPartyName?.trim();
      if (partyId != null &&
          partyId.isNotEmpty &&
          partyName != null &&
          partyName.isNotEmpty) {
        notifier.updateParty(partyName, partyId: partyId);
        unawaited(notifier.refreshBalanceDue());
      }
      final form = ref.read(paymentInFormProvider);
      _receiptController.text = form.receiptNo;
      _descriptionController.text = form.description;
      if (form.discount > 0) {
        _discountController.text = form.discount.toStringAsFixed(2);
      }
    });
  }

  Future<void> _pickParty(PaymentInForm notifier) async {
    final party = await pickMobileDocumentParty(
      context,
      title: 'Select customer',
    );
    if (party != null) {
      notifier.updateParty(party.name, partyId: party.id);
      await notifier.refreshBalanceDue();
    }
  }

  Future<ShortPaymentHandling?> _resolveShortPaymentHandling(
    PaymentInForm notifier,
  ) async {
    await notifier.refreshBalanceDue();
    if (!mounted) return null;

    final form = ref.read(paymentInFormProvider);
    if (!form.hasShortPayment) return ShortPaymentHandling.officialDue;

    return showShortPaymentHandlingDialog(
      context,
      paidAmount: form.receivedAmount + form.discount,
      targetAmount: form.balanceDue,
    );
  }

  Future<void> _save(PaymentInForm notifier) async {
    final payment = notifier.buildPaymentModel();
    if (payment == null) return;

    final form = ref.read(paymentInFormProvider);
    final handling = await _resolveShortPaymentHandling(notifier);
    if (!mounted || handling == null) return;

    final shortfall = form.hasShortPayment
        ? (form.balanceDue - form.receivedAmount - form.discount)
              .clamp(0, double.infinity)
              .toDouble()
        : 0.0;

    final result = await notifier.savePayment(
      shortPaymentHandling: handling.apiValue,
      shortfallAmount: handling == ShortPaymentHandling.hiddenLedger
          ? shortfall
          : null,
    );
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
      await VoucherPrintActions.previewPaymentIn(
        context,
        ref,
        paymentId,
        filename: VoucherPrintActions.filenameFor(payment.receiptNo),
      );
      if (!mounted) return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment ${payment.receiptNo} saved successfully'),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _payOnline(PaymentInForm notifier) async {
    final form = ref.read(paymentInFormProvider);
    final intent = paymentIntentFromPaymentInForm(form);
    if (intent == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a party and enter a received amount first'),
        ),
      );
      return;
    }
    await PaymentFlowLauncher.start(context, ref, intent: intent);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(paymentInFormProvider);
    final notifier = ref.read(paymentInFormProvider.notifier);

    if (_receivedController.text != form.receivedAmount.toStringAsFixed(2) &&
        !form.isSaving) {
      _receivedController.text = form.receivedAmount > 0
          ? form.receivedAmount.toStringAsFixed(2)
          : '';
    }
    if (_receiptController.text != form.receiptNo && !form.isSaving) {
      _receiptController.text = form.receiptNo;
    }
    if (_descriptionController.text != form.description && !form.isSaving) {
      _descriptionController.text = form.description;
    }

    return MobileDocumentFormScaffold(
      title: 'Payment In',
      visibility: _visibility,
      isSaving: form.isSaving,
      onClose: () => showCloseFormDialog(context, title: 'Close Payment In'),
      onSave: () => unawaited(_save(notifier)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MobileOfflineBanner(),
          const PaymentRecoveryBanner(),
          if (form.saveError != null)
            Text(
              form.saveError!,
              style: const TextStyle(color: AppColors.error),
            ),
          MobileDocumentPartySection(
            visibility: _visibility,
            useInlinePartySearch: false,
            partyValue: form.party,
            partyHasError: form.partyHasError,
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
            label: 'Received amount',
            controller: _receivedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            hasError: form.amountHasError,
            errorText: form.amountHasError ? 'Required' : null,
            onChanged: (value) {
              notifier.updateReceivedAmount(double.tryParse(value) ?? 0);
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
          FilledButton.icon(
            onPressed: form.isSaving
                ? null
                : () => unawaited(_payOnline(notifier)),
            icon: const Icon(LucideIcons.banknote, size: 18),
            label: const Text('Pay online (UPI / Card)'),
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
                paymentInDocumentSeries,
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
          MobileSaleFormField(
            label: 'Receipt No',
            controller: _receiptController,
            hintText: 'Receipt number',
            onChanged: notifier.updateReceiptNo,
          ),
          const SizedBox(height: AppSpacing.lg),
          MobileDocumentTotalsSection(
            visibility: _visibility,
            totalAmount: form.receivedAmount + form.discount,
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
                entityType: DocumentAttachmentEntityType.paymentIn.apiValue,
                entityId: _savedPaymentId,
                onAdded: notifier.addImage,
              ),
            ),
            onAddDocument: () => unawaited(
              transactionAddDocument(
                context: context,
                ref: ref,
                entityType: DocumentAttachmentEntityType.paymentIn.apiValue,
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
