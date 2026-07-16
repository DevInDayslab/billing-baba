import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/estimate_quotation_convert_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/estimate_quotation_status_badge.dart';
import 'package:billing_baba/features/sales/providers/estimate_quotation_provider.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tableHeaderBg = Color(0xFFF5F7FA);
const _zebraRowBg = Color(0xFFFAFAFA);

const _dateColWidth = 148.0;
const _referenceColWidth = 120.0;
const _partyColWidth = 160.0;
const _amountColWidth = 108.0;
const _balanceColWidth = 108.0;
const _statusColWidth = 100.0;
const _actionsColWidth = 180.0;
const double _cellHorizontalPadding = AppSpacing.sm;

class EstimateQuotationTable extends ConsumerWidget {
  const EstimateQuotationTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimatesAsync = ref.watch(estimateQuotationsProvider);
    final paginated = ref.watch(paginatedEstimateQuotationsProvider);
    final notifier = ref.read(estimateQuotationsProvider.notifier);

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
                  initialQuery: ref.read(estimateQuotationSearchQueryProvider),
                  onQueryChanged: (query) => ref
                      .read(estimateQuotationSearchQueryProvider.notifier)
                      .setQuery(query),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          estimatesAsync.when(
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
            data: (_) => _EstimateTransactionsTable(
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

class _EstimateTransactionsTable extends ConsumerStatefulWidget {
  const _EstimateTransactionsTable({required this.items});

  final List<SaleInvoiceModel> items;

  @override
  ConsumerState<_EstimateTransactionsTable> createState() =>
      _EstimateTransactionsTableState();
}

class _EstimateTransactionsTableState
    extends ConsumerState<_EstimateTransactionsTable> {
  @override
  Widget build(BuildContext context) {
    ref.watch(estimateQuotationFiltersProvider);
    final selectedId = ref.watch(selectedEstimateQuotationIdProvider);

    if (widget.items.isEmpty) {
      return const _EmptyTransactionsState();
    }

    final rows = [
      for (var i = 0; i < widget.items.length; i++)
        EstimateQuotationTableRows.buildDataRow(
          estimate: widget.items[i],
          isOdd: i.isOdd,
          isSelected: widget.items[i].id == selectedId,
          onTap: () => ref
              .read(selectedEstimateQuotationIdProvider.notifier)
              .select(widget.items[i].id),
        ),
    ];

    final columns = _EstimateTableColumns.build(
      context: context,
      ref: ref,
      onStatusFilter: (status) =>
          ref.read(estimateQuotationFiltersProvider.notifier).setStatus(status),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ResizableDataTable(
        columns: columns,
        rows: rows,
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
            Icons.description_outlined,
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
            'Create your first estimate to get started.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class EstimateQuotationTableRows {
  const EstimateQuotationTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  static ResizableDataRow buildDataRow({
    required SaleInvoiceModel estimate,
    required bool isOdd,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final balance = estimateBalanceFor(estimate);

    return ResizableDataRow(
      isSelected: isSelected,
      onTap: onTap,
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(estimate.date))),
        _DataCell(child: Text(estimate.invoiceNo)),
        _DataCell(
          child: Text(
            estimate.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(estimate.amount)),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(balance)),
        ),
        _DataCell(
          child: EstimateQuotationStatusBadge(
            status: estimate.documentStatus,
            plain: true,
          ),
        ),
        _ActionsCell(
          child: EstimateQuotationConvertButton(estimate: estimate),
        ),
      ],
    );
  }
}

class _EstimateTableColumns {
  const _EstimateTableColumns._();

  static List<ResizableDataColumn> build({
    required BuildContext context,
    required WidgetRef ref,
    required ValueChanged<String> onStatusFilter,
  }) {
    final filters = ref.watch(estimateQuotationFiltersProvider);
    final filtersNotifier = ref.read(estimateQuotationFiltersProvider.notifier);

    return [
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 96,
        maxWidth: 280,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'date',
            title: 'Date',
            type: FilterType.date,
          ),
          initialValue: filters.dateColumnFilter,
          onApply: (result) => filtersNotifier.setDateColumnFilter(
            FilterUtils.fromResult(result) as DateColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _referenceColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'referenceNo',
            title: 'Reference no',
            type: FilterType.text,
            hintText: 'Reference number',
          ),
          initialValue: filters.referenceNoColumnFilter,
          onApply: (result) => filtersNotifier.setReferenceNoColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 100,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Party Name',
            type: FilterType.text,
            hintText: 'Party name',
          ),
          initialValue: filters.partyNameColumnFilter,
          onApply: (result) => filtersNotifier.setPartyNameColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'amount',
            title: 'Amount',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.amountColumnFilter,
          onApply: (result) => filtersNotifier.setAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _balanceColWidth,
        header: _HeaderCell(
          label: 'Balance',
          alignment: Alignment.centerRight,
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
    'Open',
    'Converted',
    'Cancelled',
    'Draft',
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
  const _HeaderCell({
    required this.label,
    this.alignment = Alignment.centerLeft,
  });

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

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
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: _headerStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
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

class _ActionsCell extends StatelessWidget {
  const _ActionsCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
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
    final filtersNotifier = ref.read(estimateQuotationFiltersProvider.notifier);
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
