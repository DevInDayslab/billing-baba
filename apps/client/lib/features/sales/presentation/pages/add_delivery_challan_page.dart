import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/close_form_dialog.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/models/delivery_challan_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/delivery_challan_footer.dart';
import 'package:billing_baba/features/sales/presentation/widgets/delivery_challan_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_time_dropdown.dart';
import 'package:billing_baba/features/sales/providers/delivery_challan_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;

class AddDeliveryChallanPage extends ConsumerStatefulWidget {
  const AddDeliveryChallanPage({
    this.challanId,
    this.duplicateFromId,
    super.key,
  });

  final String? challanId;
  final String? duplicateFromId;

  @override
  ConsumerState<AddDeliveryChallanPage> createState() =>
      _AddDeliveryChallanPageState();
}

class _AddDeliveryChallanPageState extends ConsumerState<AddDeliveryChallanPage> {
  var _initialized = false;

  bool get _isEditing => widget.challanId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeForm());
  }

  Future<void> _initializeForm() async {
    final notifier = ref.read(deliveryChallanFormProvider.notifier);
    if (widget.duplicateFromId != null) {
      await notifier.duplicateDocument(widget.duplicateFromId!);
    } else if (widget.challanId != null) {
      await notifier.loadDocument(widget.challanId!);
    } else {
      notifier.openForm();
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _handleClose() async {
    final confirmed = await showCloseFormDialog(
      context,
      title: 'Close Delivery Challan',
    );
    if (!confirmed || !mounted) return;
    ref.read(deliveryChallanFormProvider.notifier).resetForm();
    context.go(AppRoutes.saleDeliveryChallan);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      deliveryChallanFormProvider.select((form) => form.isLoading),
    );

    if (!_initialized || isLoading) {
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
                currentRoute: AppRoutes.saleDeliveryChallan,
                onSettingsTap: () {},
              ),
            ),
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
                        child: _ChallanPageHeader(
                          isEditing: _isEditing,
                          onClose: _handleClose,
                        ),
                      ),
                      const SizedBox(height: _sectionGap),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: _sectionGap),
                        child: _ChallanFormFields(),
                      ),
                      const SizedBox(height: _sectionGap),
                      const DeliveryChallanLineItemsTable(embedded: true),
                      const Divider(height: 1, color: _cardBorder),
                      const Padding(
                        padding: EdgeInsets.all(_sectionGap),
                        child: DeliveryChallanFooter(),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      _ChallanBottomActionBar(
                        isEditing: _isEditing,
                        onSaved: () => context.go(AppRoutes.saleDeliveryChallan),
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

class _ChallanPageHeader extends ConsumerWidget {
  const _ChallanPageHeader({
    required this.isEditing,
    required this.onClose,
  });

  final bool isEditing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(deliveryChallanFormProvider);
    final notifier = ref.read(deliveryChallanFormProvider.notifier);

    return Row(
      children: [
        Text(
          isEditing ? 'Edit Delivery Challan' : 'Delivery Challan',
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
        const SizedBox(width: AppSpacing.xs),
        IconButton(
          onPressed: onClose,
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

class _ChallanFormFields extends ConsumerStatefulWidget {
  const _ChallanFormFields();

  @override
  ConsumerState<_ChallanFormFields> createState() =>
      _ChallanFormFieldsState();
}

class _ChallanFormFieldsState extends ConsumerState<_ChallanFormFields> {
  final _invoiceDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(deliveryChallanFormProvider);
    final notifier = ref.read(deliveryChallanFormProvider.notifier);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
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
            ),
          ),
        ),
        const SizedBox(width: _sectionGap),
        SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LabeledField(
                label: 'Challan No.',
                child: _SaleTextField(
                  initialValue: form.challanNo,
                  hintText: '1',
                  onChanged: notifier.updateChallanNo,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Invoice Date',
                child: SaleSingleDatePickerAnchor(
                  key: _invoiceDatePickerKey,
                  selectedDate: form.invoiceDate,
                  onDateSelected: notifier.updateInvoiceDate,
                  child: _PickerField(
                    value: formatSaleSingleDate(form.invoiceDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _invoiceDatePickerKey.currentState?.toggle(),
                  ),
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Time',
                child: SaleTimeDropdown(
                  value: form.invoiceTime,
                  onSelected: notifier.updateInvoiceTime,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Due Date',
                child: SaleSingleDatePickerAnchor(
                  key: _dueDatePickerKey,
                  selectedDate: form.dueDate,
                  onDateSelected: notifier.updateDueDate,
                  child: _PickerField(
                    value: formatSaleSingleDate(form.dueDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _dueDatePickerKey.currentState?.toggle(),
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

class _ChallanBottomActionBar extends ConsumerWidget {
  const _ChallanBottomActionBar({
    required this.isEditing,
    required this.onSaved,
  });

  final bool isEditing;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(deliveryChallanFormProvider);
    final notifier = ref.read(deliveryChallanFormProvider.notifier);
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

  String _filename(DeliveryChallanFormState form) {
    final number = form.challanNo.trim();
    if (number.isNotEmpty) {
      return DocumentPrintActions.filenameFor(number);
    }
    final id = form.documentId;
    return id == null
        ? 'delivery-challan'
        : DocumentPrintActions.filenameFor(id);
  }

  Future<void> _handlePrintPreview(
    BuildContext context,
    WidgetRef ref,
    DeliveryChallanFormState form,
  ) async {
    final docId = form.documentId;
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save the delivery challan before printing'),
        ),
      );
      return;
    }
    await DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.deliveryChallan(docId),
      filename: _filename(form),
    );
  }

  Future<void> _handleSaveAndShare(
    BuildContext context,
    WidgetRef ref,
    DeliveryChallanFormNotifier notifier,
  ) async {
    final form = ref.read(deliveryChallanFormProvider);
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
    final saved = ref.read(deliveryChallanFormProvider);
    final docId = saved.documentId;
    if (docId == null) {
      onSaved();
      return;
    }
    await DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.deliveryChallan(docId),
      filename: _filename(saved),
    );
    if (context.mounted) onSaved();
  }

  void _showSaveSuccessSnackBar(BuildContext context) {
    final message = isEditing
        ? 'Delivery challan updated successfully.'
        : 'Delivery challan created successfully.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    DeliveryChallanFormNotifier notifier,
  ) async {
    final form = ref.read(deliveryChallanFormProvider);
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
    ref.read(deliveryChallanFormProvider.notifier).resetForm();
    onSaved();
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
            style: saleFieldLabelStyle.copyWith(color: AppColors.primary),
            children: [
              TextSpan(text: label),
              const TextSpan(
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
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;

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
      onChanged: widget.onChanged,
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SaleFieldTrigger(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: saleFieldTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon, size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
