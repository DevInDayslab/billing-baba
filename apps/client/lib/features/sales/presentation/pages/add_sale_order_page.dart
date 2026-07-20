import 'package:billing_baba/core/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/models/sale_order_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_order_footer.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_order_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_order_tabs_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/providers/sale_order_form_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_order_tabs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

class AddSaleOrderPage extends ConsumerStatefulWidget {
  const AddSaleOrderPage({
    this.orderId,
    super.key,
  });

  final String? orderId;

  @override
  ConsumerState<AddSaleOrderPage> createState() => _AddSaleOrderPageState();
}

class _AddSaleOrderPageState extends ConsumerState<AddSaleOrderPage> {
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

  void _handleBack() {
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
              currentRoute: AppRoutes.saleOrder,
              onSettingsTap: () {},
              onBack: _handleBack,
            ),
          ),
          if (_supportsTabs) ...[
            const SizedBox(height: AppSpacing.sm),
            const SaleOrderTabsBar(),
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
                        isEditing: widget.orderId != null,
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
                      child: SaleOrderFooter(sessionKey: sessionKey),
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

    return Row(
      children: [
        Text(
          widget.isEditing ? 'Edit Sale Order' : 'Sale Order',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _InlineHeaderField(
          label: 'Order No.',
          fieldWidth: 80,
          child: _SaleTextField(
            initialValue: form.orderNo.isEmpty ? 'Auto' : form.orderNo,
            hintText: 'Order number',
            compact: true,
            onChanged: notifier.updateOrderNo,
          ),
        ),
        const SizedBox(width: _sectionGap),
        _InlineHeaderField(
          label: 'Order Date',
          fieldWidth: 120,
          child: SaleSingleDatePickerAnchor(
            key: _orderDatePickerKey,
            selectedDate: form.orderDate,
            onDateSelected: notifier.updateOrderDate,
            child: _PickerField(
              value: form.orderDate != null
                  ? formatSaleSingleDate(form.orderDate)
                  : 'Select Date',
              icon: Icons.calendar_today_outlined,
              isPlaceholder: form.orderDate == null,
              compact: true,
              onTap: () => _orderDatePickerKey.currentState?.toggle(),
            ),
          ),
        ),
        const SizedBox(width: _sectionGap),
        _InlineHeaderField(
          label: 'Time',
          fieldWidth: 100,
          child: SaleTimeDropdown(
            value: form.orderTime,
            compact: true,
            onSelected: notifier.updateOrderTime,
          ),
        ),
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
        const SizedBox(width: _sectionGap),
        _InlineHeaderField(
          label: 'State of supply',
          fieldWidth: 140,
          child: SaleGenericSelectDropdown(
            value: form.stateOfSupply,
            options: SaleDropdownOptions.indianStates,
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
    final form = ref.watch(
      saleOrderFormProvider(sessionKey: sessionKey),
    );
    final notifier = ref.read(
      saleOrderFormProvider(sessionKey: sessionKey).notifier,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RequiredLabeledField(
            label: 'Party',
            child: BillingNamePartySearchField(
              value: form.party,
              hasError: form.partyHasError,
              emptyPlaceholder: 'Search Party Name',
              errorMessage: 'Party is required',
              onSelected: notifier.updateParty,
              onPartySelectedWithId: (partyId, name) =>
                  notifier.updatePartyWithId(partyId: partyId, partyName: name),
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
          ),
        ),
        const SizedBox(width: _sectionGap),
        Expanded(
          child: _LabeledField(
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
    this.hasError = false,
    this.errorText,
    this.inputFormatters,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool compact;
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
    return TextField(
      controller: _controller,
      style: saleFieldTextStyle.copyWith(
        fontSize: widget.compact ? 13 : 14,
      ),
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        compact: widget.compact,
        hasError: widget.hasError,
      ).copyWith(
        errorText: widget.hasError ? widget.errorText : null,
      ),
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
