import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/models/debit_note_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/debit_note_footer.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/debit_note_line_items_table.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/transaction_form_busy_overlay.dart';
import 'package:billing_baba/features/purchases/providers/debit_note_form_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_time_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

class AddDebitNotePage extends ConsumerWidget {
  const AddDebitNotePage({this.debitNoteId, super.key});

  final String? debitNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(debitNoteFormProvider(debitNoteId: debitNoteId));

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
                  currentRoute: AppRoutes.purchaseReturnDebitNote,
                  onSettingsTap: () {},
                  onBack: () => leaveTransactionFormPage(
                    context: context,
                    isDirty: form.isDirty,
                    isSaving: form.isSaving,
                    listRoute: AppRoutes.purchaseReturnDebitNote,
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
                        child: _PageHeader(debitNoteId: debitNoteId),
                      ),
                      const SizedBox(height: _sectionGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _sectionGap,
                        ),
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
        ),
        Positioned.fill(
          child: TransactionFormBusyOverlay(
            isLoading: form.isLoading,
            isSaving: form.isSaving,
            savingLabel: debitNoteId == null
                ? 'Saving purchase return…'
                : 'Updating purchase return…',
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends ConsumerWidget {
  const _PageHeader({this.debitNoteId});

  final String? debitNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(debitNoteFormProvider(debitNoteId: debitNoteId));
    final notifier = ref.read(
      debitNoteFormProvider(debitNoteId: debitNoteId).notifier,
    );

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
    final form = ref.watch(
      debitNoteFormProvider(debitNoteId: widget.debitNoteId),
    );
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
              errorMessage: 'Please select a party',
              onSelected: notifier.updateParty,
              onPartySelectedWithId: (partyId, name) =>
                  notifier.updateParty(name, partyId: partyId),
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
                child: SaleTimeDropdown(
                  value: form.returnTime,
                  hasError: form.returnTime == null,
                  onSelected: notifier.updateReturnTime,
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
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({this.debitNoteId});

  final String? debitNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(debitNoteFormProvider(debitNoteId: debitNoteId));
    final notifier = ref.read(
      debitNoteFormProvider(debitNoteId: debitNoteId).notifier,
    );

    final isSaving = form.isSaving;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Spacer(),
          OutlinedButton(
            onPressed: isSaving
                ? null
                : () => leaveTransactionFormPage(
                    context: context,
                    isDirty: form.isDirty,
                    isSaving: form.isSaving,
                    listRoute: AppRoutes.purchaseReturnDebitNote,
                  ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: const BorderSide(color: _cardBorder),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (form.documentId != null) ...[
            OutlinedButton.icon(
              onPressed: () => _handlePrintPreview(context, ref, form),
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
            IconButton(
              onPressed: () => _handleShare(context, ref, form),
              icon: const Icon(Icons.share_outlined, size: 20),
              color: AppColors.textSecondary,
              tooltip: 'Share PDF',
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          FilledButton(
            onPressed: isSaving
                ? null
                : () => _handleSave(context, ref, notifier),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
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

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    DebitNoteForm notifier,
  ) async {
    final form = ref.read(debitNoteFormProvider(debitNoteId: debitNoteId));
    await handleTransactionFormSave(
      context: context,
      isSaving: form.isSaving,
      save: notifier.saveDebitNote,
      listRoute: AppRoutes.purchaseReturnDebitNote,
    );
  }

  Future<void> _handlePrintPreview(
    BuildContext context,
    WidgetRef ref,
    DebitNoteFormState form,
  ) async {
    final docId = form.documentId ?? debitNoteId;
    if (docId == null) return;
    await DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.debitNote(docId),
      filename: DocumentPrintActions.filenameFor(form.returnNo),
    );
  }

  Future<void> _handleShare(
    BuildContext context,
    WidgetRef ref,
    DebitNoteFormState form,
  ) async {
    final docId = form.documentId ?? debitNoteId;
    if (docId == null) return;
    await DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.debitNote(docId),
      filename: DocumentPrintActions.filenameFor(form.returnNo),
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
