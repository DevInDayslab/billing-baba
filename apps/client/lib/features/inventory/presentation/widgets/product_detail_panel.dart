import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _typeColWidth = 160.0;
const _invoiceColWidth = 110.0;
const _nameColWidth = 120.0;
const _dateColWidth = 140.0;
const _quantityColWidth = 90.0;
const _priceColWidth = 100.0;
const _statusColWidth = 80.0;

const double _minTableWidth =
    _typeColWidth +
    _invoiceColWidth +
    _nameColWidth +
    _dateColWidth +
    _quantityColWidth +
    _priceColWidth +
    _statusColWidth +
    24;

class ProductDetailPanel extends ConsumerWidget {
  const ProductDetailPanel({required this.item, super.key});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(productTransactionsProvider(item.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StockSummaryBar(item: item),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                'TRANSACTIONS',
                style: InventoryStyles.listHeaderStyle.copyWith(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 220,
                child: InventorySearchField(
                  hint: 'Search',
                  onChanged: (query) => ref
                      .read(productTransactionSearchQueryProvider.notifier)
                      .update(query),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? const Center(
                  child: Text(
                    'No transactions found',
                    style: InventoryStyles.emptyStateStyle,
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final tableWidth = constraints.maxWidth > _minTableWidth
                        ? constraints.maxWidth
                        : _minTableWidth;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        height: constraints.maxHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _TransactionTableHeader(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  return _TransactionTableRow(
                                    transaction: transactions[index],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StockSummaryBar extends StatelessWidget {
  const _StockSummaryBar({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final available = item.availableForSale ?? item.quantity;
    final reserved = item.reservedQuantity;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: Row(
        children: [
          Text(
            'Available for Sale: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            available?.toStringAsFixed(
                  available == available.roundToDouble() ? 0 : 1,
                ) ??
                '-',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Text(
            'RESERVED QUANTITY: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            reserved?.toStringAsFixed(
                  reserved == reserved.roundToDouble() ? 0 : 1,
                ) ??
                '-',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTableHeader extends StatelessWidget {
  const _TransactionTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 12),
          _HeaderCell(width: _typeColWidth, label: 'TYPE'),
          _HeaderCell(width: _invoiceColWidth, label: 'INVOICE/REF. NO'),
          _HeaderCell(width: _nameColWidth, label: 'NAME'),
          _HeaderCell(
            width: _dateColWidth,
            label: 'DATE',
            showSort: true,
          ),
          _HeaderCell(width: _quantityColWidth, label: 'QUANTITY'),
          _HeaderCell(width: _priceColWidth, label: 'PRICE/ UNIT'),
          _HeaderCell(width: _statusColWidth, label: 'STATUS'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.width,
    required this.label,
    this.showSort = false,
  });

  final double width;
  final String label;
  final bool showSort;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              style: InventoryStyles.listHeaderStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.filter_list,
            size: 14,
            color: Colors.grey.shade500,
          ),
          if (showSort) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_downward,
              size: 12,
              color: Colors.grey.shade600,
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionTableRow extends StatelessWidget {
  const _TransactionTableRow({required this.transaction});

  final ProductTransaction transaction;

  static final _dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final dotColor = transaction.isInbound
        ? inventoryPositiveColor
        : inventoryNegativeColor;

    final quantityText = transaction.unit != null
        ? '${_formatQuantity(transaction.quantity)} ${transaction.unit}'
        : _formatQuantity(transaction.quantity);

    final priceText = transaction.pricePerUnit > 0
        ? _currencyFormat.format(transaction.pricePerUnit)
        : '-';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        hoverColor: const Color(0xFFF5F5F5),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inventoryCardBorder)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              _DataCell(
                width: _typeColWidth,
                child: Text(
                  transaction.typeLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DataCell(
                width: _invoiceColWidth,
                child: Text(
                  transaction.invoiceRefNo,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DataCell(
                width: _nameColWidth,
                child: Text(
                  transaction.partyName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DataCell(
                width: _dateColWidth,
                child: Text(
                  _dateFormat.format(transaction.date),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DataCell(
                width: _quantityColWidth,
                child: Text(quantityText),
              ),
              _DataCell(
                width: _priceColWidth,
                child: Text(priceText),
              ),
              _DataCell(
                width: _statusColWidth,
                child: Text(
                  transaction.status,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({required this.width, required this.child});

  final double width;
  final Widget child;

  static const _dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DefaultTextStyle(style: _dataStyle, child: child),
    );
  }
}
