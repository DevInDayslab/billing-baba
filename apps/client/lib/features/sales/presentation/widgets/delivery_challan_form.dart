import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/delivery_challan_footer.dart';
import 'package:billing_baba/features/sales/presentation/widgets/delivery_challan_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_empty_state_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/providers/delivery_challan_form_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addCtaOrange = Color(0xFFFF9800);

/// Delivery Challan list / empty state / add form card.
class DeliveryChallanContent extends ConsumerWidget {
  const DeliveryChallanContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(deliveryChallanFormProvider);

    if (form.isFormOpen) {
      return const _DeliveryChallanFormCard();
    }

    return _DeliveryChallanListState(
      onAddPressed: () =>
          ref.read(deliveryChallanFormProvider.notifier).openForm(),
    );
  }
}

class _DeliveryChallanListState extends ConsumerWidget {
  const _DeliveryChallanListState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = deliveryChallanListScope();
    final documentsAsync = ref.watch(salesDocumentsListProvider(scope));
    final documents = documentsAsync.maybeWhen(
      data: (page) => page.items,
      orElse: () => const <SaleInvoiceModel>[],
    );
    final listNotifier = ref.read(salesDocumentsListProvider(scope).notifier);

    if (documentsAsync.isLoading && documents.isEmpty) {
      return const SizedBox(
        height: 480,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (documentsAsync.hasError && documents.isEmpty) {
      return SizedBox(
        height: 480,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                documentsAsync.error.toString(),
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: listNotifier.refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (documents.isEmpty) {
      return _EmptyState(onAddPressed: onAddPressed);
    }

    return _SavedChallansList(challans: documents);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 480,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SaleGeometricIllustration(
              circleColor: Color(0xFFE8F5E9),
              shapeColor: Color(0xFF81C784),
              shapeIcon: Icons.local_shipping_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Make & share delivery challan with your customers & '
                'convert it to sale whenever you want.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onAddPressed,
              style: FilledButton.styleFrom(
                backgroundColor: _addCtaOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Add Your First Delivery Challan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedChallansList extends ConsumerWidget {
  const _SavedChallansList({required this.challans});

  final List<SaleInvoiceModel> challans;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(deliveryChallanFormProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(_sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: notifier.openForm,
              style: FilledButton.styleFrom(
                backgroundColor: _addCtaOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Delivery Challan'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final challan in challans)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _cardBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => notifier.loadDocument(challan.id),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  challan.partyName.isEmpty
                                      ? 'Untitled'
                                      : challan.partyName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Challan #${challan.invoiceNo} · '
                                  '${_dateFormat.format(challan.date)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _currencyFormat.format(challan.amount),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (challan.isDraft)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: AppColors.textSecondary,
                              tooltip: 'Delete',
                              onPressed: () async {
                                final error = await ref
                                    .read(
                                      salesDocumentsListProvider(
                                        deliveryChallanListScope(),
                                      ).notifier,
                                    )
                                    .deleteDraft(challan.id);
                                if (!context.mounted) return;
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeliveryChallanFormCard extends ConsumerWidget {
  const _DeliveryChallanFormCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _sectionGap,
            _sectionGap,
            _sectionGap,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Challan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create Delivery Challan',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _sectionGap),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: _sectionGap),
          child: _DeliveryChallanFormFields(),
        ),
        const SizedBox(height: _sectionGap),
        const DeliveryChallanLineItemsTable(),
        const Divider(height: 1, color: _cardBorder),
        const Padding(
          padding: EdgeInsets.all(_sectionGap),
          child: DeliveryChallanFooter(),
        ),
        const Divider(height: 1, color: _cardBorder),
        const _DeliveryChallanBottomActionBar(),
      ],
    );
  }
}

class _DeliveryChallanFormFields extends ConsumerStatefulWidget {
  const _DeliveryChallanFormFields();

  @override
  ConsumerState<_DeliveryChallanFormFields> createState() =>
      _DeliveryChallanFormFieldsState();
}

class _DeliveryChallanFormFieldsState
    extends ConsumerState<_DeliveryChallanFormFields> {
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
            label: 'Search by Name/Phone',
            child: BillingNamePartySearchField(
              value: form.party,
              hasError: form.partyHasError,
              emptyPlaceholder: 'Search by Name/Phone',
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
                label: 'Godown',
                child: Builder(
                  builder: (context) {
                    final godownsAsync = ref.watch(inventoryGodownsProvider);
                    final options = godownsAsync.maybeWhen(
                      data: (godowns) =>
                          godowns.map((godown) => godown.name).toList(),
                      orElse: () => SaleDropdownOptions.godowns,
                    );
                    return SaleGenericSelectDropdown(
                      value: form.godown,
                      options: options,
                      hintText: 'Main Godown',
                      onSelected: (name) {
                        final godowns =
                            ref.read(inventoryGodownsProvider).value ?? [];
                        final match = godowns
                            .where((godown) => godown.name == name)
                            .firstOrNull;
                        notifier.updateGodown(name, godownId: match?.id);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: _sectionGap),
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
                child: _PickerField(
                  value: _formatTime(form.invoiceTime),
                  icon: Icons.access_time,
                  onTap: () => _pickTime(context, form.invoiceTime),
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

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay? current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
    );
    if (picked != null) {
      ref.read(deliveryChallanFormProvider.notifier).updateInvoiceTime(picked);
    }
  }
}

class _DeliveryChallanBottomActionBar extends ConsumerWidget {
  const _DeliveryChallanBottomActionBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(deliveryChallanFormProvider);
    final notifier = ref.read(deliveryChallanFormProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionGap,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: notifier.closeForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: const BorderSide(color: _cardBorder),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          const Spacer(),
          ShareMenuButton(
            onChannelSelected: (channel) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${channel.label} coming soon')),
              );
            },
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            onPressed: form.isSaving
                ? null
                : () async {
                    final error = await notifier.save();
                    if (!context.mounted) return;
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delivery challan saved')),
                    );
                  },
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
}

class _RequiredLabeledField extends StatelessWidget {
  const _RequiredLabeledField({required this.label, required this.child});

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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: saleFieldErrorColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
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
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
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
          Expanded(child: Text(value, style: saleFieldTextStyle)),
          Icon(icon, size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
