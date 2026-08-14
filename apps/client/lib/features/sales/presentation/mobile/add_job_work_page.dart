import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/application/job_work_out_form_provider.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileAddJobWorkPage extends ConsumerStatefulWidget {
  const MobileAddJobWorkPage({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<MobileAddJobWorkPage> createState() =>
      _MobileAddJobWorkPageState();
}

class _MobileAddJobWorkPageState extends ConsumerState<MobileAddJobWorkPage> {
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(jobWorkOutFormProvider.notifier);
      if (widget.orderId != null) {
        await notifier.loadOrder(widget.orderId!);
      } else {
        await notifier.prepareNewForm();
      }
    });
  }

  Future<void> _pickParty(JobWorkOutFormNotifier notifier) async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.supplier,
      title: 'Select party',
    );
    if (party != null) {
      notifier.updatePartyWithId(partyId: party.id, partyName: party.name);
    }
  }

  Future<void> _save(JobWorkOutFormNotifier notifier) async {
    final error = await notifier.save();
    showMobileFormResult(
      context,
      error: error,
      successMessage: 'Job work order saved',
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(jobWorkOutFormProvider);
    final notifier = ref.read(jobWorkOutFormProvider.notifier);

    return MobileFormScaffold(
      title: widget.orderId != null ? 'Edit job work' : 'Add job work',
      isSaving: form.isSaving,
      primaryActionLabel: 'Save',
      onPrimaryAction: () => _save(notifier),
      topBanner: const MobileOfflineBanner(),
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: false,
        isSaving: form.isSaving,
        listRoute: AppRoutes.saleJobWorkOut,
      ),
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
          MobileFormTextField(
            label: 'Job ID',
            value: form.jobId,
            readOnly: true,
          ),
          MobileFormPickerField(
            label: 'Party',
            value: form.party,
            onTap: () => _pickParty(notifier),
          ),
          MobileFormPickerField(
            label: 'Invoice date',
            value: form.invoiceDate != null
                ? _dateFormat.format(form.invoiceDate!)
                : '',
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.invoiceDate,
              );
              if (date != null) notifier.updateInvoiceDate(date);
            },
          ),
          MobileFormPickerField(
            label: 'Delivery date',
            value: form.deliveryDate != null
                ? _dateFormat.format(form.deliveryDate!)
                : '',
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.deliveryDate,
              );
              if (date != null) notifier.updateDeliveryDate(date);
            },
          ),
          MobileFormTextField(
            label: 'Total amount',
            value: '₹ ${form.grandTotal.toStringAsFixed(2)}',
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
