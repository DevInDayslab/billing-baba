import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/other_income/application/add_other_income_form_provider.dart';
import 'package:billing_baba/features/other_income/application/other_incomes_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/add_other_income_category_dialog.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/add_other_income_footer.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/other_income_line_items_table.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/other_income_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/transaction_form_busy_overlay.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/shared/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/shared/widgets/share_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addOtherIncomeGreen = Color(0xFFD32F2F);

class DesktopAddOtherIncomePage extends ConsumerStatefulWidget {
  const DesktopAddOtherIncomePage({this.incomeId, super.key});

  final String? incomeId;

  @override
  ConsumerState<DesktopAddOtherIncomePage> createState() => _AddOtherIncomePageState();
}

class _AddOtherIncomePageState extends ConsumerState<DesktopAddOtherIncomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(inventoryItemsProvider.notifier).refresh());
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addOtherIncomeFormProvider(incomeId: widget.incomeId));

    return Stack(
      children: [
        ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OtherIncomePageTitleBar(
                  currentRoute: AppRoutes.otherIncome,
                  onBack: () => leaveTransactionFormPage(
                    context: context,
                    isDirty: form.isDirty,
                    isSaving: form.isSaving,
                    listRoute: AppRoutes.otherIncome,
                  ),
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
                        child: _PageHeader(incomeId: widget.incomeId),
                      ),
                      const SizedBox(height: _sectionGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _sectionGap,
                        ),
                        child: _FormFields(incomeId: widget.incomeId),
                      ),
                      const SizedBox(height: _sectionGap),
                      OtherIncomeLineItemsTable(incomeId: widget.incomeId),
                      const Divider(height: 1, color: _cardBorder),
                      Padding(
                        padding: const EdgeInsets.all(_sectionGap),
                        child: AddOtherIncomeFooter(incomeId: widget.incomeId),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      _BottomActionBar(incomeId: widget.incomeId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: TransactionFormBusyOverlay(
            isLoading: form.isLoading,
            isSaving: form.isSaving,
            savingLabel: widget.incomeId == null
                ? 'Saving expense…'
                : 'Updating expense…',
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends ConsumerWidget {
  const _PageHeader({this.incomeId});

  final String? incomeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addOtherIncomeFormProvider(incomeId: incomeId));
    final notifier = ref.read(
      addOtherIncomeFormProvider(incomeId: incomeId).notifier,
    );

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
  const _FormFields({this.incomeId});

  final String? incomeId;

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _incomeDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addOtherIncomeFormProvider(incomeId: widget.incomeId));
    final notifier = ref.read(
      addOtherIncomeFormProvider(incomeId: widget.incomeId).notifier,
    );

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
                    selectedPartyId: form.partyId,
                    partyTypeFilter: PartyTypeFilter.supplier,
                    hasError: form.partyHasError,
                    errorMessage: 'Please select a supplier',
                    onSelected: notifier.updateParty,
                    onPartySelectedWithId: (partyId, partyName) =>
                        notifier.updateParty(partyName, partyId: partyId),
                  ),
                ),
              ),
            if (form.gstEnabled) const SizedBox(width: _sectionGap),
            Expanded(
              flex: form.gstEnabled ? 2 : 3,
              child: _LabeledField(
                label: 'Expense Category *',
                child: IncomeCategoryDropdown(
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
                label: 'Income No',
                child: _ExpenseTextField(
                  initialValue: resolveDocumentNumberDisplay(
                    documentId: form.incomeId,
                    currentNumber: form.incomeNumber,
                    preview: watchDocumentNumberPreview(
                      ref,
                      expenseDocumentSeries,
                    ),
                  ),
                  hintText: 'Income reference',
                  readOnly: true,
                  onChanged: (_) {},
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: form.gstEnabled ? 'Bill Date' : 'Date',
                child: SaleSingleDatePickerAnchor(
                  key: _incomeDatePickerKey,
                  selectedDate: form.incomeDate,
                  onDateSelected: notifier.updateOtherIncomeDate,
                  child: _PickerField(
                    value: form.incomeDate != null
                        ? formatSaleSingleDate(form.incomeDate)
                        : 'Select Date',
                    icon: Icons.calendar_today_outlined,
                    isPlaceholder: form.incomeDate == null,
                    onTap: () => _incomeDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Time',
                child: SaleTimeDropdown(
                  value: form.incomeTime,
                  hasError: form.incomeTime == null,
                  onSelected: notifier.updateOtherIncomeTime,
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
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({this.incomeId});

  final String? incomeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addOtherIncomeFormProvider(incomeId: incomeId));
    final notifier = ref.read(
      addOtherIncomeFormProvider(incomeId: incomeId).notifier,
    );
    final resolvedId = incomeId ?? form.incomeId;
    final isSaving = form.isSaving;
    final filename = form.incomeNumber.trim().isNotEmpty
        ? VoucherPrintActions.filenameFor(form.incomeNumber)
        : (resolvedId != null
              ? VoucherPrintActions.filenameFor(resolvedId)
              : 'expense');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (incomeId != null)
            TextButton.icon(
              onPressed: isSaving ? null : () => _handleDelete(context, ref),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
          const Spacer(),
          if (resolvedId != null) ...[
            OutlinedButton.icon(
              onPressed: () => VoucherPrintActions.previewExpense(
                context,
                ref,
                resolvedId,
                filename: filename,
              ),
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
            const SizedBox(width: AppSpacing.sm),
          ],
          OutlinedButton(
            onPressed: isSaving
                ? null
                : () => leaveTransactionFormPage(
                    context: context,
                    isDirty: form.isDirty,
                    isSaving: form.isSaving,
                    listRoute: AppRoutes.otherIncome,
                  ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: const BorderSide(color: _cardBorder),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: AppSpacing.sm),
          ShareMenuButton(
            onChannelSelected: (_) {
              if (resolvedId == null) {
                VoucherPrintActions.showSaveBeforePrinting(context);
                return;
              }
              VoucherPrintActions.shareExpense(
                context,
                ref,
                resolvedId,
                filename: filename,
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: isSaving
                ? null
                : () => _handleSave(context, ref, notifier),
            style: FilledButton.styleFrom(
              backgroundColor: _addOtherIncomeGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    if (incomeId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text(
          'This expense will be permanently removed. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await ref
        .read(otherIncomeTransactionsProvider.notifier)
        .deleteOtherIncome(incomeId!);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ref
        .read(otherIncomeSaveSuccessMessageProvider.notifier)
        .setMessage('Expense deleted successfully.');
    returnToTransactionList(context, AppRoutes.otherIncome);
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    AddOtherIncomeForm notifier,
  ) async {
    final form = ref.read(addOtherIncomeFormProvider(incomeId: incomeId));
    final listRoute = form.gstEnabled && incomeId == null
        ? AppRoutes.purchaseBills
        : AppRoutes.otherIncome;

    await handleTransactionFormSave(
      context: context,
      isSaving: form.isSaving,
      save: notifier.saveOtherIncome,
      listRoute: listRoute,
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
    this.readOnly = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final bool readOnly;

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
      readOnly: widget.readOnly,
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        filled: widget.readOnly,
      ),
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
