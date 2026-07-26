import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_print_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/module_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_return_provider.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_bill_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_return_actions.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/shared/sales_table_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _indexColWidth = 44.0;
const _typeColWidth = 97.0;
const _categoryColWidth = 132.0;
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

class PurchaseReturnTable extends ConsumerWidget {
  const PurchaseReturnTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPurchaseReturnsProvider);
    final summary = ref.watch(purchaseReturnSummaryProvider);
    final filters = ref.watch(purchaseReturnFiltersProvider);
    final filtersNotifier = ref.read(purchaseReturnFiltersProvider.notifier);
    final notifier = ref.read(purchaseReturnsProvider.notifier);

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
                SalesXlsChip(
                  onTap: () =>
                      ModuleExportActions.exportDebitNotes(context, ref),
                ),
                IconButton(
                  onPressed: () =>
                      ModulePrintActions.printDebitNotes(context, ref),
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
          const Divider(height: 1, color: purchaseTransactionTableCardBorder),
          if (paginated.items.isEmpty)
            const SalesEmptyListState(message: 'No debit notes found')
          else
            _PurchaseReturnTransactionsTable(
              items: paginated.items,
              currentPage: paginated.currentPage,
              onBuildRow: (item, rowNumber, index) =>
                  _buildRow(context, ref, item, rowNumber, index),
            ),
          const Divider(height: 1, color: purchaseTransactionTableCardBorder),
          _SummaryFooter(
            totalAmount: summary.totalAmount,
            balance: summary.balance,
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
    PurchaseReturnModel item,
    int rowNumber,
    int index,
  ) {
    return ResizableDataRow(
      backgroundColor: index.isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text('$rowNumber')),
        _DataCell(child: Text(_dateFormat.format(item.date))),
        _DataCell(child: Text(item.debitNoteNo)),
        _DataCell(
          child: Text(
            item.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          child: Text(
            item.categoryName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          child: Text(
            item.type,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.total),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.receivedPaid),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.balance),
            style: purchaseTransactionAmountTextStyle,
          ),
        ),
        _DataCell(child: Text(_dueDateFormat.format(item.dueDate))),
        _DataCell(child: PurchaseBillStatusBadge(status: item.status)),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  PrintRequest.debitNote(item.id),
                  filename: DocumentPrintActions.filenameFor(item.debitNoteNo),
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
                  PrintRequest.debitNote(item.id),
                  filename: DocumentPrintActions.filenameFor(item.debitNoteNo),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Share',
              ),
              SalesActionMenuButton(
                items: [
                  for (final action in purchaseReturnMenuActionsFor(item))
                    SalesActionMenuItem(
                      label: purchaseReturnMenuActionLabel(action),
                      onSelected: () => handlePurchaseReturnMenuAction(
                        context: context,
                        ref: ref,
                        action: action,
                        item: item,
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

class _PurchaseReturnTransactionsTable extends ConsumerWidget {
  const _PurchaseReturnTransactionsTable({
    required this.items,
    required this.currentPage,
    required this.onBuildRow,
  });

  final List<PurchaseReturnModel> items;
  final int currentPage;
  final ResizableDataRow Function(
    PurchaseReturnModel item,
    int rowNumber,
    int index,
  ) onBuildRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = _PurchaseReturnTableColumns.build(ref: ref);
    final rows = [
      for (var i = 0; i < items.length; i++)
        onBuildRow(
          items[i],
          (currentPage - 1) * purchaseReturnPageSize + i + 1,
          i,
        ),
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

class _PurchaseReturnTableColumns {
  const _PurchaseReturnTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(purchaseReturnFiltersProvider);
    final filtersNotifier = ref.read(purchaseReturnFiltersProvider.notifier);
    final partyOptions = ref.watch(purchaseReturnPartyOptionsProvider);
    final categoryOptions = ref.watch(purchaseReturnCategoryOptionsProvider);
    final typeOptions = ref.watch(purchaseReturnTypeOptionsProvider);
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
      onCategory: filtersNotifier.setCategory,
      onType: filtersNotifier.setType,
      onApplyReceivedPaidFilter: filtersNotifier.applyReceivedPaidFilter,
      onClearReceivedPaidFilter: filtersNotifier.clearReceivedPaidFilter,
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
        statusOptions: purchaseBillStatusOptions,
        selectedStatus: filters.selectedStatus,
        alignment: alignment,
        documentNoHint: documentNoHint,
        categoryOptions: categoryOptions,
        typeOptions: typeOptions,
      );
    }

    return [
      const ResizableDataColumn(
        initialWidth: _indexColWidth,
        minWidth: _indexColWidth,
        maxWidth: _indexColWidth,
        resizable: false,
        header: _HeaderCell(label: '#'),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionDateColWidth,
        minWidth: 120,
        maxWidth: 280,
        header: filterHeader('DATE', PurchaseColumnFilterKind.date),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionRefColWidth,
        minWidth: 96,
        header: filterHeader(
          'REF NO.',
          PurchaseColumnFilterKind.documentNo,
          documentNoHint: 'Search ref no',
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionPartyColMinWidth,
        minWidth: 120,
        header: filterHeader('PARTY NAME', PurchaseColumnFilterKind.partyName),
      ),
      ResizableDataColumn(
        initialWidth: _categoryColWidth,
        minWidth: 100,
        header: filterHeader(
          'CATEGORY NAME',
          PurchaseColumnFilterKind.categoryName,
        ),
      ),
      ResizableDataColumn(
        initialWidth: _typeColWidth,
        minWidth: 88,
        header: filterHeader('TYPE', PurchaseColumnFilterKind.typeName),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionAmountColWidth,
        minWidth: 80,
        header: filterHeader(
          'TOTAL',
          PurchaseColumnFilterKind.amount,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionAmountColWidth,
        minWidth: 100,
        header: filterHeader(
          'RECEIVED/PAID',
          PurchaseColumnFilterKind.receivedPaid,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionAmountColWidth,
        minWidth: 80,
        header: filterHeader(
          'BALANCE',
          PurchaseColumnFilterKind.balanceDue,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionDueDateColWidth,
        minWidth: 96,
        header: filterHeader('DUE DATE', PurchaseColumnFilterKind.dueDate),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionStatusColWidth,
        minWidth: 88,
        header: filterHeader('STATUS', PurchaseColumnFilterKind.status),
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

class _SummaryFooter extends StatelessWidget {
  const _SummaryFooter({
    required this.totalAmount,
    required this.balance,
  });

  final double totalAmount;
  final double balance;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Total Amount: ${_currencyFormat.format(totalAmount)}',
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
    final notifier = ref.read(purchaseReturnFiltersProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () => notifier.setPage(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left, size: 20),
            color: AppColors.textSecondary,
          ),
          Text(
            '$currentPage / $totalPages',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => notifier.setPage(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right, size: 20),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
