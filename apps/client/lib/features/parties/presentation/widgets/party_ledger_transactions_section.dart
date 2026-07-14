import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_detail_list_tile.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_item_list_table.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_transaction_navigation.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_ledger_transaction_actions_menu.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_table_shared.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

enum PartyTransactionSortColumn {
  type,
  reference,
  date,
  total,
  balance,
  status,
}

enum PartyTransactionSortDirection { none, ascending, descending }

class PartyTransactionTableState {
  const PartyTransactionTableState({
    this.sortColumn,
    this.sortDirection = PartyTransactionSortDirection.none,
    this.typeFilter,
    this.referenceFilter,
    this.dateFilter,
    this.totalFilter,
    this.balanceFilter,
    this.statusFilter,
  });

  final PartyTransactionSortColumn? sortColumn;
  final PartyTransactionSortDirection sortDirection;
  final MultiSelectColumnFilter? typeFilter;
  final TextColumnFilter? referenceFilter;
  final DateColumnFilter? dateFilter;
  final AmountColumnFilter? totalFilter;
  final AmountColumnFilter? balanceFilter;
  final MultiSelectColumnFilter? statusFilter;

  bool get hasColumnFilters =>
      FilterUtils.isFilterActive(FilterType.multiSelect, typeFilter) ||
      FilterUtils.isFilterActive(FilterType.text, referenceFilter) ||
      FilterUtils.isFilterActive(FilterType.date, dateFilter) ||
      FilterUtils.isFilterActive(FilterType.number, totalFilter) ||
      FilterUtils.isFilterActive(FilterType.number, balanceFilter) ||
      FilterUtils.isFilterActive(FilterType.multiSelect, statusFilter);

  PartyTransactionTableState copyWith({
    PartyTransactionSortColumn? sortColumn,
    PartyTransactionSortDirection? sortDirection,
    MultiSelectColumnFilter? Function()? typeFilter,
    TextColumnFilter? Function()? referenceFilter,
    DateColumnFilter? Function()? dateFilter,
    AmountColumnFilter? Function()? totalFilter,
    AmountColumnFilter? Function()? balanceFilter,
    MultiSelectColumnFilter? Function()? statusFilter,
  }) {
    return PartyTransactionTableState(
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
      typeFilter: typeFilter != null ? typeFilter() : this.typeFilter,
      referenceFilter:
          referenceFilter != null ? referenceFilter() : this.referenceFilter,
      dateFilter: dateFilter != null ? dateFilter() : this.dateFilter,
      totalFilter: totalFilter != null ? totalFilter() : this.totalFilter,
      balanceFilter:
          balanceFilter != null ? balanceFilter() : this.balanceFilter,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
    );
  }

  PartyTransactionTableState toggleSort(PartyTransactionSortColumn column) {
    if (sortColumn != column ||
        sortDirection == PartyTransactionSortDirection.none) {
      return copyWith(
        sortColumn: column,
        sortDirection: PartyTransactionSortDirection.ascending,
      );
    }
    if (sortDirection == PartyTransactionSortDirection.ascending) {
      return copyWith(
        sortDirection: PartyTransactionSortDirection.descending,
      );
    }
    return const PartyTransactionTableState();
  }
}

class PartyLedgerTransactionsSection extends StatefulWidget {
  const PartyLedgerTransactionsSection({
    required this.transactionsAsync,
    required this.onRefresh,
    super.key,
  });

  final AsyncValue<List<PartyLedgerTransactionModel>> transactionsAsync;
  final Future<void> Function() onRefresh;

  @override
  State<PartyLedgerTransactionsSection> createState() =>
      _PartyLedgerTransactionsSectionState();
}

class _PartyLedgerTransactionsSectionState
    extends State<PartyLedgerTransactionsSection> {
  PartyTransactionTableState _tableState = const PartyTransactionTableState();
  String _searchQuery = '';

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  void _toggleSort(PartyTransactionSortColumn column) {
    setState(() {
      _tableState = _tableState.toggleSort(column);
    });
  }

  bool _isSorted(PartyTransactionSortColumn column) =>
      _tableState.sortColumn == column &&
      _tableState.sortDirection != PartyTransactionSortDirection.none;

  bool _sortAscending(PartyTransactionSortColumn column) =>
      _tableState.sortColumn == column &&
      _tableState.sortDirection == PartyTransactionSortDirection.ascending;

  double _transactionTotal(PartyLedgerTransactionModel transaction) =>
      transaction.debit > 0 ? transaction.debit : transaction.credit;

  String _transactionStatus(PartyLedgerTransactionModel transaction) {
    return switch (transaction.entryType) {
      'payment' => 'Paid',
      'sale' || 'purchase' => 'Paid',
      'return' => 'Returned',
      _ => '—',
    };
  }

  List<String> _typeOptions(List<PartyLedgerTransactionModel> transactions) {
    return transactions
        .map((tx) => tx.type.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _statusOptions(List<PartyLedgerTransactionModel> transactions) {
    return transactions
        .map(_transactionStatus)
        .where((value) => value != '—')
        .toSet()
        .toList()
      ..sort();
  }

  List<PartyLedgerTransactionModel> _applyTableState(
    List<PartyLedgerTransactionModel> transactions,
  ) {
    var rows = List<PartyLedgerTransactionModel>.from(transactions);

    final searchQuery = _searchQuery.trim();
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      rows = rows.where((tx) {
        final haystack = [
          tx.type,
          tx.referenceNumber ?? '',
          _dateFormat.format(tx.createdAt.toLocal()),
          _currencyFormat.format(_transactionTotal(tx)),
          _currencyFormat.format(tx.balanceAfter),
          _transactionStatus(tx),
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      }).toList();
    }

    final typeFilter = _tableState.typeFilter;
    if (typeFilter != null && typeFilter.values.isNotEmpty) {
      rows = rows.where((tx) => typeFilter.values.contains(tx.type)).toList();
    }

    final referenceFilter = _tableState.referenceFilter;
    if (referenceFilter != null && referenceFilter.isActive) {
      rows = rows
          .where(
            (tx) => referenceFilter.matches(tx.referenceNumber ?? ''),
          )
          .toList();
    }

    final dateFilter = _tableState.dateFilter;
    if (dateFilter != null && dateFilter.isActive) {
      rows = rows.where((tx) => dateFilter.matches(tx.date)).toList();
    }

    final totalFilter = _tableState.totalFilter;
    if (totalFilter != null && totalFilter.isActive) {
      rows = rows
          .where((tx) => totalFilter.matches(_transactionTotal(tx)))
          .toList();
    }

    final balanceFilter = _tableState.balanceFilter;
    if (balanceFilter != null && balanceFilter.isActive) {
      rows = rows
          .where((tx) => balanceFilter.matches(tx.balanceAfter))
          .toList();
    }

    final statusFilter = _tableState.statusFilter;
    if (statusFilter != null && statusFilter.values.isNotEmpty) {
      rows = rows
          .where((tx) => statusFilter.values.contains(_transactionStatus(tx)))
          .toList();
    }

    final sortColumn = _tableState.sortColumn;
    if (sortColumn != null &&
        _tableState.sortDirection != PartyTransactionSortDirection.none) {
      final ascending =
          _tableState.sortDirection == PartyTransactionSortDirection.ascending;
      rows.sort((a, b) {
        final comparison = switch (sortColumn) {
          PartyTransactionSortColumn.type => a.type.compareTo(b.type),
          PartyTransactionSortColumn.reference =>
            (a.referenceNumber ?? '').compareTo(b.referenceNumber ?? ''),
          PartyTransactionSortColumn.date => a.date.compareTo(b.date),
          PartyTransactionSortColumn.total =>
            _transactionTotal(a).compareTo(_transactionTotal(b)),
          PartyTransactionSortColumn.balance =>
            a.balanceAfter.compareTo(b.balanceAfter),
          PartyTransactionSortColumn.status => _transactionStatus(
            a,
          ).compareTo(_transactionStatus(b)),
        };
        return ascending ? comparison : -comparison;
      });
    }

    return rows;
  }

  List<InventoryListColumn> _buildColumns(
    List<PartyLedgerTransactionModel> sourceTransactions,
  ) {
    InventoryListColumn column({
      required String label,
      required int flex,
      required PartyTransactionSortColumn sortColumn,
      required ColumnFilter filterConfig,
      required Object? initialFilter,
      required ValueChanged<FilterResult?> onApply,
      bool alignEnd = false,
    }) {
      return InventoryListColumn(
        label: label,
        flex: flex,
        alignEnd: alignEnd,
        sortable: true,
        isSorted: _isSorted(sortColumn),
        sortAscending: _sortAscending(sortColumn),
        onSort: () => _toggleSort(sortColumn),
        trailing: TableColumnFilterTrigger(
          config: filterConfig,
          iconOnly: true,
          initialValue: initialFilter,
          onApply: onApply,
        ),
      );
    }

    final typeOptions = _typeOptions(sourceTransactions);
    final statusOptions = _statusOptions(sourceTransactions);

    return [
      column(
        label: 'TYPE',
        flex: 2,
        sortColumn: PartyTransactionSortColumn.type,
        filterConfig: ColumnFilter(
          id: 'type',
          title: 'Type',
          type: FilterType.multiSelect,
          values: typeOptions,
          searchable: false,
        ),
        initialFilter: _tableState.typeFilter,
        onApply: (result) => setState(() {
          _tableState = _tableState.copyWith(
            typeFilter: () =>
                FilterUtils.fromResult(result) as MultiSelectColumnFilter?,
          );
        }),
      ),
      column(
        label: 'REFERENCE NUMBER',
        flex: 2,
        sortColumn: PartyTransactionSortColumn.reference,
        filterConfig: const ColumnFilter(
          id: 'reference',
          title: 'Reference Number',
          type: FilterType.text,
          hintText: 'Reference number',
        ),
        initialFilter: _tableState.referenceFilter,
        onApply: (result) => setState(() {
          _tableState = _tableState.copyWith(
            referenceFilter: () =>
                FilterUtils.fromResult(result) as TextColumnFilter?,
          );
        }),
      ),
      column(
        label: 'DATE',
        flex: 2,
        sortColumn: PartyTransactionSortColumn.date,
        filterConfig: const ColumnFilter(
          id: 'date',
          title: 'Date',
          type: FilterType.date,
        ),
        initialFilter: _tableState.dateFilter,
        onApply: (result) => setState(() {
          _tableState = _tableState.copyWith(
            dateFilter: () =>
                FilterUtils.fromResult(result) as DateColumnFilter?,
          );
        }),
      ),
      column(
        label: 'TOTAL',
        flex: 2,
        sortColumn: PartyTransactionSortColumn.total,
        alignEnd: true,
        filterConfig: const ColumnFilter(
          id: 'total',
          title: 'Total',
          type: FilterType.number,
        ),
        initialFilter: _tableState.totalFilter,
        onApply: (result) => setState(() {
          _tableState = _tableState.copyWith(
            totalFilter: () =>
                FilterUtils.fromResult(result) as AmountColumnFilter?,
          );
        }),
      ),
      column(
        label: 'BALANCE / OUTSTANDING',
        flex: 2,
        sortColumn: PartyTransactionSortColumn.balance,
        alignEnd: true,
        filterConfig: const ColumnFilter(
          id: 'balance',
          title: 'Balance / Outstanding',
          type: FilterType.number,
        ),
        initialFilter: _tableState.balanceFilter,
        onApply: (result) => setState(() {
          _tableState = _tableState.copyWith(
            balanceFilter: () =>
                FilterUtils.fromResult(result) as AmountColumnFilter?,
          );
        }),
      ),
      column(
        label: 'STATUS',
        flex: 2,
        sortColumn: PartyTransactionSortColumn.status,
        filterConfig: ColumnFilter(
          id: 'status',
          title: 'Status',
          type: FilterType.multiSelect,
          values: statusOptions,
          searchable: false,
        ),
        initialFilter: _tableState.statusFilter,
        onApply: (result) => setState(() {
          _tableState = _tableState.copyWith(
            statusFilter: () =>
                FilterUtils.fromResult(result) as MultiSelectColumnFilter?,
          );
        }),
      ),
      const InventoryListColumn(
        label: 'ACTIONS',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sourceTransactions = widget.transactionsAsync.value ?? const [];
    final filteredTransactions = _applyTableState(sourceTransactions);
    final isFiltered = _tableState.hasColumnFilters || _searchQuery.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              ExpandableTableSearchField(
                hint: 'Search Data',
                initialQuery: _searchQuery,
                onQueryChanged: (query) => setState(() => _searchQuery = query),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Print coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.print_outlined, size: 20),
                color: AppColors.textSecondary,
                tooltip: 'Print',
              ),
              SalesXlsChip(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _cardBorder),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: InventoryItemListTable<PartyLedgerTransactionModel>(
              includeTrailingSpace: false,
              columns: _buildColumns(sourceTransactions),
              items: filteredTransactions,
              itemsAsync: widget.transactionsAsync,
              onRefresh: widget.onRefresh,
              emptyMessage: isFiltered
                  ? 'No matching transactions'
                  : 'No transactions yet',
              itemBuilder: (context, transaction, index) {
                final total = _transactionTotal(transaction);
                final status = _transactionStatus(transaction);

                return InventoryDetailListTile(
                  index: index,
                  onTap: () => navigateToPartyLedgerTransaction(
                    context,
                    transaction,
                  ),
                  flexValues: const [2, 2, 2, 2, 2, 2, 1],
                  alignEnds: const [
                    false,
                    false,
                    false,
                    true,
                    true,
                    false,
                    false,
                  ],
                  cells: [
                    InventoryListValueText(value: transaction.type),
                    InventoryListValueText(
                      value: PartyModel.displayOrDash(
                        transaction.referenceNumber,
                      ),
                    ),
                    InventoryListValueText(
                      value: _dateFormat.format(transaction.createdAt.toLocal()),
                    ),
                    InventoryListValueText(
                      value: _currencyFormat.format(total),
                      textAlign: TextAlign.right,
                    ),
                    InventoryListValueText(
                      value: _currencyFormat.format(transaction.balanceAfter),
                      textAlign: TextAlign.right,
                    ),
                    _PartyTransactionStatusChip(status: status),
                    Center(
                      child: PartyLedgerTransactionActionsMenu(
                        transaction: transaction,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PartyTransactionStatusChip extends StatelessWidget {
  const _PartyTransactionStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == '—') {
      return InventoryListValueText(value: status);
    }

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
      'returned' => (
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
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
