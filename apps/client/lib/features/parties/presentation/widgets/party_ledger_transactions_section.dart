import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_ledger_column_filters.dart';
import 'package:billing_baba/features/parties/presentation/utils/party_transaction_navigation.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_date_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_numeric_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_select_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_text_filter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tableHeaderBg = Color(0xFFF5F7FA);
const _zebraRowBg = Color(0xFFFAFAFA);
const _cellHorizontalPadding = AppSpacing.sm;

const _typeColWidth = 112.0;
const _numberColWidth = 96.0;
const _dateColWidth = 148.0;
const _totalColWidth = 88.0;
const _balanceColWidth = 112.0;
const _dueDateColWidth = 90.0;
const _statusColWidth = 82.0;

const _tableHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
);

const _statusFilterOptions = [
  PartyLedgerColumnFilters.allStatusLabel,
  'Paid',
  'Unpaid',
  'Partial',
];

class PartyLedgerTransactionsSection extends StatefulWidget {
  const PartyLedgerTransactionsSection({
    required this.transactions,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    super.key,
  });

  final List<PartyLedgerTransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  State<PartyLedgerTransactionsSection> createState() =>
      _PartyLedgerTransactionsSectionState();
}

class _PartyLedgerTransactionsSectionState
    extends State<PartyLedgerTransactionsSection> {
  String _searchQuery = '';
  PartyLedgerColumnFilters _columnFilters = const PartyLedgerColumnFilters();

  List<String> get _typeOptions {
    final types = widget.transactions.map((tx) => tx.type).toSet().toList()
      ..sort();
    return types;
  }

  List<PartyLedgerTransactionModel> get _filteredTransactions {
    final query = _searchQuery.trim().toLowerCase();

    return widget.transactions.where((tx) {
      if (!_columnFilters.matches(tx)) return false;

      if (query.isEmpty) return true;

      final refNo = tx.referenceNumber?.toLowerCase() ?? '';
      final type = tx.type.toLowerCase();
      final description = tx.description?.toLowerCase() ?? '';
      return refNo.contains(query) ||
          type.contains(query) ||
          description.contains(query);
    }).toList();
  }

  void _setColumnFilters(PartyLedgerColumnFilters filters) {
    setState(() => _columnFilters = filters);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          AppSpacing.sm,
          0,
          AppSpacing.md,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: _cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _cellHorizontalPadding,
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
                      hint: 'Search',
                      initialQuery: _searchQuery,
                      onQueryChanged: (query) =>
                          setState(() => _searchQuery = query),
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
                    _XlsChip(
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
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 32),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: widget.onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final transactions = _filteredTransactions;
    final columns = _PartyLedgerTableColumns.build(
      filters: _columnFilters,
      typeOptions: _typeOptions,
      onFiltersChanged: _setColumnFilters,
    );

    if (transactions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _cellHorizontalPadding),
            child: ResizableDataTable(
              columns: columns,
              rows: const [],
              headerBackgroundColor: _tableHeaderBg,
              rowBorderColor: _cardBorder,
            ),
          ),
          Expanded(
            child: _TransactionsEmptyState(
              isFiltered:
                  _searchQuery.trim().isNotEmpty || _columnFilters.hasColumnFilters,
            ),
          ),
        ],
      );
    }

    final rows = [
      for (var i = 0; i < transactions.length; i++)
        _PartyLedgerTableRows.buildDataRow(
          context: context,
          transaction: transactions[i],
          isOdd: i.isOdd,
        ),
    ];

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: _cellHorizontalPadding),
        child: ResizableDataTable(
          columns: columns,
          rows: rows,
          headerBackgroundColor: _tableHeaderBg,
          rowBorderColor: _cardBorder,
        ),
      ),
    );
  }
}

class _PartyLedgerTableColumns {
  const _PartyLedgerTableColumns._();

  static List<ResizableDataColumn> build({
    required PartyLedgerColumnFilters filters,
    required List<String> typeOptions,
    required ValueChanged<PartyLedgerColumnFilters> onFiltersChanged,
  }) {
    return [
      ResizableDataColumn(
        initialWidth: _typeColWidth,
        minWidth: 88,
        maxWidth: 280,
        header: SaleColumnSelectFilterTrigger(
          label: 'Type',
          headerStyle: _tableHeaderStyle,
          options: typeOptions,
          initialFilter: filters.typeFilter,
          onApply: (filter) => onFiltersChanged(
            filters.copyWith(
              typeFilter: filter,
              clearTypeFilter: filter == null,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _numberColWidth,
        minWidth: 72,
        maxWidth: 200,
        header: SaleColumnTextFilterTrigger(
          label: 'Number',
          hintText: 'Number',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.numberFilter,
          onApply: (filter) => onFiltersChanged(
            filters.copyWith(
              numberFilter: filter,
              clearNumberFilter: filter == null,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 120,
        maxWidth: 220,
        header: SaleColumnDateFilterTrigger(
          label: 'Date',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.dateFilter,
          onApply: (filter) => onFiltersChanged(
            filters.copyWith(
              dateFilter: filter,
              clearDateFilter: filter == null,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _totalColWidth,
        minWidth: 72,
        maxWidth: 160,
        header: SaleColumnNumericFilterTrigger(
          label: 'Total',
          valueLabel: 'Total',
          alignment: Alignment.centerRight,
          alignPopoverRight: true,
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.totalFilter,
          onApply: (filter) => onFiltersChanged(
            filters.copyWith(
              totalFilter: filter,
              clearTotalFilter: filter == null,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _balanceColWidth,
        minWidth: 96,
        maxWidth: 200,
        header: SaleColumnNumericFilterTrigger(
          label: 'Balance/ Unused',
          valueLabel: 'Balance/ Unused',
          alignment: Alignment.centerRight,
          alignPopoverRight: true,
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.balanceFilter,
          onApply: (filter) => onFiltersChanged(
            filters.copyWith(
              balanceFilter: filter,
              clearBalanceFilter: filter == null,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dueDateColWidth,
        minWidth: 72,
        maxWidth: 140,
        header: SaleColumnDateFilterTrigger(
          label: 'Due Date',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.dueDateFilter,
          onApply: (filter) => onFiltersChanged(
            filters.copyWith(
              dueDateFilter: filter,
              clearDueDateFilter: filter == null,
            ),
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        minWidth: 72,
        maxWidth: 140,
        header: _PartyLedgerStatusFilterHeader(
          selectedStatus: filters.statusFilter,
          onStatusFilter: (status) => onFiltersChanged(
            filters.copyWith(statusFilter: status),
          ),
        ),
      ),
    ];
  }
}

class _PartyLedgerTableRows {
  const _PartyLedgerTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required PartyLedgerTransactionModel transaction,
    required bool isOdd,
  }) {
    final status = PartyLedgerTransactionMetrics.statusFor(transaction);
    final total = PartyLedgerTransactionMetrics.totalAmount(transaction);
    final balance = PartyLedgerTransactionMetrics.balanceUnused(
      transaction,
      status,
    );
    final refNo = transaction.referenceNumber?.trim();

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      onTap: () => navigateToPartyLedgerTransaction(context, transaction),
      cells: [
        _DataCell(
          child: Text(
            transaction.type,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        _DataCell(
          child: Text(refNo != null && refNo.isNotEmpty ? refNo : '-'),
        ),
        _DataCell(
          child: Text(
            _dateFormat.format(transaction.date),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(total),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            balance == null ? '-' : _currencyFormat.format(balance),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const _DataCell(
          child: Text(
            '-',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        _DataCell(
          child: _PartyTransactionStatusBadge(status: status),
        ),
      ],
    );
  }
}

class _PartyLedgerStatusFilterHeader extends StatefulWidget {
  const _PartyLedgerStatusFilterHeader({
    required this.selectedStatus,
    required this.onStatusFilter,
  });

  final String selectedStatus;
  final ValueChanged<String> onStatusFilter;

  @override
  State<_PartyLedgerStatusFilterHeader> createState() =>
      _PartyLedgerStatusFilterHeaderState();
}

class _PartyLedgerStatusFilterHeaderState
    extends State<_PartyLedgerStatusFilterHeader> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showMenu();
  }

  void _showMenu() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              offset: const Offset(0, 4),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 160),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final option in _statusFilterOptions)
                        _StatusFilterMenuItem(
                          label: option,
                          isSelected: option == widget.selectedStatus,
                          onTap: () {
                            _removeOverlay();
                            widget.onStatusFilter(option);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final isActive =
        widget.selectedStatus != PartyLedgerColumnFilters.allStatusLabel;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Status',
                style: _tableHeaderStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 2),
            InkWell(
              key: _triggerKey,
              onTap: _toggleMenu,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.filter_list,
                  size: 14,
                  color: isActive ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterMenuItem extends StatelessWidget {
  const _StatusFilterMenuItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _hoverColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: _hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
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
          vertical: AppSpacing.sm,
        ),
        child: Align(
          alignment: alignment,
          widthFactor: 1,
          child: child,
        ),
      ),
    );
  }
}

class _PartyTransactionStatusBadge extends StatelessWidget {
  const _PartyTransactionStatusBadge({required this.status});

  final PartyTransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      PartyTransactionStatus.paid => (
        'Paid',
        const Color(0xFFE8F5E9),
        listPanelPositiveColor,
      ),
      PartyTransactionStatus.unpaid => (
        'Unpaid',
        const Color(0xFFFFEBEE),
        listPanelNegativeColor,
      ),
      PartyTransactionStatus.partial => (
        'Partial',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

class _XlsChip extends StatelessWidget {
  const _XlsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Text(
            'xls',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: listPanelPositiveColor,
            ),
          ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isFiltered
                  ? 'No matching transactions'
                  : 'No transactions yet',
              style: ListPanelStyles.emptyStateStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isFiltered
                  ? 'Try a different search term.'
                  : 'Sales, purchases and payments involving this party will appear here.',
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
