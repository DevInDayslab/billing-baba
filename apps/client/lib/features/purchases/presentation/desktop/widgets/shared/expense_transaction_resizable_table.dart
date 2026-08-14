import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/expense_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _expenseTableHeaderStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
);

PurchaseColumnFilterActions expenseTransactionFilterActions(
  ExpenseFilters notifier,
) {
  return PurchaseColumnFilterActions(
    onDateRange: notifier.setColumnDateRange,
    onDueDateRange: notifier.setDueDateRange,
    onClearDateRange: notifier.clearColumnDateRange,
    onClearDueDateRange: notifier.clearDueDateRange,
    onDocumentNo: notifier.setDocumentNo,
    onParty: notifier.setParty,
    onTogglePaymentType: notifier.togglePaymentType,
    onClearPaymentTypes: notifier.clearPaymentTypes,
    onApplyAmountFilter: notifier.applyAmountFilter,
    onClearAmountFilter: notifier.clearAmountFilter,
    onApplyBalanceFilter: notifier.applyBalanceFilter,
    onClearBalanceFilter: notifier.clearBalanceFilter,
    onStatus: notifier.setStatus,
  );
}

class ExpenseResizableTable extends ConsumerWidget {
  const ExpenseResizableTable({
    required this.transactions,
    this.variant = ExpenseCategoryVariant.standard,
    super.key,
  });

  final List<ExpenseTransactionModel> transactions;
  final ExpenseCategoryVariant variant;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy, HH:mm');
  static final _dueDateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(expenseFiltersProvider);
    final notifier = ref.read(expenseFiltersProvider.notifier);
    final partyOptions = ref.watch(expenseTransactionPartyOptionsProvider);
    final actions = expenseTransactionFilterActions(notifier);

    final tableColumns = switch (variant) {
      ExpenseCategoryVariant.loyaltyRedeemed => _buildLoyaltyColumns(
        filters,
        notifier,
        partyOptions,
      ),
      ExpenseCategoryVariant.paymentInDiscount =>
        _buildPaymentInDiscountColumns(
          filters,
          notifier,
          partyOptions,
          actions,
        ),
      ExpenseCategoryVariant.standard => _buildStandardColumns(
        filters,
        notifier,
        partyOptions,
        actions,
        ref,
      ),
    };

    final rows = [
      for (var i = 0; i < transactions.length; i++)
        ResizableDataRow(
          onTap: transactions[i].isSyncManaged
              ? null
              : () => context.push(
                  '${AppRoutes.editExpense}/${transactions[i].id}',
                ),
          backgroundColor: i.isOdd ? _zebraRowBg : Colors.transparent,
          cells: switch (variant) {
            ExpenseCategoryVariant.loyaltyRedeemed => _loyaltyCells(
              transactions[i],
            ),
            ExpenseCategoryVariant.paymentInDiscount => _paymentInDiscountCells(
              transactions[i],
            ),
            ExpenseCategoryVariant.standard => _standardCells(transactions[i]),
          },
        ),
    ];

    return SingleChildScrollView(
      child: ResizableDataTable(columns: tableColumns, rows: rows),
    );
  }

  List<ResizableDataColumn> _buildStandardColumns(
    ExpenseFiltersState filters,
    ExpenseFilters notifier,
    List<String> partyOptions,
    PurchaseColumnFilterActions actions,
    WidgetRef ref,
  ) {
    final columns = filters.columnFilters;

    Widget filterHeader(
      String label,
      PurchaseColumnFilterKind kind, {
      Alignment alignment = Alignment.centerLeft,
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
        statusOptions: expenseTransactionStatusOptions,
        selectedStatus: filters.selectedStatus,
        alignment: alignment,
      );
    }

    return [
      ResizableDataColumn(
        initialWidth: expenseTransactionDateColWidth,
        minWidth: 80,
        header: filterHeader('DATE', PurchaseColumnFilterKind.date),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionInvoiceColWidth,
        minWidth: 80,
        header: purchaseColumnFilterCell(
          label: 'EXP NO.',
          kind: PurchaseColumnFilterKind.documentNo,
          headerStyle: purchaseTransactionTableHeaderStyle,
          isActive: purchaseColumnFilterIsActive(
            PurchaseColumnFilterKind.documentNo,
            columns,
            selectedStatus: filters.selectedStatus,
          ),
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: expenseTransactionStatusOptions,
          selectedStatus: filters.selectedStatus,
          documentNoHint: 'Search exp no',
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionPartyColMinWidth,
        minWidth: 100,
        maxWidth: 400,
        header: filterHeader('PARTY', PurchaseColumnFilterKind.partyName),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionPaymentColWidth,
        minWidth: 80,
        header: filterHeader(
          'PAYMENT TYPE',
          PurchaseColumnFilterKind.paymentType,
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionAmountColWidth,
        minWidth: 70,
        header: filterHeader(
          'AMOUNT',
          PurchaseColumnFilterKind.amount,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionBalanceColWidth,
        minWidth: 70,
        header: filterHeader(
          'BALANCE',
          PurchaseColumnFilterKind.balanceDue,
          alignment: Alignment.centerRight,
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionDueDateColWidth,
        minWidth: 80,
        header: filterHeader('DUE DATE', PurchaseColumnFilterKind.dueDate),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionStatusColWidth,
        minWidth: 70,
        resizable: false,
        header: filterHeader('STATUS', PurchaseColumnFilterKind.status),
      ),
    ];
  }

  List<ResizableDataColumn> _buildLoyaltyColumns(
    ExpenseFiltersState filters,
    ExpenseFilters notifier,
    List<String> partyOptions,
  ) {
    final columns = filters.columnFilters;
    final actions = expenseTransactionFilterActions(notifier);
    return [
      ResizableDataColumn(
        initialWidth: expenseTransactionDateColWidth,
        minWidth: 96,
        maxWidth: 280,
        header: purchaseColumnFilterCell(
          label: 'Date',
          kind: PurchaseColumnFilterKind.date,
          headerStyle: _expenseTableHeaderStyle,
          isActive: purchaseColumnFilterIsActive(
            PurchaseColumnFilterKind.date,
            columns,
          ),
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: expenseTransactionStatusOptions,
          selectedStatus: filters.selectedStatus,
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionInvoiceColWidth,
        header: purchaseColumnFilterCell(
          label: 'Transaction no.',
          kind: PurchaseColumnFilterKind.documentNo,
          headerStyle: _expenseTableHeaderStyle,
          isActive: purchaseColumnFilterIsActive(
            PurchaseColumnFilterKind.documentNo,
            columns,
          ),
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: expenseTransactionStatusOptions,
          selectedStatus: filters.selectedStatus,
          documentNoHint: 'Search transaction no',
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionPartyColMinWidth,
        minWidth: 100,
        maxWidth: 400,
        header: purchaseColumnFilterCell(
          label: 'Party',
          kind: PurchaseColumnFilterKind.partyName,
          headerStyle: _expenseTableHeaderStyle,
          isActive: purchaseColumnFilterIsActive(
            PurchaseColumnFilterKind.partyName,
            columns,
          ),
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: expenseTransactionStatusOptions,
          selectedStatus: filters.selectedStatus,
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionAmountColWidth,
        header: _plainHeaderCell('Loyalty redeemed in points'),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionAmountColWidth,
        resizable: false,
        header: _plainHeaderCell('Loyalty value redeemed'),
      ),
    ];
  }

  List<ResizableDataColumn> _buildPaymentInDiscountColumns(
    ExpenseFiltersState filters,
    ExpenseFilters notifier,
    List<String> partyOptions,
    PurchaseColumnFilterActions actions,
  ) {
    final columns = filters.columnFilters;
    return [
      ResizableDataColumn(
        initialWidth: expenseTransactionDateColWidth,
        minWidth: 96,
        header: purchaseColumnFilterCell(
          label: 'Date',
          kind: PurchaseColumnFilterKind.date,
          headerStyle: _expenseTableHeaderStyle,
          isActive: purchaseColumnFilterIsActive(
            PurchaseColumnFilterKind.date,
            columns,
          ),
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: expenseTransactionStatusOptions,
          selectedStatus: filters.selectedStatus,
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionInvoiceColWidth,
        header: purchaseColumnFilterCell(
          label: 'Payment no.',
          kind: PurchaseColumnFilterKind.documentNo,
          headerStyle: _expenseTableHeaderStyle,
          isActive: purchaseColumnFilterIsActive(
            PurchaseColumnFilterKind.documentNo,
            columns,
          ),
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: expenseTransactionStatusOptions,
          selectedStatus: filters.selectedStatus,
          documentNoHint: 'Search payment no',
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionPartyColMinWidth,
        minWidth: 100,
        maxWidth: 400,
        header: purchaseColumnFilterCell(
          label: 'Party',
          kind: PurchaseColumnFilterKind.partyName,
          headerStyle: _expenseTableHeaderStyle,
          isActive: purchaseColumnFilterIsActive(
            PurchaseColumnFilterKind.partyName,
            columns,
          ),
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: expenseTransactionStatusOptions,
          selectedStatus: filters.selectedStatus,
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionPaymentColWidth,
        header: purchaseColumnFilterCell(
          label: 'Payment type',
          kind: PurchaseColumnFilterKind.paymentType,
          headerStyle: _expenseTableHeaderStyle,
          isActive: purchaseColumnFilterIsActive(
            PurchaseColumnFilterKind.paymentType,
            columns,
          ),
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: expenseTransactionStatusOptions,
          selectedStatus: filters.selectedStatus,
        ),
      ),
      ResizableDataColumn(
        initialWidth: expenseTransactionAmountColWidth,
        resizable: false,
        header: _plainHeaderCell('Discount amount'),
      ),
    ];
  }

  List<Widget> _standardCells(ExpenseTransactionModel tx) {
    return [
      _ExpenseDataCell(
        child: Text(
          tx.date.hour == 0 && tx.date.minute == 0
              ? _dateFormat.format(tx.date)
              : _dateTimeFormat.format(tx.date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _ExpenseDataCell(
        child: Text(tx.transactionNo, overflow: TextOverflow.ellipsis),
      ),
      _ExpenseDataCell(
        child: Text(tx.party, overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
      _ExpenseDataCell(
        child: Text(tx.paymentType ?? '', overflow: TextOverflow.ellipsis),
      ),
      _ExpenseDataCell(
        alignment: Alignment.centerRight,
        child: Text(
          _currencyFormat.format(tx.amount ?? 0),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
      ),
      _ExpenseDataCell(
        alignment: Alignment.centerRight,
        child: Text(
          _currencyFormat.format(tx.balance ?? 0),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
      ),
      _ExpenseDataCell(
        child: Text(
          tx.dueDate != null ? _dueDateFormat.format(tx.dueDate!) : '',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _ExpenseDataCell(
        child: tx.status != null
            ? ExpenseStatusBadge(status: tx.status!, plain: true)
            : const SizedBox.shrink(),
      ),
    ];
  }

  List<Widget> _loyaltyCells(ExpenseTransactionModel tx) {
    return [
      _ExpenseDataCell(
        child: Text(
          tx.date.hour == 0 && tx.date.minute == 0
              ? _dateFormat.format(tx.date)
              : _dateTimeFormat.format(tx.date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _ExpenseDataCell(
        child: Text(tx.transactionNo, overflow: TextOverflow.ellipsis),
      ),
      _ExpenseDataCell(
        child: Text(tx.party, overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
      _ExpenseDataCell(
        child: Text(
          '${tx.loyaltyPoints ?? 0}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _ExpenseDataCell(
        child: Text(
          _currencyFormat.format(tx.loyaltyValue ?? 0),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }

  List<Widget> _paymentInDiscountCells(ExpenseTransactionModel tx) {
    return [
      _ExpenseDataCell(
        child: Text(
          tx.date.hour == 0 && tx.date.minute == 0
              ? _dateFormat.format(tx.date)
              : _dateTimeFormat.format(tx.date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _ExpenseDataCell(
        child: Text(tx.transactionNo, overflow: TextOverflow.ellipsis),
      ),
      _ExpenseDataCell(
        child: Text(tx.party, overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
      _ExpenseDataCell(
        child: Text(tx.paymentType ?? '', overflow: TextOverflow.ellipsis),
      ),
      _ExpenseDataCell(
        alignment: Alignment.centerRight,
        child: Text(
          _currencyFormat.format(tx.amount ?? 0),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
      ),
    ];
  }

  Widget _plainHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: _expenseTableHeaderStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}

class _ExpenseDataCell extends StatelessWidget {
  const _ExpenseDataCell({
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
