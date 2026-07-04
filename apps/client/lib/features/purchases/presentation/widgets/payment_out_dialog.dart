import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/core/widgets/transaction_success_toast.dart';
import 'package:billing_baba/features/purchases/providers/payment_out_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

/// Shows the Payment-Out modal from the Payment-Out page.
Future<void> showPaymentOutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: PaymentOutDialog(),
    ),
  );
}

class PaymentOutDialog extends ConsumerStatefulWidget {
  const PaymentOutDialog({super.key});

  @override
  ConsumerState<PaymentOutDialog> createState() => _PaymentOutDialogState();
}

class _PaymentOutDialogState extends ConsumerState<PaymentOutDialog> {
  final _datePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _paidController = TextEditingController();
  final _discountController = TextEditingController();

  static final _amountFormat = NumberFormat('#,##0.##', 'en_IN');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentOutFormProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _paidController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(TimeOfDay? current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
    );
    if (picked != null) {
      ref.read(paymentOutFormProvider.notifier).updateTime(picked);
    }
  }

  Future<void> _handleSave({bool saveAndNew = false}) async {
    final notifier = ref.read(paymentOutFormProvider.notifier);
    final receiptNo = ref.read(paymentOutFormProvider).receiptNo;
    final error = await notifier.savePayment();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    showTransactionSuccessToast(
      context,
      message: 'Payment $receiptNo saved successfully',
    );

    if (saveAndNew) {
      notifier.reset();
      _paidController.clear();
      _discountController.clear();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showComingSoon(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(paymentOutFormProvider);
    final notifier = ref.read(paymentOutFormProvider.notifier);

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
                            hasError:
                                form.showValidationErrors &&
                                form.party.trim().isEmpty,
                            child: BillingNamePartySearchField(
                              value: form.party,
                              emptyPlaceholder: 'Select Party',
                              onSelected: notifier.updateParty,
                              onPartySelectedWithId: (partyId, name) =>
                                  notifier.updateParty(name, partyId: partyId),
                              hasError:
                                  form.showValidationErrors &&
                                  form.party.trim().isEmpty,
                              errorMessage: 'Party is required',
                            ),
                          ),
                          const SizedBox(height: _sectionGap),
                          _LabeledField(
                            label: 'Payment Type',
                            child: SizedBox(
                              width: 160,
                              child: SaleGenericSelectDropdown(
                                value: form.paymentType,
                                options: PaymentOutDropdownOptions.paymentTypes,
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
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.camera_alt_outlined),
                            color: AppColors.textSecondary,
                            tooltip: 'Attach image',
                          ),
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
                            child: _PickerField(
                              value: _formatTime(form.time),
                              icon: Icons.access_time,
                              onTap: () => _pickTime(form.time),
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
                                      form.paidAmount <= 0,
                                ),
                                onChanged: (value) {
                                  final amount = double.tryParse(value) ?? 0;
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
                                  final amount = double.tryParse(value) ?? 0;
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
                    onPrint: () => _showComingSoon('Print'),
                    onSaveAndNew: () => _handleSave(saveAndNew: true),
                    onChannelSelected: (channel) =>
                        _showComingSoon(channel.label),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _handleSave,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                    child: const Text('Save'),
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

enum _PaymentOutMenuAction { share, print, saveAndNew }

/// Vyapar-style actions menu: Share (submenu), Print, Save & New.
class _PaymentOutActionsMenu extends StatelessWidget {
  const _PaymentOutActionsMenu({
    required this.onPrint,
    required this.onSaveAndNew,
    required this.onChannelSelected,
  });

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
