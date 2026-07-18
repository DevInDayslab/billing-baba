import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/close_form_dialog.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/pricing/providers/item_api_tier_prices_provider.dart';
import 'package:billing_baba/features/print/presentation/widgets/sale_invoice_print_actions.dart';
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
import 'package:billing_baba/features/sales/presentation/widgets/sale_tabs_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/providers/add_sale_form_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_tabs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addressFieldLines = 3;

class AddSalePage extends ConsumerStatefulWidget {
  const AddSalePage({
    this.invoiceId,
    this.duplicateFromId,
    this.attachOrderIds,
    this.readOnly = false,
    super.key,
  });

  final String? invoiceId;
  final String? duplicateFromId;
  final List<String>? attachOrderIds;
  final bool readOnly;

  @override
  ConsumerState<AddSalePage> createState() => _AddSalePageState();
}

class _AddSalePageState extends ConsumerState<AddSalePage> {
  var _initialized = false;
  late final String _duplicateSessionKey =
      'duplicate_${widget.duplicateFromId}';
  late final String _attachSessionKey =
      'attach_${widget.attachOrderIds?.join('_') ?? ''}';

  bool get _supportsTabs =>
      widget.invoiceId == null &&
      !widget.readOnly &&
      widget.duplicateFromId == null &&
      widget.attachOrderIds == null;

  String get _sessionKey {
    if (widget.attachOrderIds != null && widget.attachOrderIds!.isNotEmpty) {
      return _attachSessionKey;
    }
    if (widget.duplicateFromId != null) return _duplicateSessionKey;
    if (widget.invoiceId != null) return widget.invoiceId!;
    if (_supportsTabs) {
      return ref.read(saleTabsProvider()).activeTab.sessionKey;
    }
    return 'default';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sale item picker needs the full catalog, not an inventory-tab search subset.
      unawaited(
        ref.read(inventoryItemsProvider.notifier).refresh().then((_) async {
          final items = ref.read(inventoryItemsProvider).value ?? [];
          if (items.isEmpty) return;
          await ref
              .read(itemApiTierPricesProvider.notifier)
              .preloadForItemIds(items.map((item) => item.id));
        }),
      );
    });
    if (widget.invoiceId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeEditForm(),
      );
    } else if (widget.attachOrderIds != null &&
        widget.attachOrderIds!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeAttachForm(),
      );
    } else if (widget.duplicateFromId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeForm());
    } else {
      _initialized = true;
    }
  }

  Future<void> _initializeAttachForm() async {
    await ref
        .read(addSaleFormProvider(sessionKey: _attachSessionKey).notifier)
        .attachSaleOrders(widget.attachOrderIds!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _initializeEditForm() async {
    await ref
        .read(addSaleFormProvider(sessionKey: widget.invoiceId!).notifier)
        .loadDocument(widget.invoiceId!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _initializeForm() async {
    await ref
        .read(
          addSaleFormProvider(sessionKey: _duplicateSessionKey).notifier,
        )
        .duplicateDocument(widget.duplicateFromId!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  bool get _isEditing => widget.invoiceId != null;

  void _resetSaleFormState(String sessionKey) {
    ref.invalidate(addSaleFormProvider(sessionKey: sessionKey));
    ref.invalidate(addSaleSubtotalProvider(sessionKey: sessionKey));
    ref.invalidate(addSaleTotalTaxProvider(sessionKey: sessionKey));
    ref.invalidate(addSaleGrandTotalProvider(sessionKey: sessionKey));
  }

  Future<void> _handleClose() async {
    if (!widget.readOnly) {
      final confirmed = await showCloseFormDialog(
        context,
        title: 'Close Sale',
      );
      if (!confirmed || !mounted) return;
    }
    _resetSaleFormState(_sessionKey);
    _navigateBackToSaleInvoices();
  }

  void _navigateBackToSaleInvoices() {
    context.go(AppRoutes.saleInvoices);
  }

  void _navigateToSaleInvoices() {
    _resetSaleFormState(_sessionKey);
    _navigateBackToSaleInvoices();
  }

  @override
  Widget build(BuildContext context) {
    if (_supportsTabs) {
      final tabsState = ref.watch(saleTabsProvider());
      final activeSessionKey = tabsState.activeTab.sessionKey;

      ref.listen(
        addSaleFormProvider(sessionKey: activeSessionKey),
        (previous, next) {
          if (previous?.saleType == next.saleType &&
              previous?.billingName == next.billingName) {
            return;
          }
          ref
              .read(saleTabsProvider().notifier)
              .updateTabLabel(
                tabsState.activeIndex,
                saleTabLabelForForm(
                  saleNumber: tabsState.activeTab.saleNumber,
                  billingName: next.billingName,
                ),
              );
        },
      );
    }

    final sessionKey = _sessionKey;
    final isLoading = ref.watch(
      addSaleFormProvider(
        sessionKey: sessionKey,
      ).select((form) => form.isLoading),
    );

    if (!_initialized ||
        (widget.invoiceId != null && isLoading) ||
        (widget.duplicateFromId != null && isLoading) ||
        (widget.attachOrderIds != null && isLoading)) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleClose();
      },
      child: ColoredBox(
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
                currentRoute: AppRoutes.saleInvoices,
                onSettingsTap: () {},
              ),
            ),
            if (_supportsTabs) ...[
              const SizedBox(height: AppSpacing.sm),
              const SaleTabsBar(),
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
                          readOnly: widget.readOnly,
                          isEditing: _isEditing,
                          onClose: _handleClose,
                        ),
                      ),
                      const SizedBox(height: _sectionGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _sectionGap,
                        ),
                        child: IgnorePointer(
                          ignoring: widget.readOnly,
                          child: Opacity(
                            opacity: widget.readOnly ? 0.85 : 1,
                            child: _FormFields(sessionKey: sessionKey),
                          ),
                        ),
                      ),
                      const SizedBox(height: _sectionGap),
                      IgnorePointer(
                        ignoring: widget.readOnly,
                        child: Opacity(
                          opacity: widget.readOnly ? 0.85 : 1,
                          child: SaleLineItemsTable(
                            sessionKey: sessionKey,
                            embedded: true,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      Padding(
                        padding: const EdgeInsets.all(_sectionGap),
                        child: IgnorePointer(
                          ignoring: widget.readOnly,
                          child: Opacity(
                            opacity: widget.readOnly ? 0.85 : 1,
                            child: AddSaleFooter(sessionKey: sessionKey),
                          ),
                        ),
                      ),
                      if (!widget.readOnly) ...[
                        const Divider(height: 1, color: _cardBorder),
                        _BottomActionBar(
                          sessionKey: sessionKey,
                          isEditing: _isEditing,
                          onSaved: _navigateToSaleInvoices,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends ConsumerStatefulWidget {
  const _PageHeader({
    required this.sessionKey,
    required this.onClose,
    this.readOnly = false,
    this.isEditing = false,
  });

  final String sessionKey;
  final VoidCallback onClose;
  final bool readOnly;
  final bool isEditing;

  @override
  ConsumerState<_PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends ConsumerState<_PageHeader> {
  final _invoiceDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      addSaleFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey).notifier,
    );
    final isAutoNumber = form.invoiceNumberMode == InvoiceNumberMode.auto;

    return Row(
      children: [
        Text(
          widget.readOnly
              ? 'View Sale'
              : (widget.isEditing ? 'Edit Sale' : 'Sale'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        if (!widget.readOnly)
          _SaleTypeToggle(
            saleType: form.saleType,
            onChanged: notifier.toggleSaleType,
          ),
        const Spacer(),
        if (!widget.readOnly) ...[
          _InlineHeaderField(
            label: 'Invoice Number',
            fieldWidth: 80,
            child: _SaleTextField(
              initialValue: isAutoNumber ? 'Auto' : form.invoiceNumber,
              hintText: 'Invoice number',
              readOnly: isAutoNumber,
              filled: isAutoNumber,
              compact: true,
              onChanged: notifier.updateInvoiceNumber,
            ),
          ),
          const SizedBox(width: _sectionGap),
          _InlineHeaderField(
            label: 'Invoice Date',
            fieldWidth: 120,
            child: SaleSingleDatePickerAnchor(
              key: _invoiceDatePickerKey,
              selectedDate: form.invoiceDate,
              onDateSelected: notifier.updateInvoiceDate,
              child: _PickerField(
                value: formatSaleSingleDate(form.invoiceDate),
                icon: Icons.calendar_today_outlined,
                compact: true,
                onTap: () => _invoiceDatePickerKey.currentState?.toggle(),
              ),
            ),
          ),
          const SizedBox(width: _sectionGap),
          _InlineHeaderField(
            label: 'Time',
            fieldWidth: 100,
            child: SaleTimeDropdown(
              value: form.invoiceTime,
              compact: true,
              onSelected: notifier.updateInvoiceTime,
            ),
          ),
          if (form.saleType == SaleType.credit) ...[
            const SizedBox(width: _sectionGap),
            _InlineHeaderField(
              label: 'Due Date',
              fieldWidth: 120,
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
                  compact: true,
                  onTap: () => _dueDatePickerKey.currentState?.toggle(),
                ),
              ),
            ),
          ],
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
        IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close, size: 20),
          color: AppColors.textSecondary,
          tooltip: 'Close',
          visualDensity: VisualDensity.compact,
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
  const _FormFields({required this.sessionKey});

  final String sessionKey;

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      addSaleFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: widget.sessionKey).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                onPartySelected: notifier.applyPartyDetails,
                onPartySelectedWithId: (partyId, name) => notifier.updateParty(
                  partyId: partyId,
                  partyName: name,
                ),
                onPartyCreated: (party) {
                  notifier.updateBillingName(party.partyName);
                  if (party.phone.isNotEmpty) {
                    notifier.updatePhone(party.phone);
                  }
                  if (party.billingAddress.isNotEmpty) {
                    notifier.updateAddresses(billing: party.billingAddress);
                  }
                  if (party.shippingAddress.isNotEmpty) {
                    notifier.updateAddresses(shipping: party.shippingAddress);
                  }
                  if (party.gstin.isNotEmpty) {
                    notifier.updateGstin(party.gstin);
                  }
                  if (party.email.isNotEmpty) {
                    notifier.updateEmail(party.email);
                  }
                  if (party.state.isNotEmpty) {
                    notifier.updateStateOfSupply(party.state);
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
              flex: 2,
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
              flex: 2,
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
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'E-Way Bill No.',
                child: _SaleTextField(
                  initialValue: form.eWayBillNo,
                  hintText: 'E-Way bill number',
                  minLines: _addressFieldLines,
                  maxLines: _addressFieldLines,
                  onChanged: notifier.updateEWayBillNo,
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
  const _BottomActionBar({
    required this.sessionKey,
    required this.onSaved,
    this.isEditing = false,
  });

  final String sessionKey;
  final VoidCallback onSaved;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSaleFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: sessionKey).notifier,
    );
    final isSaving = form.isSaving;
    final isCash = form.saleType == SaleType.cash;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (!isCash)
            OutlinedButton.icon(
              onPressed: isSaving
                  ? null
                  : () => _handlePrintPreview(context, ref),
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
                : (_) => _handleSaveAndShare(context, ref),
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

  String? _documentIdForForm(AddSaleFormState form) => form.documentId;

  String _filename(AddSaleFormState form) {
    final number = form.invoiceNumber.trim();
    if (number.isNotEmpty) {
      return SaleInvoicePrintActions.filenameFor(number);
    }
    final id = _documentIdForForm(form);
    return id == null ? 'invoice' : SaleInvoicePrintActions.filenameFor(id);
  }

  Future<void> _handlePrintPreview(BuildContext context, WidgetRef ref) async {
    final form = ref.read(addSaleFormProvider(sessionKey: sessionKey));
    final docId = _documentIdForForm(form);
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the invoice before printing')),
      );
      return;
    }
    await SaleInvoicePrintActions.preview(
      context,
      ref,
      docId,
      filename: _filename(form),
    );
  }

  Future<void> _handleSaveAndShare(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(
      addSaleFormProvider(sessionKey: sessionKey).notifier,
    );
    final form = ref.read(addSaleFormProvider(sessionKey: sessionKey));
    if (form.isSaving) return;

    final result = await notifier.saveInvoice();
    if (!context.mounted) return;
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    await _showSaveSuccessDialog(
      context,
      isEditing: isEditing,
      earnedLoyaltyPoints: result.earnedLoyaltyPoints,
      pointsAvailable: result.pointsAvailable,
    );
    if (!context.mounted) return;
    final saved = ref.read(addSaleFormProvider(sessionKey: sessionKey));
    final docId = saved.documentId;
    if (docId == null) {
      onSaved();
      return;
    }
    await SaleInvoicePrintActions.share(
      context,
      ref,
      docId,
      filename: _filename(saved),
    );
    if (context.mounted) onSaved();
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    AddSaleForm notifier,
  ) async {
    final form = ref.read(addSaleFormProvider(sessionKey: sessionKey));
    if (form.isSaving) return;

    final result = await notifier.saveInvoice();
    if (!context.mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }

    await _showSaveSuccessDialog(
      context,
      isEditing: isEditing,
      earnedLoyaltyPoints: result.earnedLoyaltyPoints,
      pointsAvailable: result.pointsAvailable,
    );
    if (!context.mounted) return;
    onSaved();
  }

  Future<void> _showSaveSuccessDialog(
    BuildContext context, {
    required bool isEditing,
    int earnedLoyaltyPoints = 0,
    double pointsAvailable = 0,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'Sale Updated' : 'Sale Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing
                  ? 'Sale updated successfully.'
                  : 'Sale created successfully.',
            ),
            if (earnedLoyaltyPoints > 0) ...[
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFE082).withValues(alpha: 0.7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '⭐',
                            style: AppTypography.inter(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Loyalty Points Earned',
                            style: AppTypography.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$earnedLoyaltyPoints',
                        style: AppTypography.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (pointsAvailable > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Total available: ${pointsAvailable == pointsAvailable.roundToDouble() ? pointsAvailable.toInt() : pointsAvailable.toStringAsFixed(0)} points',
                          style: AppTypography.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        Text(
          '$label ',
          style: saleFieldLabelStyle,
        ),
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
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.filled = false,
    this.compact = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final bool filled;
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
      readOnly: widget.readOnly,
      style: saleFieldTextStyle.copyWith(
        fontSize: widget.compact ? 13 : 14,
      ),
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        filled: widget.filled,
        compact: widget.compact,
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
                fontSize: compact ? 13 : 14,
                color: isPlaceholder ? saleFieldErrorColor : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            icon,
            size: compact ? 14 : 15,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
