import 'package:billing_baba/core/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/core/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/core/forms/transaction_form_validation.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/hidden_ledger/models/short_payment_handling.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/desktop/widgets/short_payment_handling_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/core/attachments/document_attachment_providers.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_form_attachments_section.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

/// Shows the Payment-In modal from the Payment-In page filter bar.
Future<void> showPaymentInDialog(
  BuildContext context, {
  String? initialPartyId,
  String? initialPartyName,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: PaymentInDialog(
        initialPartyId: initialPartyId,
        initialPartyName: initialPartyName,
      ),
    ),
  );
}

class PaymentInDialog extends ConsumerStatefulWidget {
  const PaymentInDialog({
    super.key,
    this.initialPartyId,
    this.initialPartyName,
  });

  final String? initialPartyId;
  final String? initialPartyName;

  @override
  ConsumerState<PaymentInDialog> createState() => _PaymentInDialogState();
}

class _PaymentInDialogState extends ConsumerState<PaymentInDialog> {
  final _datePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _receivedController = TextEditingController();
  final _discountController = TextEditingController();
  final _receiptNoController = TextEditingController();
  String? _savedPaymentId;
  bool _showUpiBanner = true;

  static final _amountFormat = NumberFormat('#,##0.00', 'en_IN');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(paymentInFormProvider.notifier);
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
    _receivedController.dispose();
    _discountController.dispose();
    _receiptNoController.dispose();
    super.dispose();
  }

  Future<ShortPaymentHandling?> _resolveShortPaymentHandling() async {
    final notifier = ref.read(paymentInFormProvider.notifier);
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

  Future<void> _handleSave({bool previewAfterSave = false}) async {
    final notifier = ref.read(paymentInFormProvider.notifier);
    final payment = notifier.buildPaymentModel();
    if (payment == null) return;

    final form = ref.read(paymentInFormProvider);
    final handling = await _resolveShortPaymentHandling();
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
    }

    if (previewAfterSave && paymentId != null) {
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

  Future<void> _handleShare() async {
    final notifier = ref.read(paymentInFormProvider.notifier);
    final payment = notifier.buildPaymentModel();
    var paymentId = _savedPaymentId;

    if (paymentId == null) {
      if (payment == null) {
        VoucherPrintActions.showSaveBeforePrinting(context);
        return;
      }
      final form = ref.read(paymentInFormProvider);
      final handling = await _resolveShortPaymentHandling();
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
      paymentId = result.paymentId;
      if (paymentId == null) return;
      _savedPaymentId = paymentId;
    }

    final filename = payment != null
        ? VoucherPrintActions.filenameFor(payment.receiptNo)
        : VoucherPrintActions.filenameFor(paymentId);
    await VoucherPrintActions.sharePaymentIn(
      context,
      ref,
      paymentId,
      filename: filename,
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(paymentInFormProvider);
    final notifier = ref.read(paymentInFormProvider.notifier);
    final totalAmount = form.receivedAmount + form.discount;

    if (_receiptNoController.text != form.receiptNo) {
      _receiptNoController.text = form.receiptNo;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).pop()),
            if (_showUpiBanner)
              _UpiBanner(
                onDismiss: () => setState(() => _showUpiBanner = false),
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
                              onPartySelected: (party) => notifier.updateParty(
                                party.name,
                                partyId: party.id,
                              ),
                              onPartySelectedWithId: (partyId, name) =>
                                  notifier.updateParty(name, partyId: partyId),
                              hasError: form.partyHasError,
                              errorMessage: kPartyValidationMessage,
                            ),
                          ),
                          const SizedBox(height: _sectionGap),
                          _LabeledField(
                            label: 'Payment Type',
                            child: SizedBox(
                              width: 160,
                              child: SaleGenericSelectDropdown(
                                value: form.paymentType,
                                options: PaymentInDropdownOptions.paymentTypes,
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
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(height: _sectionGap),
                          OutlinedButton.icon(
                            onPressed: notifier.toggleDescriptionField,
                            icon: const Icon(
                              Icons.description_outlined,
                              size: 16,
                            ),
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
                              side: const BorderSide(color: _cardBorder),
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
                                        .paymentIn.apiValue,
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
                                    side: const BorderSide(color: _cardBorder),
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
                                        .paymentIn.apiValue,
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
                                    side: const BorderSide(color: _cardBorder),
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
                            child: TextField(
                              controller: _receiptNoController,
                              style: saleFieldTextStyle,
                              decoration: buildSaleFieldDecoration(
                                compact: true,
                              ),
                              onChanged: notifier.updateReceiptNo,
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
                          if (form.partyId != null && form.balanceDue > 0)
                            _AmountRow(
                              label: 'Balance Due',
                              value: _amountFormat.format(form.balanceDue),
                              valueColor: AppColors.textSecondary,
                            ),
                          if (form.partyId != null && form.balanceDue > 0)
                            const SizedBox(height: AppSpacing.sm),
                          _AmountRow(
                            label: 'Received',
                            child: SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _receivedController,
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
                                      form.receivedAmount <= 0,
                                ),
                                onChanged: (value) {
                                  final amount = double.tryParse(value) ?? 0;
                                  notifier.updateReceivedAmount(amount);
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
                                  final amount = double.tryParse(value) ?? 0;
                                  notifier.updateDiscount(amount);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _AmountRow(
                            label: 'Total',
                            value: _amountFormat.format(totalAmount),
                            valueColor: AppColors.primary,
                            isBold: true,
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
                  ShareMenuButton(
                    onChannelSelected: (_) => _handleShare(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: form.isSaving ? null : _handleSave,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                    child: form.isSaving
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
    );
  }
}

class _UpiBanner extends StatelessWidget {
  const _UpiBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        _sectionGap,
        _sectionGap,
        _sectionGap,
        0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Accept UPI, debit cards, credit cards, and net banking payments '
              'to boost revenue and reconcile incoming payments with invoices directly.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Accept Payments Online',
              style: TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 16),
            color: AppColors.textSecondary,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

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
            'Payment-In',
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
      fontSize: 13,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
      color: AppColors.textPrimary,
    );
    final valueStyle = textStyle.copyWith(
      color: valueColor ?? AppColors.textPrimary,
      fontWeight: isBold ? FontWeight.w700 : textStyle.fontWeight,
    );

    return Row(
      children: [
        Text(label, style: textStyle),
        const Spacer(),
        if (child != null) child! else Text(value ?? '', style: valueStyle),
      ],
    );
  }
}
