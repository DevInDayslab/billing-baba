import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';
import 'package:flutter/material.dart';

export 'report_table_scopes.dart';
export 'report_transaction_table_shared.dart';

ReportColumnSpec<T> _textCol<T>({
  required String id,
  required String label,
  required Object? Function(T row) value,
  required Widget Function(T row) child,
  double? width,
  int flex = 0,
  Alignment alignment = Alignment.centerLeft,
  String? hintText,
  List<String> options = const [],
}) {
  return ReportColumnSpec(
    id: id,
    label: label,
    filterType: options.isEmpty ? FilterType.text : FilterType.singleSelect,
    filterOptions: options,
    hintText: hintText,
    width: width,
    flex: flex,
    alignment: alignment,
    filterValue: value,
    buildCell: (row, _) => width != null
        ? ReportAlignedCell.fixed(width, alignment: alignment, child: child(row))
        : ReportAlignedCell.flex(alignment: alignment, child: child(row)),
  );
}

ReportColumnSpec<T> _numberCol<T>({
  required String id,
  required String label,
  required Object? Function(T row) value,
  required Widget Function(T row) child,
  double? width,
  int flex = 0,
  Alignment alignment = Alignment.centerRight,
}) {
  return ReportColumnSpec(
    id: id,
    label: label,
    filterType: FilterType.number,
    width: width,
    flex: flex,
    alignment: alignment,
    filterValue: value,
    buildCell: (row, _) => width != null
        ? ReportAlignedCell.fixed(width, alignment: alignment, child: child(row))
        : ReportAlignedCell.flex(alignment: alignment, child: child(row)),
  );
}

ReportColumnSpec<T> _dateCol<T>({
  required String id,
  required String label,
  required DateTime Function(T row) value,
  required Widget Function(T row) child,
  double? width,
  int flex = 0,
}) {
  return ReportColumnSpec(
    id: id,
    label: label,
    filterType: FilterType.date,
    width: width,
    flex: flex,
    filterValue: (row) => value(row),
    buildCell: (row, _) => width != null
        ? ReportAlignedCell.fixed(width, child: child(row))
        : ReportAlignedCell.flex(child: child(row)),
  );
}

Widget _currencyText(double amount, {bool hideZero = false}) {
  if (hideZero && amount == 0) return const Text('');
  return Text(formatReportCurrency(amount));
}

Widget _currencyCompact(double amount, {bool hideZero = false}) {
  if (hideZero && amount == 0) return const Text('');
  return Text(formatReportCurrencyCompact(amount));
}

List<ReportColumnSpec<ReportStockSummaryRow>> stockSummaryColumns() => [
  _textCol(
    id: 'itemName',
    label: 'ITEM NAME',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _numberCol(
    id: 'salePrice',
    label: 'SALE PRICE',
    width: 110,
    value: (row) => row.salePrice,
    child: (row) => _currencyText(row.salePrice),
  ),
  _numberCol(
    id: 'purchasePrice',
    label: 'PURCHASE PRICE',
    width: 130,
    value: (row) => row.purchasePrice,
    child: (row) => _currencyText(row.purchasePrice),
  ),
  _numberCol(
    id: 'stockQty',
    label: 'STOCK QTY',
    width: 100,
    value: (row) => row.stockQty,
    alignment: Alignment.centerRight,
    child: (row) => Text(row.stockQty.toStringAsFixed(0)),
  ),
  _numberCol(
    id: 'stockValue',
    label: 'STOCK VALUE',
    width: 120,
    value: (row) => row.stockValue,
    child: (row) => _currencyText(row.stockValue),
  ),
];

List<ReportColumnSpec<ReportPartyStatementEntry>> partyStatementColumns({
  required bool accountingView,
}) {
  if (accountingView) {
    return [
      _dateCol(
        id: 'date',
        label: 'DATE',
        width: 100,
        value: (row) => row.date,
        child: (row) => Text(formatReportDate(row.date)),
      ),
      _textCol(
        id: 'type',
        label: 'TYPE',
        width: 100,
        value: (row) => row.type,
        child: (row) => Text(row.type),
      ),
      _textCol(
        id: 'refNo',
        label: 'REF NO',
        width: 100,
        value: (row) => row.refNo,
        child: (row) => Text(row.refNo),
      ),
      _numberCol(
        id: 'debit',
        label: 'DEBIT',
        width: 100,
        value: (row) => row.debit,
        child: (row) => _currencyText(row.debit, hideZero: true),
      ),
      _numberCol(
        id: 'credit',
        label: 'CREDIT',
        width: 100,
        value: (row) => row.credit,
        child: (row) => _currencyText(row.credit, hideZero: true),
      ),
      _numberCol(
        id: 'balance',
        label: 'BALANCE',
        width: 110,
        value: (row) => row.balance,
        child: (row) => _currencyText(row.balance),
      ),
    ];
  }

  return [
    _dateCol(
      id: 'date',
      label: 'DATE',
      width: 100,
      value: (row) => row.date,
      child: (row) => Text(formatReportDate(row.date)),
    ),
    _textCol(
      id: 'type',
      label: 'TYPE',
      width: 100,
      value: (row) => row.type,
      child: (row) => Text(row.type),
    ),
    _textCol(
      id: 'refNo',
      label: 'REF NO',
      width: 100,
      value: (row) => row.refNo,
      child: (row) => Text(row.refNo),
    ),
    _numberCol(
      id: 'total',
      label: 'TOTAL',
      width: 100,
      value: (row) => row.total,
      child: (row) => _currencyText(row.total),
    ),
    _numberCol(
      id: 'balance',
      label: 'BALANCE',
      width: 110,
      value: (row) => row.balance,
      child: (row) => _currencyText(row.balance),
    ),
  ];
}

List<ReportColumnSpec<PartyModel>> allPartiesColumns() => [
  ReportColumnSpec(
    id: 'index',
    label: '#',
    filterType: FilterType.text,
    width: 40,
    showFilter: false,
    filterValue: (_) => '',
    buildCell: (_, index) => ReportAlignedCell.fixed(40, child: Text('${index + 1}')),
  ),
  _textCol(
    id: 'name',
    label: 'PARTY NAME',
    flex: 1,
    value: (row) => row.name,
    child: (row) => Text(row.name),
  ),
  _textCol(
    id: 'email',
    label: 'EMAIL',
    width: 140,
    value: (row) => row.email,
    child: (row) => Text(row.email.isEmpty ? '—' : row.email),
  ),
  _textCol(
    id: 'phone',
    label: 'PHONE NO.',
    width: 110,
    value: (row) => row.phone,
    child: (row) => Text(row.phone),
  ),
  _numberCol(
    id: 'receivable',
    label: 'RECEIVABLE BALANCE',
    width: 140,
    value: (row) => row.balance > 0 ? row.balance : 0,
    child: (row) => Text(row.balance > 0 ? formatReportCurrency(row.balance) : '—'),
  ),
  _numberCol(
    id: 'payable',
    label: 'PAYABLE BALANCE',
    width: 130,
    value: (row) => row.balance < 0 ? row.balance.abs() : 0,
    child: (row) => Text(row.balance < 0 ? formatReportCurrency(row.balance.abs()) : '—'),
  ),
  _textCol(
    id: 'creditLimit',
    label: 'CREDIT LIMIT',
    width: 110,
    alignment: Alignment.centerRight,
    value: (row) => row.creditLimit,
    child: (row) => Text(
      row.creditLimit.isEmpty
          ? '—'
          : formatReportCurrency(double.tryParse(row.creditLimit) ?? 0),
    ),
  ),
];

List<ReportColumnSpec<ReportTransactionRow>> dayBookColumns({
  required List<String> exportHeaders,
  required List<String> Function(ReportTransactionRow row) exportRow,
}) => [
  _textCol(
    id: 'partyName',
    label: 'NAME',
    flex: 1,
    value: (row) => row.partyName,
    child: (row) => Text(row.partyName),
  ),
  _textCol(
    id: 'refNo',
    label: 'REF NO.',
    width: 100,
    value: (row) => row.refNo,
    child: (row) => Text(row.refNo),
  ),
  _textCol(
    id: 'type',
    label: 'TYPE',
    width: 90,
    value: (row) => row.type,
    child: (row) => Text(row.type),
  ),
  _numberCol(
    id: 'total',
    label: 'TOTAL',
    width: 90,
    value: (row) => row.total,
    child: (row) => _currencyCompact(row.total),
  ),
  _numberCol(
    id: 'moneyIn',
    label: 'MONEY IN',
    width: 100,
    value: (row) => row.moneyIn,
    child: (row) => _currencyCompact(row.moneyIn, hideZero: true),
  ),
  _numberCol(
    id: 'moneyOut',
    label: 'MONEY OUT',
    width: 100,
    value: (row) => row.moneyOut,
    child: (row) => _currencyCompact(row.moneyOut, hideZero: true),
  ),
  ReportColumnSpec(
    id: 'actions',
    label: 'PRINT/ SHARE',
    filterType: FilterType.text,
    width: 110,
    showFilter: false,
    filterValue: (_) => '',
    buildCell: (_, __) => const ReportAlignedCell.fixed(
      110,
      child: Text('—', style: TextStyle(color: AppColors.textSecondary)),
    ),
  ),
];

List<ReportColumnSpec<ReportCashFlowTableRow>> cashFlowColumns({
  required List<String> exportHeaders,
  required List<String> Function(ReportCashFlowTableRow row) exportRow,
}) => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 90,
    value: (row) => row.transaction.date,
    child: (row) => Text(formatReportDate(row.transaction.date)),
  ),
  _textCol(
    id: 'refNo',
    label: 'REF NO.',
    width: 90,
    value: (row) => row.transaction.refNo,
    child: (row) => Text(row.transaction.refNo),
  ),
  _textCol(
    id: 'partyName',
    label: 'NAME',
    flex: 1,
    value: (row) => row.transaction.partyName,
    child: (row) => Text(row.transaction.partyName),
  ),
  _textCol(
    id: 'category',
    label: 'CATEGORY',
    width: 90,
    value: (row) => row.transaction.category,
    child: (row) => Text(row.transaction.category),
  ),
  _textCol(
    id: 'type',
    label: 'TYPE',
    width: 80,
    value: (row) => row.transaction.type,
    child: (row) => Text(row.transaction.type),
  ),
  _numberCol(
    id: 'moneyIn',
    label: 'CASH IN',
    width: 90,
    value: (row) => row.transaction.moneyIn,
    child: (row) => _currencyCompact(row.transaction.moneyIn, hideZero: true),
  ),
  _numberCol(
    id: 'moneyOut',
    label: 'CASH OUT',
    width: 90,
    value: (row) => row.transaction.moneyOut,
    child: (row) => _currencyCompact(row.transaction.moneyOut, hideZero: true),
  ),
  _numberCol(
    id: 'runningBalance',
    label: 'RUNNING BAL.',
    width: 100,
    value: (row) => row.runningBalance,
    child: (row) => _currencyCompact(row.runningBalance),
  ),
];

List<ReportColumnSpec<ReportBillWiseProfitRow>> billWiseProfitColumns({
  required List<String> exportHeaders,
  required List<String> Function(ReportBillWiseProfitRow row) exportRow,
}) => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 100,
    value: (row) => row.date,
    child: (row) => Text(formatReportDate(row.date)),
  ),
  _textCol(
    id: 'invoiceNo',
    label: 'INVOICE NO',
    width: 110,
    value: (row) => row.invoiceNo,
    child: (row) => Text(row.invoiceNo),
  ),
  _textCol(
    id: 'partyName',
    label: 'PARTY NAME',
    flex: 1,
    value: (row) => row.partyName,
    child: (row) => Text(row.partyName),
  ),
  _numberCol(
    id: 'saleAmount',
    label: 'SALE AMOUNT',
    width: 120,
    value: (row) => row.saleAmount,
    child: (row) => _currencyText(row.saleAmount),
  ),
  _numberCol(
    id: 'profit',
    label: 'PROFIT',
    width: 110,
    value: (row) => row.profit,
    child: (row) => _currencyText(row.profit),
  ),
];

List<ReportColumnSpec<ReportBankStatementRow>> bankStatementColumns() => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 100,
    value: (row) => row.date,
    child: (row) => Text(formatReportDate(row.date)),
  ),
  _textCol(
    id: 'description',
    label: 'DESCRIPTION',
    flex: 1,
    value: (row) => row.description,
    child: (row) => Text(row.description),
  ),
  _textCol(
    id: 'refNo',
    label: 'REF NO',
    width: 100,
    value: (row) => row.refNo,
    child: (row) => Text(row.refNo),
  ),
  _numberCol(
    id: 'moneyIn',
    label: 'MONEY IN',
    width: 100,
    value: (row) => row.moneyIn,
    child: (row) => _currencyText(row.moneyIn, hideZero: true),
  ),
  _numberCol(
    id: 'moneyOut',
    label: 'MONEY OUT',
    width: 100,
    value: (row) => row.moneyOut,
    child: (row) => _currencyText(row.moneyOut, hideZero: true),
  ),
  _numberCol(
    id: 'balance',
    label: 'BALANCE',
    width: 110,
    value: (row) => row.balance,
    child: (row) => _currencyText(row.balance),
  ),
];

List<ReportColumnSpec<ReportLoanStatementRow>> loanStatementColumns() => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 100,
    value: (row) => row.date,
    child: (row) => Text(formatReportDate(row.date)),
  ),
  _textCol(
    id: 'description',
    label: 'DESCRIPTION',
    flex: 1,
    value: (row) => row.description,
    child: (row) => Text(row.description),
  ),
  _textCol(
    id: 'refNo',
    label: 'REF NO',
    width: 100,
    value: (row) => row.refNo,
    child: (row) => Text(row.refNo),
  ),
  _numberCol(
    id: 'debit',
    label: 'DEBIT',
    width: 100,
    value: (row) => row.debit,
    child: (row) => _currencyText(row.debit, hideZero: true),
  ),
  _numberCol(
    id: 'credit',
    label: 'CREDIT',
    width: 100,
    value: (row) => row.credit,
    child: (row) => _currencyText(row.credit, hideZero: true),
  ),
  _numberCol(
    id: 'balance',
    label: 'BALANCE',
    width: 110,
    value: (row) => row.balance,
    child: (row) => _currencyText(row.balance),
  ),
];

List<ReportColumnSpec<ReportPartyWiseProfitLossRow>> partyWiseProfitLossColumns() =>
    [
      _textCol(
        id: 'partyName',
        label: 'PARTY NAME',
        flex: 1,
        value: (row) => row.partyName,
        child: (row) => Text(row.partyName),
      ),
      _textCol(
        id: 'phone',
        label: 'PHONE',
        width: 120,
        value: (row) => row.phone,
        child: (row) => Text(row.phone),
      ),
      _numberCol(
        id: 'saleAmount',
        label: 'SALE',
        width: 110,
        value: (row) => row.saleAmount,
        child: (row) => _currencyText(row.saleAmount),
      ),
      _numberCol(
        id: 'purchaseAmount',
        label: 'PURCHASE',
        width: 110,
        value: (row) => row.purchaseAmount,
        child: (row) => _currencyText(row.purchaseAmount),
      ),
      _numberCol(
        id: 'profit',
        label: 'PROFIT',
        width: 110,
        value: (row) => row.profit,
        child: (row) => _currencyText(row.profit),
      ),
    ];

List<ReportColumnSpec<ReportSalePurchaseByPartyTableRow>>
salePurchaseByPartyColumns() => [
  _textCol(
    id: 'partyName',
    label: 'PARTY NAME',
    flex: 1,
    value: (row) => row.row.partyName,
    child: (row) => Text(row.row.partyName),
  ),
  _numberCol(
    id: 'saleAmount',
    label: 'SALE',
    width: 120,
    value: (row) => row.row.saleAmount,
    child: (row) => _currencyText(row.row.saleAmount),
  ),
  _numberCol(
    id: 'purchaseAmount',
    label: 'PURCHASE',
    width: 120,
    value: (row) => row.row.purchaseAmount,
    child: (row) => _currencyText(row.row.purchaseAmount),
  ),
  _numberCol(
    id: 'receivable',
    label: 'RECEIVABLE',
    width: 120,
    value: (row) => (row.party?.balance ?? 0) > 0 ? row.party!.balance : 0,
    child: (row) {
      final balance = row.party?.balance ?? 0;
      return Text(balance > 0 ? formatReportCurrency(balance) : '—');
    },
  ),
  _numberCol(
    id: 'payable',
    label: 'PAYABLE',
    width: 120,
    value: (row) => (row.party?.balance ?? 0) < 0 ? row.party!.balance.abs() : 0,
    child: (row) {
      final balance = row.party?.balance ?? 0;
      return Text(balance < 0 ? formatReportCurrency(balance.abs()) : '—');
    },
  ),
];

List<ReportColumnSpec<ReportSalePurchaseByPartyGroupRow>>
salePurchaseByPartyGroupColumns() => [
  _textCol(
    id: 'partyGroup',
    label: 'PARTY GROUP',
    width: 140,
    value: (row) => row.partyGroup,
    child: (row) => Text(row.partyGroup),
  ),
  _textCol(
    id: 'partyName',
    label: 'PARTY NAME',
    flex: 1,
    value: (row) => row.partyName,
    child: (row) => Text(row.partyName),
  ),
  _numberCol(
    id: 'saleAmount',
    label: 'SALE',
    width: 120,
    value: (row) => row.saleAmount,
    child: (row) => _currencyText(row.saleAmount),
  ),
  _numberCol(
    id: 'purchaseAmount',
    label: 'PURCHASE',
    width: 120,
    value: (row) => row.purchaseAmount,
    child: (row) => _currencyText(row.purchaseAmount),
  ),
];

List<ReportColumnSpec<ReportPartyByItemRow>> partyReportByItemColumns() => [
  _textCol(
    id: 'partyName',
    label: 'PARTY NAME',
    flex: 1,
    value: (row) => row.partyName,
    child: (row) => Text(row.partyName),
  ),
  _numberCol(
    id: 'quantity',
    label: 'QUANTITY',
    width: 110,
    alignment: Alignment.centerRight,
    value: (row) => row.quantity,
    child: (row) => Text(row.quantity.toStringAsFixed(2)),
  ),
  _numberCol(
    id: 'amount',
    label: 'AMOUNT',
    width: 120,
    value: (row) => row.amount,
    child: (row) => _currencyText(row.amount),
  ),
];

List<ReportColumnSpec<ReportItemByPartyRow>> itemReportByPartyColumns() => [
  _textCol(
    id: 'itemName',
    label: 'ITEM NAME',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _textCol(
    id: 'partyName',
    label: 'PARTY NAME',
    width: 160,
    value: (row) => row.partyName,
    child: (row) => Text(row.partyName),
  ),
  _numberCol(
    id: 'quantity',
    label: 'QUANTITY',
    width: 100,
    alignment: Alignment.centerRight,
    value: (row) => row.quantity,
    child: (row) => Text(row.quantity.toStringAsFixed(2)),
  ),
  _numberCol(
    id: 'amount',
    label: 'AMOUNT',
    width: 120,
    value: (row) => row.amount,
    child: (row) => _currencyText(row.amount),
  ),
];

List<ReportColumnSpec<ReportItemWiseProfitLossRow>> itemWiseProfitLossColumns() =>
    [
      _textCol(
        id: 'itemName',
        label: 'ITEM NAME',
        flex: 1,
        value: (row) => row.itemName,
        child: (row) => Text(row.itemName),
      ),
      _numberCol(
        id: 'saleAmount',
        label: 'SALE',
        width: 120,
        value: (row) => row.saleAmount,
        child: (row) => _currencyText(row.saleAmount),
      ),
      _numberCol(
        id: 'purchaseAmount',
        label: 'PURCHASE',
        width: 120,
        value: (row) => row.purchaseAmount,
        child: (row) => _currencyText(row.purchaseAmount),
      ),
      _numberCol(
        id: 'profit',
        label: 'PROFIT',
        width: 120,
        value: (row) => row.profit,
        child: (row) => _currencyText(row.profit),
      ),
    ];

List<ReportColumnSpec<ReportCategoryAmountRow>>
itemCategoryWiseProfitLossColumns() => [
  _textCol(
    id: 'category',
    label: 'CATEGORY',
    flex: 1,
    value: (row) => row.category,
    child: (row) => Text(row.category),
  ),
  _numberCol(
    id: 'saleAmount',
    label: 'SALE',
    width: 120,
    value: (row) => row.saleAmount,
    child: (row) => _currencyText(row.saleAmount),
  ),
  _numberCol(
    id: 'purchaseAmount',
    label: 'PURCHASE',
    width: 120,
    value: (row) => row.purchaseAmount,
    child: (row) => _currencyText(row.purchaseAmount),
  ),
];

List<ReportColumnSpec<ReportCategoryAmountRow>> stockSummaryByCategoryColumns() =>
    itemCategoryWiseProfitLossColumns();

List<ReportColumnSpec<ReportCategoryAmountRow>> salePurchaseByCategoryColumns() =>
    itemCategoryWiseProfitLossColumns();

List<ReportColumnSpec<ReportLowStockRow>> lowStockColumns() => [
  _textCol(
    id: 'itemName',
    label: 'ITEM NAME',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _numberCol(
    id: 'minStock',
    label: 'MIN STOCK',
    width: 110,
    alignment: Alignment.centerRight,
    value: (row) => row.minStock,
    child: (row) => Text(row.minStock.toStringAsFixed(0)),
  ),
  _numberCol(
    id: 'currentStock',
    label: 'CURRENT STOCK',
    width: 120,
    alignment: Alignment.centerRight,
    value: (row) => row.currentStock,
    child: (row) => Text(row.currentStock.toStringAsFixed(0)),
  ),
  _numberCol(
    id: 'shortage',
    label: 'SHORTAGE',
    width: 110,
    alignment: Alignment.centerRight,
    value: (row) => row.shortage,
    child: (row) => Text(row.shortage.toStringAsFixed(0)),
  ),
];

List<ReportColumnSpec<ReportStockDetailRow>> stockDetailColumns() => [
  _textCol(
    id: 'itemName',
    label: 'ITEM NAME',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _numberCol(
    id: 'openingQty',
    label: 'OPENING',
    width: 100,
    alignment: Alignment.centerRight,
    value: (row) => row.openingQty,
    child: (row) => Text(row.openingQty.toStringAsFixed(0)),
  ),
  _numberCol(
    id: 'inQty',
    label: 'IN',
    width: 90,
    alignment: Alignment.centerRight,
    value: (row) => row.inQty,
    child: (row) => Text(row.inQty.toStringAsFixed(0)),
  ),
  _numberCol(
    id: 'outQty',
    label: 'OUT',
    width: 90,
    alignment: Alignment.centerRight,
    value: (row) => row.outQty,
    child: (row) => Text(row.outQty.toStringAsFixed(0)),
  ),
  _numberCol(
    id: 'closingQty',
    label: 'CLOSING',
    width: 100,
    alignment: Alignment.centerRight,
    value: (row) => row.closingQty,
    child: (row) => Text(row.closingQty.toStringAsFixed(0)),
  ),
];

List<ReportColumnSpec<ReportItemDetailTableRow>> itemDetailColumns() => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 100,
    value: (row) => row.row.date,
    child: (row) => Text(formatReportDate(row.row.date)),
  ),
  _textCol(
    id: 'type',
    label: 'TYPE',
    width: 90,
    value: (row) => row.row.type,
    child: (row) => Text(row.row.type),
  ),
  _textCol(
    id: 'refNo',
    label: 'REF NO',
    width: 100,
    value: (row) => row.row.refNo,
    child: (row) => Text(row.row.refNo),
  ),
  _textCol(
    id: 'partyName',
    label: 'PARTY',
    flex: 1,
    value: (row) => row.row.partyName,
    child: (row) => Text(row.row.partyName),
  ),
  _numberCol(
    id: 'quantity',
    label: 'QTY',
    width: 80,
    alignment: Alignment.centerRight,
    value: (row) => row.row.quantity,
    child: (row) => Text(row.row.quantity.toStringAsFixed(2)),
  ),
  _numberCol(
    id: 'price',
    label: 'PRICE',
    width: 90,
    value: (row) => row.row.price,
    child: (row) => _currencyText(row.row.price),
  ),
  _numberCol(
    id: 'amount',
    label: 'AMOUNT',
    width: 100,
    value: (row) => row.row.amount,
    child: (row) => _currencyText(row.row.amount),
  ),
  _numberCol(
    id: 'closingQty',
    label: 'CLOSING QTY',
    width: 110,
    alignment: Alignment.centerRight,
    value: (row) => row.closingQty,
    child: (row) => Text(row.closingQty.toStringAsFixed(2)),
  ),
];

List<ReportColumnSpec<ReportItemDiscountRow>> itemWiseDiscountColumns() => [
  _textCol(
    id: 'itemName',
    label: 'ITEM NAME',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _numberCol(
    id: 'saleQty',
    label: 'SALE QTY',
    width: 100,
    alignment: Alignment.centerRight,
    value: (row) => row.saleQty,
    child: (row) => Text(row.saleQty.toStringAsFixed(2)),
  ),
  _numberCol(
    id: 'discountAmount',
    label: 'DISCOUNT',
    width: 120,
    value: (row) => row.discountAmount,
    child: (row) => _currencyText(row.discountAmount),
  ),
  _numberCol(
    id: 'discountPercent',
    label: 'DISCOUNT %',
    width: 110,
    alignment: Alignment.centerRight,
    value: (row) => row.discountPercent,
    child: (row) => Text('${row.discountPercent.toStringAsFixed(1)}%'),
  ),
];

List<ReportColumnSpec<ReportManufacturingRow>> manufacturingColumns() => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 100,
    value: (row) => row.date,
    child: (row) => Text(formatReportDate(row.date)),
  ),
  _textCol(
    id: 'refNo',
    label: 'REF NO',
    width: 100,
    value: (row) => row.refNo,
    child: (row) => Text(row.refNo),
  ),
  _textCol(
    id: 'itemName',
    label: 'ITEM',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _numberCol(
    id: 'quantity',
    label: 'QTY',
    width: 90,
    alignment: Alignment.centerRight,
    value: (row) => row.quantity,
    child: (row) => Text(row.quantity.toStringAsFixed(2)),
  ),
  _numberCol(
    id: 'cost',
    label: 'COST',
    width: 110,
    value: (row) => row.cost,
    child: (row) => _currencyText(row.cost),
  ),
];

List<ReportColumnSpec<ReportConsumptionRow>> consumptionColumns() => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 100,
    value: (row) => row.date,
    child: (row) => Text(formatReportDate(row.date)),
  ),
  _textCol(
    id: 'refNo',
    label: 'REF NO',
    width: 100,
    value: (row) => row.refNo,
    child: (row) => Text(row.refNo),
  ),
  _textCol(
    id: 'itemName',
    label: 'ITEM',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _numberCol(
    id: 'quantity',
    label: 'QTY',
    width: 90,
    alignment: Alignment.centerRight,
    value: (row) => row.quantity,
    child: (row) => Text(row.quantity.toStringAsFixed(2)),
  ),
  _numberCol(
    id: 'value',
    label: 'VALUE',
    width: 110,
    value: (row) => row.value,
    child: (row) => _currencyText(row.value),
  ),
];

List<ReportColumnSpec<ReportStockTransferRow>> stockTransferColumns() => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 100,
    value: (row) => row.date,
    child: (row) => Text(formatReportDate(row.date)),
  ),
  _textCol(
    id: 'refNo',
    label: 'REF NO',
    width: 100,
    value: (row) => row.refNo,
    child: (row) => Text(row.refNo),
  ),
  _textCol(
    id: 'fromGodown',
    label: 'FROM',
    width: 120,
    value: (row) => row.fromGodown,
    child: (row) => Text(row.fromGodown),
  ),
  _textCol(
    id: 'toGodown',
    label: 'TO',
    width: 120,
    value: (row) => row.toGodown,
    child: (row) => Text(row.toGodown),
  ),
  _textCol(
    id: 'itemName',
    label: 'ITEM',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _numberCol(
    id: 'quantity',
    label: 'QTY',
    width: 90,
    alignment: Alignment.centerRight,
    value: (row) => row.quantity,
    child: (row) => Text(row.quantity.toStringAsFixed(2)),
  ),
];

List<ReportColumnSpec<ReportExpenseCategoryRow>> expenseCategoryReportColumns() =>
    [
      _textCol(
        id: 'category',
        label: 'EXPENSE CATEGORY',
        flex: 1,
        value: (row) => row.category,
        child: (row) => Text(row.category),
      ),
      ReportColumnSpec(
        id: 'categoryType',
        label: 'CATEGORY TYPE',
        filterType: FilterType.text,
        width: 180,
        showFilter: false,
        filterValue: (_) => 'Direct Expense',
        buildCell: (_, __) =>
            const ReportAlignedCell.fixed(180, child: Text('Direct Expense')),
      ),
      _numberCol(
        id: 'amount',
        label: 'AMOUNT',
        width: 140,
        value: (row) => row.amount,
        child: (row) => _currencyText(row.amount),
      ),
    ];

List<ReportColumnSpec<ReportExpenseItemRow>> expenseItemReportColumns() => [
  _textCol(
    id: 'itemName',
    label: 'ITEM',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _textCol(
    id: 'category',
    label: 'CATEGORY',
    width: 160,
    value: (row) => row.category,
    child: (row) => Text(row.category),
  ),
  _numberCol(
    id: 'amount',
    label: 'AMOUNT',
    width: 120,
    value: (row) => row.amount,
    child: (row) => _currencyText(row.amount),
  ),
];

List<ReportColumnSpec<ReportOrderItemRow>> salePurchaseOrderItemColumns() => [
  _textCol(
    id: 'itemName',
    label: 'ITEM',
    flex: 1,
    value: (row) => row.itemName,
    child: (row) => Text(row.itemName),
  ),
  _textCol(
    id: 'orderNo',
    label: 'ORDER NO',
    width: 110,
    value: (row) => row.orderNo,
    child: (row) => Text(row.orderNo),
  ),
  _textCol(
    id: 'partyName',
    label: 'PARTY',
    width: 150,
    value: (row) => row.partyName,
    child: (row) => Text(row.partyName),
  ),
  _numberCol(
    id: 'quantity',
    label: 'QTY',
    width: 90,
    alignment: Alignment.centerRight,
    value: (row) => row.quantity,
    child: (row) => Text(row.quantity.toStringAsFixed(2)),
  ),
  _numberCol(
    id: 'amount',
    label: 'AMOUNT',
    width: 110,
    value: (row) => row.amount,
    child: (row) => _currencyText(row.amount),
  ),
];

List<ReportColumnSpec<ReportOtherIncomeRow>> otherIncomeReportColumns() => [
  _dateCol(
    id: 'date',
    label: 'DATE',
    width: 100,
    value: (row) => row.date,
    child: (row) => Text(formatReportDate(row.date)),
  ),
  _textCol(
    id: 'incomeNo',
    label: 'INCOME NO',
    width: 110,
    value: (row) => row.incomeNo,
    child: (row) => Text(row.incomeNo),
  ),
  _textCol(
    id: 'partyName',
    label: 'PARTY',
    flex: 1,
    value: (row) => row.partyName,
    child: (row) => Text(row.partyName),
  ),
  _textCol(
    id: 'category',
    label: 'CATEGORY',
    width: 120,
    value: (row) => row.category,
    child: (row) => Text(row.category),
  ),
  _numberCol(
    id: 'amount',
    label: 'AMOUNT',
    width: 110,
    value: (row) => row.amount,
    child: (row) => _currencyText(row.amount),
  ),
  _textCol(
    id: 'status',
    label: 'STATUS',
    width: 100,
    value: (row) => row.status,
    child: (row) => Text(row.status),
  ),
];

List<ReportColumnSpec<ReportOtherIncomeCategoryRow>>
otherIncomeCategoryReportColumns() => [
  _textCol(
    id: 'category',
    label: 'CATEGORY',
    flex: 1,
    value: (row) => row.category,
    child: (row) => Text(row.category),
  ),
  _numberCol(
    id: 'amount',
    label: 'AMOUNT',
    width: 140,
    value: (row) => row.amount,
    child: (row) => _currencyText(row.amount),
  ),
];

List<ReportColumnSpec<ReportOtherIncomeItemRow>> otherIncomeItemReportColumns() =>
    [
      _textCol(
        id: 'itemName',
        label: 'ITEM',
        flex: 1,
        value: (row) => row.itemName,
        child: (row) => Text(row.itemName),
      ),
      _textCol(
        id: 'category',
        label: 'CATEGORY',
        width: 160,
        value: (row) => row.category,
        child: (row) => Text(row.category),
      ),
      _numberCol(
        id: 'amount',
        label: 'AMOUNT',
        width: 120,
        value: (row) => row.amount,
        child: (row) => _currencyText(row.amount),
      ),
    ];

List<ReportColumnSpec<ReportGstTaxPartyRow>> gstTaxColumns() => [
  _textCol(
    id: 'partyName',
    label: 'PARTY NAME',
    flex: 1,
    value: (row) => row.partyName,
    child: (row) => Text(row.partyName),
  ),
  _numberCol(
    id: 'saleTax',
    label: 'SALE TAX',
    width: 120,
    value: (row) => row.saleTax,
    child: (row) => _currencyText(row.saleTax),
  ),
  _numberCol(
    id: 'purchaseExpenseTax',
    label: 'PURCHASE/EXPENSE TAX',
    width: 160,
    value: (row) => row.purchaseExpenseTax,
    child: (row) => _currencyText(row.purchaseExpenseTax),
  ),
];

List<ReportColumnSpec<ReportGstTaxRateRow>> gstTaxRateColumns() => [
  _textCol(
    id: 'taxName',
    label: 'TAX NAME',
    flex: 1,
    value: (row) => row.taxName,
    child: (row) => Text(row.taxName),
  ),
  _numberCol(
    id: 'taxPercent',
    label: 'RATE %',
    width: 90,
    alignment: Alignment.centerRight,
    value: (row) => row.taxPercent,
    child: (row) => Text('${row.taxPercent.toStringAsFixed(1)}%'),
  ),
  _numberCol(
    id: 'taxableSaleAmount',
    label: 'TAXABLE SALE',
    width: 120,
    value: (row) => row.taxableSaleAmount,
    child: (row) => _currencyText(row.taxableSaleAmount),
  ),
  _numberCol(
    id: 'taxIn',
    label: 'TAX IN',
    width: 100,
    value: (row) => row.taxIn,
    child: (row) => _currencyText(row.taxIn),
  ),
  _numberCol(
    id: 'taxOut',
    label: 'TAX OUT',
    width: 100,
    value: (row) => row.taxOut,
    child: (row) => _currencyText(row.taxOut),
  ),
];

List<ReportColumnSpec<ReportSacRow>> sacReportColumns() => [
  _textCol(
    id: 'sac',
    label: 'SAC',
    width: 100,
    value: (row) => row.sac,
    child: (row) => Text(row.sac),
  ),
  _textCol(
    id: 'invoiceType',
    label: 'INVOICE TYPE',
    width: 120,
    value: (row) => row.invoiceType,
    child: (row) => Text(row.invoiceType),
  ),
  _numberCol(
    id: 'totalValue',
    label: 'TOTAL VALUE',
    width: 120,
    value: (row) => row.totalValue,
    child: (row) => _currencyText(row.totalValue),
  ),
  _numberCol(
    id: 'taxableValue',
    label: 'TAXABLE VALUE',
    width: 130,
    value: (row) => row.taxableValue,
    child: (row) => _currencyText(row.taxableValue),
  ),
  _numberCol(
    id: 'igst',
    label: 'IGST',
    width: 100,
    value: (row) => row.igst,
    child: (row) => _currencyText(row.igst),
  ),
  _numberCol(
    id: 'cgst',
    label: 'CGST',
    width: 100,
    value: (row) => row.cgst,
    child: (row) => _currencyText(row.cgst),
  ),
  _numberCol(
    id: 'sgst',
    label: 'SGST',
    width: 100,
    value: (row) => row.sgst,
    child: (row) => _currencyText(row.sgst),
  ),
];

List<ReportColumnSpec<ReportGstr3bRow>> gstr3bColumns() => [
  _textCol(
    id: 'nature',
    label: 'NATURE OF SUPPLIES',
    flex: 1,
    value: (row) => row.nature,
    child: (row) => Text(row.nature),
  ),
  _numberCol(
    id: 'taxableValue',
    label: 'TAXABLE VALUE',
    width: 130,
    value: (row) => row.taxableValue,
    child: (row) => _currencyText(row.taxableValue),
  ),
  _numberCol(
    id: 'integratedTax',
    label: 'INTEGRATED TAX',
    width: 130,
    value: (row) => row.integratedTax,
    child: (row) => _currencyText(row.integratedTax),
  ),
  _numberCol(
    id: 'centralTax',
    label: 'CENTRAL TAX',
    width: 120,
    value: (row) => row.centralTax,
    child: (row) => _currencyText(row.centralTax),
  ),
  _numberCol(
    id: 'stateTax',
    label: 'STATE TAX',
    width: 120,
    value: (row) => row.stateTax,
    child: (row) => _currencyText(row.stateTax),
  ),
  _numberCol(
    id: 'cess',
    label: 'CESS',
    width: 100,
    value: (row) => row.cess,
    child: (row) => _currencyText(row.cess),
  ),
];
