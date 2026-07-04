import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/add_sale_footer.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/providers/add_sale_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addressFieldLines = 4;

class AddSalePage extends ConsumerWidget {
  const AddSalePage({this.invoiceId, super.key});

  final String? invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SalePageTitleBar(
              currentRoute: AppRoutes.saleInvoices,
              onSettingsTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: _cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _sectionGap,
                      _sectionGap,
                      _sectionGap,
                      0,
                    ),
                    child: _PageHeader(invoiceId: invoiceId),
                  ),
                  const SizedBox(height: _sectionGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _sectionGap,
                    ),
                    child: _FormFields(invoiceId: invoiceId),
                  ),
                  const SizedBox(height: _sectionGap),
                  SaleLineItemsTable(
                    invoiceId: invoiceId,
                    embedded: true,
                  ),
                  const Divider(height: 1, color: _cardBorder),
                  Padding(
                    padding: const EdgeInsets.all(_sectionGap),
                    child: AddSaleFooter(invoiceId: invoiceId),
                  ),
                  const Divider(height: 1, color: _cardBorder),
                  _BottomActionBar(invoiceId: invoiceId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends ConsumerWidget {
  const _PageHeader({this.invoiceId});

  final String? invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSaleFormProvider(invoiceId: invoiceId));
    final notifier = ref.read(
      addSaleFormProvider(invoiceId: invoiceId).notifier,
    );

    return Row(
      children: [
        Text(
          invoiceId == null ? 'Sale' : 'Edit Sale',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _SaleTypeToggle(
          saleType: form.saleType,
          onChanged: notifier.toggleSaleType,
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import Challan coming soon')),
            );
          },
          icon: const Icon(Icons.upload_file_outlined, size: 16),
          label: const Text('Import Challan', style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: const Color(0xFFE8F0FE),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: const BorderSide(color: Color(0xFF90CAF9)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _GodownSelector(
          value: form.godown,
          onSelected: notifier.updateGodown,
        ),
      ],
    );
  }
}

class _GodownSelector extends ConsumerWidget {
  const _GodownSelector({
    required this.value,
    required this.onSelected,
  });

  final String value;
  final void Function(String name, {String? godownId}) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final godownsAsync = ref.watch(inventoryGodownsProvider);
    final options = godownsAsync.maybeWhen(
      data: (godowns) => godowns.map((godown) => godown.name).toList(),
      orElse: () => SaleDropdownOptions.godowns,
    );

    return GodownLabelSelector(
      value: value,
      options: options,
      onSelected: (name) {
        final godowns = ref.read(inventoryGodownsProvider).value ?? [];
        final match = godowns.where((godown) => godown.name == name).firstOrNull;
        onSelected(name, godownId: match?.id);
      },
    );
  }
}

class _SaleTypeToggle extends StatelessWidget {
  const _SaleTypeToggle({
    required this.saleType,
    required this.onChanged,
  });

  final SaleType saleType;
  final ValueChanged<SaleType> onChanged;

  static const _trackColor = Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _trackColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TogglePill(
            label: 'Credit',
            isActive: saleType == SaleType.credit,
            onTap: () => onChanged(SaleType.credit),
          ),
          _TogglePill(
            label: 'Cash',
            isActive: saleType == SaleType.cash,
            onTap: () => onChanged(SaleType.cash),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FormFields extends ConsumerStatefulWidget {
  const _FormFields({this.invoiceId});

  final String? invoiceId;

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _invoiceDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addSaleFormProvider(invoiceId: widget.invoiceId));
    final notifier = ref.read(
      addSaleFormProvider(invoiceId: widget.invoiceId).notifier,
    );
    final isAutoNumber = form.invoiceNumberMode == InvoiceNumberMode.auto;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BillingNamePartySearchField(
                      value: form.billingName,
                      hasError: form.partyHasError,
                      emptyPlaceholder: 'Billing Name (Optional)',
                      onSelected: notifier.updateBillingName,
                      onPartySelectedWithId: (partyId, name) =>
                          notifier.updateParty(
                            partyId: partyId,
                            partyName: name,
                          ),
                      onPartyCreated: (party) {
                        notifier.updateBillingName(party.partyName);
                        if (party.phone.isNotEmpty) {
                          notifier.updatePhone(party.phone);
                        }
                        if (party.billingAddress.isNotEmpty) {
                          notifier.updateAddresses(
                            billing: party.billingAddress,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: _sectionGap),
                  Expanded(
                    child: _LabeledField(
                      label: 'Phone No.',
                      child: _SaleTextField(
                        initialValue: form.phone,
                        hintText: 'Phone number',
                        keyboardType: TextInputType.phone,
                        onChanged: notifier.updatePhone,
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
                    child: _LabeledField(
                      label: 'Billing Address',
                      child: _SaleTextField(
                        initialValue: form.billingAddress,
                        hintText: 'Billing address',
                        minLines: _addressFieldLines,
                        maxLines: _addressFieldLines,
                        onChanged: (value) =>
                            notifier.updateAddresses(billing: value),
                      ),
                    ),
                  ),
                  const SizedBox(width: _sectionGap),
                  Expanded(
                    child: _LabeledField(
                      label: 'Shipping Address',
                      child: _SaleTextField(
                        initialValue: form.shippingAddress,
                        hintText: 'Shipping address',
                        minLines: _addressFieldLines,
                        maxLines: _addressFieldLines,
                        onChanged: (value) =>
                            notifier.updateAddresses(shipping: value),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: _sectionGap),
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LabeledField(
                label: 'Invoice Number',
                child: _SaleTextField(
                  initialValue: isAutoNumber ? 'Auto' : form.invoiceNumber,
                  hintText: 'Invoice number',
                  readOnly: isAutoNumber,
                  filled: isAutoNumber,
                  onChanged: notifier.updateInvoiceNumber,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Invoice Date',
                child: SaleSingleDatePickerAnchor(
                  key: _invoiceDatePickerKey,
                  selectedDate: form.invoiceDate,
                  onDateSelected: notifier.updateInvoiceDate,
                  child: _PickerField(
                    value: formatSaleSingleDate(form.invoiceDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _invoiceDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
              const SizedBox(height: _sectionGap),
              if (form.saleType == SaleType.credit) ...[
                _LabeledField(
                  label: 'Due Date',
                  child: SaleSingleDatePickerAnchor(
                    key: _dueDatePickerKey,
                    selectedDate: form.dueDate,
                    onDateSelected: notifier.updateDueDate,
                    child: _PickerField(
                      value: form.dueDate != null
                          ? formatSaleSingleDate(form.dueDate)
                          : 'Select Date',
                      icon: Icons.calendar_today_outlined,
                      isPlaceholder: form.dueDate == null,
                      onTap: () => _dueDatePickerKey.currentState?.toggle(),
                    ),
                  ),
                ),
                const SizedBox(height: _sectionGap),
              ],
              _LabeledField(
                label: 'Time',
                child: _PickerField(
                  value: _formatTime(form.invoiceTime),
                  icon: Icons.access_time,
                  onTap: () => _pickTime(context, form.invoiceTime),
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'State of Supply',
                child: SaleGenericSelectDropdown(
                  value: form.stateOfSupply,
                  options: SaleDropdownOptions.indianStates,
                  hintText: 'Select state',
                  maxMenuHeight: 280,
                  onSelected: notifier.updateStateOfSupply,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'E-Way Bill No.',
                child: _SaleTextField(
                  initialValue: form.eWayBillNo,
                  hintText: 'E-Way bill number',
                  onChanged: notifier.updateEWayBillNo,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  // Built-in showTimePicker — simpler than a custom overlay; slight visual mismatch.
  Future<void> _pickTime(BuildContext context, TimeOfDay? current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
    );
    if (picked != null) {
      ref
          .read(addSaleFormProvider(invoiceId: widget.invoiceId).notifier)
          .updateInvoiceTime(picked);
    }
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({this.invoiceId});

  final String? invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSaleFormProvider(invoiceId: invoiceId));
    final notifier = ref.read(
      addSaleFormProvider(invoiceId: invoiceId).notifier,
    );
    final isCash = form.saleType == SaleType.cash;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (!isCash) ...[
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Print preview coming soon')),
                );
              },
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text(
                'Print / Preview',
                style: TextStyle(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                side: const BorderSide(color: _cardBorder),
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => _handleCancel(context, ref),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                side: const BorderSide(color: _cardBorder),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: () => _handleSave(context, ref, notifier),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 13)),
            ),
          ] else ...[
            const Spacer(),
            _SaveSplitButton(
              onSave: () => _handleSave(context, ref, notifier),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final form = ref.read(addSaleFormProvider(invoiceId: invoiceId));
    if (form.isDirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (discard != true || !context.mounted) return;
    }
    if (context.mounted) context.pop();
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    AddSaleForm notifier,
  ) async {
    final error = await notifier.saveInvoice();
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice saved successfully')),
    );
    context.go(AppRoutes.saleInvoices);
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
        Text(
          label,
          style: saleFieldLabelStyle,
        ),
        const SizedBox(height: 4),
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
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.filled = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final bool filled;

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
      readOnly: widget.readOnly,
      style: saleFieldTextStyle,
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        filled: widget.filled,
      ),
      keyboardType: widget.keyboardType,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.icon,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return SaleFieldTrigger(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: saleFieldTextStyle.copyWith(
                color: isPlaceholder ? saleFieldErrorColor : null,
              ),
            ),
          ),
          Icon(icon, size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Vyapar-style Save button with a dropdown for Save & Print / Share.
class _SaveSplitButton extends StatelessWidget {
  const _SaveSplitButton({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 13)),
          ),
          Container(width: 1, color: Colors.white38),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'save') {
                onSave();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$value coming soon')),
                );
              }
            },
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: _cardBorder),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'save', child: Text('Save')),
              PopupMenuItem(value: 'Save & Print', child: Text('Save & Print')),
              PopupMenuItem(value: 'Save & Share', child: Text('Save & Share')),
            ],
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
