import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/debit_note_footer.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/debit_note_line_items_table.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/providers/debit_note_form_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

class AddDebitNotePage extends ConsumerWidget {
  const AddDebitNotePage({this.debitNoteId, super.key});

  final String? debitNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PurchasePageTitleBar(
              currentRoute: AppRoutes.purchaseReturnDebitNote,
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
                    child: _PageHeader(debitNoteId: debitNoteId),
                  ),
                  const SizedBox(height: _sectionGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _sectionGap),
                    child: _FormFields(debitNoteId: debitNoteId),
                  ),
                  const SizedBox(height: _sectionGap),
                  DebitNoteLineItemsTable(debitNoteId: debitNoteId),
                  const Divider(height: 1, color: _cardBorder),
                  Padding(
                    padding: const EdgeInsets.all(_sectionGap),
                    child: DebitNoteFooter(debitNoteId: debitNoteId),
                  ),
                  const Divider(height: 1, color: _cardBorder),
                  _BottomActionBar(debitNoteId: debitNoteId),
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
  const _PageHeader({this.debitNoteId});

  final String? debitNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(debitNoteFormProvider(debitNoteId: debitNoteId));
    final notifier =
        ref.read(debitNoteFormProvider(debitNoteId: debitNoteId).notifier);

    return Row(
      children: [
        const Text(
          'Debit Note',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        GodownLabelSelector(
          value: form.godown,
          onSelected: notifier.updateGodown,
        ),
      ],
    );
  }
}

class _FormFields extends ConsumerStatefulWidget {
  const _FormFields({this.debitNoteId});

  final String? debitNoteId;

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _billDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _returnDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form =
        ref.watch(debitNoteFormProvider(debitNoteId: widget.debitNoteId));
    final notifier = ref.read(
      debitNoteFormProvider(debitNoteId: widget.debitNoteId).notifier,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _LabeledField(
            label: 'Party *',
            child: BillingNamePartySearchField(
              value: form.party,
              hasError: form.partyHasError,
              errorMessage: 'Party is required',
              onSelected: notifier.updateParty,
            ),
          ),
        ),
        const SizedBox(width: _sectionGap),
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LabeledField(
                label: 'Return No.',
                child: _DebitNoteTextField(
                  initialValue: form.returnNo,
                  hintText: 'Return number',
                  onChanged: notifier.updateReturnNo,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Bill Number',
                child: _DebitNoteTextField(
                  initialValue: form.billNumber,
                  hintText: 'Bill number',
                  onChanged: notifier.updateBillNumber,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Bill Date',
                child: SaleSingleDatePickerAnchor(
                  key: _billDatePickerKey,
                  selectedDate: form.billDate,
                  onDateSelected: notifier.updateBillDate,
                  child: _PickerField(
                    value: form.billDate != null
                        ? formatSaleSingleDate(form.billDate)
                        : 'DD/MM/YYYY',
                    icon: Icons.calendar_today_outlined,
                    isPlaceholder: form.billDate == null,
                    onTap: () => _billDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Date',
                child: SaleSingleDatePickerAnchor(
                  key: _returnDatePickerKey,
                  selectedDate: form.returnDate,
                  onDateSelected: notifier.updateReturnDate,
                  child: _PickerField(
                    value: form.returnDate != null
                        ? formatSaleSingleDate(form.returnDate)
                        : 'DD/MM/YYYY',
                    icon: Icons.calendar_today_outlined,
                    isPlaceholder: form.returnDate == null,
                    onTap: () => _returnDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Time',
                child: _PickerField(
                  value: _formatTime(form.returnTime),
                  icon: Icons.access_time,
                  isPlaceholder: form.returnTime == null,
                  onTap: () => _pickTime(context, form.returnTime),
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'State of supply',
                child: SaleGenericSelectDropdown(
                  value: form.stateOfSupply,
                  options: SaleDropdownOptions.indianStates,
                  maxMenuHeight: 280,
                  onSelected: notifier.updateStateOfSupply,
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

  Future<void> _pickTime(BuildContext context, TimeOfDay? current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
    );
    if (picked != null) {
      ref
          .read(debitNoteFormProvider(debitNoteId: widget.debitNoteId).notifier)
          .updateReturnTime(picked);
    }
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({this.debitNoteId});

  final String? debitNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.read(debitNoteFormProvider(debitNoteId: debitNoteId).notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Spacer(),
          OutlinedButton(
            onPressed: () => _handleCancel(context, ref),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: const BorderSide(color: _cardBorder),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: AppSpacing.sm),
          ShareMenuButton(
            onChannelSelected: (channel) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${channel.label} coming soon')),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () => _handleSave(context, ref, notifier),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final form = ref.read(debitNoteFormProvider(debitNoteId: debitNoteId));
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
    DebitNoteForm notifier,
  ) async {
    final error = await notifier.saveDebitNote();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debit note saved successfully')),
    );
    context.go(AppRoutes.purchaseReturnDebitNote);
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
        Text(label, style: saleFieldLabelStyle),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _DebitNoteTextField extends StatefulWidget {
  const _DebitNoteTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<_DebitNoteTextField> createState() => _DebitNoteTextFieldState();
}

class _DebitNoteTextFieldState extends State<_DebitNoteTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_DebitNoteTextField oldWidget) {
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
      decoration: buildSaleFieldDecoration(hint: widget.hintText),
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
