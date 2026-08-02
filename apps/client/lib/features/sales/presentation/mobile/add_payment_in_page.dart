import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/sales/application/payment_in_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddPaymentInPage extends ConsumerStatefulWidget {
  const MobileAddPaymentInPage({super.key, this.paymentId});

  final String? paymentId;

  @override
  ConsumerState<MobileAddPaymentInPage> createState() =>
      _MobileAddPaymentInPageState();
}

class _MobileAddPaymentInPageState extends ConsumerState<MobileAddPaymentInPage> {
  final _receivedController = TextEditingController();
  final _discountController = TextEditingController();
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _receivedController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentInFormProvider.notifier).reset();
    });
  }

  Future<void> _pickParty(PaymentInForm notifier) async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.customer,
      title: 'Select customer',
    );
    if (party != null) {
      notifier.updateParty(party.name, partyId: party.id);
      await notifier.refreshBalanceDue();
    }
  }

  Future<void> _pickPaymentType(PaymentInForm notifier) async {
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

  Future<void> _save(PaymentInForm notifier) async {
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
    final form = ref.watch(paymentInFormProvider);
    final notifier = ref.read(paymentInFormProvider.notifier);

    if (_receivedController.text !=
            form.receivedAmount.toStringAsFixed(2) &&
        !form.isSaving) {
      _receivedController.text = form.receivedAmount > 0
          ? form.receivedAmount.toStringAsFixed(2)
          : '';
    }

    return MobileFormScaffold(
      title: 'Payment in',
      isSaving: form.isSaving,
      primaryActionLabel: 'Record payment',
      onPrimaryAction: () => _save(notifier),
      topBanner: const MobileOfflineBanner(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (form.saveError != null)
            Text(form.saveError!, style: AppTypography.inter(
              fontSize: AppTypography.bodySize,
              color: AppColors.error,
            )),
          MobileFormPickerField(
            label: 'Customer',
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
            label: 'Received amount',
            controller: _receivedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            errorText: form.amountHasError ? 'Required' : null,
            onChanged: (value) {
              notifier.updateReceivedAmount(double.tryParse(value) ?? 0);
            },
          ),
          MobileFormTextField(
            label: 'Discount',
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              notifier.updateDiscount(double.tryParse(value) ?? 0);
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
