import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_empty_state_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _posAccent = Color(0xFF00897B);
const _posCircle = Color(0xFFE0F2F1);
const _posShape = Color(0xFF4DB6AC);

/// Landing card: empty state or list of completed POS bills.
class PosLandingContent extends ConsumerWidget {
  const PosLandingContent({required this.onStartSale, super.key});

  final VoidCallback onStartSale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(posSalesListProvider);

    return salesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _EmptyState(onStartSale: onStartSale),
      data: (sales) {
        if (sales.isEmpty) {
          return _EmptyState(onStartSale: onStartSale);
        }
        return _SalesList(sales: sales, onStartSale: onStartSale);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStartSale});

  final VoidCallback onStartSale;

  @override
  Widget build(BuildContext context) {
    return SaleEmptyStateCard(
      illustration: const SaleGeometricIllustration(
        circleColor: _posCircle,
        shapeColor: _posShape,
        shapeIcon: Icons.point_of_sale_outlined,
      ),
      description:
          'Bill customers quickly with barcode scan, split payments, and hold bills.',
      buttonLabel: 'New Sale',
      buttonColor: _posAccent,
      onPressed: onStartSale,
    );
  }
}

class _SalesList extends StatelessWidget {
  const _SalesList({required this.sales, required this.onStartSale});

  final List<PosSale> sales;
  final VoidCallback onStartSale;

  static final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onStartSale,
              style: FilledButton.styleFrom(
                backgroundColor: _posAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Sale'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final sale in sales)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _posCircle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_outlined,
                          color: _posAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SaleCustomerDropdown(
                              sale: sale,
                              currencyFormat: _currencyFormat,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${sale.billNo} · ${_dateFormat.format(sale.completedAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${sale.itemCount} item${sale.itemCount == 1 ? '' : 's'} · ${_paymentLabel(sale.payments)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _currencyFormat.format(sale.amount),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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

  static String _paymentLabel(List<PaymentEntry> payments) {
    if (payments.isEmpty) return 'Cash';
    return payments
        .map(
          (p) => switch (p.mode) {
            PaymentMode.cash => 'Cash',
            PaymentMode.upi => 'UPI',
            PaymentMode.card => 'Card',
            PaymentMode.bank => 'Bank',
          },
        )
        .join(', ');
  }
}

class _SaleCustomerDropdown extends StatelessWidget {
  const _SaleCustomerDropdown({
    required this.sale,
    required this.currencyFormat,
  });

  final PosSale sale;
  final NumberFormat currencyFormat;

  static const _nameStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    if (sale.items.isEmpty) {
      return Text(sale.displayName, style: _nameStyle);
    }

    return PopupMenuButton<void>(
      onSelected: (_) {},
      offset: const Offset(0, 28),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      constraints: BoxConstraints(
        minWidth: 240,
        maxWidth: 320,
        maxHeight: sale.items.length > 6 ? 240 : double.infinity,
      ),
      itemBuilder: (context) => [
        for (final item in sale.items)
          PopupMenuItem<void>(
            enabled: false,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.name} × ${item.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currencyFormat.format(item.lineTotal),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sale.displayName, style: _nameStyle),
          const SizedBox(width: 2),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
