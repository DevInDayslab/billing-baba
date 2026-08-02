import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Mobile receive-payment flow in a rounded bottom sheet.
Future<void> showMobileReceivePaymentSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
}) {
  return showMobilePaymentSheet<void>(
    context: context,
    title: 'Receive Payment',
    subtitle: party.name,
    footer: mobilePaymentSheetFooter(
      onCancel: () => Navigator.of(context).pop(),
      onSave: () => Navigator.of(context).pop(true),
    ),
    builder: (sheetContext) => _MobileReceivePaymentSheetBody(
      parentContext: context,
      ref: ref,
      party: party,
    ),
  );
}

/// Mobile record-payment flow in a rounded bottom sheet.
Future<void> showMobileRecordPaymentSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PartyModel party,
}) {
  return showMobilePaymentSheet<void>(
    context: context,
    title: 'Record Payment',
    subtitle: party.name,
    footer: mobilePaymentSheetFooter(
      onCancel: () => Navigator.of(context).pop(),
      onSave: () => Navigator.of(context).pop(true),
    ),
    builder: (sheetContext) => _MobileRecordPaymentSheetBody(
      parentContext: context,
      ref: ref,
      party: party,
    ),
  );
}

class _MobileReceivePaymentSheetBody extends ConsumerStatefulWidget {
  const _MobileReceivePaymentSheetBody({
    required this.parentContext,
    required this.ref,
    required this.party,
  });

  final BuildContext parentContext;
  final WidgetRef ref;
  final PartyModel party;

  @override
  ConsumerState<_MobileReceivePaymentSheetBody> createState() =>
      _MobileReceivePaymentSheetBodyState();
}

class _MobileReceivePaymentSheetBodyState
    extends ConsumerState<_MobileReceivePaymentSheetBody> {
  final _amountController = TextEditingController();
  final _dateFormat = DateFormat('dd MMM yyyy');
  bool _initialized = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(paymentInFormProvider.notifier);
      notifier.reset();
      await notifier.updateParty(widget.party.name, partyId: widget.party.id);
      setState(() => _initialized = true);
    });
  }

  Future<void> _save() async {
    final result =
        await ref.read(paymentInFormProvider.notifier).savePayment();
    if (result.error != null) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    Navigator.of(widget.parentContext).pop();
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      const SnackBar(content: Text('Payment recorded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final form = ref.watch(paymentInFormProvider);
    final notifier = ref.read(paymentInFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Balance due: ₹ ${form.balanceDue.toStringAsFixed(2)}',
          style: AppTypography.inter(
            fontSize: AppTypography.bodySize,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        MobileFormTextField(
          label: 'Amount received',
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          onChanged: (value) {
            notifier.updateReceivedAmount(double.tryParse(value) ?? 0);
          },
        ),
        MobileFormPickerField(
          label: 'Payment mode',
          value: form.paymentType,
          onTap: () async {
            final picked = await showModalBottomSheet<String>(
              context: context,
              builder: (ctx) => SafeArea(
                child: ListView(
                  children: [
                    for (final type in SaleDropdownOptions.paymentTypes)
                      ListTile(
                        title: Text(type),
                        onTap: () => Navigator.pop(ctx, type),
                      ),
                  ],
                ),
              ),
            );
            if (picked != null) notifier.updatePaymentType(picked);
          },
        ),
        MobileFormPickerField(
          label: 'Date',
          value: form.date != null ? _dateFormat.format(form.date!) : '',
          onTap: () async {
            final date = await showMobileDatePicker(context, initialDate: form.date);
            if (date != null) notifier.updateDate(date);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: form.isSaving ? null : _save,
          child: form.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save payment'),
        ),
      ],
    );
  }
}

class _MobileRecordPaymentSheetBody extends ConsumerStatefulWidget {
  const _MobileRecordPaymentSheetBody({
    required this.parentContext,
    required this.ref,
    required this.party,
  });

  final BuildContext parentContext;
  final WidgetRef ref;
  final PartyModel party;

  @override
  ConsumerState<_MobileRecordPaymentSheetBody> createState() =>
      _MobileRecordPaymentSheetBodyState();
}

class _MobileRecordPaymentSheetBodyState
    extends ConsumerState<_MobileRecordPaymentSheetBody> {
  final _amountController = TextEditingController();
  final _dateFormat = DateFormat('dd MMM yyyy');
  bool _initialized = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(paymentOutFormProvider.notifier);
      notifier.reset();
      await notifier.updateParty(widget.party.name, partyId: widget.party.id);
      setState(() => _initialized = true);
    });
  }

  Future<void> _save() async {
    final result =
        await ref.read(paymentOutFormProvider.notifier).savePayment();
    if (result.error != null) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    Navigator.of(widget.parentContext).pop();
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      const SnackBar(content: Text('Payment recorded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final form = ref.watch(paymentOutFormProvider);
    final notifier = ref.read(paymentOutFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Balance due: ₹ ${form.balanceDue.toStringAsFixed(2)}',
          style: AppTypography.inter(
            fontSize: AppTypography.bodySize,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        MobileFormTextField(
          label: 'Amount paid',
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          onChanged: (value) {
            notifier.updatePaidAmount(double.tryParse(value) ?? 0);
          },
        ),
        MobileFormPickerField(
          label: 'Payment mode',
          value: form.paymentType,
          onTap: () async {
            final picked = await showModalBottomSheet<String>(
              context: context,
              builder: (ctx) => SafeArea(
                child: ListView(
                  children: [
                    for (final type in SaleDropdownOptions.paymentTypes)
                      ListTile(
                        title: Text(type),
                        onTap: () => Navigator.pop(ctx, type),
                      ),
                  ],
                ),
              ),
            );
            if (picked != null) notifier.updatePaymentType(picked);
          },
        ),
        MobileFormPickerField(
          label: 'Date',
          value: form.date != null ? _dateFormat.format(form.date!) : '',
          onTap: () async {
            final date = await showMobileDatePicker(context, initialDate: form.date);
            if (date != null) notifier.updateDate(date);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: form.isSaving ? null : _save,
          child: form.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save payment'),
        ),
      ],
    );
  }
}
