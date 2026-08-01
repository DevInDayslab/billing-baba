import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/application/payment_out_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddPaymentOutPage extends ConsumerStatefulWidget {
  const MobileAddPaymentOutPage({super.key, this.paymentId});

  final String? paymentId;

  @override
  ConsumerState<MobileAddPaymentOutPage> createState() =>
      _MobileAddPaymentOutPageState();
}

class _MobileAddPaymentOutPageState extends ConsumerState<MobileAddPaymentOutPage> {
  final _paidController = TextEditingController();
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentOutFormProvider.notifier).reset();
    });
  }

  Future<void> _pickParty(PaymentOutForm notifier) async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.supplier,
      title: 'Select supplier',
    );
    if (party != null) {
      await notifier.updateParty(party.name, partyId: party.id);
    }
  }

  Future<void> _pickPaymentType(PaymentOutForm notifier) async {
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
    if (picked != null) notifier.updatePaymentType(picked);
  }

  Future<void> _save(PaymentOutForm notifier) async {
    final result = await notifier.savePayment();
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment recorded')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(paymentOutFormProvider);
    final notifier = ref.read(paymentOutFormProvider.notifier);

    return MobileFormScaffold(
      title: 'Payment out',
      isSaving: form.isSaving,
      primaryActionLabel: 'Record payment',
      onPrimaryAction: () => _save(notifier),
      topBanner: const MobileOfflineBanner(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (form.saveError != null)
            Text(
              form.saveError!,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.error,
              ),
            ),
          MobileFormPickerField(
            label: 'Supplier',
            value: form.party,
            errorText: form.partyHasError ? 'Required' : null,
            onTap: () => _pickParty(notifier),
          ),
          MobileFormTextField(
            label: 'Balance due',
            value: '₹ ${form.balanceDue.toStringAsFixed(2)}',
            readOnly: true,
          ),
          MobileFormTextField(
            label: 'Paid amount',
            controller: _paidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            errorText: form.amountHasError ? 'Required' : null,
            onChanged: (value) {
              notifier.updatePaidAmount(double.tryParse(value) ?? 0);
            },
          ),
          MobileFormPickerField(
            label: 'Payment mode',
            value: form.paymentType,
            onTap: () => _pickPaymentType(notifier),
          ),
          MobileFormPickerField(
            label: 'Date',
            value: form.date != null ? _dateFormat.format(form.date!) : '',
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.date,
              );
              if (date != null) notifier.updateDate(date);
            },
          ),
        ],
      ),
    );
  }
}
