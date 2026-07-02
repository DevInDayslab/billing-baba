import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/share_menu_button.dart';
import 'package:billing_baba/features/sales/models/sale_order_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/billing_name_party_search_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/preview_share_dialog.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_empty_state_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_order_footer.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_order_line_items_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/features/sales/providers/sale_order_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _sectionGap = 16.0;
const _addCtaOrange = Color(0xFFFF9800);

/// Sale Order list / empty state / add form card.
class SaleOrderContent extends ConsumerWidget {
  const SaleOrderContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(saleOrderFormProvider);
    final savedOrders = ref.watch(savedSaleOrdersProvider);

    if (form.isFormOpen) {
      return const _SaleOrderFormCard();
    }

    if (savedOrders.isEmpty) {
      return _EmptyState(
        onAddPressed: () =>
            ref.read(saleOrderFormProvider.notifier).openForm(),
      );
    }

    return _SavedOrdersList(orders: savedOrders);
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
              circleColor: Color(0xFFFFF3E0),
              shapeColor: Color(0xFFFFB74D),
              shapeIcon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Make & share sale orders & convert them to sale invoice instantly.',
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
                'Add Your First Sale Order',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedOrdersList extends ConsumerWidget {
  const _SavedOrdersList({required this.orders});

  final List<SavedSaleOrder> orders;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(saleOrderFormProvider.notifier);

    return Column(
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
            child: const Text('Add Sale Order'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final order in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => notifier.loadSavedOrder(order),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.party,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.orderDate != null
                                  ? _dateFormat.format(order.orderDate!)
                                  : '—',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _currencyFormat.format(order.total),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: 'Delete',
                        onPressed: () {
                          ref
                              .read(savedSaleOrdersProvider.notifier)
                              .removeOrder(order.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SaleOrderFormCard extends ConsumerWidget {
  const _SaleOrderFormCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            _sectionGap,
            _sectionGap,
            _sectionGap,
            0,
          ),
          child: Text(
            'Sale Order',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: _sectionGap),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _sectionGap),
          child: _SaleOrderFormFields(),
        ),
        SizedBox(height: _sectionGap),
        SaleOrderLineItemsTable(),
        Divider(height: 1, color: _cardBorder),
        Padding(
          padding: EdgeInsets.all(_sectionGap),
          child: SaleOrderFooter(),
        ),
        Divider(height: 1, color: _cardBorder),
        _SaleOrderBottomActionBar(),
      ],
    );
  }
}

class _SaleOrderFormFields extends ConsumerStatefulWidget {
  const _SaleOrderFormFields();

  @override
  ConsumerState<_SaleOrderFormFields> createState() =>
      _SaleOrderFormFieldsState();
}

class _SaleOrderFormFieldsState extends ConsumerState<_SaleOrderFormFields> {
  final _orderDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();
  final _dueDatePickerKey = GlobalKey<SaleSingleDatePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(saleOrderFormProvider);
    final notifier = ref.read(saleOrderFormProvider.notifier);

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
                label: 'Order No.',
                child: _SaleTextField(
                  initialValue: form.orderNo,
                  hintText: 'Auto',
                  onChanged: notifier.updateOrderNo,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _LabeledField(
                label: 'Order Date',
                child: SaleSingleDatePickerAnchor(
                  key: _orderDatePickerKey,
                  selectedDate: form.orderDate,
                  onDateSelected: notifier.updateOrderDate,
                  child: _PickerField(
                    value: formatSaleSingleDate(form.orderDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _orderDatePickerKey.currentState?.toggle(),
                  ),
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

class _SaleOrderBottomActionBar extends ConsumerWidget {
  const _SaleOrderBottomActionBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(saleOrderFormProvider.notifier);

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
              if (channel == ShareChannel.email) {
                unawaited(
                  showPreviewShareDialog(
                    context,
                    initialTab: PreviewShareTab.saleOrder,
                  ),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${channel.label} coming soon')),
              );
            },
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            onPressed: () {
              final saved = notifier.save();
              if (!saved) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sale order saved')),
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
