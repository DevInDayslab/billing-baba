import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/models/credit_note_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/credit_note_footer.dart';
import 'package:billing_baba/features/sales/presentation/widgets/credit_note_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/providers/credit_note_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

class AddCreditNotePage extends ConsumerWidget {
  const AddCreditNotePage({super.key});

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
              currentRoute: AppRoutes.saleReturnCreditNote,
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
                    child: _FormFields(),
                  ),
                  SizedBox(height: _sectionGap),
                  CreditNoteLineItemsTable(),
                  Divider(height: 1, color: _cardBorder),
                  Padding(
                    padding: EdgeInsets.all(_sectionGap),
                    child: CreditNoteFooter(),
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

class _FormFields extends ConsumerStatefulWidget {
  const _FormFields();

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _originalInvoiceDatePickerKey =
      GlobalKey<SaleSingleDatePickerAnchorState>();
  final _returnDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(creditNoteFormProvider);
    final notifier = ref.read(creditNoteFormProvider.notifier);

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
                    child: _LabeledField(
                      label: 'Party Name',
                      child: BillingNamePartySearchField(
                        value: form.party,
                        hasError: form.partyHasError,
                        emptyPlaceholder: 'Search Party...',
                        errorMessage: 'Party is required',
                        onSelected: notifier.updateParty,
                        onPartySelectedWithId: (partyId, name) =>
                            notifier.updatePartyWithId(
                              partyId: partyId,
                              partyName: name,
                            ),
                        onPartyCreated: (party) {
                          notifier.updateParty(party.partyName);
                          if (party.phone.isNotEmpty) {
                            notifier.updatePhone(party.phone);
                          }
                        },
                      ),
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
                label: 'Return No.',
                child: _SaleTextField(
                  initialValue: form.returnNo,
                  hintText: 'Return number',
                  onChanged: notifier.updateReturnNo,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Original Inv. No.',
                child: _SaleTextField(
                  initialValue: form.originalInvoiceNo,
                  hintText: 'Original invoice number',
                  onChanged: notifier.updateOriginalInvoiceNo,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Invoice Date',
                child: SaleSingleDatePickerAnchor(
                  key: _originalInvoiceDatePickerKey,
                  selectedDate: form.originalInvoiceDate,
                  onDateSelected: notifier.updateOriginalInvoiceDate,
                  child: _PickerField(
                    value: form.originalInvoiceDate != null
                        ? formatSaleSingleDate(form.originalInvoiceDate)
                        : 'DD/MM/YYYY',
                    icon: Icons.calendar_today_outlined,
                    isPlaceholder: form.originalInvoiceDate == null,
                    onTap: () =>
                        _originalInvoiceDatePickerKey.currentState?.toggle(),
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
                    value: formatSaleSingleDate(form.returnDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _returnDatePickerKey.currentState?.toggle(),
                  ),
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
  const _BottomActionBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(creditNoteFormProvider);
    final notifier = ref.read(creditNoteFormProvider.notifier);

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
          if (form.documentId != null) ...[
            OutlinedButton.icon(
              onPressed: () => _handlePrintPreview(context, ref, form),
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text('Print / Preview', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            onPressed: form.isSaving
                ? null
                : () => _handleSave(context, ref, notifier),
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
    final form = ref.read(creditNoteFormProvider);
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
    CreditNoteForm notifier,
  ) async {
    final error = await notifier.save();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credit note saved successfully')),
    );
    context.go(AppRoutes.saleReturnCreditNote);
  }

  Future<void> _handlePrintPreview(
    BuildContext context,
    WidgetRef ref,
    CreditNoteFormState form,
  ) async {
    final docId = form.documentId;
    if (docId == null) return;
    await DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.creditNote(docId),
      filename: DocumentPrintActions.filenameFor(form.returnNo),
    );
  }

  Future<void> _handleShare(
    BuildContext context,
    WidgetRef ref,
    CreditNoteFormState form,
  ) async {
    final docId = form.documentId;
    if (docId == null) return;
    await DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.creditNote(docId),
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

class _SaleTextField extends StatefulWidget {
  const _SaleTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;

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
      decoration: buildSaleFieldDecoration(hint: widget.hintText),
      keyboardType: widget.keyboardType,
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
