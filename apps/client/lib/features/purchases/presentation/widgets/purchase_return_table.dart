import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/widgets/module_print_actions.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_return_actions.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/features/purchases/providers/purchase_return_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_table_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _indexColWidth = 44.0;
const _typeColWidth = 97.0;
const _categoryColWidth = 132.0;

const double _minTableWidth =
    _indexColWidth +
    purchaseTransactionDateColWidth +
    purchaseTransactionRefColWidth +
    purchaseTransactionPartyColMinWidth +
    _categoryColWidth +
    _typeColWidth +
    purchaseTransactionAmountColWidth +
    purchaseTransactionAmountColWidth +
    purchaseTransactionAmountColWidth +
    purchaseTransactionDueDateColWidth +
    purchaseTransactionStatusColWidth +
    purchaseTransactionActionsColWidth3;

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
                        for (var i = 0; i < paginated.items.length; i++)
                          _buildRow(
                            context,
                            ref,
                            paginated.items[i],
                            (paginated.currentPage - 1) *
                                    purchaseReturnPageSize +
                                i +
                                1,
                          ),
                      ],
                    ),
                  ),
                );
              },
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

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    PurchaseReturnModel item,
    int rowNumber,
  ) {
    return PurchaseTransactionTableDataRow(
      children: [
        PurchaseTransactionTableCell(
          width: _indexColWidth,
          child: Text('$rowNumber'),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDateColWidth,
          child: Text(
            _dateFormat.format(item.date),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionRefColWidth,
          child: Text(
            item.debitNoteNo,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Expanded(
          child: PurchaseTransactionTableCell(
            child: Text(
              item.partyName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: _categoryColWidth,
          child: Text(
            item.categoryName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        PurchaseTransactionTableCell(
          width: _typeColWidth,
          child: Text(
            item.type,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.total),
            style: purchaseTransactionAmountTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.receivedPaid),
            style: purchaseTransactionAmountTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(item.balance),
            style: purchaseTransactionAmountTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDueDateColWidth,
          child: Text(
            _dueDateFormat.format(item.dueDate),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionStatusColWidth,
          child: PurchaseBillStatusBadge(status: item.status),
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

class _TableHeaderRow extends ConsumerWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return PurchaseTransactionTableHeaderRow(
      children: [
        const PurchaseTransactionTableCell(
          width: _indexColWidth,
          child: Text('#', style: purchaseTransactionTableHeaderStyle),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDateColWidth,
          child: purchaseColumnFilterCell(
            label: 'DATE',
            kind: PurchaseColumnFilterKind.date,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.date,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionRefColWidth,
          child: purchaseColumnFilterCell(
            label: 'REF NO.',
            kind: PurchaseColumnFilterKind.documentNo,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.documentNo,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
            documentNoHint: 'Search ref no',
          ),
        ),
        Expanded(
          child: PurchaseTransactionTableCell(
            child: purchaseColumnFilterCell(
              label: 'PARTY NAME',
              kind: PurchaseColumnFilterKind.partyName,
              headerStyle: purchaseTransactionTableHeaderStyle,
              isActive: purchaseColumnFilterIsActive(
                PurchaseColumnFilterKind.partyName,
                columns,
              ),
              columns: columns,
              actions: actions,
              partyOptions: partyOptions,
              statusOptions: purchaseBillStatusOptions,
              selectedStatus: filters.selectedStatus,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: _categoryColWidth,
          child: purchaseColumnFilterCell(
            label: 'CATEGORY NAME',
            kind: PurchaseColumnFilterKind.categoryName,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.categoryName,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
            categoryOptions: categoryOptions,
          ),
        ),
        PurchaseTransactionTableCell(
          width: _typeColWidth,
          child: purchaseColumnFilterCell(
            label: 'TYPE',
            kind: PurchaseColumnFilterKind.typeName,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.typeName,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
            typeOptions: typeOptions,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'TOTAL',
            kind: PurchaseColumnFilterKind.amount,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.amount,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'RECEIVED/PAID',
            kind: PurchaseColumnFilterKind.receivedPaid,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.receivedPaid,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'BALANCE',
            kind: PurchaseColumnFilterKind.balanceDue,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.balanceDue,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDueDateColWidth,
          child: purchaseColumnFilterCell(
            label: 'DUE DATE',
            kind: PurchaseColumnFilterKind.dueDate,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.dueDate,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionStatusColWidth,
          child: purchaseColumnFilterCell(
            label: 'STATUS',
            kind: PurchaseColumnFilterKind.status,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnStatusFilterIsActive(
              filters.selectedStatus,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: purchaseBillStatusOptions,
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
