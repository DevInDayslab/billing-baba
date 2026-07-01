import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/job_work_out_footer.dart';
import 'package:billing_baba/features/sales/presentation/widgets/job_work_out_raw_material_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/providers/job_work_out_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _linkColor = Color(0xFF1565C0);

Future<bool?> showJobWorkOutDialog(
  BuildContext context, {
  SavedJobWorkOut? existing,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => JobWorkOutDialog(existing: existing),
  );
}

class JobWorkOutDialog extends ConsumerStatefulWidget {
  const JobWorkOutDialog({this.existing, super.key});

  final SavedJobWorkOut? existing;

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
      if (widget.existing != null) {
        notifier.loadSaved(widget.existing!);
      } else {
        notifier.resetForm();
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
                    JobWorkOutRawMaterialTable(
                      finishedGoodQty: form.finishedGoodQty,
                      finishedGoodUnit: form.finishedGoodUnit,
                    ),
                    if (form.additionalCosts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _AdditionalCostsSection(
                        costs: form.additionalCosts,
                        notifier: notifier,
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: notifier.addAdditionalCost,
                          style: TextButton.styleFrom(
                            foregroundColor: _linkColor,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            '+ Additional Cost',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: _sectionGap),
                    const JobWorkOutFooter(),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            _DialogBottomBar(
              onSave: () {
                final saved = notifier.save();
                if (!saved) return;
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job work out saved')),
                  );
                }
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

class _DialogBottomBar extends StatelessWidget {
  const _DialogBottomBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Spacer(),
          FilledButton(
            onPressed: onSave,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RequiredLabeledField(
                label: 'Party Name',
                child: BillingNamePartySearchField(
                  value: form.party,
                  hasError: form.partyHasError,
                  errorMessage: 'Party is required',
                  onSelected: notifier.updateParty,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Phone No.',
                child: _SaleTextField(
                  initialValue: form.phoneNo,
                  hintText: 'Phone number',
                  keyboardType: TextInputType.phone,
                  onChanged: notifier.updatePhoneNo,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: _sectionGap),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LabeledField(
                label: 'Job ID',
                child: _SaleTextField(
                  initialValue: form.jobId,
                  hintText: 'Job ID',
                  onChanged: notifier.updateJobId,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
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
              const SizedBox(height: _sectionGap),
              _LabeledField(
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
            ],
          ),
        ),
      ],
    );
  }
}

class _FinishedGoodSection extends StatelessWidget {
  const _FinishedGoodSection({
    required this.form,
    required this.notifier,
  });

  final JobWorkOutFormState form;
  final JobWorkOutFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
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
                child: _SaleTextField(
                  initialValue: form.finishedGoodName,
                  hintText: 'Item name',
                  hasError: form.finishedGoodHasError,
                  onChanged: notifier.updateFinishedGoodName,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            SizedBox(
              width: 100,
              child: _RequiredLabeledField(
                label: 'Quantity',
                child: _SaleTextField(
                  initialValue: form.finishedGoodQty.toString(),
                  hintText: '1',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) =>
                      notifier.updateFinishedGoodQty(double.tryParse(value) ?? 0),
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
                  hintText: 'PCS',
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

class _AdditionalCostsSection extends StatelessWidget {
  const _AdditionalCostsSection({
    required this.costs,
    required this.notifier,
  });

  final List<JobWorkOutAdditionalCost> costs;
  final JobWorkOutFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final cost in costs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _SaleTextField(
                    initialValue: cost.label,
                    hintText: 'Cost description',
                    onChanged: (value) => notifier.updateAdditionalCost(
                      cost.id,
                      cost.copyWith(label: value),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: _SaleTextField(
                    initialValue: cost.amount == 0
                        ? '0'
                        : cost.amount.toString(),
                    hintText: '0',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) => notifier.updateAdditionalCost(
                      cost.id,
                      cost.copyWith(amount: double.tryParse(value) ?? 0),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => notifier.removeAdditionalCost(cost.id),
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  tooltip: 'Remove',
                ),
              ],
            ),
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
    this.hasError = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool hasError;

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
