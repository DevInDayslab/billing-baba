import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:billing_baba/features/inventory/utils/gst_tax_slabs.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_quantity_pad_sheet.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_settings_panel.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/shared/widgets/app_text_field.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

const _itemsHeaderColor = Color(0xFFE8456A);
const _customerBorderColor = Color(0xFFE8E8E8);
const _taxDropdownBorderColor = Color(0xFFE0E0E0);

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

final _dateFormat = DateFormat('d MMM yyyy');
final _timeFormat = DateFormat('hh:mm a');

const _billDiscountChips = [100.0, 50.0, 30.0, 20.0, 10.0, 5.0];

List<({String label, double percent})> get _taxRateOptions => [
  (label: 'None', percent: 0),
  ...GstTaxSlabs.definitions().map(
    (slab) => (
      label: slab.itemFormLabel.replaceFirst('GST @ ', 'GST@'),
      percent: slab.percent,
    ),
  ),
];

int _nextInvoiceNumber = 1;

class PosCartPage extends ConsumerStatefulWidget {
  const PosCartPage({super.key});

  @override
  ConsumerState<PosCartPage> createState() => _PosCartPageState();
}

class _PosCartPageState extends ConsumerState<PosCartPage> {
  bool _customerExpanded = false;
  bool _paymentExpanded = false;
  bool _notesExpanded = false;
  bool _isSaving = false;
  bool _isSavingAndPrinting = false;
  double _selectedTaxPercent = 0;
  String _selectedTaxLabel = 'None';

  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerGstinController = TextEditingController();
  final _notesController = TextEditingController();

  late final int _invoiceNumber;
  late final DateTime _openedAt;

  @override
  void initState() {
    super.initState();
    _invoiceNumber = _nextInvoiceNumber;
    _openedAt = DateTime.now();
    _customerNameController.addListener(_onCustomerNameChanged);
  }

  void _onCustomerNameChanged() {
    final trimmed = _customerNameController.text.trim();
    ref
        .read(posCartProvider.notifier)
        .setCustomerName(
          trimmed.isEmpty ? null : trimmed,
        );
  }

  @override
  void dispose() {
    _customerNameController
      ..removeListener(_onCustomerNameChanged)
      ..dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _customerGstinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _billerName {
    final name = ref.read(authProvider).session?.user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Admin';
  }

  bool _isFullyPaid(PosCartState cart, double displayTotal) {
    if (cart.payments.isEmpty) return false;
    return cart.payments.any(
      (payment) =>
          payment.mode == PaymentMode.cash &&
          payment.amount >= displayTotal - 0.01,
    );
  }

  void _setFullyPaid(
    bool value,
    PosCart notifier,
    PosCartState cart,
    double displayTotal,
  ) {
    if (value) {
      if (!notifier.isPaymentModeSelected(PaymentMode.cash)) {
        notifier.togglePaymentMode(PaymentMode.cash);
      }
      notifier.updatePaymentAmount(PaymentMode.cash, displayTotal);
      return;
    }

    if (notifier.isPaymentModeSelected(PaymentMode.cash)) {
      notifier.togglePaymentMode(PaymentMode.cash);
    }
  }

  double _taxableAmount(PosCartState cart) {
    return cart.subtotal - cart.billDiscountAmount;
  }

  double _taxAmount(PosCartState cart) {
    return _taxableAmount(cart) * _selectedTaxPercent / 100;
  }

  double _cgst(PosCartState cart) => _taxAmount(cart) / 2;

  double _sgst(PosCartState cart) => _taxAmount(cart) / 2;

  double _displayTotal(PosCartState cart) {
    return _taxableAmount(cart) + _taxAmount(cart);
  }

  Future<void> _showTaxRateSheet() async {
    await showMobileBottomSheet<void>(
      context: context,
      title: 'Tax Rate',
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: _taxRateOptions.map((option) {
            final isSelected = _selectedTaxLabel == option.label;

            return Material(
              color: Colors.transparent,
              child: ListTile(
                title: Text(
                  option.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(LucideIcons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedTaxPercent = option.percent;
                    _selectedTaxLabel = option.label;
                  });
                  Navigator.pop(sheetContext);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _paymentModeLabel(PaymentMode mode) => switch (mode) {
    PaymentMode.cash => 'Cash',
    PaymentMode.upi => 'UPI',
    PaymentMode.card => 'Card',
    PaymentMode.bank => 'Bank',
  };

  String _selectedPaymentLabel(PosCartState cart) {
    if (cart.payments.isEmpty) return 'None';
    return cart.payments.map((p) => _paymentModeLabel(p.mode)).join(', ');
  }

  Future<void> _completeSaleFlow() async {
    // TODO(pos): Wire selectedTaxRate through to PosSaleService when tax
    // override is supported. Sale currently uses hardcoded 18% GST.
    final cart = ref.read(posCartProvider.notifier);
    await cart.completeSale(clearCartOnSuccess: false);
    // Push finalize_sale to server immediately.
    unawaited(
      ref.read(commandAwareSyncEngineProvider.future).then((engine) {
        return engine.syncNow();
      }),
    );
    if (!mounted) return;
    _nextInvoiceNumber++;
    final navigator = Navigator.of(context);
    navigator.pop();
    cart.clearCart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(navigator.context).showSnackBar(
        const SnackBar(
          content: Text('Sale completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Future<void> _saveBill() async {
    if (_isSaving || _isSavingAndPrinting) return;

    setState(() => _isSaving = true);
    try {
      await _completeSaleFlow();
    } on PosRepositoryException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.error,
        ),
      );
      // Surface Drift/query StateErrors (e.g. duplicate stock rows) in the UI.
      // ignore: avoid_catching_errors
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAndPrint() async {
    if (_isSaving || _isSavingAndPrinting) return;

    setState(() => _isSavingAndPrinting = true);
    try {
      // TODO(pos): Trigger receipt print after sale completes.
      await _completeSaleFlow();
    } on PosRepositoryException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.error,
        ),
      );
      // Surface Drift/query StateErrors (e.g. duplicate stock rows) in the UI.
      // ignore: avoid_catching_errors
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingAndPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(posCartProvider);
    final cart = ref.read(posCartProvider.notifier);
    final theme = Theme.of(context);
    final taxAmount = _taxAmount(cartState);
    final cgst = _cgst(cartState);
    final sgst = _sgst(cartState);
    final displayTotal = _displayTotal(cartState);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Billing Summary',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            color: AppColors.textSecondary,
            onPressed: () => unawaited(
              showMobileSaleSettingsPanel(context: context, ref: ref),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                _InfoRow(
                  biller: _billerName,
                  invoiceNo: 'INV/$_invoiceNumber',
                  date: _dateFormat.format(_openedAt),
                  time: _timeFormat.format(_openedAt),
                ),
                const SizedBox(height: AppSpacing.md),
                _CustomerSection(
                  expanded: _customerExpanded,
                  initialCustomerName: cartState.customerName,
                  nameController: _customerNameController,
                  phoneController: _customerPhoneController,
                  addressController: _customerAddressController,
                  gstinController: _customerGstinController,
                  onExpand: () => setState(() => _customerExpanded = true),
                  onCollapse: () => setState(() => _customerExpanded = false),
                ),
                const SizedBox(height: AppSpacing.md),
                _ItemsSection(
                  cartState: cartState,
                  priceListLabel: cartState.priceListLabel,
                  onDecrease: (item) =>
                      cart.updateQuantity(item.item.id, item.quantity - 1),
                  onIncrease: (item) => cart.addItem(item.item),
                  onSetQuantity: (item, qty) =>
                      cart.updateQuantity(item.item.id, qty),
                  onAddMoreItems: () => context.pop(),
                ),
                const SizedBox(height: AppSpacing.md),
                _TotalsCard(
                  cartState: cartState,
                  selectedTaxPercent: _selectedTaxPercent,
                  selectedTaxLabel: _selectedTaxLabel,
                  taxAmount: taxAmount,
                  cgst: cgst,
                  sgst: sgst,
                  displayTotal: displayTotal,
                  isFullyPaid: _isFullyPaid(cartState, displayTotal),
                  onBillDiscount: cart.updateBillDiscount,
                  onShowTaxRateSheet: _showTaxRateSheet,
                  onFullyPaidChanged: (value) => _setFullyPaid(
                    value,
                    cart,
                    cartState,
                    displayTotal,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _PaymentModeCard(
                  cartState: cartState,
                  expanded: _paymentExpanded,
                  selectedLabel: _selectedPaymentLabel(cartState),
                  isModeSelected: cart.isPaymentModeSelected,
                  onToggleExpanded: () =>
                      setState(() => _paymentExpanded = !_paymentExpanded),
                  onToggleMode: cart.togglePaymentMode,
                ),
                const SizedBox(height: AppSpacing.md),
                _NotesCard(
                  expanded: _notesExpanded,
                  controller: _notesController,
                  onToggle: () =>
                      setState(() => _notesExpanded = !_notesExpanded),
                ),
              ],
            ),
          ),
          _CartBottomBar(
            totalPayable: displayTotal,
            isSaving: _isSaving,
            isSavingAndPrinting: _isSavingAndPrinting,
            onSaveAndPrint: _saveAndPrint,
            onSaveBill: _saveBill,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.biller,
    required this.invoiceNo,
    required this.date,
    required this.time,
  });

  final String biller;
  final String invoiceNo;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: _InfoColumn(label: 'Biller', value: biller),
            ),
            Expanded(
              child: _InfoColumn(label: 'Invoice No.', value: invoiceNo),
            ),
            Expanded(
              child: _InfoColumn(label: 'Date', value: date),
            ),
            Expanded(
              child: _InfoColumn(label: 'Time', value: time),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CustomerSection extends StatefulWidget {
  const _CustomerSection({
    required this.expanded,
    required this.initialCustomerName,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.gstinController,
    required this.onExpand,
    required this.onCollapse,
  });

  final bool expanded;
  final String? initialCustomerName;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController gstinController;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;

  @override
  State<_CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<_CustomerSection> {
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    widget.nameController.text = widget.initialCustomerName ?? '';
    widget.phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(_onPhoneChanged);
    super.dispose();
  }

  void _onPhoneChanged() {
    final error = Validators.phone(widget.phoneController.text);
    if (_phoneError != error) {
      setState(() => _phoneError = error);
    }
  }

  @override
  void didUpdateWidget(covariant _CustomerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCustomerName != widget.initialCustomerName &&
        widget.nameController.text.isEmpty) {
      widget.nameController.text = widget.initialCustomerName ?? '';
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    const borderSide = BorderSide(color: _customerBorderColor);
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      border: const UnderlineInputBorder(borderSide: borderSide),
      enabledBorder: const UnderlineInputBorder(borderSide: borderSide),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _customerBorderColor),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.expanded ? null : widget.onExpand,
                borderRadius: AppRadius.mdBorder,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const _CustomerIconContainer(
                        icon: LucideIcons.user,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.expanded
                              ? 'Customer Details'
                              : 'Add Customer Details',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (widget.expanded)
                        TextButton(
                          onPressed: widget.onCollapse,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Done',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          LucideIcons.plus,
                          color: AppColors.primary,
                          size: AppIconSize.md,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.expanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CustomerFieldRow(
                      icon: LucideIcons.user,
                      child: TextField(
                        controller: widget.nameController,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: _fieldDecoration('Customer Name'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CustomerFieldRow(
                      icon: LucideIcons.phone,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: widget.phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: _fieldDecoration('Phone Number'),
                          ),
                          if (_phoneError != null) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              _phoneError!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CustomerFieldRow(
                      icon: LucideIcons.mapPin,
                      child: TextField(
                        controller: widget.addressController,
                        maxLines: 2,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: _fieldDecoration('Billing Address'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CustomerFieldRow(
                      icon: LucideIcons.building2,
                      child: TextField(
                        controller: widget.gstinController,
                        textCapitalization: TextCapitalization.characters,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: _fieldDecoration('GSTIN'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _DashedDivider(),
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: widget.onCollapse,
                      borderRadius: AppRadius.mdBorder,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hide Customer Details',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(
                              LucideIcons.chevronUp,
                              color: AppColors.primary,
                              size: AppIconSize.md,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomerIconContainer extends StatelessWidget {
  const _CustomerIconContainer({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: AppIconSize.md,
      ),
    );
  }
}

class _CustomerFieldRow extends StatelessWidget {
  const _CustomerFieldRow({
    required this.icon,
    required this.child,
  });

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: _CustomerIconContainer(icon: icon),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({
    required this.cartState,
    required this.priceListLabel,
    required this.onDecrease,
    required this.onIncrease,
    required this.onSetQuantity,
    required this.onAddMoreItems,
  });

  final PosCartState cartState;
  final String priceListLabel;
  final void Function(CartItem item) onDecrease;
  final void Function(CartItem item) onIncrease;
  final void Function(CartItem item, int qty) onSetQuantity;
  final VoidCallback onAddMoreItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemCount = cartState.totalQty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: const BoxDecoration(
              color: _itemsHeaderColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.md),
              ),
            ),
            child: Text(
              '$itemCount items added',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (cartState.items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No items in cart',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            ...cartState.items.asMap().entries.map((entry) {
              final index = entry.key;
              final cartItem = entry.value;
              final showDivider = index < cartState.items.length - 1;

              return Column(
                children: [
                  _CartItemRow(
                    cartItem: cartItem,
                    priceListLabel: priceListLabel,
                    onDecrease: () => onDecrease(cartItem),
                    onIncrease: () => onIncrease(cartItem),
                    onQuantityTap: () async {
                      final qty = await showPosQuantityPad(
                        context,
                        itemName: cartItem.item.name,
                        initialQuantity: cartItem.quantity,
                        maxQuantity: cartItem.item.stock > 0
                            ? cartItem.item.stock
                            : null,
                      );
                      if (qty != null) onSetQuantity(cartItem, qty);
                    },
                  ),
                  if (showDivider)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: _DashedDivider(),
                    ),
                ],
              );
            }),
          InkWell(
            onTap: onAddMoreItems,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                '+ Add More Items',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.cartItem,
    required this.priceListLabel,
    required this.onDecrease,
    required this.onIncrease,
    required this.onQuantityTap,
  });

  final CartItem cartItem;
  final String priceListLabel;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onQuantityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = cartItem.item;
    final primaryTint = AppColors.primary.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${cartItem.quantity} × ${_currencyFormat.format(item.price)} • $priceListLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(cartItem.lineTotal),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _QuantityStepper(
                quantity: cartItem.quantity,
                tint: primaryTint,
                onDecrease: onDecrease,
                onIncrease: onIncrease,
                onQuantityTap: onQuantityTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.tint,
    required this.onDecrease,
    required this.onIncrease,
    required this.onQuantityTap,
  });

  final int quantity;
  final Color tint;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onQuantityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: LucideIcons.minus, onPressed: onDecrease),
          InkWell(
            onTap: onQuantityTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                '$quantity',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          _StepperButton(icon: LucideIcons.plus, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 36,
          height: 32,
          child: Icon(icon, color: AppColors.primary, size: AppIconSize.md),
        ),
      ),
    );
  }
}

class _TotalsCard extends StatefulWidget {
  const _TotalsCard({
    required this.cartState,
    required this.selectedTaxPercent,
    required this.selectedTaxLabel,
    required this.taxAmount,
    required this.cgst,
    required this.sgst,
    required this.displayTotal,
    required this.isFullyPaid,
    required this.onBillDiscount,
    required this.onShowTaxRateSheet,
    required this.onFullyPaidChanged,
  });

  final PosCartState cartState;
  final double selectedTaxPercent;
  final String selectedTaxLabel;
  final double taxAmount;
  final double cgst;
  final double sgst;
  final double displayTotal;
  final bool isFullyPaid;
  final ValueChanged<double> onBillDiscount;
  final VoidCallback onShowTaxRateSheet;
  final ValueChanged<bool> onFullyPaidChanged;

  @override
  State<_TotalsCard> createState() => _TotalsCardState();
}

class _TotalsCardState extends State<_TotalsCard> {
  bool _showCustomDiscountInput = false;
  final _customDiscountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customDiscountController.addListener(_onCustomDiscountChanged);
  }

  @override
  void dispose() {
    _customDiscountController
      ..removeListener(_onCustomDiscountChanged)
      ..dispose();
    super.dispose();
  }

  void _onCustomDiscountChanged() => setState(() {});

  void _showCustomInput() {
    setState(() {
      _showCustomDiscountInput = true;
      final current = widget.cartState.billDiscountPercent;
      if (current > 0 && !_billDiscountChips.contains(current)) {
        _customDiscountController.text = current == current.roundToDouble()
            ? current.toStringAsFixed(0)
            : current.toString();
      } else {
        _customDiscountController.clear();
      }
    });
  }

  void _hideCustomInput() {
    setState(() {
      _showCustomDiscountInput = false;
      _customDiscountController.clear();
    });
  }

  void _applyCustomDiscount() {
    final value = double.tryParse(_customDiscountController.text.trim());
    if (value == null) return;
    widget.onBillDiscount(value.clamp(0.0, 100.0));
    _hideCustomInput();
  }

  double? get _highlightDiscountPercent {
    if (_showCustomDiscountInput) {
      final parsed = double.tryParse(_customDiscountController.text.trim());
      if (parsed != null) {
        return parsed.clamp(0.0, 100.0);
      }
      return null;
    }
    final applied = widget.cartState.billDiscountPercent;
    return applied > 0 ? applied : null;
  }

  bool _isChipActive(double percent) {
    final highlighted = _highlightDiscountPercent;
    return highlighted != null && highlighted == percent;
  }

  String _formatTaxRate(double rate) {
    return rate == rate.roundToDouble()
        ? rate.toStringAsFixed(0)
        : rate.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartState = widget.cartState;
    final selectedTaxPercent = widget.selectedTaxPercent;
    final halfRate = selectedTaxPercent / 2;
    final showTaxBreakdown = selectedTaxPercent > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TotalRow(
              label: 'Sub Total',
              value: _currencyFormat.format(cartState.subtotal),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Discount (%)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _showCustomInput,
                  child: Text(
                    '+ Add',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _billDiscountChips.map((percent) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _DiscountChip(
                      label: '${percent.toStringAsFixed(0)}%',
                      isActive: _isChipActive(percent),
                      onTap: () {
                        _hideCustomInput();
                        widget.onBillDiscount(
                          _isChipActive(percent) ? 0 : percent,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_showCustomDiscountInput) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customDiscountController,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      maxLength: 5,
                      textAlignVertical: TextAlignVertical.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter discount %',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        isDense: true,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.smBorder,
                          borderSide: const BorderSide(
                            color: _customerBorderColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.smBorder,
                          borderSide: const BorderSide(
                            color: _customerBorderColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.smBorder,
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _applyCustomDiscount(),
                    ),
                  ),
                  TextButton(
                    onPressed: _applyCustomDiscount,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center,
                    ),
                    child: Text(
                      'Apply',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _hideCustomInput,
                    icon: const Icon(LucideIcons.x),
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ],
            if (cartState.billDiscountAmount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              _TotalRow(
                label: 'Bill Discount',
                value:
                    '-${_currencyFormat.format(cartState.billDiscountAmount)}',
                valueColor: AppColors.error,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const _DashedDivider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (selectedTaxPercent > 0)
                  Text(
                    _currencyFormat.format(widget.taxAmount),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                GestureDetector(
                  onTap: widget.onShowTaxRateSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: _taxDropdownBorderColor),
                      borderRadius: AppRadius.mdBorder,
                      color: AppColors.surface,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.selectedTaxLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          LucideIcons.chevronDown,
                          color: AppColors.textSecondary,
                          size: AppIconSize.md,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (showTaxBreakdown) ...[
              const SizedBox(height: AppSpacing.sm),
              _TaxBreakdownRow(
                label: 'CGST (${_formatTaxRate(halfRate)}%)',
                value: _currencyFormat.format(widget.cgst),
              ),
              const SizedBox(height: AppSpacing.xxs),
              _TaxBreakdownRow(
                label: 'SGST (${_formatTaxRate(halfRate)}%)',
                value: _currencyFormat.format(widget.sgst),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const _DashedDivider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Amount',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  _currencyFormat.format(widget.displayTotal),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const _DashedDivider(),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                value: widget.isFullyPaid,
                onChanged: (value) => widget.onFullyPaidChanged(value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                title: Text(
                  'Mark As Fully Paid',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
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

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _TaxBreakdownRow extends StatelessWidget {
  const _TaxBreakdownRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DiscountChip extends StatelessWidget {
  const _DiscountChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isActive ? AppColors.primary : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive ? Colors.white : AppColors.textPrimary,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentModeCard extends StatelessWidget {
  const _PaymentModeCard({
    required this.cartState,
    required this.expanded,
    required this.selectedLabel,
    required this.isModeSelected,
    required this.onToggleExpanded,
    required this.onToggleMode,
  });

  final PosCartState cartState;
  final bool expanded;
  final String selectedLabel;
  final bool Function(PaymentMode mode) isModeSelected;
  final VoidCallback onToggleExpanded;
  final void Function(PaymentMode mode) onToggleMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const modes = [PaymentMode.cash, PaymentMode.upi, PaymentMode.card];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpanded,
            borderRadius: AppRadius.mdBorder,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.banknote,
                    color: AppColors.textSecondary,
                    size: AppIconSize.md,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Payment Mode',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    selectedLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    expanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: modes.map((mode) {
                  final selected = isModeSelected(mode);
                  final label = switch (mode) {
                    PaymentMode.cash => 'Cash',
                    PaymentMode.upi => 'UPI',
                    PaymentMode.card => 'Card',
                    PaymentMode.bank => 'Bank',
                  };

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: mode != modes.last ? AppSpacing.sm : 0,
                      ),
                      child: _PaymentModePill(
                        label: label,
                        selected: selected,
                        onTap: () => onToggleMode(mode),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentModePill extends StatelessWidget {
  const _PaymentModePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({
    required this.expanded,
    required this.controller,
    required this.onToggle,
  });

  final bool expanded;
  final TextEditingController controller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: AppRadius.mdBorder,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.stickyNote,
                    color: AppColors.textSecondary,
                    size: AppIconSize.md,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Add Descriptions / Notes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? LucideIcons.minus : LucideIcons.plus,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: AppTextField(
                controller: controller,
                hint: 'Enter notes…',
              ),
            ),
        ],
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.totalPayable,
    required this.isSaving,
    required this.isSavingAndPrinting,
    required this.onSaveAndPrint,
    required this.onSaveBill,
  });

  final double totalPayable;
  final bool isSaving;
  final bool isSavingAndPrinting;
  final VoidCallback onSaveAndPrint;
  final VoidCallback onSaveBill;

  bool get _isBusy => isSaving || isSavingAndPrinting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Total Amount: ${_currencyFormat.format(totalPayable)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isBusy ? null : onSaveAndPrint,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
                      ),
                      child: isSavingAndPrinting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save & Print'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isBusy ? null : onSaveBill,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
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
                          : const Text('Save Bill'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.35),
            );
          }),
        );
      },
    );
  }
}
