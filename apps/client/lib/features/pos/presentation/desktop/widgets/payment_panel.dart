import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_avatar.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/split_payment_sheet.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';
import 'package:billing_baba/shared/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

class PaymentPanel extends ConsumerStatefulWidget {
  const PaymentPanel({
    required this.onCompleteSale,
    super.key,
  });

  final VoidCallback onCompleteSale;

  @override
  ConsumerState<PaymentPanel> createState() => _PaymentPanelState();
}

class _PaymentPanelState extends ConsumerState<PaymentPanel> {
  late final TextEditingController _amountReceivedController;
  final _notesController = TextEditingController();
  final _customerSearchController = TextEditingController();
  final _customerSearchDebouncer = Debouncer();
  String _debouncedCustomerQuery = '';

  @override
  void initState() {
    super.initState();
    _amountReceivedController = TextEditingController();
  }

  @override
  void dispose() {
    _amountReceivedController.dispose();
    _notesController.dispose();
    _customerSearchController.dispose();
    _customerSearchDebouncer.dispose();
    super.dispose();
  }

  void _onCustomerSearchChanged(String value) {
    _customerSearchDebouncer.run(() {
      setState(() => _debouncedCustomerQuery = value.trim());
    });
  }

  void _selectCustomer(PosCustomer customer) {
    ref.read(posCartProvider.notifier).setCustomerName(customer.name);
    _customerSearchController.text = customer.name;
    setState(() => _debouncedCustomerQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartProvider);
    final notifier = ref.read(posCartProvider.notifier);

    ref.listen(posCartProvider, (previous, next) {
      final text = next.totalPaid > 0
          ? next.totalPaid.toStringAsFixed(2)
          : next.totalPayable.toStringAsFixed(2);
      if (_amountReceivedController.text != text) {
        _amountReceivedController.text = text;
      }
    });

    final selectedModes = cart.payments.map((p) => p.mode).toList();
    final customerSearchAsync = ref.watch(
      posCustomerSearchProvider(_debouncedCustomerQuery),
    );

    return PosPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Customer', style: PosStyles.sectionTitleStyle),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _customerSearchController,
                    style: saleFieldTextStyle,
                    onChanged: _onCustomerSearchChanged,
                    decoration: buildPosFieldDecoration(
                      hint: 'Search or select customer',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.person_add_outlined, size: 20),
                        color: AppColors.textSecondary,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  if (_debouncedCustomerQuery.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _CustomerSearchResults(
                      searchAsync: customerSearchAsync,
                      onSelect: _selectCustomer,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  _WalkInCustomerCard(
                    customerName: cart.customerName,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StaticDropdown(
                    label: 'Warehouse',
                    value: cart.warehouseLabel,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StaticDropdown(
                    label: 'Price List',
                    value: cart.priceListLabel,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Payment Mode',
                    style: PosStyles.sectionTitleStyle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tileWidth =
                          (constraints.maxWidth - AppSpacing.sm) / 2;
                      return Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: PaymentMode.values.map((mode) {
                          final selected = notifier.isPaymentModeSelected(mode);
                          return SizedBox(
                            width: tileWidth,
                            height: 64,
                            child: _PaymentModeTile(
                              mode: mode,
                              selected: selected,
                              onTap: () => notifier.togglePaymentMode(mode),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  if (selectedModes.length >= 2) ...[
                    const SizedBox(height: AppSpacing.md),
                    SplitPaymentSheet(payments: cart.payments),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _amountReceivedController,
                    style: saleFieldTextStyle,
                    decoration: buildPosFieldDecoration(
                      labelText: 'Amount Received',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calculate_outlined, size: 20),
                        color: AppColors.textSecondary,
                        onPressed: () {},
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0;
                      if (cart.payments.length == 1) {
                        notifier.updatePaymentAmount(
                          cart.payments.first.mode,
                          amount,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _notesController,
                    style: saleFieldTextStyle,
                    decoration: buildPosFieldDecoration(
                      labelText: 'Notes (Optional)',
                      hint: 'Add invoice notes here...',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: posCardBorder),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('Share on WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: widget.onCompleteSale,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Complete Sale (F9)'),
                  style: PosButtonStyles.primaryFilled.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                    textStyle: const WidgetStatePropertyAll(
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerSearchResults extends StatelessWidget {
  const _CustomerSearchResults({
    required this.searchAsync,
    required this.onSelect,
  });

  final AsyncValue<List<PosCustomer>> searchAsync;
  final ValueChanged<PosCustomer> onSelect;

  @override
  Widget build(BuildContext context) {
    return searchAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          'Search failed: $error',
          style: PosStyles.metadataStyle.copyWith(color: AppColors.error),
        ),
      ),
      data: (customers) {
        if (customers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'No customers found',
              style: PosStyles.metadataStyle,
            ),
          );
        }

        return Material(
          elevation: 2,
          borderRadius: AppRadius.mdBorder,
          color: AppColors.surface,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customers.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: posCardBorder),
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                dense: true,
                leading: PartyAvatar(
                  name: customer.name,
                  seed: customer.id,
                  partyId: customer.id,
                  diameter: 32,
                  profileImageUrl: customer.profileImageUrl,
                  profileMediaAssetId: customer.profileMediaAssetId,
                ),
                title: Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: customer.phone != null
                    ? Text(
                        customer.phone!,
                        style: PosStyles.metadataStyle,
                      )
                    : null,
                onTap: () => onSelect(customer),
              );
            },
          ),
        );
      },
    );
  }
}

class _WalkInCustomerCard extends StatelessWidget {
  const _WalkInCustomerCard({this.customerName});

  final String? customerName;

  @override
  Widget build(BuildContext context) {
    final displayName = customerName?.trim().isNotEmpty == true
        ? customerName!
        : 'Walk-in Customer';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: posCardBorder),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: posPositiveColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smBorder,
                ),
                child: const Text(
                  'Retail',
                  style: TextStyle(
                    fontSize: 11,
                    color: posPositiveColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Outstanding: ₹0.00', style: PosStyles.metadataStyle),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MiniBox(
                  label: 'Credit Limit',
                  value: _currencyFormat.format(0),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniBox(
                  label: 'Available Credit',
                  value: _currencyFormat.format(0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBox extends StatelessWidget {
  const _MiniBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.smBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PosStyles.metadataStyle.copyWith(fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticDropdown extends StatelessWidget {
  const _StaticDropdown({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: buildPosFieldDecoration(labelText: label).copyWith(
        suffixIcon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textSecondary,
        ),
      ),
      child: Text(value, style: saleFieldTextStyle.copyWith(fontSize: 13)),
    );
  }
}

class _PaymentModeTile extends StatelessWidget {
  const _PaymentModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final PaymentMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (mode) {
      PaymentMode.cash => (Icons.payments_outlined, 'Cash'),
      PaymentMode.upi => (Icons.qr_code_2_outlined, 'UPI'),
      PaymentMode.card => (Icons.credit_card_outlined, 'Card'),
      PaymentMode.bank => (Icons.account_balance_outlined, 'Bank'),
    };

    return Material(
      color: selected ? posSelectedBackground : AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: selected ? AppColors.primary : posCardBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
