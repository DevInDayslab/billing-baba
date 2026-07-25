import 'package:billing_baba/core/navigation/transaction_detail_navigation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/core/widgets/transaction_success_toast.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/add_sale_fa_footer.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_fa_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_fa_tabs_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/application/add_sale_fa_form_provider.dart';
import 'package:billing_baba/features/sales/application/sale_fa_tabs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

class DesktopAddSaleFaPage extends ConsumerStatefulWidget {
  const DesktopAddSaleFaPage({this.batchId, super.key});

  final String? batchId;

  @override
  ConsumerState<DesktopAddSaleFaPage> createState() => _AddSaleFaPageState();
}

class _AddSaleFaPageState extends ConsumerState<DesktopAddSaleFaPage> {
  var _initialized = false;

  bool get _supportsTabs => widget.batchId == null;

  String get _sessionKey {
    if (widget.batchId != null) return widget.batchId!;
    if (_supportsTabs) {
      return ref.read(saleFaTabsProvider()).activeTab.sessionKey;
    }
    return 'default';
  }

  @override
  void initState() {
    super.initState();
    if (widget.batchId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeEditForm(),
      );
    } else {
      _initialized = true;
    }
  }

  Future<void> _initializeEditForm() async {
    await ref
        .read(addSaleFaFormProvider(sessionKey: widget.batchId!).notifier)
        .loadBatch(widget.batchId!);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  void _handleBack() {
    returnToTransactionList(context, AppRoutes.saleFa);
  }

  @override
  Widget build(BuildContext context) {
    if (_supportsTabs) {
      final tabsState = ref.watch(saleFaTabsProvider());
      final activeSessionKey = tabsState.activeTab.sessionKey;

      ref.listen(
        addSaleFaFormProvider(sessionKey: activeSessionKey),
        (previous, next) {
          if (previous?.party == next.party) return;
          ref
              .read(saleFaTabsProvider().notifier)
              .updateTabLabel(
                tabsState.activeIndex,
                saleFaTabLabelForForm(
                  saleFaNumber: tabsState.activeTab.saleFaNumber,
                  partyName: next.party,
                ),
              );
        },
      );
    }

    final sessionKey = _sessionKey;
    final isLoading = ref.watch(
      addSaleFaFormProvider(
        sessionKey: sessionKey,
      ).select((form) => form.isLoading),
    );

    if (!_initialized || (widget.batchId != null && isLoading)) {
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
              currentRoute: AppRoutes.saleFa,
              onSettingsTap: () {},
              onBack: _handleBack,
            ),
          ),
          if (_supportsTabs) ...[
            const SizedBox(height: AppSpacing.sm),
            const SaleFaTabsBar(),
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
                        isEditing: widget.batchId != null,
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
                    SaleFaLineItemsTable(
                      sessionKey: sessionKey,
                      embedded: true,
                    ),
                    const Divider(height: 1, color: _cardBorder),
                    Padding(
                      padding: const EdgeInsets.all(_sectionGap),
                      child: AddSaleFaFooter(sessionKey: sessionKey),
                    ),
                    const Divider(height: 1, color: _cardBorder),
                    _BottomActionBar(
                      sessionKey: sessionKey,
                      isEditing: widget.batchId != null,
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
  final _invoiceDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      addSaleFaFormProvider(sessionKey: widget.sessionKey),
    );
    final notifier = ref.read(
      addSaleFaFormProvider(sessionKey: widget.sessionKey).notifier,
    );

    return Row(
      children: [
        Text(
          widget.isEditing ? 'Edit Sale FA' : 'Sale FA',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _InlineHeaderField(
          label: 'Invoice Number',
          fieldWidth: 80,
          child: _SaleFaTextField(
            initialValue: form.invoiceNumber,
            hintText: 'Invoice number',
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
            selectedDate: form.saleDate,
            onDateSelected: notifier.updateSaleDate,
            child: _PickerField(
              value: form.saleDate != null
                  ? formatSaleSingleDate(form.saleDate)
                  : 'Select Date',
              icon: Icons.calendar_today_outlined,
              isPlaceholder: form.saleDate == null,
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
            value: form.saleTime,
            compact: true,
            onSelected: notifier.updateSaleTime,
          ),
        ),
        const SizedBox(width: _sectionGap),
        _InlineHeaderField(
          label: 'Payment Terms',
          fieldWidth: 140,
          child: SaleGenericSelectDropdown(
            value: form.paymentTerms,
            options: SaleDropdownOptions.paymentTerms,
            hintText: 'Select terms',
            compact: true,
            onSelected: notifier.updatePaymentTerms,
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
      ],
    );
  }
}

class _FormFields extends ConsumerWidget {
  const _FormFields({required this.sessionKey});

  final String sessionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSaleFaFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(
      addSaleFaFormProvider(sessionKey: sessionKey).notifier,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _LabeledField(
            label: 'Customer *',
            child: BillingNamePartySearchField(
              value: form.party,
              selectedPartyId: form.partyId,
              hasError: form.partyHasError,
              errorMessage: 'Customer is required',
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
            child: _SaleFaTextField(
              initialValue: form.eWayBillNo,
              hintText: 'E-Way bill number',
              onChanged: notifier.updateEWayBillNo,
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
  });

  final String sessionKey;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSaleFaFormProvider(sessionKey: sessionKey));
    final notifier = ref.read(
      addSaleFaFormProvider(sessionKey: sessionKey).notifier,
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
          ShareMenuButton(
            onChannelSelected: isSaving
                ? null
                : (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share coming soon')),
                    );
                  },
          ),
          const SizedBox(width: AppSpacing.sm),
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
    AddSaleFaForm notifier,
  ) async {
    final error = await notifier.save();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    showTransactionSuccessToast(context);
    returnToTransactionList(context, AppRoutes.saleFa);
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

class _SaleFaTextField extends StatefulWidget {
  const _SaleFaTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.compact = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final bool compact;

  @override
  State<_SaleFaTextField> createState() => _SaleFaTextFieldState();
}

class _SaleFaTextFieldState extends State<_SaleFaTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_SaleFaTextField oldWidget) {
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
