import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_order_actions.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_order_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_column_filter_builder.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_column_filter_cell.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/features/purchases/providers/purchase_orders_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _noColWidth = 110.0;
const _typeColWidth = 106.0;

const double _minTableWidth =
    _noColWidth +
    purchaseTransactionDateOnlyColWidth +
    purchaseTransactionPartyColMinWidth +
    purchaseTransactionDueDateColWidth +
    purchaseTransactionAmountColWidth +
    purchaseTransactionBalanceColWidth +
    _typeColWidth +
    purchaseTransactionStatusColWidth +
    purchaseTransactionActionsColWidth3;

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
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth.clamp(
                _minTableWidth,
                double.infinity,
              );

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TableHeaderRow(),
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
                        for (final order in paginated.items)
                          _buildRow(context, ref, order),
                    ],
                  ),
                ),
              );
            },
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

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    PurchaseOrderModel order,
  ) {
    return PurchaseTransactionTableDataRow(
      children: [
        PurchaseTransactionTableCell(
          width: _noColWidth,
          child: Text(order.orderNo),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDateOnlyColWidth,
          child: Text(_dateFormat.format(order.date)),
        ),
        Expanded(
          flex: purchaseTransactionPartyColFlex,
          child: PurchaseTransactionTableCell(
            child: Text(
              order.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDueDateColWidth,
          child: Text(_dateFormat.format(order.dueDate)),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(order.amount),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionBalanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(order.balanceDue),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        PurchaseTransactionTableCell(
          width: _typeColWidth,
          child: Text(
            order.type,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionStatusColWidth,
          child: PurchaseOrderStatusBadge(status: order.status),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionActionsColWidth3,
          showDivider: false,
          alignment: Alignment.center,
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

class _TableHeaderRow extends ConsumerWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    );

    return PurchaseTransactionTableHeaderRow(
      children: [
        PurchaseTransactionTableCell(
          width: _noColWidth,
          child: purchaseColumnFilterCell(
            label: 'No.',
            kind: PurchaseColumnFilterKind.documentNo,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.documentNo,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseOrderStatusOptions,
            selectedStatus: filters.selectedStatus,
            documentNoHint: 'Search no.',
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDateOnlyColWidth,
          child: purchaseColumnFilterCell(
            label: 'Date',
            kind: PurchaseColumnFilterKind.date,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.date,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseOrderStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        Expanded(
          flex: purchaseTransactionPartyColFlex,
          child: PurchaseTransactionTableCell(
            child: purchaseColumnFilterCell(
              label: 'Party',
              kind: PurchaseColumnFilterKind.partyName,
              headerStyle: purchaseTransactionTableHeaderStyle,
              isActive: purchaseColumnFilterIsActive(
                PurchaseColumnFilterKind.partyName,
                columns,
              ),
              columns: columns,
              actions: actions,
              partyOptions: partyOptions,
              statusOptions: purchaseOrderStatusOptions,
              selectedStatus: filters.selectedStatus,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDueDateColWidth,
          child: purchaseColumnFilterCell(
            label: 'Due Date',
            kind: PurchaseColumnFilterKind.dueDate,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.dueDate,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseOrderStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'Amount',
            kind: PurchaseColumnFilterKind.amount,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.amount,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseOrderStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionBalanceColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'Balance',
            kind: PurchaseColumnFilterKind.balanceDue,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.balanceDue,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseOrderStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: _typeColWidth,
          child: purchaseColumnFilterCell(
            label: 'Type',
            kind: PurchaseColumnFilterKind.typeName,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.typeName,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseOrderStatusOptions,
            selectedStatus: filters.selectedStatus,
            typeOptions: typeOptions,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionStatusColWidth,
          child: purchaseColumnFilterCell(
            label: 'Status',
            kind: PurchaseColumnFilterKind.status,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnStatusFilterIsActive(
              filters.selectedStatus,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseOrderStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        const PurchaseTransactionTableCell(
          width: purchaseTransactionActionsColWidth3,
          showDivider: false,
          alignment: Alignment.center,
          child: Text('Actions', style: purchaseTransactionTableHeaderStyle),
        ),
      ],
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
          border: isActive ? null : Border.all(color: purchaseTransactionTableCardBorder),
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

