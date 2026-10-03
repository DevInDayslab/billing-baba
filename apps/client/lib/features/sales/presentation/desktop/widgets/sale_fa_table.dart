import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/module_print_actions.dart';
import 'package:billing_baba/features/sales/application/sale_fa_provider.dart';
import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_fa_status_badge.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_table_shared.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);

const _dateColWidth = 148.0;
const _invoiceColWidth = 110.0;
const _partyColWidth = 160.0;
const _transactionColWidth = 108.0;
const _paymentColWidth = 108.0;
const _amountColWidth = 100.0;
const _balanceColWidth = 100.0;
const _dueDateColWidth = 108.0;
const _statusColWidth = 100.0;
const _actionsColWidth = 120.0;
const double _cellHorizontalPadding = AppSpacing.sm;

class SaleFaTable extends ConsumerWidget {
  const SaleFaTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faAsync = ref.watch(saleFaProvider);
    final paginated = ref.watch(paginatedSaleFaRecordsProvider);
    final notifier = ref.read(saleFaProvider.notifier);

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
                  initialQuery: ref.read(saleFaSearchQueryProvider),
                  onQueryChanged: ref
                      .read(saleFaSearchQueryProvider.notifier)
                      .setQuery,
                ),
                IconButton(
                  onPressed: () =>
                      ModuleExportActions.exportSaleFa(context, ref),
                  icon: const Icon(Icons.bar_chart_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Report',
                ),
                _XlsChip(
                  onTap: () => ModuleExportActions.exportSaleFa(context, ref),
                ),
                IconButton(
                  onPressed: () => ModulePrintActions.printSaleFa(context, ref),
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
          SalesPaginatedListAsyncBody(
            listAsync: faAsync,
            onRetry: notifier.refresh,
            hasStaleRows: paginated.items.isNotEmpty,
            table: _SaleFaTransactionsTable(items: paginated.items),
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

class _SaleFaTransactionsTable extends ConsumerStatefulWidget {
  const _SaleFaTransactionsTable({required this.items});

  final List<SaleFaModel> items;

  @override
  ConsumerState<_SaleFaTransactionsTable> createState() =>
      _SaleFaTransactionsTableState();
}

class _SaleFaTransactionsTableState
    extends ConsumerState<_SaleFaTransactionsTable> {
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(saleFaFiltersProvider);

    final rows = [
      for (var i = 0; i < widget.items.length; i++)
        _SaleFaTableRows.buildDataRow(
          context: context,
          ref: ref,
          record: widget.items[i],
          isOdd: i.isOdd,
        ),
    ];

    final columns = _SaleFaTableColumns.build(
      context: context,
      ref: ref,
      onStatusFilter: (status) =>
          ref.read(saleFaFiltersProvider.notifier).setStatus(status),
      selectedStatus: filters.selectedStatus,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: ResizableDataTable(
            columns: columns,
            rows: rows,
          ),
        ),
        if (widget.items.isEmpty) const _EmptyState(),
      ],
    );
  }
}

class _SaleFaTableRows {
  const _SaleFaTableRows._();

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
    required SaleFaModel record,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(record.createdAt))),
        _DataCell(child: Text(record.invoiceNo)),
        _DataCell(
          child: Text(
            record.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const _DataCell(child: Text('Sale FA')),
        _DataCell(child: Text(record.paymentType)),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(record.amount)),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(record.balanceDue)),
        ),
        _DataCell(
          child: Text(_dueDateFormat.format(record.dueDate)),
        ),
        _DataCell(
          child: SaleFaStatusBadge(status: record.status),
        ),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  PrintRequest.saleFa(record.batchId),
                  filename: DocumentPrintActions.filenameFor(record.invoiceNo),
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
                    const SnackBar(content: Text('Share coming soon')),
                  );
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Share',
              ),
              _SaleFaActionMenu(record: record),
            ],
          ),
        ),
      ],
    );
  }
}

class _SaleFaTableColumns {
  const _SaleFaTableColumns._();

  static List<ResizableDataColumn> build({
    required BuildContext context,
    required WidgetRef ref,
    required ValueChanged<String> onStatusFilter,
    required String selectedStatus,
  }) {
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
          initialValue: null,
          onApply: (_) {},
        ),
      ),
      ResizableDataColumn(
        initialWidth: _invoiceColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'invoiceNo',
            title: 'Invoice No.',
            type: FilterType.text,
            hintText: 'Invoice number',
          ),
          initialValue: null,
          onApply: (_) {},
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
          initialValue: null,
          onApply: (_) {},
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _transactionColWidth,
        header: _HeaderCell(label: 'Transaction Type'),
      ),
      ResizableDataColumn(
        initialWidth: _paymentColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'paymentType',
            title: 'Payment Type',
            type: FilterType.singleSelect,
            values: ['Cash', 'UPI', 'Card', 'Cheque', 'Bank Transfer', 'Other'],
          ),
          initialValue: null,
          onApply: (_) {},
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
          initialValue: null,
          onApply: (_) {},
        ),
      ),
      ResizableDataColumn(
        initialWidth: _balanceColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'balance',
            title: 'Balance Due',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: null,
          onApply: (_) {},
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dueDateColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'dueDate',
            title: 'Due Date',
            type: FilterType.date,
          ),
          initialValue: null,
          onApply: (_) {},
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        header: _StatusColumnHeader(
          selectedStatus: selectedStatus,
          onStatusFilter: onStatusFilter,
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

class _StatusColumnHeader extends StatefulWidget {
  const _StatusColumnHeader({
    required this.selectedStatus,
    required this.onStatusFilter,
  });

  final String selectedStatus;
  final ValueChanged<String> onStatusFilter;

  @override
  State<_StatusColumnHeader> createState() => _StatusColumnHeaderState();
}

class _StatusColumnHeaderState extends State<_StatusColumnHeader> {
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
    'Paid',
    'Unpaid',
    'Partially Paid',
    'Overdue',
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
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Stack(
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
                      _StatusMenuItem(
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
      ),
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

class _StatusMenuItem extends StatelessWidget {
  const _StatusMenuItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
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
          child: wrapEllipsisTooltipChild(child),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Color(0x80757575),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No Sale FA transactions found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Create your first Sale FA to get started.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
    final filtersNotifier = ref.read(saleFaFiltersProvider.notifier);
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

/// Inline action menu for Sale FA rows — uses MenuAnchor with bottom-aligned
/// opening so it never clips inside the table.
class _SaleFaActionMenu extends ConsumerWidget {
  const _SaleFaActionMenu({required this.record});

  final SaleFaModel record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SalesActionMenuButton(
      items: [
        SalesActionMenuItem(
          label: 'Open',
          onSelected: () async {
            await context.push(
              '${AppRoutes.editSaleFa}/${record.batchId}',
            );
          },
        ),
        SalesActionMenuItem(
          label: 'Delete',
          isDestructive: true,
          onSelected: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete sale?'),
                content: Text('Delete ${record.invoiceNo}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (confirmed != true || !context.mounted) return;
            final error = await ref
                .read(saleFaProvider.notifier)
                .deleteBatch(record.batchId);
            if (!context.mounted) return;
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            }
          },
        ),
      ],
    );
  }
}
