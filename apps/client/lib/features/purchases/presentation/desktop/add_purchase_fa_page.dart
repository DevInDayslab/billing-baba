import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/purchases/application/add_purchase_fa_form_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_fa_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/add_purchase_fa_footer.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/payment_out_dialog.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_fa_line_items_table.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/transaction_form_busy_overlay.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/shared/widgets/share_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _linkPaymentGreen = Color(0xFF2E7D32);
const _saveBlue = Color(0xFF1565C0);

class DesktopAddPurchaseFaPage extends ConsumerWidget {
  const DesktopAddPurchaseFaPage({this.batchId, super.key});

  final String? batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPurchaseFaFormProvider(batchId: batchId));

    return Stack(
      children: [
        ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PurchasePageTitleBar(
                  currentRoute: AppRoutes.purchaseFa,
                  onBack: () => leaveTransactionFormPage(
                    context: context,
                    isDirty: form.isDirty,
                    isSaving: form.isSaving,
                    listRoute: AppRoutes.purchaseFa,
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
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          _sectionGap,
                          _sectionGap,
                          _sectionGap,
                          0,
                        ),
                        child: _PageHeader(),
                      ),
                      const SizedBox(height: _sectionGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _sectionGap,
                        ),
                        child: _FormFields(batchId: batchId),
                      ),
                      const SizedBox(height: _sectionGap),
                      PurchaseFaLineItemsTable(
                        embedded: true,
                        batchId: batchId,
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      Padding(
                        padding: const EdgeInsets.all(_sectionGap),
                        child: AddPurchaseFaFooter(batchId: batchId),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      _BottomActionBar(batchId: batchId),
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
            savingLabel: batchId == null
                ? 'Saving purchase FA…'
                : 'Updating purchase FA…',
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Purchase FA',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _FormFields extends ConsumerStatefulWidget {
  const _FormFields({this.batchId});

  final String? batchId;

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _billDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addPurchaseFaFormProvider(batchId: widget.batchId));
    final notifier = ref.read(
      addPurchaseFaFormProvider(batchId: widget.batchId).notifier,
    );

    if (form.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _LabeledField(
                label: 'Party *',
                child: BillingNamePartySearchField(
                  value: form.party,
                  selectedPartyId: form.partyId,
                  hasError: form.partyHasError,
                  errorMessage: 'Please select a party',
                  onSelected: notifier.updateParty,
                  onPartySelectedWithId: (partyId, name) =>
                      notifier.updateParty(name, partyId: partyId),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'E-Way Bill No.',
                child: _PurchaseFaTextField(
                  initialValue: form.eWayBillNo,
                  hintText: 'E-Way bill number',
                  onChanged: notifier.updateEWayBillNo,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Bill Number',
                child: _PurchaseFaTextField(
                  initialValue: form.billNumber,
                  hintText: 'Bill number',
                  onChanged: notifier.updateBillNumber,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Bill Date',
                child: SaleSingleDatePickerAnchor(
                  key: _billDatePickerKey,
                  selectedDate: form.billDate,
                  onDateSelected: notifier.updateBillDate,
                  child: _PickerField(
                    value: form.billDate != null
                        ? formatSaleSingleDate(form.billDate)
                        : 'Select Date',
                    icon: Icons.calendar_today_outlined,
                    isPlaceholder: form.billDate == null,
                    onTap: () => _billDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (form.party.trim().isNotEmpty) ...[
          const SizedBox(height: _sectionGap),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _LabeledField(
                  label: 'Billing Name (optional)',
                  child: _PurchaseFaTextField(
                    initialValue: form.billingName,
                    hintText: 'Billing name',
                    onChanged: notifier.updateBillingName,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: _sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Time',
                child: SaleTimeDropdown(
                  value: form.billTime,
                  hasError: form.billTime == null,
                  onSelected: notifier.updateBillTime,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
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
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({this.batchId});

  final String? batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPurchaseFaFormProvider(batchId: batchId));
    final notifier = ref.read(
      addPurchaseFaFormProvider(batchId: batchId).notifier,
    );
    final showLinkPayment = form.party.trim().isNotEmpty;
    final resolvedBatchId = batchId ?? form.batchId;
    final filename = form.billNumber.trim().isNotEmpty
        ? VoucherPrintActions.filenameFor(form.billNumber)
        : (resolvedBatchId != null
              ? VoucherPrintActions.filenameFor(resolvedBatchId)
              : 'fa_purchase');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (showLinkPayment)
            FilledButton.icon(
              onPressed: form.isSaving
                  ? null
                  : () => _handleLinkPayment(context, ref, notifier, form),
              icon: const Icon(Icons.link, size: 16),
              label: const Text('LINK PAYMENT', style: TextStyle(fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: _linkPaymentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          const Spacer(),
          if (resolvedBatchId != null) ...[
            OutlinedButton.icon(
              onPressed: () => VoucherPrintActions.previewFixedAssetPurchase(
                context,
                ref,
                resolvedBatchId,
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
            onPressed: form.isSaving
                ? null
                : () => leaveTransactionFormPage(
                    context: context,
                    isDirty: form.isDirty,
                    isSaving: form.isSaving,
                    listRoute: AppRoutes.purchaseFa,
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
              if (resolvedBatchId == null) {
                VoucherPrintActions.showSaveBeforePrinting(context);
                return;
              }
              VoucherPrintActions.shareFixedAssetPurchase(
                context,
                ref,
                resolvedBatchId,
                filename: filename,
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: form.isSaving
                ? null
                : () => _handleSave(context, ref, notifier),
            style: FilledButton.styleFrom(
              backgroundColor: _saveBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: form.isSaving
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

  Future<void> _handleLinkPayment(
    BuildContext context,
    WidgetRef ref,
    AddPurchaseFaForm notifier,
    AddPurchaseFaFormState form,
  ) async {
    if (form.isSaving) return;

    if (form.partyId == null || form.partyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a party first')),
      );
      return;
    }

    if (form.isDirty || form.batchId == null) {
      final error = await notifier.save();
      if (!context.mounted) return;
      if (error != null) {
        showTransactionFormSaveError(context, error);
        return;
      }
    }

    if (!context.mounted) return;
    await showPaymentOutDialog(
      context,
      initialPartyId: form.partyId,
      initialPartyName: form.party,
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    AddPurchaseFaForm notifier,
  ) async {
    final form = ref.read(addPurchaseFaFormProvider(batchId: batchId));
    await handleTransactionFormSave(
      context: context,
      isSaving: form.isSaving,
      save: notifier.save,
      listRoute: AppRoutes.purchaseFa,
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

class _PurchaseFaTextField extends StatefulWidget {
  const _PurchaseFaTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<_PurchaseFaTextField> createState() => _PurchaseFaTextFieldState();
}

class _PurchaseFaTextFieldState extends State<_PurchaseFaTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_PurchaseFaTextField oldWidget) {
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
