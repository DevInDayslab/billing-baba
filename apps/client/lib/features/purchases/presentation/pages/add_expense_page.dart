import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/core/widgets/transaction_success_toast.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/add_expense_category_dialog.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/add_expense_footer.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/expense_line_items_table.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/providers/add_expense_form_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addExpenseRed = Color(0xFFD32F2F);

class AddExpensePage extends ConsumerWidget {
  const AddExpensePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PurchasePageTitleBar(currentRoute: AppRoutes.purchaseExpenses),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _sectionGap,
                      _sectionGap,
                      _sectionGap,
                      0,
                    ),
                    child: _PageHeader(),
                  ),
                  SizedBox(height: _sectionGap),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _sectionGap),
                    child: _FormFields(),
                  ),
                  SizedBox(height: _sectionGap),
                  ExpenseLineItemsTable(),
                  Divider(height: 1, color: _cardBorder),
                  Padding(
                    padding: EdgeInsets.all(_sectionGap),
                    child: AddExpenseFooter(),
                  ),
                  Divider(height: 1, color: _cardBorder),
                  _BottomActionBar(),
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
  const _PageHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addExpenseFormProvider);
    final notifier = ref.read(addExpenseFormProvider.notifier);

    return Row(
      children: [
        const Text(
          'Expense',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: form.gstEnabled,
              onChanged: (value) => notifier.toggleGst(value: value),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const Text(
              'GST',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormFields extends ConsumerStatefulWidget {
  const _FormFields();

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _expenseDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addExpenseFormProvider);
    final notifier = ref.read(addExpenseFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (form.gstEnabled)
              Expanded(
                flex: 2,
                child: _LabeledField(
                  label: 'Search by Name/Phone *',
                  child: BillingNamePartySearchField(
                    value: form.party,
                    hasError: form.partyHasError,
                    errorMessage: 'Party is required',
                    onSelected: notifier.updateParty,
                  ),
                ),
              ),
            if (form.gstEnabled) const SizedBox(width: _sectionGap),
            Expanded(
              flex: form.gstEnabled ? 2 : 3,
              child: _LabeledField(
                label: 'Expense Category *',
                child: ExpenseCategoryDropdown(
                  value: form.category,
                  hasError: form.categoryHasError,
                  onSelected: (id, name) =>
                      notifier.updateCategory(id: id, name: name),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Expense No',
                child: _ExpenseTextField(
                  initialValue: form.expenseNumber,
                  hintText: 'Expense number',
                  onChanged: notifier.updateExpenseNumber,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: form.gstEnabled ? 'Bill Date' : 'Date',
                child: SaleSingleDatePickerAnchor(
                  key: _expenseDatePickerKey,
                  selectedDate: form.expenseDate,
                  onDateSelected: notifier.updateExpenseDate,
                  child: _PickerField(
                    value: form.expenseDate != null
                        ? formatSaleSingleDate(form.expenseDate)
                        : 'Select Date',
                    icon: Icons.calendar_today_outlined,
                    isPlaceholder: form.expenseDate == null,
                    onTap: () => _expenseDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Time',
                child: _PickerField(
                  value: _formatTime(form.expenseTime),
                  icon: Icons.access_time,
                  isPlaceholder: form.expenseTime == null,
                  onTap: () => _pickTime(context, form.expenseTime),
                ),
              ),
            ),
          ],
        ),
        if (form.gstEnabled) ...[
          const SizedBox(height: _sectionGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _LabeledField(
                  label: 'Payment Terms',
                  child: SaleGenericSelectDropdown(
                    value: form.paymentTerms,
                    options: purchasePaymentTerms,
                    hintText: 'Select terms',
                    onSelected: notifier.updatePaymentTerms,
                  ),
                ),
              ),
              const SizedBox(width: _sectionGap),
              Expanded(
                child: _LabeledField(
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
              ),
              const SizedBox(width: _sectionGap),
              Expanded(
                flex: 2,
                child: _LabeledField(
                  label: 'State of supply',
                  child: SaleGenericSelectDropdown(
                    value: form.stateOfSupply,
                    options: SaleDropdownOptions.indianStates,
                    hintText: 'Select state',
                    maxMenuHeight: 280,
                    onSelected: notifier.updateStateOfSupply,
                  ),
                ),
              ),
            ],
          ),
        ],
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
      ref.read(addExpenseFormProvider.notifier).updateExpenseTime(picked);
    }
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addExpenseFormProvider.notifier);

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
              backgroundColor: _addExpenseRed,
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
    final form = ref.read(addExpenseFormProvider);
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

  void _handleSave(
    BuildContext context,
    WidgetRef ref,
    AddExpenseForm notifier,
  ) {
    final saved = notifier.save();
    if (!saved) return;

    showTransactionSuccessToast(context);
    context.go(AppRoutes.purchaseExpenses);
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

class _ExpenseTextField extends StatefulWidget {
  const _ExpenseTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<_ExpenseTextField> createState() => _ExpenseTextFieldState();
}

class _ExpenseTextFieldState extends State<_ExpenseTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_ExpenseTextField oldWidget) {
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon, size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
