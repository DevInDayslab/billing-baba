import 'package:billing_baba/core/theme/app_theme.dart';
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

const double _minTableWidth =
    purchaseTransactionDateColWidth +
    purchaseTransactionInvoiceColWidth +
    purchaseTransactionPartyColMinWidth +
    purchaseTransactionPaymentColWidth +
    purchaseTransactionStatusColWidth +
    purchaseTransactionAmountColWidth +
    purchaseTransactionBalanceColWidth +
    purchaseTransactionDueDateColWidth +
    purchaseTransactionActionsColWidth3;

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
                              'No purchase bills found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        for (final bill in paginated.items)
                          _buildRow(context, ref, bill),
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
    PurchaseBillModel bill,
  ) {
    return PurchaseTransactionTableDataRow(
      children: [
        PurchaseTransactionTableCell(
          width: purchaseTransactionDateColWidth,
          child: Text(_dateFormat.format(bill.date)),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionInvoiceColWidth,
          child: Text(bill.invoiceNo),
        ),
        Expanded(
          child: PurchaseTransactionTableCell(
            child: Text(
              bill.partyName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionPaymentColWidth,
          child: Text(
            bill.paymentType,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(bill.amount),
            style: _amountTextStyle,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionBalanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            _currencyFormat.format(bill.balanceDue),
            style: _amountTextStyle,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionDueDateColWidth,
          child: Text(_dueDateFormat.format(bill.dueDate)),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionStatusColWidth,
          child: PurchaseBillStatusBadge(status: bill.status),
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

class _TableHeaderRow extends ConsumerWidget {
  const _TableHeaderRow();

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return PurchaseTransactionTableHeaderRow(
      children: [
        PurchaseTransactionTableCell(
          width: purchaseTransactionDateColWidth,
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
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionInvoiceColWidth,
          child: purchaseColumnFilterCell(
            label: 'Invoice no',
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
            documentNoHint: 'Invoice number',
          ),
        ),
        Expanded(
          child: PurchaseTransactionTableCell(
            child: purchaseColumnFilterCell(
              label: 'Party Name',
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
          width: purchaseTransactionPaymentColWidth,
          child: purchaseColumnFilterCell(
            label: 'Payment Type',
            kind: PurchaseColumnFilterKind.paymentType,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.paymentType,
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
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionBalanceColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'Balance Due',
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
            statusOptions: purchaseBillStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: purchaseTransactionStatusColWidth,
          child: purchaseColumnFilterCell(
            label: 'Status',
            kind: PurchaseColumnFilterKind.status,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.status,
              columns,
              selectedStatus: filters.selectedStatus,
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
          child: Text(
            'Actions',
            style: purchaseTransactionTableHeaderStyle,
          ),
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
