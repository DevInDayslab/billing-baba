import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/resizable_data_table.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/presentation/widgets/document_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_actions.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

class PurchaseBillTable extends ConsumerWidget {
  const PurchaseBillTable({super.key});

  static final _dateFormat = DateFormat('dd/MM/yyyy, hh:mm a');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static const TextStyle _amountTextStyle = purchaseTransactionAmountTextStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginated = ref.watch(paginatedPurchaseBillsProvider);
    final filters = ref.watch(purchaseBillFiltersProvider);
    final searchQuery = ref.watch(purchaseBillSearchQueryProvider);
    final notifier = ref.read(purchaseBillsProvider.notifier);

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
                const _PurchaseBillSearchField(),
                if (filters.hasActiveFilters ||
                    searchQuery.trim().isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: ref
                        .read(purchaseBillFiltersProvider.notifier)
                        .clearAllFilters,
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
                  'No purchase bills found',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            _PurchaseBillTransactionsTable(
              items: paginated.items,
              onBuildRow: (bill, index) => _buildRow(context, ref, bill, index),
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
    PurchaseBillModel bill,
    int index,
  ) {
    return ResizableDataRow(
      backgroundColor: index.isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(bill.date))),
        _DataCell(child: Text(bill.invoiceNo)),
        _DataCell(
          child: Text(
            bill.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          child: Text(
            bill.paymentType,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(bill.amount),
            style: _amountTextStyle.copyWith(
              color: const Color(0xFFC62828),
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(bill.balanceDue),
            style: _amountTextStyle.copyWith(
              color: bill.balanceDue > 0 ? const Color(0xFFC62828) : null,
            ),
          ),
        ),
        _DataCell(child: Text(_dueDateFormat.format(bill.dueDate))),
        _DataCell(child: PurchaseBillStatusBadge(status: bill.status)),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => DocumentPrintActions.preview(
                  context,
                  ref,
                  PrintRequest.purchaseBill(bill.id),
                  filename: DocumentPrintActions.filenameFor(bill.invoiceNo),
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
                  PrintRequest.purchaseBill(bill.id),
                  filename: DocumentPrintActions.filenameFor(bill.invoiceNo),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Share',
              ),
              SalesActionMenuButton(
                items: [
                  for (final action in purchaseBillMenuActionsFor(bill))
                    SalesActionMenuItem(
                      label: purchaseBillMenuActionLabel(action),
                      onSelected: () => handlePurchaseBillMenuAction(
                        context: context,
                        ref: ref,
                        action: action,
                        bill: bill,
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

class _PurchaseBillTransactionsTable extends ConsumerWidget {
  const _PurchaseBillTransactionsTable({
    required this.items,
    required this.onBuildRow,
  });

  final List<PurchaseBillModel> items;
  final ResizableDataRow Function(PurchaseBillModel bill, int index) onBuildRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = _PurchaseBillTableColumns.build(ref: ref);
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

class _PurchaseBillTableColumns {
  const _PurchaseBillTableColumns._();

  static PurchaseBillNumericFilter _toBillNumeric(
    PurchaseNumericFilter filter,
  ) {
    return PurchaseBillNumericFilter(
      operator: switch (filter.operator) {
        PurchaseNumericFilterOperator.equalTo =>
          PurchaseBillNumericFilterOperator.equalTo,
        PurchaseNumericFilterOperator.lessThan =>
          PurchaseBillNumericFilterOperator.lessThan,
        PurchaseNumericFilterOperator.greaterThan =>
          PurchaseBillNumericFilterOperator.greaterThan,
      },
      value: filter.value,
    );
  }

  static PurchaseNumericFilter? _fromBillNumeric(
    PurchaseBillNumericFilter? filter,
  ) {
    if (filter == null) return null;
    return PurchaseNumericFilter(
      operator: switch (filter.operator) {
        PurchaseBillNumericFilterOperator.equalTo =>
          PurchaseNumericFilterOperator.equalTo,
        PurchaseBillNumericFilterOperator.lessThan =>
          PurchaseNumericFilterOperator.lessThan,
        PurchaseBillNumericFilterOperator.greaterThan =>
          PurchaseNumericFilterOperator.greaterThan,
      },
      value: filter.value,
    );
  }

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(purchaseBillFiltersProvider);
    final filtersNotifier = ref.read(purchaseBillFiltersProvider.notifier);
    final partyOptions = ref.watch(purchaseBillPartyOptionsProvider);

    final columns = PurchaseColumnFilterFields(
      columnDateRange: filters.columnDateRange,
      documentNoFilter: filters.invoiceNoFilter,
      selectedParty: filters.selectedParty,
      selectedPaymentTypes: filters.selectedPaymentTypes,
      amountFilter: _fromBillNumeric(filters.amountFilter),
      balanceFilter: _fromBillNumeric(filters.balanceFilter),
      dueDateRange: filters.dueDateRange,
    );

    final actions = PurchaseColumnFilterActions(
      onDocumentNo: filtersNotifier.setInvoiceNo,
      onParty: filtersNotifier.setParty,
      onTogglePaymentType: filtersNotifier.togglePaymentType,
      onClearPaymentTypes: filtersNotifier.clearPaymentTypes,
      onApplyAmountFilter: (filter) =>
          filtersNotifier.applyAmountFilter(_toBillNumeric(filter)),
      onClearAmountFilter: filtersNotifier.clearAmountFilter,
      onApplyBalanceFilter: (filter) =>
          filtersNotifier.applyBalanceFilter(_toBillNumeric(filter)),
      onClearBalanceFilter: filtersNotifier.clearBalanceFilter,
      onStatus: filtersNotifier.setStatus,
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
      );
    }

    return [
      ResizableDataColumn(
        initialWidth: purchaseTransactionDateColWidth,
        minWidth: 120,
        maxWidth: 280,
        header: filterHeader('Date', PurchaseColumnFilterKind.date),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionInvoiceColWidth,
        minWidth: 96,
        header: filterHeader(
          'Invoice no',
          PurchaseColumnFilterKind.documentNo,
          documentNoHint: 'Invoice number',
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionPartyColMinWidth,
        minWidth: 120,
        maxWidth: 420,
        header: filterHeader('Party Name', PurchaseColumnFilterKind.partyName),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionPaymentColWidth,
        minWidth: 96,
        header: filterHeader(
          'Payment Type',
          PurchaseColumnFilterKind.paymentType,
        ),
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
          'Balance Due',
          PurchaseColumnFilterKind.balanceDue,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: purchaseTransactionDueDateColWidth,
        minWidth: 96,
        header: filterHeader('Due Date', PurchaseColumnFilterKind.dueDate),
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
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}

class _PurchaseBillSearchField extends ConsumerStatefulWidget {
  const _PurchaseBillSearchField();

  @override
  ConsumerState<_PurchaseBillSearchField> createState() =>
      _PurchaseBillSearchFieldState();
}

class _PurchaseBillSearchFieldState
    extends ConsumerState<_PurchaseBillSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(purchaseBillSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(purchaseBillSearchQueryProvider, (previous, next) {
      if (next != _controller.text) {
        _controller.text = next;
      }
    });

    return SizedBox(
      width: 200,
      height: 36,
      child: TextField(
        controller: _controller,
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
        onChanged: (value) =>
            ref.read(purchaseBillSearchQueryProvider.notifier).setQuery(value),
        style: const TextStyle(fontSize: 13),
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
    final filtersNotifier = ref.read(purchaseBillFiltersProvider.notifier);
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
