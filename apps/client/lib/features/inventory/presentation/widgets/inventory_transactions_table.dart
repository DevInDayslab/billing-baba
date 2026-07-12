import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/inventory/models/inventory_transaction_filters.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_ledger_column_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_movement_indicator.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _tableBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = 8;

const _indicatorColWidth = 28.0;
const _typeColWidth = 148.0;
const _invoiceRefColWidth = 120.0;
const _partyColWidth = 128.0;
const _dateColWidth = 132.0;
const _qtyColWidth = 80.0;
const _priceColWidth = 92.0;
const _statusColWidth = 88.0;
const _actionsColWidth = 40.0;

class InventoryTransactionsTable extends ConsumerWidget {
  const InventoryTransactionsTable({
    required this.itemId,
    required this.unitLabel,
    super.key,
  });

  final String itemId;
  final String unitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(productTransactionsProvider(itemId));
    final paginated = ref.watch(paginatedProductTransactionsProvider(itemId));
    final filters = ref.watch(productTransactionFiltersProvider);
    final hasSearch =
        ref.watch(productTransactionSearchQueryProvider).isNotEmpty;

    ref.listen(productTransactionSearchQueryProvider, (previous, next) {
      if (previous != next) {
        ref.read(productTransactionFiltersProvider.notifier).setPage(0);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          child: Row(
            children: [
              const Text(
                'TRANSACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              ExpandableTableSearchField(
                hint: 'Search transactions',
                initialQuery: ref.read(productTransactionSearchQueryProvider),
                onQueryChanged: (query) => ref
                    .read(productTransactionSearchQueryProvider.notifier)
                    .query = query,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _tableBorder),
        Expanded(
          child: transactionsAsync.when(
            skipLoadingOnReload: true,
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, _) => _TransactionsTableShell(
              itemId: itemId,
              unitLabel: unitLabel,
              rows: const [],
              showEmpty: true,
              isFiltered: false,
            ),
            data: (_) => _TransactionsTableShell(
              itemId: itemId,
              unitLabel: unitLabel,
              rows: paginated.items,
              showEmpty: paginated.totalItems == 0,
              isFiltered: hasSearch || filters.hasColumnFilters,
            ),
          ),
        ),
        if (paginated.totalPages > 1) ...[
          const Divider(height: 1, color: _tableBorder),
          _PaginationRow(
            currentPage: paginated.currentPage,
            totalPages: paginated.totalPages,
          ),
        ],
      ],
    );
  }
}

class _TransactionsTableShell extends ConsumerWidget {
  const _TransactionsTableShell({
    required this.itemId,
    required this.unitLabel,
    required this.rows,
    required this.showEmpty,
    required this.isFiltered,
  });

  final String itemId;
  final String unitLabel;
  final List<ProductTransaction> rows;
  final bool showEmpty;
  final bool isFiltered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedProductTransactionIdProvider);
    final columns = _InventoryTransactionTableColumns.build(
      ref: ref,
      itemId: itemId,
    );

    final dataRows = [
      for (var i = 0; i < rows.length; i++)
        InventoryTransactionTableRows.buildDataRow(
          transaction: rows[i],
          unitLabel: unitLabel,
          isOdd: i.isOdd,
          isSelected: rows[i].id == selectedId,
          onTap: () => ref
              .read(selectedProductTransactionIdProvider.notifier)
              .select(rows[i].id),
        ),
    ];

    if (showEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: ResizableDataTable(
              columns: columns,
              rows: const [],
            ),
          ),
          Expanded(
            child: _TransactionsEmptyState(isFiltered: isFiltered),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: ResizableDataTable(
          columns: columns,
          rows: dataRows,
        ),
      ),
    );
  }
}

class InventoryTransactionTableRows {
  const InventoryTransactionTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String _typeLabel(ProductTransaction transaction) {
    final type = transaction.transactionType;
    final godown = transaction.godownName?.trim();
    if (godown != null && godown.isNotEmpty) {
      return '$type ($godown)';
    }
    return type;
  }

  static String _invoiceRef(ProductTransaction transaction) {
    final ref = transaction.invoiceRefNo.trim();
    if (ref.isNotEmpty) return ref;
    return transaction.referenceNo.trim();
  }

  static ResizableDataRow buildDataRow({
    required ProductTransaction transaction,
    required String unitLabel,
    required bool isOdd,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final quantityColor = transaction.isInbound
        ? inventoryPositiveColor
        : inventoryNegativeColor;
    final signedPrefix = transaction.isInbound ? '+' : '-';
    final unit = transaction.unit ?? unitLabel;
    final quantityText =
        '$signedPrefix${formatQuantityValue(transaction.quantity)} $unit';
    final priceText = transaction.pricePerUnit > 0
        ? _currencyFormat.format(transaction.pricePerUnit)
        : inventoryEmDash;

    return ResizableDataRow(
      isSelected: isSelected,
      onTap: onTap,
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(
          child: InventoryMovementIndicator(
            movementType: transaction.movementType,
          ),
        ),
        _DataCell(
          child: Text(
            _typeLabel(transaction),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DataCell(
          child: Text(
            _invoiceRef(transaction),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DataCell(
          child: Text(
            transaction.partyName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DataCell(child: Text(_dateFormat.format(transaction.date))),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            quantityText,
            style: TextStyle(
              color: quantityColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(priceText),
        ),
        _DataCell(child: _TransactionStatusText(status: transaction.status)),
        _DataCell(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 16),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Actions',
          ),
        ),
      ],
    );
  }
}

class _InventoryTransactionTableColumns {
  const _InventoryTransactionTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required String itemId,
  }) {
    final filters = ref.watch(productTransactionFiltersProvider);
    final filtersNotifier = ref.read(productTransactionFiltersProvider.notifier);
    final typeOptions = ref.watch(productTransactionTypeOptionsProvider(itemId));
    final statusOptions =
        ref.watch(productTransactionStatusOptionsProvider(itemId));

    return [
      const ResizableDataColumn(
        initialWidth: _indicatorColWidth,
        minWidth: _indicatorColWidth,
        maxWidth: _indicatorColWidth,
        resizable: false,
        header: SizedBox.shrink(),
      ),
      ResizableDataColumn(
        initialWidth: _typeColWidth,
        header: InventoryLedgerColumnHeader(
          label: 'Type',
          sortColumn: InventoryTransactionSortColumn.type,
          filters: filters,
          onSort: () => filtersNotifier.toggleSort(
            InventoryTransactionSortColumn.type,
          ),
          filter: TableColumnFilterTrigger(
            config: ColumnFilter(
              id: 'type',
              title: 'Type',
              type: FilterType.multiSelect,
              values: typeOptions,
              searchable: false,
            ),
            iconOnly: true,
            initialValue: filters.typeColumnFilter,
            onApply: (result) => filtersNotifier.setTypeColumnFilter(
              FilterUtils.fromResult(result) as MultiSelectColumnFilter?,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _invoiceRefColWidth,
        header: InventoryLedgerColumnHeader(
          label: 'Invoice / Ref.',
          sortColumn: InventoryTransactionSortColumn.invoiceRef,
          filters: filters,
          onSort: () => filtersNotifier.toggleSort(
            InventoryTransactionSortColumn.invoiceRef,
          ),
          filter: TableColumnFilterTrigger(
            config: const ColumnFilter(
              id: 'invoiceRef',
              title: 'Invoice / Ref.',
              type: FilterType.text,
              hintText: 'Invoice / reference',
            ),
            iconOnly: true,
            initialValue: filters.invoiceRefColumnFilter,
            onApply: (result) => filtersNotifier.setInvoiceRefColumnFilter(
              FilterUtils.fromResult(result) as TextColumnFilter?,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        header: InventoryLedgerColumnHeader(
          label: 'Party',
          sortColumn: InventoryTransactionSortColumn.party,
          filters: filters,
          onSort: () => filtersNotifier.toggleSort(
            InventoryTransactionSortColumn.party,
          ),
          filter: TableColumnFilterTrigger(
            config: const ColumnFilter(
              id: 'party',
              title: 'Party',
              type: FilterType.text,
              hintText: 'Party',
            ),
            iconOnly: true,
            initialValue: filters.partyColumnFilter,
            onApply: (result) => filtersNotifier.setPartyColumnFilter(
              FilterUtils.fromResult(result) as TextColumnFilter?,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        header: InventoryLedgerColumnHeader(
          label: 'Date',
          sortColumn: InventoryTransactionSortColumn.date,
          filters: filters,
          onSort: () => filtersNotifier.toggleSort(
            InventoryTransactionSortColumn.date,
          ),
          filter: TableColumnFilterTrigger(
            config: const ColumnFilter(
              id: 'date',
              title: 'Date',
              type: FilterType.date,
            ),
            iconOnly: true,
            initialValue: filters.dateColumnFilter,
            onApply: (result) => filtersNotifier.setDateColumnFilter(
              FilterUtils.fromResult(result) as DateColumnFilter?,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _qtyColWidth,
        header: InventoryLedgerColumnHeader(
          label: 'Quantity',
          sortColumn: InventoryTransactionSortColumn.quantity,
          filters: filters,
          onSort: () => filtersNotifier.toggleSort(
            InventoryTransactionSortColumn.quantity,
          ),
          filter: TableColumnFilterTrigger(
            config: const ColumnFilter(
              id: 'quantity',
              title: 'Quantity',
              type: FilterType.number,
              prefixText: '',
              hintText: 'Enter quantity',
            ),
            iconOnly: true,
            initialValue: filters.quantityColumnFilter,
            onApply: (result) => filtersNotifier.setQuantityColumnFilter(
              FilterUtils.fromResult(result) as AmountColumnFilter?,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _priceColWidth,
        header: InventoryLedgerColumnHeader(
          label: 'Price / Unit',
          sortColumn: InventoryTransactionSortColumn.pricePerUnit,
          filters: filters,
          onSort: () => filtersNotifier.toggleSort(
            InventoryTransactionSortColumn.pricePerUnit,
          ),
          filter: TableColumnFilterTrigger(
            config: const ColumnFilter(
              id: 'price',
              title: 'Price / Unit',
              type: FilterType.number,
            ),
            iconOnly: true,
            initialValue: filters.priceColumnFilter,
            onApply: (result) => filtersNotifier.setPriceColumnFilter(
              FilterUtils.fromResult(result) as AmountColumnFilter?,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        header: InventoryLedgerColumnHeader(
          label: 'Status',
          sortColumn: InventoryTransactionSortColumn.status,
          filters: filters,
          onSort: () => filtersNotifier.toggleSort(
            InventoryTransactionSortColumn.status,
          ),
          filter: TableColumnFilterTrigger(
            config: ColumnFilter(
              id: 'status',
              title: 'Status',
              type: FilterType.multiSelect,
              values: statusOptions,
              searchable: false,
            ),
            iconOnly: true,
            initialValue: filters.statusColumnFilter,
            onApply: (result) => filtersNotifier.setStatusColumnFilter(
              FilterUtils.fromResult(result) as MultiSelectColumnFilter?,
            ),
          ),
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _actionsColWidth,
        minWidth: _actionsColWidth,
        maxWidth: _actionsColWidth,
        resizable: false,
        header: SizedBox.shrink(),
      ),
    ];
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final Alignment alignment;

  static const _dataStyle = TextStyle(
    fontSize: 12,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: _dataStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: 4,
        ),
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}

class _TransactionStatusText extends StatelessWidget {
  const _TransactionStatusText({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final (background, foreground) = switch (normalized) {
      'paid' || 'completed' => (
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      'unpaid' => (
        const Color(0xFFFFEBEE),
        const Color(0xFFC62828),
      ),
      'partial' || 'partially paid' => (
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      'cancelled' => (
        const Color(0xFFF5F5F5),
        const Color(0xFF9E9E9E),
      ),
      _ => (
        const Color(0xFFF5F5F5),
        AppColors.textPrimary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}

class _TransactionsEmptyState extends StatelessWidget {
  const _TransactionsEmptyState({this.isFiltered = false});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isFiltered
                  ? 'No matching transactions'
                  : 'No inventory transactions yet',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isFiltered
                  ? 'Try adjusting your filters or search.'
                  : 'Stock movements for this item will appear here.',
              style: const TextStyle(
                fontSize: 12,
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

class _PaginationRow extends ConsumerWidget {
  const _PaginationRow({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productTransactionFiltersProvider.notifier);
    final canGoPrevious = currentPage > 0;
    final canGoNext = currentPage < totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: canGoPrevious
                ? () => notifier.setPage(currentPage - 1)
                : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Previous',
              style: TextStyle(
                fontSize: 12,
                color: canGoPrevious
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          for (var page = 0; page < totalPages; page++) ...[
            if (page > 0) const SizedBox(width: 4),
            _PageNumber(
              page: page + 1,
              isActive: page == currentPage,
              onTap: () => notifier.setPage(page),
            ),
          ],
          const SizedBox(width: AppSpacing.xs),
          TextButton(
            onPressed:
                canGoNext ? () => notifier.setPage(currentPage + 1) : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Next',
              style: TextStyle(
                fontSize: 12,
                color: canGoNext
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.surface : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
