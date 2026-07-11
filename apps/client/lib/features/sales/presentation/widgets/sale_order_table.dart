import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_amount_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_date_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_text_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/bulk_convert_sale_orders_dialog.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_order_convert_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_order_status_badge.dart';
import 'package:billing_baba/features/sales/providers/sale_orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tableHeaderBg = Color(0xFFF5F7FA);
const _zebraRowBg = Color(0xFFFAFAFA);
const _bulkConvertColor = Color(0xFFD32F2F);
const _addButtonColor = Color(0xFF1565C0);

const _partyColWidth = 140.0;
const _noColWidth = 72.0;
const _dateColWidth = 148.0;
const _dueDateColWidth = 108.0;
const _amountColWidth = 108.0;
const _balanceColWidth = 96.0;
const _typeColWidth = 100.0;
const _statusColWidth = 120.0;
const _actionsColWidth = 180.0;
const _cellHorizontalPadding = AppSpacing.sm;
const _tableHeaderStyle = ListPanelStyles.listHeaderStyle;

class SaleOrderTable extends ConsumerWidget {
  const SaleOrderTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(saleOrdersProvider);
    final paginated = ref.watch(paginatedSaleOrdersProvider);
    final notifier = ref.read(saleOrdersProvider.notifier);

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
                Text(
                  'TRANSACTIONS',
                  style: ListPanelStyles.listHeaderStyle.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                ExpandableTableSearchField(
                  hint: 'Search Data',
                  initialQuery: ref.read(saleOrderSearchQueryProvider),
                  onQueryChanged: (query) => ref
                      .read(saleOrderSearchQueryProvider.notifier)
                      .setQuery(query),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => _handleBulkConvert(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ).copyWith(
                    foregroundColor: WidgetStatePropertyAll(_bulkConvertColor),
                    side: WidgetStatePropertyAll(
                      const BorderSide(color: _bulkConvertColor),
                    ),
                  ),
                  child: const Text(
                    'Bulk Convert To Sale',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.addSaleOrder),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Sale Order'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _addButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          ordersAsync.when(
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
            data: (_) => _SaleOrderTransactionsTable(items: paginated.items),
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

  Future<void> _handleBulkConvert(BuildContext context) async {
    final selected = await showBulkConvertSaleOrdersDialog(context);
    if (!context.mounted || selected == null || selected.isEmpty) return;

    context.push(AppRoutes.addSale, extra: selected);
  }
}

class _SaleOrderTransactionsTable extends ConsumerStatefulWidget {
  const _SaleOrderTransactionsTable({required this.items});

  final List<SaleInvoiceModel> items;

  @override
  ConsumerState<_SaleOrderTransactionsTable> createState() =>
      _SaleOrderTransactionsTableState();
}

class _SaleOrderTransactionsTableState
    extends ConsumerState<_SaleOrderTransactionsTable> {
  @override
  Widget build(BuildContext context) {
    ref.watch(saleOrderFiltersProvider);

    if (widget.items.isEmpty) {
      return const _EmptyTransactionsState();
    }

    final rows = [
      for (var i = 0; i < widget.items.length; i++)
        SaleOrderTableRows.buildDataRow(
          order: widget.items[i],
          isOdd: i.isOdd,
        ),
    ];

    final columns = _SaleOrderTableColumns.build(
      context: context,
      ref: ref,
      onStatusFilter: (status) =>
          ref.read(saleOrderFiltersProvider.notifier).setStatus(status),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ResizableDataTable(
        columns: columns,
        rows: rows,
        headerBackgroundColor: _tableHeaderBg,
        rowBorderColor: _cardBorder,
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState();

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
          const Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Create your first sale order to get started.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => context.push(AppRoutes.addSaleOrder),
            style: FilledButton.styleFrom(
              backgroundColor: _addButtonColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Sale Order'),
          ),
        ],
      ),
    );
  }
}

class SaleOrderTableRows {
  const SaleOrderTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  static ResizableDataRow buildDataRow({
    required SaleInvoiceModel order,
    required bool isOdd,
  }) {
    final dueDate = order.dueDate ?? order.date;
    final balance = saleOrderBalanceFor(order);

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(
          child: Text(
            order.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(order.invoiceNo)),
        _DataCell(child: Text(_dateFormat.format(order.date))),
        _DataCell(child: Text(_dueDateFormat.format(dueDate))),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(order.amount)),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(balance)),
        ),
        _DataCell(child: Text(order.transactionType)),
        _DataCell(child: SaleOrderStatusBadge(order: order, plain: true)),
        _DataCell(child: SaleOrderConvertButton(order: order)),
      ],
    );
  }
}

class _SaleOrderTableColumns {
  const _SaleOrderTableColumns._();

  static List<ResizableDataColumn> build({
    required BuildContext context,
    required WidgetRef ref,
    required ValueChanged<String> onStatusFilter,
  }) {
    final filters = ref.watch(saleOrderFiltersProvider);
    final filtersNotifier = ref.read(saleOrderFiltersProvider.notifier);

    return [
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 100,
        maxWidth: 420,
        header: SaleColumnTextFilterTrigger(
          label: 'PARTY',
          hintText: 'Party name',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.partyNameColumnFilter,
          onApply: filtersNotifier.setPartyNameColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _noColWidth,
        header: SaleColumnTextFilterTrigger(
          label: 'NO.',
          hintText: 'Order number',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.orderNoColumnFilter,
          onApply: filtersNotifier.setOrderNoColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 96,
        maxWidth: 280,
        header: SaleColumnDateFilterTrigger(
          label: 'DATE',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.dateColumnFilter,
          onApply: filtersNotifier.setDateColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dueDateColWidth,
        header: SaleColumnDateFilterTrigger(
          label: 'DUE DATE',
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.dueDateColumnFilter,
          onApply: filtersNotifier.setDueDateColumnFilter,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: SaleColumnAmountFilterTrigger(
          label: 'TOTAL AMOUNT',
          alignment: Alignment.centerRight,
          headerStyle: _tableHeaderStyle,
          initialFilter: filters.amountColumnFilter,
          onApply: filtersNotifier.setAmountColumnFilter,
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _balanceColWidth,
        header: _HeaderCell(
          label: 'BALANCE',
          alignment: Alignment.centerRight,
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _typeColWidth,
        header: _HeaderCell(label: 'TYPE'),
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
        header: _HeaderCell(label: 'ACTION'),
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

  static const _headerStyle = _tableHeaderStyle;

  static const _statusOptions = [
    'All Status',
    'Order Overdue',
    'Order Completed',
    'Open',
    'Draft',
    'Cancelled',
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
                  constraints: const BoxConstraints(minWidth: 180),
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
                'STATUS',
                style: _headerStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFFF5F5F5),
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
  const _HeaderCell({
    required this.label,
    this.alignment = Alignment.centerLeft,
  });

  static const _headerStyle = _tableHeaderStyle;

  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Align(
        alignment: alignment,
        child: Text(
          label,
          style: _headerStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Align(alignment: alignment, child: child),
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
    final notifier = ref.read(saleOrderFiltersProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => notifier.setPage(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: const TextStyle(fontSize: 13),
          ),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => notifier.setPage(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

