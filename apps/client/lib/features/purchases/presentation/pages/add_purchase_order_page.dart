import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_form_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/add_purchase_order_footer.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_order_line_items_table.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/providers/add_purchase_order_form_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/godown_label_selector.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_time_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addPurchaseRed = Color(0xFFD32F2F);

class AddPurchaseOrderPage extends ConsumerWidget {
  const AddPurchaseOrderPage({this.orderId, super.key});

  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPurchaseOrderFormProvider(orderId: orderId));
    final isBusy = form.isSaving || form.isLoading;

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
                  currentRoute: AppRoutes.purchaseOrder,
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
                        child: _PageHeader(orderId: orderId),
                      ),
                      const SizedBox(height: _sectionGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _sectionGap,
                        ),
                        child: _FormFields(orderId: orderId),
                      ),
                      const SizedBox(height: _sectionGap),
                      PurchaseOrderLineItemsTable(
                        embedded: true,
                        orderId: orderId,
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      Padding(
                        padding: const EdgeInsets.all(_sectionGap),
                        child: AddPurchaseOrderFooter(orderId: orderId),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      _BottomActionBar(orderId: orderId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isBusy)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.12),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _PageHeader extends ConsumerWidget {
  const _PageHeader({this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPurchaseOrderFormProvider(orderId: orderId));
    final notifier =
        ref.read(addPurchaseOrderFormProvider(orderId: orderId).notifier);

    return Row(
      children: [
        const Text(
          'Purchase Order',
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
  const _FormFields({this.orderId});

  final String? orderId;

  @override
  ConsumerState<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends ConsumerState<_FormFields> {
  final _orderDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form =
        ref.watch(addPurchaseOrderFormProvider(orderId: widget.orderId));
    final notifier = ref.read(
      addPurchaseOrderFormProvider(orderId: widget.orderId).notifier,
    );

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
                label: 'Order No',
                child: _PurchaseOrderTextField(
                  initialValue: form.orderNumber,
                  hintText: 'Order number',
                  onChanged: notifier.updateOrderNumber,
                ),
              ),
            ),
            const SizedBox(width: _sectionGap),
            Expanded(
              child: _LabeledField(
                label: 'Order Date',
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
                    onTap: () => _orderDatePickerKey.currentState?.toggle(),
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
                  child: _PurchaseOrderTextField(
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
                  value: form.orderTime,
                  hasError: form.orderTime == null,
                  onSelected: notifier.updateOrderTime,
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
  const _BottomActionBar({this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addPurchaseOrderFormProvider(orderId: orderId));
    final notifier =
        ref.read(addPurchaseOrderFormProvider(orderId: orderId).notifier);
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
            onPressed: isSaving ? null : () => _handleCancel(context, ref),
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
            onPressed: isSaving ? null : () => _handleSave(context, ref, notifier),
            style: FilledButton.styleFrom(
              backgroundColor: _addPurchaseRed,
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

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final form = ref.read(addPurchaseOrderFormProvider(orderId: orderId));
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
    AddPurchaseOrderForm notifier,
  ) async {
    if (ref.read(addPurchaseOrderFormProvider(orderId: orderId)).isSaving) {
      return;
    }

    final error = await notifier.saveOrder();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    context.go(AppRoutes.purchaseOrder);
  }

  Future<void> _handlePrintPreview(
    BuildContext context,
    WidgetRef ref,
    AddPurchaseOrderFormState form,
  ) async {
    final docId = form.documentId ?? orderId;
    if (docId == null) return;
    await DocumentPrintActions.preview(
      context,
      ref,
      PrintRequest.purchaseOrder(docId),
      filename: DocumentPrintActions.filenameFor(
        form.orderNumber.isNotEmpty ? form.orderNumber : docId,
      ),
    );
  }

  Future<void> _handleShare(
    BuildContext context,
    WidgetRef ref,
    AddPurchaseOrderFormState form,
  ) async {
    final docId = form.documentId ?? orderId;
    if (docId == null) return;
    await DocumentPrintActions.share(
      context,
      ref,
      PrintRequest.purchaseOrder(docId),
      filename: DocumentPrintActions.filenameFor(
        form.orderNumber.isNotEmpty ? form.orderNumber : docId,
      ),
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

class _PurchaseOrderTextField extends StatefulWidget {
  const _PurchaseOrderTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<_PurchaseOrderTextField> createState() =>
      _PurchaseOrderTextFieldState();
}

class _PurchaseOrderTextFieldState extends State<_PurchaseOrderTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_PurchaseOrderTextField oldWidget) {
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
