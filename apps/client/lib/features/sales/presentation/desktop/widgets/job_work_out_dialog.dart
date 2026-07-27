import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/sales/application/job_work_out_form_provider.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/item_name_autocomplete_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/job_work_out_additional_cost_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/job_work_out_footer.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/job_work_out_raw_material_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/utils/sale_quantity_input.dart';
import 'package:billing_baba/shared/widgets/share_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

Future<bool?> showJobWorkOutDialog(
  BuildContext context, {
  String? orderId,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => JobWorkOutDialog(orderId: orderId),
  );
}

class JobWorkOutDialog extends ConsumerStatefulWidget {
  const JobWorkOutDialog({this.orderId, super.key});

  final String? orderId;

  @override
  ConsumerState<JobWorkOutDialog> createState() => _JobWorkOutDialogState();
}

class _JobWorkOutDialogState extends ConsumerState<JobWorkOutDialog> {
  final _invoiceDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _deliveryDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(jobWorkOutFormProvider.notifier);
      if (widget.orderId != null) {
        notifier.loadOrder(widget.orderId!);
      } else {
        notifier.prepareNewForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(jobWorkOutFormProvider);
    final notifier = ref.read(jobWorkOutFormProvider.notifier);
    final screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 960,
          maxHeight: screenSize.height * 0.92,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).pop(false)),
            const Divider(height: 1, color: _cardBorder),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_sectionGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _JobWorkOutFormFields(
                      form: form,
                      notifier: notifier,
                      invoiceDatePickerKey: _invoiceDatePickerKey,
                      deliveryDatePickerKey: _deliveryDatePickerKey,
                    ),
                    const SizedBox(height: _sectionGap),
                    _FinishedGoodSection(form: form, notifier: notifier),
                    const SizedBox(height: _sectionGap),
                    const JobWorkOutRawMaterialTable(),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: notifier.addAdditionalCost,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add Additional Cost',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    if (form.additionalCosts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const JobWorkOutAdditionalCostTable(),
                    ],
                    const SizedBox(height: _sectionGap),
                    const JobWorkOutFooter(),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            _DialogBottomBar(
              isSaving: form.isSaving,
              orderId: widget.orderId ?? form.orderId,
              jobNumber: form.jobId,
              onSave: () async {
                final error = await notifier.save();
                if (!context.mounted) return;
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job work out saved')),
                );
              },
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _sectionGap,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Text(
            'Job Work Out (Challan)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
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

class _DialogBottomBar extends ConsumerWidget {
  const _DialogBottomBar({
    required this.onSave,
    this.isSaving = false,
    this.orderId,
    this.jobNumber = '',
  });

  final VoidCallback onSave;
  final bool isSaving;
  final String? orderId;
  final String jobNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filename = jobNumber.trim().isNotEmpty
        ? VoucherPrintActions.filenameFor(jobNumber)
        : (orderId != null
              ? VoucherPrintActions.filenameFor(orderId!)
              : 'job_work');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (orderId != null) ...[
            OutlinedButton.icon(
              onPressed: () => VoucherPrintActions.previewJobWorkOrder(
                context,
                ref,
                orderId!,
                filename: filename,
              ),
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text(
                'Print / Preview',
                style: TextStyle(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                side: const BorderSide(color: _cardBorder),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ShareMenuButton(
              onChannelSelected: (_) => VoucherPrintActions.shareJobWorkOrder(
                context,
                ref,
                orderId!,
                filename: filename,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          const Spacer(),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _JobWorkOutFormFields extends StatelessWidget {
  const _JobWorkOutFormFields({
    required this.form,
    required this.notifier,
    required this.invoiceDatePickerKey,
    required this.deliveryDatePickerKey,
  });

  final JobWorkOutFormState form;
  final JobWorkOutFormNotifier notifier;
  final GlobalKey<SaleSingleDatePickerAnchorState> invoiceDatePickerKey;
  final GlobalKey<SaleSingleDatePickerAnchorState> deliveryDatePickerKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _RequiredLabeledField(
                label: 'Party Name',
                child: BillingNamePartySearchField(
                  value: form.party,
                  selectedPartyId: form.partyId,
                  hasError: form.partyHasError,
                  errorMessage: 'Party is required',
                  onSelected: notifier.updateParty,
                  onPartySelectedWithId: (partyId, name) =>
                      notifier.updatePartyWithId(
                        partyId: partyId,
                        partyName: name,
                      ),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              flex: 2,
              child: _LabeledField(
                label: 'Job ID',
                child: _SaleTextField(
                  initialValue: form.jobId,
                  hintText: '—',
                  readOnly: true,
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _LabeledField(
                label: 'Phone No.',
                child: _SaleTextField(
                  initialValue: form.phoneNo,
                  hintText: 'Phone number',
                  keyboardType: TextInputType.phone,
                  onChanged: notifier.updatePhoneNo,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              flex: 2,
              child: _LabeledField(
                label: 'Invoice Date',
                child: SaleSingleDatePickerAnchor(
                  key: invoiceDatePickerKey,
                  selectedDate: form.invoiceDate,
                  onDateSelected: notifier.updateInvoiceDate,
                  child: _PickerField(
                    value: formatSaleSingleDate(form.invoiceDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => invoiceDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 3, child: SizedBox()),
            const SizedBox(width: _sectionGap),
            Expanded(
              flex: 2,
              child: _LabeledField(
                label: 'Delivery Date',
                child: SaleSingleDatePickerAnchor(
                  key: deliveryDatePickerKey,
                  selectedDate: form.deliveryDate,
                  onDateSelected: notifier.updateDeliveryDate,
                  child: _PickerField(
                    value: formatSaleSingleDate(form.deliveryDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => deliveryDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FinishedGoodSection extends ConsumerWidget {
  const _FinishedGoodSection({
    required this.form,
    required this.notifier,
  });

  final JobWorkOutFormState form;
  final JobWorkOutFormNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Finished Good',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _RequiredLabeledField(
                label: 'Finished Good',
                child: ItemNameAutocompleteField(
                  value: form.finishedGoodName,
                  onChanged: notifier.updateFinishedGoodName,
                  onItemSelected: notifier.selectFinishedGood,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            SizedBox(
              width: 100,
              child: _RequiredLabeledField(
                label: 'Quantity',
                child: _SaleTextField(
                  initialValue: SaleQuantityInput.format(form.finishedGoodQty),
                  hintText: '1',
                  keyboardType: SaleQuantityInput.integerKeyboardType,
                  inputFormatters: SaleQuantityInput.integerFormatters,
                  onChanged: (value) => notifier.updateFinishedGoodQty(
                    SaleQuantityInput.parse(value),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            SizedBox(
              width: 120,
              child: _LabeledField(
                label: 'Units',
                child: SaleGenericSelectDropdown(
                  value: form.finishedGoodUnit,
                  options: SaleDropdownOptions.units,
                  hintText: 'None',
                  onSelected: notifier.updateFinishedGoodUnit,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RequiredLabeledField extends StatelessWidget {
  const _RequiredLabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: saleFieldErrorColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _SaleTextField extends StatefulWidget {
  const _SaleTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
  }) : hasError = false;

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool hasError;
  final bool readOnly;

  @override
  State<_SaleTextField> createState() => _SaleTextFieldState();
}

class _SaleTextFieldState extends State<_SaleTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_SaleTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: saleFieldTextStyle,
      readOnly: widget.readOnly,
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        hasError: widget.hasError,
      ),
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
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
