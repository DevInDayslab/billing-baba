import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/providers/payment_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

/// Shows the Payment-In modal from the Payment-In page filter bar.
Future<void> showPaymentInDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: PaymentInDialog(),
    ),
  );
}

class PaymentInDialog extends ConsumerStatefulWidget {
  const PaymentInDialog({super.key});

  @override
  ConsumerState<PaymentInDialog> createState() => _PaymentInDialogState();
}

class _PaymentInDialogState extends ConsumerState<PaymentInDialog> {
  final _datePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _receivedController = TextEditingController();
  final _discountController = TextEditingController();

  static final _amountFormat = NumberFormat('#,##0.00', 'en_IN');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentInFormProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _receivedController.dispose();
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
      ref.read(paymentInFormProvider.notifier).updateTime(picked);
    }
  }

  void _handleSave() {
    final notifier = ref.read(paymentInFormProvider.notifier);
    final payment = notifier.buildPaymentModel();
    if (payment == null) return;

    notifier.savePayment();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment ${payment.receiptNo} saved successfully'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(paymentInFormProvider);
    final notifier = ref.read(paymentInFormProvider.notifier);

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
                                options:
                                    PaymentInDropdownOptions.paymentTypes,
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
                            icon: const Icon(Icons.description_outlined, size: 16),
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
                            label: 'Balance Due',
                            value: _amountFormat.format(form.balanceDue),
                          ),
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
                            label: 'Remaining Balance',
                            value: _amountFormat.format(form.remainingBalance),
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
                    onChannelSelected: (channel) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${channel.label} coming soon'),
                        ),
                      );
                    },
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
  });

  final String label;
  final String? value;
  final Widget? child;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 13,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
      color: AppColors.textPrimary,
    );

    return Row(
      children: [
        Text(label, style: textStyle),
        const Spacer(),
        if (child != null)
          child!
        else
          Text(value ?? '', style: textStyle),
      ],
    );
  }
}
