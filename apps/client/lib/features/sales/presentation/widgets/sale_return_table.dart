import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/core/widgets/expandable_table_search_field.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_document_actions_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_empty_state_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_status_badge.dart';
import 'package:billing_baba/features/sales/providers/credit_note_form_provider.dart';
import 'package:billing_baba/features/sales/providers/credit_note_tabs_provider.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:billing_baba/features/sales/providers/sale_return_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tableHeaderBg = Color(0xFFF5F7FA);
const _zebraRowBg = Color(0xFFFAFAFA);
const _summaryFooterBg = Color(0xFFF5F5F5);

const _indexColWidth = 36.0;
const _dateColWidth = 148.0;
const _refColWidth = 88.0;
const _partyColWidth = 140.0;
const _categoryColWidth = 120.0;
const _typeColWidth = 100.0;
const _amountColWidth = 100.0;
const _dueDateColWidth = 108.0;
const _statusColWidth = 88.0;
const _actionsColWidth = 120.0;
const double _cellHorizontalPadding = AppSpacing.sm;
const TextStyle _tableHeaderStyle = ListPanelStyles.listHeaderStyle;

class SaleReturnTable extends ConsumerWidget {
  const SaleReturnTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAsync = ref.watch(saleReturnsProvider);
    final paginated = ref.watch(paginatedSaleReturnsProvider);
    final summary = ref.watch(saleReturnSummaryProvider);
    final filters = ref.watch(saleReturnFiltersProvider);
    final filtersNotifier = ref.read(saleReturnFiltersProvider.notifier);
    final notifier = ref.read(saleReturnsProvider.notifier);

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
                ExpandableTableSearchField(
                  hint: 'Search',
                  initialQuery: filters.searchQuery,
                  onQueryChanged: filtersNotifier.setSearchQuery,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    final sessionKey =
                        ref.read(creditNoteTabsProvider()).activeTab.sessionKey;
                    ref
                        .read(
                          creditNoteFormProvider(sessionKey: sessionKey)
                              .notifier,
                        )
                        .resetForm();
                    unawaited(context.push(AppRoutes.addCreditNote));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Add Credit Note',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          returnsAsync.when(
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
            data: (_) => _SaleReturnTransactionsTable(
              items: paginated.items,
              currentPage: paginated.currentPage,
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          _SummaryFooter(
            totalAmount: summary.totalAmount,
            balance: summary.balance,
          ),
          if (paginated.totalPages > 1) ...[
            const Divider(height: 1, color: _cardBorder),
            _PaginationRow(
              currentPage: paginated.currentPage,
              totalPages: paginated.totalPages,
            ),
          ],
        ],
      ),
    );
  }
}

class _SaleReturnTransactionsTable extends ConsumerWidget {
  const _SaleReturnTransactionsTable({
    required this.items,
    required this.currentPage,
  });

  final List<SaleInvoiceModel> items;
  final int currentPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(saleReturnFiltersProvider);
    final hasActiveFilters = needsSaleReturnClientSideFiltering(filters);

    if (items.isEmpty) {
      return _EmptyTransactionsState(isFiltered: hasActiveFilters);
    }

    final rows = [
      for (var i = 0; i < items.length; i++)
        SaleReturnTableRows.buildDataRow(
          context: context,
          ref: ref,
          item: items[i],
          rowNumber: (currentPage - 1) * saleReturnPageSize + i + 1,
          isOdd: i.isOdd,
        ),
    ];

    final columns = _SaleReturnTableColumns.build(
      context: context,
      ref: ref,
      onStatusFilter: (status) =>
          ref.read(saleReturnFiltersProvider.notifier).setStatus(status),
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

class SaleReturnTableRows {
  const SaleReturnTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required WidgetRef ref,
    required SaleInvoiceModel item,
    required int rowNumber,
    required bool isOdd,
  }) {
    final receivedPaid = item.amount - item.balance;
    final dueDate = item.dueDate ?? item.date;

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text('$rowNumber')),
        _DataCell(child: Text(_dateFormat.format(item.date))),
        _DataCell(child: Text(item.invoiceNo)),
        _DataCell(
          child: Text(
            item.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const _DataCell(child: Text('')),
        _DataCell(child: Text(item.transactionType)),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(item.amount)),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(receivedPaid)),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(_currencyFormat.format(item.balance)),
        ),
        _DataCell(child: Text(_dueDateFormat.format(dueDate))),
        _DataCell(child: _StatusCell(item: item)),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  PrintRequest.creditNote(item.id),
                  filename: DocumentPrintActions.filenameFor(item.invoiceNo),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Print',
              ),
              IconButton(
                onPressed: () => DocumentPrintActions.share(
                  context,
                  ref,
                  PrintRequest.creditNote(item.id),
                  filename: DocumentPrintActions.filenameFor(item.invoiceNo),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Share',
              ),
              SaleDocumentActionsMenuButton(
                document: item,
                config: SaleDocumentActionsConfig.salesReturn(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({required this.item});

  final SaleInvoiceModel item;

  @override
  Widget build(BuildContext context) {
    if (item.isDraft) {
      return const Text(
        'Draft',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      );
    }

    if (item.isCancelled) {
      return const SaleInvoiceStatusBadge(
        status: SaleInvoiceStatus.cancelled,
        plain: true,
      );
    }

    return SaleInvoiceStatusBadge(status: item.status, plain: true);
  }
}

class _SaleReturnTableColumns {
  const _SaleReturnTableColumns._();

  static const _typeOptions = [
    'Credit Note',
    'Sale',
    'Estimate',
    'Sale Order',
    'Delivery Challan',
  ];

  static List<ResizableDataColumn> build({
    required BuildContext context,
    required WidgetRef ref,
    required ValueChanged<String> onStatusFilter,
  }) {
    final filters = ref.watch(saleReturnFiltersProvider);
    final filtersNotifier = ref.read(saleReturnFiltersProvider.notifier);

    return [
      const ResizableDataColumn(
        initialWidth: _indexColWidth,
        minWidth: _indexColWidth,
        maxWidth: _indexColWidth,
        resizable: false,
        header: _HeaderCell(label: '#', headerStyle: _tableHeaderStyle),
      ),
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 96,
        maxWidth: 280,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'date',
            title: 'DATE',
            type: FilterType.date,
          ),
          headerStyle: _tableHeaderStyle,
          initialValue: filters.dateColumnFilter,
          onApply: (result) => filtersNotifier.setDateColumnFilter(
            FilterUtils.fromResult(result) as DateColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _refColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'refNo',
            title: 'REF NO.',
            type: FilterType.text,
            hintText: 'Reference number',
          ),
          headerStyle: _tableHeaderStyle,
          initialValue: filters.refNoColumnFilter,
          onApply: (result) => filtersNotifier.setRefNoColumnFilter(
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
            title: 'PARTY NAME',
            type: FilterType.text,
            hintText: 'Party name',
          ),
          headerStyle: _tableHeaderStyle,
          initialValue: filters.partyNameColumnFilter,
          onApply: (result) => filtersNotifier.setPartyNameColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _categoryColWidth,
        header: _HeaderCell(
          label: 'CATEGORY NAME',
          headerStyle: _tableHeaderStyle,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _typeColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'type',
            title: 'TYPE',
            type: FilterType.singleSelect,
            values: _typeOptions,
          ),
          headerStyle: _tableHeaderStyle,
          initialValue: filters.typeColumnFilter,
          onApply: (result) => filtersNotifier.setTypeColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'total',
            title: 'TOTAL',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          headerStyle: _tableHeaderStyle,
          initialValue: filters.totalAmountColumnFilter,
          onApply: (result) => filtersNotifier.setTotalAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'receivedPaid',
            title: 'RECEIVED/PAID',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          headerStyle: _tableHeaderStyle,
          initialValue: filters.receivedPaidColumnFilter,
          onApply: (result) => filtersNotifier.setReceivedPaidColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'balance',
            title: 'BALANCE',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          headerStyle: _tableHeaderStyle,
          initialValue: filters.balanceColumnFilter,
          onApply: (result) => filtersNotifier.setBalanceColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dueDateColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'dueDate',
            title: 'DUE DATE',
            type: FilterType.date,
          ),
          headerStyle: _tableHeaderStyle,
          initialValue: filters.dueDateColumnFilter,
          onApply: (result) => filtersNotifier.setDueDateColumnFilter(
            FilterUtils.fromResult(result) as DateColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        header: _StatusColumnFilterHeader(
          headerStyle: _tableHeaderStyle,
          onStatusFilter: onStatusFilter,
          selectedStatus: filters.selectedStatus,
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _actionsColWidth,
        resizable: false,
        header: _HeaderCell(
          label: 'PRINT / SHARE',
          headerStyle: _tableHeaderStyle,
        ),
      ),
    ];
  }
}

class _StatusColumnFilterHeader extends StatefulWidget {
  const _StatusColumnFilterHeader({
    required this.onStatusFilter,
    required this.selectedStatus,
    this.headerStyle,
  });

  final ValueChanged<String> onStatusFilter;
  final String selectedStatus;
  final TextStyle? headerStyle;

  @override
  State<_StatusColumnFilterHeader> createState() =>
      _StatusColumnFilterHeaderState();
}

class _StatusColumnFilterHeaderState extends State<_StatusColumnFilterHeader> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  static const _statusOptions = [
    'All Status',
    'Cancelled',
    'Draft',
    'Finalized',
    'Paid',
    'Unpaid',
    'Partial',
  ];

  TextStyle get _headerStyle =>
      widget.headerStyle ??
      const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

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
            Expanded(
              child: Text(
                'STATUS',
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
    this.headerStyle,
  });

  final String label;
  final TextStyle? headerStyle;

  static const _defaultHeaderStyle = TextStyle(
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: headerStyle ?? _defaultHeaderStyle,
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

class _SummaryFooter extends StatelessWidget {
  const _SummaryFooter({
    required this.totalAmount,
    required this.balance,
  });

  final double totalAmount;
  final double balance;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _summaryFooterBg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Amount: ${_currencyFormat.format(totalAmount)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            'Balance: ${_currencyFormat.format(balance)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
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
    final filtersNotifier = ref.read(saleReturnFiltersProvider.notifier);
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

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState({required this.isFiltered});

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
          const SaleGeometricIllustration(
            circleColor: Color(0xFFE3F2FD),
            shapeColor: AppColors.primary,
            shapeIcon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isFiltered
                ? 'No credit notes match your filters.'
                : 'No data is available for Credit Note.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Please try again after making relevant changes.',
            textAlign: TextAlign.center,
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
