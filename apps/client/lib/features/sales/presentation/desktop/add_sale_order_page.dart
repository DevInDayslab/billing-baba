import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:billing_baba/features/sales/application/sale_order_form_provider.dart';
import 'package:billing_baba/features/sales/application/sale_order_tabs_provider.dart';
import 'package:billing_baba/features/sales/models/sale_order_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_order_footer.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_order_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_order_tabs_bar.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/shared/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/shared/widgets/share_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _orderMetaWidth = 200.0;
const _partyRowFlex = 3;
const _partyRowTrailingSpacerFlex = 9;
/// Phone sits under party at 60% of the party field width (40% narrower).
const _phoneWidthFactor = 0.6;

class DesktopAddSaleOrderPage extends ConsumerStatefulWidget {
  const DesktopAddSaleOrderPage({
    this.orderId,
    super.key,
  });

  final String? orderId;

  @override
  ConsumerState<DesktopAddSaleOrderPage> createState() =>
      _AddSaleOrderPageState();
}

class _AddSaleOrderPageState extends ConsumerState<DesktopAddSaleOrderPage> {
  var _initialized = false;

  bool get _supportsTabs => widget.orderId == null;

  String get _sessionKey {
    if (widget.orderId != null) return widget.orderId!;
    if (_supportsTabs) {
      return ref.read(saleOrderTabsProvider()).activeTab.sessionKey;
    }
    return 'default';
  }

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeEditForm(),
      );
    } else {
      _initialized = true;
    }
  }

  Future<void> _initializeEditForm() async {
    await ref
        .read(saleOrderFormProvider(sessionKey: widget.orderId!).notifier)
        .loadDocument(widget.orderId!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _handleClose() async {
    final confirmed = await showCloseFormDialog(
      context,
      title: 'Close Sale Order',
    );
    if (!confirmed || !mounted) return;
    returnToTransactionList(context, AppRoutes.saleOrder);
  }

  @override
  Widget build(BuildContext context) {
    if (_supportsTabs) {
      final tabsState = ref.watch(saleOrderTabsProvider());
      final activeSessionKey = tabsState.activeTab.sessionKey;

      ref.listen(
        saleOrderFormProvider(sessionKey: activeSessionKey),
        (previous, next) {
          if (previous?.party == next.party) return;
          ref
              .read(saleOrderTabsProvider().notifier)
              .updateTabLabel(
                tabsState.activeIndex,
                saleOrderTabLabelForForm(
                  orderNumber: tabsState.activeTab.orderNumber,
                  partyName: next.party,
                ),
              );
        },
      );
    }

    final sessionKey = _sessionKey;
    final isLoading = ref.watch(
      saleOrderFormProvider(
        sessionKey: sessionKey,
      ).select((form) => form.isLoading),
    );

    if (!_initialized || (widget.orderId != null && isLoading)) {
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
            if (_supportsTabs)
              SaleOrderTabsBar(onFormClose: _handleClose),
            Expanded(
              child: Padding(
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
                      Expanded(
                        child: SingleChildScrollView(
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
                                  isEditing: widget.orderId != null,
                                  showTitle: !_supportsTabs,
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
                              SaleOrderLineItemsTable(
                                sessionKey: sessionKey,
                                embedded: true,
                              ),
                              const Divider(height: 1, color: _cardBorder),
                              Padding(
                                padding: const EdgeInsets.all(_sectionGap),
                                child: SaleOrderFooter(
                                  sessionKey: sessionKey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      _BottomActionBar(
                        sessionKey: sessionKey,
                        isEditing: widget.orderId != null,
                        supportsTabs: _supportsTabs,
                      ),
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

class _PageHeader extends ConsumerWidget {
  const _PageHeader({
    required this.sessionKey,
    this.isEditing = false,
    this.showTitle = true,
  });

  final String sessionKey;
  final bool isEditing;
  final bool showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(
      saleOrderFormProvider(sessionKey: sessionKey),
    );
    final notifier = ref.read(
      saleOrderFormProvider(sessionKey: sessionKey).notifier,
    );

    return Row(
      children: [
        if (showTitle)
          Text(
            isEditing ? 'Edit Sale Order' : 'Sale Order',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        const Spacer(),
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
        final match = godowns
            .where((godown) => godown.name == name)
            .firstOrNull;
        onSelected(name, godownId: match?.id);
      },
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
  final _orderDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      saleOrderFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      saleOrderFormProvider(sessionKey: widget.sessionKey).notifier,
    );

    final partyField = _RequiredLabeledField(
      label: 'Party',
      child: BillingNamePartySearchField(
        value: form.party,
        selectedPartyId: form.partyId,
        hasError: form.partyHasError,
        emptyPlaceholder: 'Search Party Name',
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
            notifier.updatePhoneNo(party.phone);
          }
          if (party.state.isNotEmpty) {
            notifier.updateStateOfSupply(party.state);
          }
        },
      ),
    );
    final phoneField = _LabeledField(
      label: 'Phone No.',
      child: _SaleTextField(
        initialValue: form.phoneNo,
        hintText: 'Phone number',
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        hasError: form.phoneHasError,
        errorText: form.phoneErrorMessage,
        onChanged: notifier.updatePhoneNo,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: _partyRowFlex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    partyField,
                    const SizedBox(height: _sectionGap),
                    FractionallySizedBox(
                      widthFactor: _phoneWidthFactor,
                      alignment: Alignment.centerLeft,
                      child: phoneField,
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: _partyRowTrailingSpacerFlex,
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(width: _sectionGap),
        SizedBox(
          width: _orderMetaWidth,
          child: _OrderDetailsFields(
            sessionKey: widget.sessionKey,
            orderDatePickerKey: _orderDatePickerKey,
            dueDatePickerKey: _dueDatePickerKey,
          ),
        ),
      ],
    );
  }
}

class _OrderDetailsFields extends ConsumerWidget {
  const _OrderDetailsFields({
    required this.sessionKey,
    required this.orderDatePickerKey,
    required this.dueDatePickerKey,
  });

  final String sessionKey;
  final GlobalKey<SaleSingleDatePickerAnchorState> orderDatePickerKey;
  final GlobalKey<SaleSingleDatePickerAnchorState> dueDatePickerKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleOrderFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(
      saleOrderFormProvider(sessionKey: sessionKey).notifier,
    );
    final preview = watchDocumentNumberPreview(
      ref,
      SalesConstants.saleOrderSeries,
    );
    final displayNumber = resolveDocumentNumberDisplay(
      documentId: form.documentId,
      currentNumber: form.orderNo,
      preview: preview,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledField(
          label: 'Order No.',
          child: _SaleTextField(
            initialValue: displayNumber,
            hintText: 'Order number',
            compact: true,
            readOnly: true,
            filled: true,
            onChanged: (_) {},
          ),
        ),
        const SizedBox(height: _sectionGap),
        _LabeledField(
          label: 'Order Date',
          child: SaleSingleDatePickerAnchor(
            key: orderDatePickerKey,
            selectedDate: form.orderDate,
            onDateSelected: notifier.updateOrderDate,
            child: _PickerField(
              value: form.orderDate != null
                  ? formatSaleSingleDate(form.orderDate)
                  : 'Select Date',
              icon: Icons.calendar_today_outlined,
              isPlaceholder: form.orderDate == null,
              compact: true,
              onTap: () => orderDatePickerKey.currentState?.toggle(),
            ),
          ),
        ),
        const SizedBox(height: _sectionGap),
        _LabeledField(
          label: 'Time',
          child: SaleTimeDropdown(
            value: form.orderTime,
            compact: true,
            onSelected: notifier.updateOrderTime,
          ),
        ),
        const SizedBox(height: _sectionGap),
        _LabeledField(
          label: 'Due Date',
          child: SaleSingleDatePickerAnchor(
            key: dueDatePickerKey,
            selectedDate: form.dueDate,
            onDateSelected: notifier.updateDueDate,
            child: _PickerField(
              value: form.dueDate != null
                  ? formatSaleSingleDate(form.dueDate)
                  : 'Select Date',
              icon: Icons.calendar_today_outlined,
              isPlaceholder: form.dueDate == null,
              compact: true,
              onTap: () => dueDatePickerKey.currentState?.toggle(),
            ),
          ),
        ),
        const SizedBox(height: _sectionGap),
        _LabeledField(
          label: 'State of supply',
          child: SaleGenericSelectDropdown(
            value: form.stateOfSupply,
            options: SaleDropdownOptions.indianStates,
            hintText: 'Select state',
            maxMenuHeight: 280,
            compact: true,
            onSelected: notifier.updateStateOfSupply,
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
    final form = ref.watch(saleOrderFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(
      saleOrderFormProvider(sessionKey: sessionKey).notifier,
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

  Future<void> _handlePrintPreview(
    BuildContext context,
    WidgetRef ref,
    SaleOrderFormState form,
  ) async {
    final docId = form.documentId;
    if (docId == null) return;
    await DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.saleOrder(docId),
      filename: DocumentPrintActions.filenameFor(form.orderNo),
    );
  }

  Future<void> _handleSaveAndShare(
    BuildContext context,
    WidgetRef ref,
    SaleOrderFormNotifier notifier,
  ) async {
    final form = ref.read(saleOrderFormProvider(sessionKey: sessionKey));
    if (form.isSaving) return;

    final error = await notifier.save();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    _showSaveSuccessSnackBar(context);
    final saved = ref.read(saleOrderFormProvider(sessionKey: sessionKey));
    final docId = saved.documentId;
    if (docId == null) {
      _afterSave(context, ref);
      return;
    }
    await DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.saleOrder(docId),
      filename: DocumentPrintActions.filenameFor(saved.orderNo),
    );
    if (context.mounted) _afterSave(context, ref);
  }

  void _showSaveSuccessSnackBar(BuildContext context) {
    final message = isEditing
        ? 'Sale order updated successfully.'
        : 'Sale order created successfully.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    SaleOrderFormNotifier notifier,
  ) async {
    final form = ref.read(saleOrderFormProvider(sessionKey: sessionKey));
    if (form.isSaving) return;

    final error = await notifier.save();
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    _showSaveSuccessSnackBar(context);
    _afterSave(context, ref);
  }

  void _afterSave(BuildContext context, WidgetRef ref) {
    if (supportsTabs) {
      ref.invalidate(saleOrderFormProvider(sessionKey: sessionKey));
      final tabsState = ref.read(saleOrderTabsProvider());
      ref
          .read(saleOrderTabsProvider().notifier)
          .updateTabLabel(
            tabsState.activeIndex,
            saleOrderTabLabelForForm(
              orderNumber: tabsState.activeTab.orderNumber,
            ),
          );
      return;
    }
    returnToTransactionList(context, AppRoutes.saleOrder);
  }
}

class _RequiredLabeledField extends StatelessWidget {
  const _RequiredLabeledField({
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
        RichText(
          text: TextSpan(
            text: label,
            style: saleFieldLabelStyle,
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: saleFieldErrorColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
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
    this.compact = false,
    this.readOnly = false,
    this.filled = false,
    this.hasError = false,
    this.errorText,
    this.inputFormatters,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool compact;
  final bool readOnly;
  final bool filled;
  final bool hasError;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;

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
    return SaleTextField(
      controller: _controller,
      hint: widget.hintText,
      hasError: widget.hasError,
      compact: widget.compact,
      readOnly: widget.readOnly,
      filled: widget.filled,
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
