import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_export_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_ledger_transaction_actions_menu.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_transaction_navigation.dart';
import 'package:billing_baba/features/parties/utils/party_ledger_pdf_builder.dart';
import 'package:billing_baba/features/print/application/print_output_service.dart';
import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_table_shared.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:billing_baba/shared/utils/output_error_mapper.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _typeColWidth = 132.0;
const _referenceColWidth = 128.0;
const _dateColWidth = 148.0;
const _totalColWidth = 100.0;
const _balanceColWidth = 160.0;
const _dueDateColWidth = 108.0;
const _statusColWidth = 128.0;
const _actionsColWidth = 72.0;

enum PartyTransactionSortColumn {
  type,
  reference,
  date,
  total,
  balance,
  dueDate,
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
      referenceFilter: referenceFilter != null
          ? referenceFilter()
          : this.referenceFilter,
      dateFilter: dateFilter != null ? dateFilter() : this.dateFilter,
      totalFilter: totalFilter != null ? totalFilter() : this.totalFilter,
      balanceFilter: balanceFilter != null
          ? balanceFilter()
          : this.balanceFilter,
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

class PartyLedgerTransactionsSection extends ConsumerStatefulWidget {
  const PartyLedgerTransactionsSection({
    required this.transactionsAsync,
    required this.onRefresh,
    super.key,
  });

  final AsyncValue<List<PartyLedgerTransactionModel>> transactionsAsync;
  final Future<void> Function() onRefresh;

  @override
  ConsumerState<PartyLedgerTransactionsSection> createState() =>
      _PartyLedgerTransactionsSectionState();
}

class _PartyLedgerTransactionsSectionState
    extends ConsumerState<PartyLedgerTransactionsSection> {
  PartyTransactionTableState _tableState = const PartyTransactionTableState();
  String _searchQuery = '';

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

  double _transactionTotal(PartyLedgerTransactionModel transaction) =>
      transaction.total > 0
      ? transaction.total
      : (transaction.debit > 0 ? transaction.debit : transaction.credit);

  double _transactionBalance(PartyLedgerTransactionModel transaction) =>
      transaction.balance > 0 || transaction.balanceAfter == 0
      ? transaction.balance
      : transaction.balanceAfter;

  String _transactionStatus(PartyLedgerTransactionModel transaction) {
    final status = transaction.status?.trim();
    if (status != null && status.isNotEmpty) {
      return status;
    }

    final paymentStatus = transaction.paymentStatus?.trim();
    if (paymentStatus != null && paymentStatus.isNotEmpty) {
      return paymentStatus;
    }

    return switch (transaction.entryType) {
      'payment' => transaction.isPayment ? 'Unpaid' : 'Paid',
      'return' => 'Returned',
      _ => '—',
    };
  }

  String _dueDateLabel(PartyLedgerTransactionModel transaction) {
    final dueDate = transaction.dueDate;
    if (dueDate == null) {
      return '—';
    }
    return DateTimeUtils.formatDisplayDate(dueDate);
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
          DateTimeUtils.formatDisplayDateTime(tx.createdAt),
          _currencyFormat.format(_transactionTotal(tx)),
          _currencyFormat.format(_transactionBalance(tx)),
          _transactionStatus(tx),
          _dueDateLabel(tx),
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
      rows = rows.where((tx) => dateFilter.matches(tx.createdAt)).toList();
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
          .where((tx) => balanceFilter.matches(_transactionBalance(tx)))
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
          PartyTransactionSortColumn.date =>
            a.createdAt.compareTo(b.createdAt),
          PartyTransactionSortColumn.total =>
            _transactionTotal(a).compareTo(_transactionTotal(b)),
          PartyTransactionSortColumn.balance =>
            _transactionBalance(a).compareTo(_transactionBalance(b)),
          PartyTransactionSortColumn.dueDate =>
            (a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
              b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0),
            ),
          PartyTransactionSortColumn.status => _transactionStatus(
            a,
          ).compareTo(_transactionStatus(b)),
        };
        return ascending ? comparison : -comparison;
      });
    }

    return rows;
  }

  Future<void> _exportPartyLedger(BuildContext context) async {
    final party = ref.read(selectedPartyProvider);
    if (party == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Party details are not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final transactions = widget.transactionsAsync.value ?? const [];

    await PartyExportActions.exportLedgerTransactions(
      context,
      partyName: party.name,
      transactions: transactions,
    );
  }

  Future<void> _printPartyLedger(BuildContext context) async {
    final party = ref.read(selectedPartyProvider);
    if (party == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Party details are not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final transactions = widget.transactionsAsync.value ?? const [];
    final businessName = ref.read(sidebarBusinessProvider).name;
    final ledger = ref.read(partyLedgerProvider(party.id)).value;

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final bytes = await PartyLedgerPdfBuilder.build(
        party: party,
        transactions: transactions,
        businessName: businessName,
        outstanding: ledger?.summary.outstanding ?? party.balance,
        creditLimit: ledger?.summary.creditLimit,
      );
      if (!context.mounted) return;

      final safeName = party.name.replaceAll(RegExp(r'[^\w\-]+'), '_');
      await PrintOutputService().previewDocument(
        context,
        PrintablePdf(
          bytes: bytes,
          name: 'Party_Ledger_$safeName',
          profile: PdfPageProfile.transactionCompact,
        ),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(OutputErrorMapper.printMessage(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  List<ResizableDataColumn> _buildColumns(
    List<PartyLedgerTransactionModel> sourceTransactions,
  ) {
    ResizableDataColumn column({
      required String label,
      required double initialWidth,
      required PartyTransactionSortColumn sortColumn,
      required ColumnFilter filterConfig,
      required Object? initialFilter,
      required ValueChanged<FilterResult?> onApply,
      double minWidth = 72,
      double maxWidth = 420,
    }) {
      return ResizableDataColumn(
        initialWidth: initialWidth,
        minWidth: minWidth,
        maxWidth: maxWidth,
        header: _PartyLedgerColumnHeader(
          label: label,
          sortColumn: sortColumn,
          tableState: _tableState,
          onSort: () => _toggleSort(sortColumn),
          filter: TableColumnFilterTrigger(
            config: filterConfig,
            iconOnly: true,
            initialValue: initialFilter,
            onApply: onApply,
          ),
        ),
      );
    }

    final typeOptions = _typeOptions(sourceTransactions);
    final statusOptions = _statusOptions(sourceTransactions);

    return [
      column(
        label: 'Type',
        initialWidth: _typeColWidth,
        sortColumn: PartyTransactionSortColumn.type,
        filterConfig: ColumnFilter(
          id: 'type',
          title: 'Type',
          type: FilterType.multiSelect,
          values: typeOptions,
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
        label: 'Reference Number',
        initialWidth: _referenceColWidth,
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
        label: 'Date',
        initialWidth: _dateColWidth,
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
        label: 'Total',
        initialWidth: _totalColWidth,
        sortColumn: PartyTransactionSortColumn.total,
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
        label: 'Balance / Outstanding',
        initialWidth: _balanceColWidth,
        minWidth: 120,
        sortColumn: PartyTransactionSortColumn.balance,
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
        label: 'Due Date',
        initialWidth: _dueDateColWidth,
        sortColumn: PartyTransactionSortColumn.dueDate,
        filterConfig: const ColumnFilter(
          id: 'due_date',
          title: 'Due Date',
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
        label: 'Status',
        initialWidth: _statusColWidth,
        sortColumn: PartyTransactionSortColumn.status,
        filterConfig: ColumnFilter(
          id: 'status',
          title: 'Status',
          type: FilterType.multiSelect,
          values: statusOptions,
        ),
        initialFilter: _tableState.statusFilter,
        onApply: (result) => setState(() {
          _tableState = _tableState.copyWith(
            statusFilter: () =>
                FilterUtils.fromResult(result) as MultiSelectColumnFilter?,
          );
        }),
      ),
      const ResizableDataColumn(
        initialWidth: _actionsColWidth,
        minWidth: _actionsColWidth,
        maxWidth: _actionsColWidth,
        resizable: false,
        header: _HeaderCell(label: 'Actions'),
      ),
    ];
  }

  List<ResizableDataRow> _buildRows(
    List<PartyLedgerTransactionModel> transactions,
  ) {
    return [
      for (var i = 0; i < transactions.length; i++)
        _buildRow(transactions[i], i),
    ];
  }

  ResizableDataRow _buildRow(
    PartyLedgerTransactionModel transaction,
    int index,
  ) {
    final total = _transactionTotal(transaction);
    final status = _transactionStatus(transaction);

    return ResizableDataRow(
      backgroundColor: index.isOdd ? _zebraRowBg : Colors.transparent,
      onTap: () => navigateToPartyLedgerTransaction(context, transaction),
      cells: [
        _DataCell(child: Text(transaction.type)),
        _DataCell(
          child: Text(
            PartyModel.displayOrDash(transaction.referenceNumber),
          ),
        ),
        _DataCell(
          child: Text(
            DateTimeUtils.formatDisplayDateTime(transaction.createdAt),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(total),
            style: TextStyle(
              color: transaction.credit > 0
                  ? const Color(0xFFC62828)
                  : transaction.debit > 0
                      ? const Color(0xFF2E7D32)
                      : null,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(_transactionBalance(transaction)),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(child: Text(_dueDateLabel(transaction))),
        _DataCell(
          child: _PartyTransactionStatusChip(status: status),
        ),
        _DataCell(
          child: Center(
            child: PartyLedgerTransactionActionsMenu(
              transaction: transaction,
            ),
          ),
        ),
      ],
    );
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
                onPressed: () => _printPartyLedger(context),
                icon: const Icon(Icons.print_outlined, size: 20),
                color: AppColors.textSecondary,
                tooltip: 'Print',
              ),
              SalesXlsChip(
                onTap: () => _exportPartyLedger(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _cardBorder),
        Expanded(
          child: widget.transactionsAsync.when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    PartyErrorMapper.messageFor(error),
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: widget.onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (_) {
              final columns = _buildColumns(sourceTransactions);
              final rows = _buildRows(filteredTransactions);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final table = SizedBox(
                    width: constraints.maxWidth,
                    child: ResizableDataTable(
                      columns: columns,
                      rows: filteredTransactions.isEmpty ? const [] : rows,
                    ),
                  );

                  if (filteredTransactions.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        table,
                        Expanded(
                          child: _EmptyTransactionsState(
                            isFiltered: isFiltered,
                          ),
                        ),
                      ],
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: table,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PartyLedgerColumnHeader extends StatelessWidget {
  const _PartyLedgerColumnHeader({
    required this.label,
    required this.sortColumn,
    required this.tableState,
    required this.onSort,
    this.filter,
  });

  final String label;
  final PartyTransactionSortColumn sortColumn;
  final PartyTransactionTableState tableState;
  final VoidCallback onSort;
  final Widget? filter;

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    final isSorted =
        tableState.sortColumn == sortColumn &&
        tableState.sortDirection != PartyTransactionSortDirection.none;

    final sortIcon = switch (tableState.sortDirection) {
      PartyTransactionSortDirection.ascending => Icons.arrow_upward,
      PartyTransactionSortDirection.descending => Icons.arrow_downward,
      _ => Icons.arrow_upward,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onSort,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label.toUpperCase(),
                      style: _headerStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (isSorted) ...[
                    const SizedBox(width: 2),
                    Icon(
                      sortIcon,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          ?filter,
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: _headerStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
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
    fontSize: 13,
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
          vertical: AppSpacing.sm,
        ),
        child: Align(alignment: alignment, child: wrapEllipsisTooltipChild(child)),
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState({required this.isFiltered});

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
              isFiltered ? 'No matching transactions' : 'No transactions yet',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyTransactionStatusChip extends StatelessWidget {
  const _PartyTransactionStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == '—') {
      return Text(status);
    }

    final normalized = status.trim().toLowerCase();
    final (background, foreground) = switch (normalized) {
      'paid' || 'completed' => (
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      'unpaid' || 'unused' => (
        const Color(0xFFFFEBEE),
        const Color(0xFFC62828),
      ),
      'partial' || 'partially paid' => (
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      'returned' => (
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      _ when normalized.startsWith('overdue') => (
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
