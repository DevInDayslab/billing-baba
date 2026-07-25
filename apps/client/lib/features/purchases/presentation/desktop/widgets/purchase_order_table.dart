import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_orders_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_order_actions.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_order_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _noColWidth = 110.0;
const _typeColWidth = 106.0;
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

class PurchaseOrderTable extends ConsumerWidget {
  const PurchaseOrderTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPurchaseOrdersProvider);
    final filters = ref.watch(purchaseOrderFiltersProvider);
    final filtersNotifier = ref.read(purchaseOrderFiltersProvider.notifier);
    final notifier = ref.read(purchaseOrdersProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: purchaseTransactionTableCardBorder),
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
                SizedBox(
                  width: 200,
                  height: 36,
                  child: TextField(
                    onChanged: filtersNotifier.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.smBorder,
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (filters.hasActiveFilters) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: filtersNotifier.clearAllFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: notifier.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: purchaseTransactionTableCardBorder),
          if (paginated.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No purchase orders found',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            _PurchaseOrderTransactionsTable(
              items: paginated.items,
              onBuildRow: (order, index) =>
                  _buildRow(context, ref, order, index),
            ),
          if (paginated.totalPages > 1) ...[
            const Divider(height: 1, color: purchaseTransactionTableCardBorder),
            _PaginationRow(
              currentPage: paginated.currentPage,
              totalPages: paginated.totalPages,
            ),
          ],
        ],
      ),
    );
  }

  ResizableDataRow _buildRow(
    BuildContext context,
    WidgetRef ref,
    PurchaseOrderModel order,
    int index,
  ) {
    return ResizableDataRow(
      backgroundColor: index.isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(order.orderNo)),
        _DataCell(child: Text(_dateFormat.format(order.date))),
        _DataCell(
          child: Text(
            order.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(_dateFormat.format(order.dueDate))),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(order.amount),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(order.balanceDue),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(
          child: Text(
            order.type,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: PurchaseOrderStatusBadge(status: order.status)),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  PrintRequest.purchaseOrder(order.id),
                  filename: DocumentPrintActions.filenameFor(order.orderNo),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Print',
              ),
              IconButton(
                onPressed: () => DocumentPrintActions.share(
                  context,
                  ref,
                  PrintRequest.purchaseOrder(order.id),
                  filename: DocumentPrintActions.filenameFor(order.orderNo),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Share',
              ),
              SalesActionMenuButton(
                items: [
                  for (final action in purchaseOrderMenuActionsFor(order))
                    SalesActionMenuItem(
                      label: purchaseOrderMenuActionLabel(action),
                      onSelected: () => handlePurchaseOrderMenuAction(
                        context: context,
                        ref: ref,
                        action: action,
                        order: order,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PurchaseOrderTransactionsTable extends ConsumerWidget {
  const _PurchaseOrderTransactionsTable({
    required this.items,
    required this.onBuildRow,
  });

  final List<PurchaseOrderModel> items;
  final ResizableDataRow Function(PurchaseOrderModel order, int index) onBuildRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = _PurchaseOrderTableColumns.build(ref: ref);
    final rows = [
      for (var i = 0; i < items.length; i++) onBuildRow(items[i], i),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: SizedBox(
            width: constraints.maxWidth,
            child: ResizableDataTable(
              columns: columns,
              rows: rows,
              headerBackgroundColor: purchaseTransactionTableHeaderBg,
              rowBorderColor: purchaseTransactionTableRowBorder,
            ),
          ),
        );
      },
    );
  }
}

class _PurchaseOrderTableColumns {
  const _PurchaseOrderTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(purchaseOrderFiltersProvider);
    final filtersNotifier = ref.read(purchaseOrderFiltersProvider.notifier);
    final partyOptions = ref.watch(purchaseOrderPartyOptionsProvider);
    final typeOptions = ref.watch(purchaseOrderTypeOptionsProvider);
    final columns = filters.columnFilters;

    final actions = PurchaseColumnFilterActions(
      onDocumentNo: filtersNotifier.setDocumentNoFilter,
      onParty: filtersNotifier.setParty,
      onTogglePaymentType: filtersNotifier.togglePaymentType,
      onClearPaymentTypes: filtersNotifier.clearPaymentTypes,
      onApplyAmountFilter: filtersNotifier.applyAmountFilter,
      onClearAmountFilter: filtersNotifier.clearAmountFilter,
      onApplyBalanceFilter: filtersNotifier.applyBalanceFilter,
      onClearBalanceFilter: filtersNotifier.clearBalanceFilter,
      onStatus: filtersNotifier.setStatus,
      onType: filtersNotifier.setType,
      onDateRange: filtersNotifier.setColumnDateRange,
      onDueDateRange: filtersNotifier.setDueDateRange,
      onClearDateRange: filtersNotifier.clearColumnDateRange,
      onClearDueDateRange: filtersNotifier.clearDueDateRange,
    );

    Widget filterHeader(
      String label,
      PurchaseColumnFilterKind kind, {
      Alignment alignment = Alignment.centerLeft,
      String documentNoHint = 'Search',
    }) {
      return purchaseColumnFilterCell(
        label: label,
        kind: kind,
        headerStyle: purchaseTransactionTableHeaderStyle,
        isActive: purchaseColumnFilterIsActive(
          kind,
          columns,
          selectedStatus: filters.selectedStatus,
        ),
        columns: columns,
        actions: actions,
        partyOptions: partyOptions,
        statusOptions: purchaseOrderStatusOptions,
        selectedStatus: filters.selectedStatus,
        alignment: alignment,
        documentNoHint: documentNoHint,
        typeOptions: typeOptions,
      );
    }

    return [
      ResizableDataColumn(
        initialWidth: _noColWidth,
        minWidth: 80,
        header: filterHeader(
          'No.',
          PurchaseColumnFilterKind.documentNo,
          documentNoHint: 'Search no.',
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionDateOnlyColWidth,
        minWidth: 96,
        header: filterHeader('Date', PurchaseColumnFilterKind.date),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionPartyColMinWidth,
        minWidth: 120,
        header: filterHeader('Party', PurchaseColumnFilterKind.partyName),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionDueDateColWidth,
        minWidth: 96,
        header: filterHeader('Due Date', PurchaseColumnFilterKind.dueDate),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionAmountColWidth,
        minWidth: 80,
        header: filterHeader(
          'Amount',
          PurchaseColumnFilterKind.amount,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionBalanceColWidth,
        minWidth: 80,
        header: filterHeader(
          'Balance',
          PurchaseColumnFilterKind.balanceDue,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _typeColWidth,
        minWidth: 88,
        header: filterHeader('Type', PurchaseColumnFilterKind.typeName),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionStatusColWidth,
        minWidth: 88,
        header: filterHeader('Status', PurchaseColumnFilterKind.status),
      ),
      const ResizableDataColumn(
        initialWidth: purchaseTransactionActionsColWidth3,
        minWidth: purchaseTransactionActionsColWidth3,
        maxWidth: purchaseTransactionActionsColWidth3,
        resizable: false,
        header: _HeaderCell(label: 'Actions'),
      ),
    ];
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

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
        style: purchaseTransactionTableHeaderStyle,
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

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: purchaseTransactionTableDataStyle,
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

class _PaginationRow extends ConsumerWidget {
  const _PaginationRow({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtersNotifier = ref.read(purchaseOrderFiltersProvider.notifier);
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
          border: isActive
              ? null
              : Border.all(color: purchaseTransactionTableCardBorder),
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
