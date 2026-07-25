import 'package:billing_baba/core/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/models/credit_note_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/credit_note_footer.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/credit_note_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/credit_note_tabs_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/application/credit_note_form_provider.dart';
import 'package:billing_baba/features/sales/application/credit_note_tabs_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

class DesktopAddCreditNotePage extends ConsumerStatefulWidget {
  const DesktopAddCreditNotePage({
    this.creditNoteId,
    this.fromInvoiceId,
    super.key,
  });

  final String? creditNoteId;
  final String? fromInvoiceId;

  @override
  ConsumerState<DesktopAddCreditNotePage> createState() => _AddCreditNotePageState();
}

class _AddCreditNotePageState extends ConsumerState<DesktopAddCreditNotePage> {
  var _initialized = false;
  late final String _fromInvoiceSessionKey =
      'from_invoice_${widget.fromInvoiceId}';

  bool get _supportsTabs =>
      widget.creditNoteId == null && widget.fromInvoiceId == null;

  String get _sessionKey {
    if (widget.fromInvoiceId != null) return _fromInvoiceSessionKey;
    if (widget.creditNoteId != null) return widget.creditNoteId!;
    if (_supportsTabs) {
      return ref.read(creditNoteTabsProvider()).activeTab.sessionKey;
    }
    return 'default';
  }

  @override
  void initState() {
    super.initState();
    if (widget.fromInvoiceId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeFromInvoice(),
      );
    } else if (widget.creditNoteId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeEditForm(),
      );
    } else {
      _initialized = true;
    }
  }

  Future<void> _initializeFromInvoice() async {
    await ref
        .read(
          creditNoteFormProvider(sessionKey: _fromInvoiceSessionKey).notifier,
        )
        .loadFromInvoice(widget.fromInvoiceId!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _initializeEditForm() async {
    await ref
        .read(creditNoteFormProvider(sessionKey: widget.creditNoteId!).notifier)
        .loadDocument(widget.creditNoteId!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  void _handleBack() {
    returnToTransactionList(context, AppRoutes.saleReturnCreditNote);
  }

  @override
  Widget build(BuildContext context) {
    if (_supportsTabs) {
      final tabsState = ref.watch(creditNoteTabsProvider());
      final activeSessionKey = tabsState.activeTab.sessionKey;

      ref.listen(
        creditNoteFormProvider(sessionKey: activeSessionKey),
        (previous, next) {
          if (previous?.party == next.party) return;
          ref
              .read(creditNoteTabsProvider().notifier)
              .updateTabLabel(
                tabsState.activeIndex,
                creditNoteTabLabelForForm(
                  creditNoteNumber: tabsState.activeTab.creditNoteNumber,
                  partyName: next.party,
                ),
              );
        },
      );
    }

    final sessionKey = _sessionKey;

    if (!_initialized &&
        (widget.creditNoteId != null || widget.fromInvoiceId != null)) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: SalePageTitleBar(
              currentRoute: AppRoutes.saleReturnCreditNote,
              onSettingsTap: () {},
              onBack: _handleBack,
            ),
          ),
          if (_supportsTabs) ...[
            const SizedBox(height: AppSpacing.sm),
            const CreditNoteTabsBar(),
          ],
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: DecoratedBox(
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
                      child: _PageHeader(
                        sessionKey: sessionKey,
                        isEditing: widget.creditNoteId != null,
                      ),
                    ),
                    const SizedBox(height: _sectionGap),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _sectionGap,
                      ),
                      child: _FormFields(sessionKey: sessionKey),
                    ),
                    const SizedBox(height: _sectionGap),
                    CreditNoteLineItemsTable(
                      sessionKey: sessionKey,
                      embedded: true,
                    ),
                    const Divider(height: 1, color: _cardBorder),
                    Padding(
                      padding: const EdgeInsets.all(_sectionGap),
                      child: CreditNoteFooter(sessionKey: sessionKey),
                    ),
                    const Divider(height: 1, color: _cardBorder),
                    _BottomActionBar(
                      sessionKey: sessionKey,
                      isEditing: widget.creditNoteId != null,
                      supportsTabs: _supportsTabs,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends ConsumerStatefulWidget {
  const _PageHeader({
    required this.sessionKey,
    this.isEditing = false,
  });

  final String sessionKey;
  final bool isEditing;

  @override
  ConsumerState<_PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends ConsumerState<_PageHeader> {
  final _returnDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _originalInvoiceDatePickerKey =
      GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      creditNoteFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      creditNoteFormProvider(sessionKey: widget.sessionKey).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              widget.isEditing ? 'Edit Credit Note' : 'Credit Note',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            _InlineHeaderField(
              label: 'Return No.',
              fieldWidth: 80,
              child: _SaleTextField(
                initialValue: form.returnNo,
                hintText: 'Return number',
                compact: true,
                onChanged: notifier.updateReturnNo,
              ),
            ),
            const SizedBox(width: _sectionGap),
            _InlineHeaderField(
              label: 'Invoice Number',
              fieldWidth: 100,
              child: _SaleTextField(
                initialValue: form.originalInvoiceNo,
                hintText: 'Invoice number',
                compact: true,
                onChanged: notifier.updateOriginalInvoiceNo,
              ),
            ),
            const SizedBox(width: _sectionGap),
            _InlineHeaderField(
              label: 'Invoice Date',
              fieldWidth: 120,
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
                  compact: true,
                  onTap: () =>
                      _originalInvoiceDatePickerKey.currentState?.toggle(),
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            _InlineHeaderField(
              label: 'Date',
              fieldWidth: 120,
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
                  compact: true,
                  onTap: () => _returnDatePickerKey.currentState?.toggle(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Spacer(),
            _InlineHeaderField(
              label: 'Time',
              fieldWidth: 100,
              child: SaleTimeDropdown(
                value: form.returnTime,
                compact: true,
                onSelected: notifier.updateReturnTime,
              ),
            ),
            const SizedBox(width: _sectionGap),
            _InlineHeaderField(
              label: 'State of supply',
              fieldWidth: 140,
              child: SaleGenericSelectDropdown(
                value: form.stateOfSupply,
                options: SaleDropdownOptions.indianStates,
                hintText: 'Select state',
                maxMenuHeight: 280,
                compact: true,
                onSelected: notifier.updateStateOfSupply,
              ),
            ),
            const SizedBox(width: _sectionGap),
            _GodownSelector(
              value: form.godown,
              onSelected: notifier.updateGodown,
            ),
          ],
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
        final match = godowns
            .where((godown) => godown.name == name)
            .firstOrNull;
        onSelected(name, godownId: match?.id);
      },
    );
  }
}

class _FormFields extends ConsumerWidget {
  const _FormFields({required this.sessionKey});

  final String sessionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(creditNoteFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(
      creditNoteFormProvider(sessionKey: sessionKey).notifier,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _LabeledField(
            label: 'Party *',
            child: BillingNamePartySearchField(
              value: form.party,
              selectedPartyId: form.partyId,
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
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({
    required this.sessionKey,
    this.isEditing = false,
    this.supportsTabs = false,
  });

  final String sessionKey;
  final bool isEditing;
  final bool supportsTabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(creditNoteFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(
      creditNoteFormProvider(sessionKey: sessionKey).notifier,
    );
    final isSaving = form.isSaving;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (form.documentId != null)
            OutlinedButton.icon(
              onPressed: isSaving
                  ? null
                  : () => _handlePrintPreview(context, ref, form),
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
          ShareMenuButton(
            onChannelSelected: isSaving
                ? null
                : (_) => _handleSaveAndShare(context, ref, notifier),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: isSaving
                ? null
                : () => _handleSave(context, ref, notifier),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
            ),
            child: isSaving
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Saving...', style: TextStyle(fontSize: 13)),
                    ],
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
    CreditNoteForm notifier,
  ) async {
    final form = ref.read(creditNoteFormProvider(sessionKey: sessionKey));
    if (form.isSaving) return;

    final error = await notifier.save();
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Credit note updated successfully.'
              : 'Credit note created successfully.',
        ),
      ),
    );
    _afterSave(context, ref);
  }

  Future<void> _handleSaveAndShare(
    BuildContext context,
    WidgetRef ref,
    CreditNoteForm notifier,
  ) async {
    final form = ref.read(creditNoteFormProvider(sessionKey: sessionKey));
    if (form.isSaving) return;

    final error = await notifier.save();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final saved = ref.read(creditNoteFormProvider(sessionKey: sessionKey));
    final docId = saved.documentId;
    if (docId != null) {
      await DocumentPrintActions.share(
        context,
        ref,
        PrintRequest.creditNote(docId),
        filename: DocumentPrintActions.filenameFor(saved.returnNo),
      );
    }
    if (context.mounted) _afterSave(context, ref);
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

  void _afterSave(BuildContext context, WidgetRef ref) {
    if (supportsTabs) {
      ref.invalidate(creditNoteFormProvider(sessionKey: sessionKey));
      ref.invalidate(creditNoteTotalTaxProvider(sessionKey: sessionKey));
      ref.invalidate(creditNoteGrandTotalProvider(sessionKey: sessionKey));
      final tabsState = ref.read(creditNoteTabsProvider());
      ref
          .read(creditNoteTabsProvider().notifier)
          .updateTabLabel(
            tabsState.activeIndex,
            creditNoteTabLabelForForm(
              creditNoteNumber: tabsState.activeTab.creditNoteNumber,
            ),
          );
      return;
    }
    returnToTransactionList(context, AppRoutes.saleReturnCreditNote);
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

class _InlineHeaderField extends StatelessWidget {
  const _InlineHeaderField({
    required this.label,
    required this.child,
    this.fieldWidth,
  });

  final String label;
  final Widget child;
  final double? fieldWidth;

  @override
  Widget build(BuildContext context) {
    final field = fieldWidth != null
        ? SizedBox(width: fieldWidth, child: child)
        : child;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: saleFieldLabelStyle),
        field,
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
    this.compact = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool compact;

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
        compact: widget.compact,
      ),
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
    this.compact = false,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPlaceholder;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SaleFieldTrigger(
      onTap: onTap,
      compact: compact,
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
