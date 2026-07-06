import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/inventory/models/dto/stock_level_dto.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/adjust_stock_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_primary_button.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProductDetailPanel extends ConsumerWidget {
  const ProductDetailPanel({required this.item, super.key});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(item.id));
    final displayItem = detailAsync.value ?? item;
    final transactionsAsync = ref.watch(productTransactionsProvider(item.id));
    final stockLevels = ref.watch(itemStockLevelsProvider(item.id)).value ?? [];
    final categories = ref.watch(categoriesProvider);
    final categoryName = categories
        .where((category) => category.id == displayItem.categoryId)
        .map((category) => category.name)
        .firstOrNull;
    final unitLabel = displayItem.baseUnitShortName ?? 'pcs';
    final stockAfterById = transactionsAsync.maybeWhen(
      data: _stockAfterByTransactionId,
      orElse: () => const <String, double>{},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  displayItem.name,
                  style: InventoryStyles.panelTitleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              InventorySecondaryButton(
                label: 'Adjust Stock',
                onPressed: () =>
                    showAdjustStockDialog(context, item: displayItem),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProductSummaryCard(
                  item: displayItem,
                  categoryName: categoryName,
                  unitLabel: unitLabel,
                ),
                const SizedBox(height: AppSpacing.lg),
                _StockSummaryCard(
                  item: displayItem,
                  stockLevels: stockLevels,
                  unitLabel: unitLabel,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Text('TRANSACTIONS', style: InventoryStyles.listHeaderStyle),
              const Spacer(),
              SizedBox(
                width: 220,
                child: InventorySearchField(
                  hint: 'Search',
                  onChanged: (query) => ref
                      .read(productTransactionSearchQueryProvider.notifier)
                      .query = query,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: _TransactionsTable(
              transactionsAsync: transactionsAsync,
              unitLabel: unitLabel,
              stockAfterById: stockAfterById,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({
    required this.item,
    required this.categoryName,
    required this.unitLabel,
  });

  final InventoryItem item;
  final String? categoryName;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final currentStock = _formatQuantity(item.quantity, unitLabel);

    return _SectionCard(
      title: 'Product Summary',
      child: _DetailTable(
        rows: [
          _DetailRow(label: 'Product Name', value: item.name),
          const _DetailRow(label: 'SKU', value: '-'),
          _DetailRow(label: 'Barcode', value: _displayOrDash(item.barcode)),
          _DetailRow(label: 'Category', value: _displayOrDash(categoryName)),
          _DetailRow(label: 'Unit', value: unitLabel),
          _DetailRow(
            label: 'Purchase Price',
            value: item.purchasePrice != null
                ? currency.format(item.purchasePrice)
                : '-',
          ),
          _DetailRow(
            label: 'Selling Price',
            value: item.salePrice != null ? currency.format(item.salePrice) : '-',
          ),
          const _DetailRow(label: 'GST Rate', value: '-'),
          _DetailRow(label: 'Status', value: _stockStatus(item)),
          _DetailRow(label: 'Current Stock', value: currentStock),
        ],
      ),
    );
  }
}

class _StockSummaryCard extends StatelessWidget {
  const _StockSummaryCard({
    required this.item,
    required this.stockLevels,
    required this.unitLabel,
  });

  final InventoryItem item;
  final List<StockLevelDto> stockLevels;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final available = item.availableForSale ?? item.quantity;
    final reserved = item.reservedQuantity ?? 0;
    final warehouse = stockLevels
        .map((level) => level.godownName)
        .where((name) => name.isNotEmpty)
        .join(', ');
    final stockValue = item.stockValue ??
        stockLevels.fold<double>(
          0,
          (sum, level) =>
              sum +
              ((_parseDecimal(level.quantity) ?? 0) *
                  (_parseDecimal(level.averageCost) ?? 0)),
        );

    return _SectionCard(
      title: 'Stock Summary',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          _SummaryMetric(
            label: 'Available Stock',
            value: _formatQuantity(available, unitLabel),
          ),
          _SummaryMetric(
            label: 'Reserved Stock',
            value: _formatQuantity(reserved, unitLabel),
          ),
          _SummaryMetric(
            label: 'Warehouse',
            value: warehouse.isEmpty ? 'Main Warehouse' : warehouse,
          ),
          _SummaryMetric(
            label: 'Stock Value',
            value: currency.format(stockValue),
          ),
        ],
      ),
    );
  }
}

class _TransactionsTable extends StatelessWidget {
  const _TransactionsTable({
    required this.transactionsAsync,
    required this.unitLabel,
    required this.stockAfterById,
  });

  final AsyncValue<List<ProductTransaction>> transactionsAsync;
  final String unitLabel;
  final Map<String, double> stockAfterById;

  static const _columns = [
    InventoryListColumn(label: 'DATE', flex: 2),
    InventoryListColumn(label: 'DOCUMENT', flex: 2),
    InventoryListColumn(label: 'REFERENCE NO.', flex: 2),
    InventoryListColumn(label: 'PARTY', flex: 2),
    InventoryListColumn(label: 'TYPE'),
    InventoryListColumn(label: 'QUANTITY', flex: 2),
    InventoryListColumn(label: 'RATE', flex: 2),
    InventoryListColumn(label: 'STOCK AFTER', flex: 2),
    InventoryListColumn(label: 'AMOUNT', flex: 2),
    InventoryListColumn(label: 'STATUS', flex: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: inventoryCardBorder),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InventoryListHeader(columns: _columns),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) => const _TransactionsEmptyState(),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const _TransactionsEmptyState();
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _TransactionRow(
                      transaction: transaction,
                      unitLabel: unitLabel,
                      stockAfter: stockAfterById[transaction.id],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.unitLabel,
    required this.stockAfter,
  });

  final ProductTransaction transaction;
  final String unitLabel;
  final double? stockAfter;

  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final quantityColor = transaction.isInbound
        ? inventoryPositiveColor
        : inventoryNegativeColor;
    final signedPrefix = transaction.isInbound ? '+' : '-';
    final quantityText =
        '$signedPrefix${_formatQuantityValue(transaction.quantity)} $unitLabel';
    final rateText = transaction.pricePerUnit > 0
        ? _currencyFormat.format(transaction.pricePerUnit)
        : '-';
    final amountText = transaction.amount > 0
        ? _currencyFormat.format(transaction.amount)
        : '-';
    final stockAfterText = stockAfter != null
        ? _formatQuantity(stockAfter, unitLabel)
        : '-';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: InventoryListRowLayout(
        flexValues: const [2, 2, 2, 2, 1, 2, 2, 2, 2, 2],
        children: [
          Text(
            _dateFormat.format(transaction.date),
            style: _cellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.documentLabel,
            style: _cellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.referenceNo,
            style: _cellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.partyName,
            style: _cellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.transactionType,
            style: _cellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            quantityText,
            style: _cellStyle.copyWith(
              color: quantityColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(rateText, style: _cellStyle, overflow: TextOverflow.ellipsis),
          Text(
            stockAfterText,
            style: _cellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(amountText, style: _cellStyle, overflow: TextOverflow.ellipsis),
          Text(
            transaction.status,
            style: _cellStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static const _cellStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: inventoryCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;
}

class _DetailTable extends StatelessWidget {
  const _DetailTable({required this.rows});

  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(140),
        1: FlexColumnWidth(),
      },
      children: [
        for (final row in rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  row.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  row.value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: listPanelCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsEmptyState extends StatelessWidget {
  const _TransactionsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No inventory transactions yet.',
              style: ListPanelStyles.emptyStateStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Stock movements related to this product will appear here.',
              style: ListPanelStyles.emptyStateStyle.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, double> _stockAfterByTransactionId(
  List<ProductTransaction> transactions,
) {
  final chronological = [...transactions]
    ..sort((a, b) => a.date.compareTo(b.date));
  final result = <String, double>{};
  var running = 0.0;

  for (final transaction in chronological) {
    running += transaction.signedQuantity;
    result[transaction.id] = running;
  }

  return result;
}

String _displayOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value;
}

String _stockStatus(InventoryItem item) {
  final quantity = item.quantity;
  if (quantity == null || quantity <= 0) return 'Out of Stock';
  final reorder = item.reorderLevel;
  if (reorder != null && quantity <= reorder) return 'Low Stock';
  return 'In Stock';
}

double? _parseDecimal(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return double.tryParse(value);
}

String _formatQuantity(double? value, String unit) {
  if (value == null) return '-';
  return '${_formatQuantityValue(value)} $unit';
}

String _formatQuantityValue(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
}
