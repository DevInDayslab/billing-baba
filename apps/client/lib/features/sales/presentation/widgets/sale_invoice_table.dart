import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/export/presentation/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/widgets/sale_invoice_print_actions.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_amount_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_date_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_select_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_text_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_status_badge.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tableHeaderBg = Color(0xFFF5F7FA);
const _zebraRowBg = Color(0xFFFAFAFA);

const _dateColWidth = 148.0;
const _invoiceColWidth = 96.0;
const _partyColWidth = 160.0;
const _transactionColWidth = 108.0;
const _paymentColWidth = 108.0;
const _amountColWidth = 100.0;
const _loyaltyColWidth = 108.0;
const _balanceColWidth = 96.0;
const _dueDateColWidth = 108.0;
const _statusColWidth = 88.0;
const _actionsColWidth = 120.0;
const _cellHorizontalPadding = AppSpacing.sm;

class SaleInvoiceTable extends ConsumerWidget {
  const SaleInvoiceTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(saleInvoicesProvider);
    final paginated = ref.watch(paginatedSaleInvoicesProvider);
    final notifier = ref.read(saleInvoicesProvider.notifier);

    return DecoratedBox(
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
                  initialQuery: ref.read(saleInvoiceSearchQueryProvider),
                  onQueryChanged: ref
                      .read(saleInvoiceSearchQueryProvider.notifier)
                      .setQuery,
                ),
                IconButton(
                  onPressed: () =>
                      ModuleExportActions.exportSaleInvoices(context, ref),
                  icon: const Icon(Icons.bar_chart_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Report',
                ),
                _XlsChip(
                  onTap: () =>
                      ModuleExportActions.exportSaleInvoices(context, ref),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.print_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Print',
                ),
                IconButton(
                  onPressed: notifier.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          invoicesAsync.when(
            skipLoadingOnReload: true,
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    SalesErrorMapper.messageFor(error),
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: notifier.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (_) => _SaleInvoiceTransactionsTable(
              items: paginated.items,
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          if (paginated.totalPages > 1)
            _PaginationRow(
              currentPage: paginated.currentPage,
              totalPages: paginated.totalPages,
            ),
        ],
      ),
    );
  }
}

class _SaleInvoiceTransactionsTable extends ConsumerStatefulWidget {
  const _SaleInvoiceTransactionsTable({required this.items});

  final List<SaleInvoiceModel> items;

  @override
  ConsumerState<_SaleInvoiceTransactionsTable> createState() =>
      _SaleInvoiceTransactionsTableState();
}

class _SaleInvoiceTransactionsTableState
    extends ConsumerState<_SaleInvoiceTransactionsTable> {
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(saleInvoiceFiltersProvider);
    final selectedId = ref.watch(selectedSaleInvoiceIdProvider);
    final hasActiveFilters = needsSaleInvoiceClientSideFiltering(filters);

    final rows = [
      for (var i = 0; i < widget.items.length; i++)
        SaleInvoiceTableRows.buildDataRow(
          context: context,
          ref: ref,
          invoice: widget.items[i],
          isOdd: i.isOdd,
          isSelected: widget.items[i].id == selectedId,
          onTap: () => ref
              .read(selectedSaleInvoiceIdProvider.notifier)
              .select(widget.items[i].id),
        ),
    ];

    final columns = _SaleInvoiceTableColumns.build(
      context: context,
      ref: ref,
      onStatusFilter: (status) =>
          ref.read(saleInvoiceFiltersProvider.notifier).setStatus(status),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: ResizableDataTable(
            columns: columns,
            rows: rows,
            headerBackgroundColor: _tableHeaderBg,
            rowBorderColor: _cardBorder,
          ),
        ),
        if (widget.items.isEmpty)
          _EmptyTransactionsState(isFiltered: hasActiveFilters),
      ],
    );
  }
}

class SaleInvoiceTableRows {
  const SaleInvoiceTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required WidgetRef ref,
    required SaleInvoiceModel invoice,
    required bool isOdd,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ResizableDataRow(
      isSelected: isSelected,
      onTap: onTap,
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(invoice.date))),
        _DataCell(child: Text(invoice.invoiceNo)),
        _DataCell(
          child: Text(
            invoice.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(invoice.transactionType)),
        _DataCell(child: Text(invoice.paymentType)),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(invoice.amount)),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(invoice.loyaltyRedeemed)),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(invoice.balance)),
        ),
        _DataCell(
          child: Text(
            invoice.dueDate != null
                ? _dueDateFormat.format(invoice.dueDate!)
                : '',
          ),
        ),
        _DataCell(
          child: SaleInvoiceStatusBadge(status: invoice.status, plain: true),
        ),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => SaleInvoicePrintActions.preview(
                  context,
                  ref,
                  invoice.id,
                  filename: SaleInvoicePrintActions.filenameFor(
                    invoice.invoiceNo,
                  ),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Print',
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing is not available yet')),
                  );
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Share',
              ),
              SaleInvoiceActionsMenuButton(invoice: invoice),
            ],
          ),
        ),
      ],
    );
  }

}

class _SaleInvoiceTableColumns {
  const _SaleInvoiceTableColumns._();

  static List<ResizableDataColumn> build({
    required BuildContext context,
    required WidgetRef ref,
    required ValueChanged<String> onStatusFilter,
  }) {
    final filters = ref.watch(saleInvoiceFiltersProvider);
    final filtersNotifier = ref.read(saleInvoiceFiltersProvider.notifier);
    final transactionOptions =
        ref.watch(saleInvoiceTransactionTypeFilterOptionsProvider);
    final paymentOptions =
        ref.watch(saleInvoicePaymentTypeFilterOptionsProvider);

    return [
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 96,
        maxWidth: 280,
        header: SaleColumnDateFilterTrigger(
          label: 'Date',
          initialFilter: filters.dateColumnFilter,
          onApply: filtersNotifier.setDateColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _invoiceColWidth,
        header: SaleColumnTextFilterTrigger(
          label: 'Invoice no',
          hintText: 'Invoice number',
          initialFilter: filters.invoiceNoColumnFilter,
          onApply: filtersNotifier.setInvoiceNoColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 100,
        maxWidth: 420,
        header: SaleColumnTextFilterTrigger(
          label: 'Party Name',
          hintText: 'Party name',
          initialFilter: filters.partyNameColumnFilter,
          onApply: filtersNotifier.setPartyNameColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _transactionColWidth,
        header: SaleColumnSelectFilterTrigger(
          label: 'Transaction',
          options: transactionOptions,
          initialFilter: filters.transactionTypeColumnFilter != null
              ? SelectColumnFilter(
                  value: filters.transactionTypeColumnFilter!.value,
                )
              : null,
          onApply: filtersNotifier.setTransactionTypeColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _paymentColWidth,
        header: SaleColumnSelectFilterTrigger(
          label: 'Payment Type',
          options: paymentOptions,
          initialFilter: filters.paymentTypeColumnFilter != null
              ? SelectColumnFilter(
                  value: filters.paymentTypeColumnFilter!.value,
                )
              : null,
          onApply: filtersNotifier.setPaymentTypeColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: SaleColumnAmountFilterTrigger(
          label: 'Amount',
          alignment: Alignment.centerRight,
          initialFilter: filters.amountColumnFilter,
          onApply: filtersNotifier.setAmountColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _loyaltyColWidth,
        header: SaleColumnAmountFilterTrigger(
          label: 'Loyalty redee...',
          alignment: Alignment.centerRight,
          initialFilter: filters.loyaltyColumnFilter,
          onApply: filtersNotifier.setLoyaltyColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _balanceColWidth,
        header: SaleColumnAmountFilterTrigger(
          label: 'Balance',
          alignment: Alignment.centerRight,
          initialFilter: filters.balanceColumnFilter,
          onApply: filtersNotifier.setBalanceColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dueDateColWidth,
        header: SaleColumnDateFilterTrigger(
          label: 'Due date',
          initialFilter: filters.dueDateColumnFilter,
          onApply: filtersNotifier.setDueDateColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        header: _StatusColumnFilterHeader(
          onStatusFilter: onStatusFilter,
          selectedStatus: filters.selectedStatus,
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _actionsColWidth,
        resizable: false,
        header: _HeaderCell(label: 'Actions'),
      ),
    ];
  }
}

class _StatusColumnFilterHeader extends StatefulWidget {
  const _StatusColumnFilterHeader({
    required this.onStatusFilter,
    required this.selectedStatus,
  });

  final ValueChanged<String> onStatusFilter;
  final String selectedStatus;

  @override
  State<_StatusColumnFilterHeader> createState() =>
      _StatusColumnFilterHeaderState();
}

class _StatusColumnFilterHeaderState extends State<_StatusColumnFilterHeader> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const _statusOptions = [
    'All Status',
    'Cancelled',
    'Paid',
    'Overdue',
    'Unpaid',
    'Partial',
  ];

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
                      for (final option in _statusOptions)
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
    final isActive = widget.selectedStatus != 'All Status';

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
                style: _headerStyle,
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
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
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
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: _headerStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
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
        child: Align(
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState({this.isFiltered = false});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isFiltered
                ? 'No matching transactions'
                : 'No sale invoices found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isFiltered
                ? 'Try adjusting your filters or clear them to see all results.'
                : 'Create your first sale to get started.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
              color: Color(0xFF2E7D32),
            ),
          ),
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
    final filtersNotifier = ref.read(saleInvoiceFiltersProvider.notifier);
    final canGoPrevious = currentPage > 1;
    final canGoNext = currentPage < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: canGoPrevious
                ? () => filtersNotifier.setPage(currentPage - 1)
                : null,
            child: Text(
              'Previous',
              style: TextStyle(
                fontSize: 13,
                color: canGoPrevious
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          for (var page = 1; page <= totalPages; page++) ...[
            if (page > 1) const SizedBox(width: AppSpacing.xs),
            _PageNumber(
              page: page,
              isActive: page == currentPage,
              onTap: () => filtersNotifier.setPage(page),
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: canGoNext
                ? () => filtersNotifier.setPage(currentPage + 1)
                : null,
            child: Text(
              'Next',
              style: TextStyle(
                fontSize: 13,
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
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEEEEE) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isActive ? null : Border.all(color: _cardBorder),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
