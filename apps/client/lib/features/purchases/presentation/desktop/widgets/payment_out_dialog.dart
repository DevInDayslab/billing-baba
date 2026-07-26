import 'dart:async';

import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/document_attachment_providers.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/transaction_form_busy_overlay.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

/// Shows the Payment-Out modal from the Payment-Out page.
/// Returns `true` when a payment was saved successfully.
Future<bool> showPaymentOutDialog(
  BuildContext context, {
  String? initialPartyId,
  String? initialPartyName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: PaymentOutDialog(
        initialPartyId: initialPartyId,
        initialPartyName: initialPartyName,
      ),
    ),
  ).then((saved) => saved ?? false);
}

class PaymentOutDialog extends ConsumerStatefulWidget {
  const PaymentOutDialog({
    super.key,
    this.initialPartyId,
    this.initialPartyName,
  });

  final String? initialPartyId;
  final String? initialPartyName;

  @override
  ConsumerState<PaymentOutDialog> createState() => _PaymentOutDialogState();
}

class _PaymentOutDialogState extends ConsumerState<PaymentOutDialog> {
  final _datePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _paidController = TextEditingController();
  final _discountController = TextEditingController();
  String? _savedPaymentId;

  static final _amountFormat = NumberFormat('#,##0.##', 'en_IN');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(paymentOutFormProvider.notifier);
      notifier.reset();
      if (widget.initialPartyId != null && widget.initialPartyId!.isNotEmpty) {
        notifier.updateParty(
          widget.initialPartyName ?? '',
          partyId: widget.initialPartyId,
        );
      }
    });
  }

  @override
  void dispose() {
    _paidController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _syncAmountFieldsFromControllers() {
    final notifier = ref.read(paymentOutFormProvider.notifier);
    final paid = double.tryParse(_paidController.text.trim()) ?? 0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    notifier.updatePaidAmount(paid);
    notifier.updateDiscount(discount);
  }

  Future<void> _handleSave({bool saveAndNew = false}) async {
    final notifier = ref.read(paymentOutFormProvider.notifier);
    if (ref.read(paymentOutFormProvider).isSaving) return;

    _syncAmountFieldsFromControllers();

    final result = await notifier.savePayment(
      showSuccessMessage: !saveAndNew,
    );
    if (!mounted) return;
    if (result.error != null) {
      showTransactionFormSaveError(context, result.error!);
      return;
    }

    if (result.paymentId != null) {
      _savedPaymentId = result.paymentId;
    }

    if (saveAndNew) {
      notifier.reset();
      _paidController.clear();
      _discountController.clear();
      _savedPaymentId = null;
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handlePrintPreview() async {
    if (ref.read(paymentOutFormProvider).isSaving) return;

    var paymentId = _savedPaymentId;
    final receiptNo = ref.read(paymentOutFormProvider).receiptNo;

    if (paymentId == null) {
      _syncAmountFieldsFromControllers();
      final result = await ref
          .read(paymentOutFormProvider.notifier)
          .savePayment(
            showSuccessMessage: false,
          );
      if (!mounted) return;
      if (result.error != null) {
        showTransactionFormSaveError(context, result.error!);
        return;
      }
      paymentId = result.paymentId;
      if (paymentId == null) return;
      _savedPaymentId = paymentId;
    }

    await VoucherPrintActions.previewPaymentOut(
      context,
      ref,
      paymentId,
      filename: VoucherPrintActions.filenameFor(receiptNo),
    );
  }

  Future<void> _handleShare() async {
    if (ref.read(paymentOutFormProvider).isSaving) return;

    var paymentId = _savedPaymentId;
    final receiptNo = ref.read(paymentOutFormProvider).receiptNo;

    if (paymentId == null) {
      _syncAmountFieldsFromControllers();
      final result = await ref
          .read(paymentOutFormProvider.notifier)
          .savePayment(
            showSuccessMessage: false,
          );
      if (!mounted) return;
      if (result.error != null) {
        showTransactionFormSaveError(context, result.error!);
        return;
      }
      paymentId = result.paymentId;
      if (paymentId == null) return;
      _savedPaymentId = paymentId;
    }

    await VoucherPrintActions.sharePaymentOut(
      context,
      ref,
      paymentId,
      filename: VoucherPrintActions.filenameFor(receiptNo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(paymentOutFormProvider);
    final notifier = ref.read(paymentOutFormProvider.notifier);
    final isSaving = form.isSaving;

    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Material(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DialogHeader(
                  onClose: isSaving ? null : () => Navigator.of(context).pop(),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(_sectionGap),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FloatingLabelField(
                                label: 'Party *',
                                hasError: form.partyHasError,
                                child: BillingNamePartySearchField(
                                  value: form.party,
                                  selectedPartyId: form.partyId,
                                  emptyPlaceholder: 'Select Party',
                                  onSelected: notifier.updateParty,
                                  onPartySelectedWithId: (partyId, name) =>
                                      notifier.updateParty(
                                        name,
                                        partyId: partyId,
                                      ),
                                  hasError: form.partyHasError,
                                  errorMessage: kPartyValidationMessage,
                                ),
                              ),
                              if (form.partyId != null &&
                                  form.partyId!.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                _AmountRow(
                                  label: 'Balance Due',
                                  value: form.isLoadingBalance
                                      ? 'Loading...'
                                      : _amountFormat.format(form.balanceDue),
                                  valueColor: form.balanceDue > 0
                                      ? const Color(0xFFE65100)
                                      : AppColors.textSecondary,
                                ),
                              ],
                              const SizedBox(height: _sectionGap),
                              _LabeledField(
                                label: 'Payment Type',
                                child: SizedBox(
                                  width: 160,
                                  child: SaleGenericSelectDropdown(
                                    value: form.paymentType,
                                    options:
                                        PaymentOutDropdownOptions.paymentTypes,
                                    compact: true,
                                    onSelected: notifier.updatePaymentType,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'Add Payment type',
                                  style: TextStyle(fontSize: 13),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(height: _sectionGap),
                              OutlinedButton.icon(
                                onPressed: notifier.toggleDescriptionField,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'ADD DESCRIPTION',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  side: const BorderSide(
                                    color: _cardBorder,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              if (form.showDescriptionField) ...[
                                const SizedBox(height: 8),
                                TextField(
                                  onChanged: notifier.updateDescription,
                                  maxLines: 3,
                                  style: saleFieldTextStyle,
                                  decoration: buildSaleFieldDecoration(
                                    hint: 'Add description...',
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => transactionAddImage(
                                        context: context,
                                        ref: ref,
                                        entityType: DocumentAttachmentEntityType
                                            .paymentOut.apiValue,
                                        entityId: _savedPaymentId,
                                        onAdded: notifier.addImage,
                                      ),
                                      icon: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16,
                                      ),
                                      label: const Text('ADD IMAGE'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        side: const BorderSide(
                                          color: _cardBorder,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => transactionAddDocument(
                                        context: context,
                                        ref: ref,
                                        entityType: DocumentAttachmentEntityType
                                            .paymentOut.apiValue,
                                        entityId: _savedPaymentId,
                                        onAdded: notifier.addDocument,
                                      ),
                                      icon: const Icon(
                                        Icons.attach_file_outlined,
                                        size: 16,
                                      ),
                                      label: const Text('ADD DOCUMENT'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        side: const BorderSide(
                                          color: _cardBorder,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (form.attachedImages.isNotEmpty ||
                                  form.attachedDocuments.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                if (form.attachedImages.isNotEmpty)
                                  SaleFormAttachmentChipList(
                                    attachments: form.attachedImages,
                                    attachmentService: ref
                                        .watch(documentAttachmentServiceProvider)
                                        .value,
                                    onRemove: (id) => transactionRemoveAttachment(
                                      ref: ref,
                                      attachments: form.attachedImages,
                                      id: id,
                                      onRemoved: notifier.removeImage,
                                    ),
                                    onRename: (id, name) =>
                                        transactionRenameAttachment(
                                      ref: ref,
                                      attachments: form.attachedImages,
                                      id: id,
                                      name: name,
                                      onRenamed: notifier.updateImage,
                                    ),
                                  ),
                                if (form.attachedDocuments.isNotEmpty)
                                  SaleFormAttachmentChipList(
                                    attachments: form.attachedDocuments,
                                    attachmentService: ref
                                        .watch(documentAttachmentServiceProvider)
                                        .value,
                                    onRemove: (id) => transactionRemoveAttachment(
                                      ref: ref,
                                      attachments: form.attachedDocuments,
                                      id: id,
                                      onRemoved: notifier.removeDocument,
                                    ),
                                    onRename: (id, name) =>
                                        transactionRenameAttachment(
                                      ref: ref,
                                      attachments: form.attachedDocuments,
                                      id: id,
                                      name: name,
                                      onRenamed: notifier.updateDocument,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: _sectionGap),
                        SizedBox(
                          width: 280,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LabeledField(
                                label: 'Receipt No',
                                child: Text(
                                  form.receiptNo,
                                  style: saleFieldTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: _sectionGap),
                              _LabeledField(
                                label: 'Date',
                                child: SaleSingleDatePickerAnchor(
                                  key: _datePickerKey,
                                  selectedDate: form.date,
                                  onDateSelected: notifier.updateDate,
                                  child: _PickerField(
                                    value: formatSaleSingleDate(form.date),
                                    icon: Icons.calendar_today_outlined,
                                    onTap: () =>
                                        _datePickerKey.currentState?.toggle(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: _sectionGap),
                              _LabeledField(
                                label: 'Time',
                                child: SaleTimeDropdown(
                                  value: form.time,
                                  compact: true,
                                  onSelected: notifier.updateTime,
                                ),
                              ),
                              const SizedBox(height: _sectionGap * 2),
                              _AmountRow(
                                label: 'Paid',
                                child: SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: _paidController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
                                    ],
                                    style: saleFieldTextStyle,
                                    textAlign: TextAlign.right,
                                    decoration: buildSaleFieldDecoration(
                                      compact: true,
                                      hasError:
                                          form.showValidationErrors &&
                                          form.total <= 0,
                                    ),
                                    onChanged: (value) {
                                      final amount =
                                          double.tryParse(value) ?? 0;
                                      notifier.updatePaidAmount(amount);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _AmountRow(
                                label: 'Discount',
                                child: SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: _discountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
                                    ],
                                    style: saleFieldTextStyle,
                                    textAlign: TextAlign.right,
                                    decoration: buildSaleFieldDecoration(
                                      compact: true,
                                    ),
                                    onChanged: (value) {
                                      final amount =
                                          double.tryParse(value) ?? 0;
                                      notifier.updateDiscount(amount);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _AmountRow(
                                label: 'Total',
                                value: _amountFormat.format(form.total),
                                isBold: true,
                                valueColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: _cardBorder),
                Padding(
                  padding: const EdgeInsets.all(_sectionGap),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _PaymentOutActionsMenu(
                        enabled: !isSaving,
                        onPrint: _handlePrintPreview,
                        onSaveAndNew: () => _handleSave(saveAndNew: true),
                        onChannelSelected: (_) => _handleShare(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        onPressed: isSaving ? null : _handleSave,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isSaving)
          const Positioned.fill(
            child: TransactionFormSaveOverlay(
              label: 'Saving payment out…',
            ),
          ),
      ],
    );
  }
}

enum _PaymentOutMenuAction { share, print, saveAndNew }

/// Vyapar-style actions menu: Share (submenu), Print, Save & New.
class _PaymentOutActionsMenu extends StatelessWidget {
  const _PaymentOutActionsMenu({
    required this.enabled,
    required this.onPrint,
    required this.onSaveAndNew,
    required this.onChannelSelected,
  });

  final bool enabled;
  final VoidCallback onPrint;
  final VoidCallback onSaveAndNew;
  final ValueChanged<ShareChannel> onChannelSelected;

  void _showSharePanel(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          child: ShareMenuPanel(
            onChannelSelected: (channel) {
              Navigator.of(dialogContext).pop();
              onChannelSelected(channel);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PaymentOutMenuAction>(
      enabled: enabled,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: _cardBorder),
      ),
      onSelected: (action) {
        switch (action) {
          case _PaymentOutMenuAction.share:
            _showSharePanel(context);
          case _PaymentOutMenuAction.print:
            onPrint();
          case _PaymentOutMenuAction.saveAndNew:
            onSaveAndNew();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _PaymentOutMenuAction.share,
          child: Row(
            children: [
              Text('Share', style: TextStyle(fontSize: 13)),
              Spacer(),
              Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _PaymentOutMenuAction.print,
          child: Row(
            children: [
              Icon(
                Icons.print_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8),
              Text('Print', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _PaymentOutMenuAction.saveAndNew,
          child: Text('Save & New', style: TextStyle(fontSize: 13)),
        ),
      ],
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _cardBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Share', style: TextStyle(fontSize: 13)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        children: [
          const Text(
            'Payment-Out',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calculate_outlined, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Calculator',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _FloatingLabelField extends StatelessWidget {
  const _FloatingLabelField({
    required this.label,
    required this.child,
    this.hasError = false,
  });

  final String label;
  final Widget child;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: child,
        ),
        Positioned(
          left: 8,
          top: 0,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: hasError ? saleFieldErrorColor : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: saleFieldLabelStyle),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SaleFieldTrigger(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: Text(value, style: saleFieldTextStyle)),
          Icon(icon, size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    this.value,
    this.child,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String? value;
  final Widget? child;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: isBold ? 15 : 13,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
      color: valueColor ?? AppColors.textPrimary,
    );

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (child != null) child! else Text(value ?? '', style: textStyle),
      ],
    );
  }
}
