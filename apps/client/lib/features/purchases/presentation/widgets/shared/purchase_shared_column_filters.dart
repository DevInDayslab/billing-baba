import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';

const purchaseBillStatusOptions = [
  'All Status',
  'Cancelled',
  'Paid',
  'Overdue',
  'Unpaid',
  'Partial',
];

const purchaseFaStatusOptions = [
  'All Status',
  'Paid',
  'Unpaid',
  'Partially Paid',
  'Partial',
  'Overdue',
  'Cancelled',
];

const purchaseOrderStatusOptions = [
  'All Status',
  'Open',
  'Order Completed',
  'Partially Received',
  'Cancelled',
];

const paymentOutStatusOptions = [
  'All Status',
  'Paid',
  'Pending',
  'Cancelled',
];

enum PurchaseColumnFilterKind {
  date,
  dueDate,
  documentNo,
  partyName,
  paymentType,
  amount,
  balanceDue,
  status,
  totalAmount,
  paidAmount,
  categoryName,
  typeName,
  receivedPaid,
}

class PurchaseColumnFilterActions {
  const PurchaseColumnFilterActions({
    required this.onDocumentNo,
    required this.onParty,
    required this.onTogglePaymentType,
    required this.onClearPaymentTypes,
    required this.onApplyAmountFilter,
    required this.onClearAmountFilter,
    required this.onApplyBalanceFilter,
    required this.onClearBalanceFilter,
    required this.onStatus,
    this.onApplyTotalAmountFilter,
    this.onClearTotalAmountFilter,
    this.onApplyPaidAmountFilter,
    this.onClearPaidAmountFilter,
    this.onCategory,
    this.onType,
    this.onApplyReceivedPaidFilter,
    this.onClearReceivedPaidFilter,
    this.onDateRange,
    this.onDueDateRange,
    this.onClearDateRange,
    this.onClearDueDateRange,
  });

  final ValueChanged<String> onDocumentNo;
  final ValueChanged<String> onParty;
  final ValueChanged<String> onTogglePaymentType;
  final VoidCallback onClearPaymentTypes;
  final ValueChanged<PurchaseNumericFilter> onApplyAmountFilter;
  final VoidCallback onClearAmountFilter;
  final ValueChanged<PurchaseNumericFilter> onApplyBalanceFilter;
  final VoidCallback onClearBalanceFilter;
  final ValueChanged<String> onStatus;
  final ValueChanged<PurchaseNumericFilter>? onApplyTotalAmountFilter;
  final VoidCallback? onClearTotalAmountFilter;
  final ValueChanged<PurchaseNumericFilter>? onApplyPaidAmountFilter;
  final VoidCallback? onClearPaidAmountFilter;
  final ValueChanged<String>? onCategory;
  final ValueChanged<String>? onType;
  final ValueChanged<PurchaseNumericFilter>? onApplyReceivedPaidFilter;
  final VoidCallback? onClearReceivedPaidFilter;
  final ValueChanged<DateTimeRange>? onDateRange;
  final ValueChanged<DateTimeRange>? onDueDateRange;
  final VoidCallback? onClearDateRange;
  final VoidCallback? onClearDueDateRange;
}

bool purchaseColumnFilterIsActive(
  PurchaseColumnFilterKind kind,
  PurchaseColumnFilterFields columns, {
  String statusAllLabel = 'All Status',
  String? selectedStatus,
}) {
  return switch (kind) {
    PurchaseColumnFilterKind.date => columns.columnDateRange != null,
    PurchaseColumnFilterKind.dueDate => columns.dueDateRange != null,
    PurchaseColumnFilterKind.documentNo =>
      columns.documentNoFilter.trim().isNotEmpty,
    PurchaseColumnFilterKind.partyName =>
      columns.selectedParty != 'All Parties',
    PurchaseColumnFilterKind.paymentType =>
      columns.selectedPaymentTypes.isNotEmpty,
    PurchaseColumnFilterKind.amount => columns.amountFilter != null,
    PurchaseColumnFilterKind.balanceDue => columns.balanceFilter != null,
    PurchaseColumnFilterKind.status =>
      selectedStatus != null && selectedStatus != statusAllLabel,
    PurchaseColumnFilterKind.totalAmount => columns.totalAmountFilter != null,
    PurchaseColumnFilterKind.paidAmount => columns.paidAmountFilter != null,
    PurchaseColumnFilterKind.categoryName =>
      columns.selectedCategory != 'All Categories',
    PurchaseColumnFilterKind.typeName => columns.selectedType != 'All Types',
    PurchaseColumnFilterKind.receivedPaid => columns.receivedPaidFilter != null,
  };
}

bool purchaseColumnStatusFilterIsActive(
  String selectedStatus, {
  String allLabel = 'All Status',
}) => selectedStatus != allLabel;

List<String> purchasePartyOptionsFromNames(Iterable<String> names) {
  final parties = names.toSet().toList()..sort();
  return ['All Parties', ...parties];
}

/// Drop-in shared filter trigger for purchase table column headers.
Widget purchaseColumnFilterCell({
  required String label,
  required PurchaseColumnFilterKind kind,
  required TextStyle headerStyle,
  required bool isActive,
  required PurchaseColumnFilterFields columns,
  required PurchaseColumnFilterActions actions,
  required List<String> partyOptions,
  required List<String> statusOptions,
  required String selectedStatus,
  double? width,
  Alignment alignment = Alignment.centerLeft,
  double gapAfter = 0,
  String documentNoHint = 'Search',
  List<String>? paymentTypeOptions,
  List<String>? categoryOptions,
  List<String>? typeOptions,
}) {
  final paymentOptions = paymentTypeOptions ?? SaleDropdownOptions.paymentTypes;
  final config = _configForKind(
    kind: kind,
    label: label,
    documentNoHint: documentNoHint,
    partyOptions: partyOptions,
    statusOptions: statusOptions,
    paymentOptions: paymentOptions,
    categoryOptions: categoryOptions ?? const ['All Categories'],
    typeOptions: typeOptions ?? const ['All Types'],
  );

  final trigger = TableColumnFilterTrigger(
    config: config,
    headerStyle: headerStyle,
    alignment: alignment,
    initialValue: _initialValueForKind(
      kind: kind,
      columns: columns,
      selectedStatus: selectedStatus,
    ),
    onApply: (result) => _applyResultForKind(
      kind: kind,
      result: result,
      actions: actions,
      columns: columns,
    ),
  );

  Widget child = trigger;
  if (width != null) {
    child = SizedBox(width: width, child: child);
  }
  if (gapAfter > 0) {
    child = Padding(
      padding: EdgeInsets.only(right: gapAfter),
      child: child,
    );
  }
  return child;
}

ColumnFilter _configForKind({
  required PurchaseColumnFilterKind kind,
  required String label,
  required String documentNoHint,
  required List<String> partyOptions,
  required List<String> statusOptions,
  required List<String> paymentOptions,
  required List<String> categoryOptions,
  required List<String> typeOptions,
}) {
  return switch (kind) {
    PurchaseColumnFilterKind.documentNo => ColumnFilter(
      id: 'documentNo',
      title: label,
      type: FilterType.text,
      hintText: documentNoHint,
    ),
    PurchaseColumnFilterKind.partyName => ColumnFilter(
      id: 'partyName',
      title: label,
      type: FilterType.singleSelect,
      values: partyOptions,
    ),
    PurchaseColumnFilterKind.paymentType => ColumnFilter(
      id: 'paymentType',
      title: label,
      type: FilterType.multiSelect,
      values: paymentOptions,
      searchable: false,
    ),
    PurchaseColumnFilterKind.amount => ColumnFilter(
      id: 'amount',
      title: label,
      type: FilterType.number,
    ),
    PurchaseColumnFilterKind.balanceDue => ColumnFilter(
      id: 'balanceDue',
      title: label,
      type: FilterType.number,
    ),
    PurchaseColumnFilterKind.totalAmount => ColumnFilter(
      id: 'totalAmount',
      title: label,
      type: FilterType.number,
    ),
    PurchaseColumnFilterKind.paidAmount => ColumnFilter(
      id: 'paidAmount',
      title: label,
      type: FilterType.number,
    ),
    PurchaseColumnFilterKind.receivedPaid => ColumnFilter(
      id: 'receivedPaid',
      title: label,
      type: FilterType.number,
    ),
    PurchaseColumnFilterKind.status => ColumnFilter(
      id: 'status',
      title: label,
      type: FilterType.singleSelect,
      values: statusOptions,
    ),
    PurchaseColumnFilterKind.categoryName => ColumnFilter(
      id: 'categoryName',
      title: label,
      type: FilterType.singleSelect,
      values: categoryOptions,
    ),
    PurchaseColumnFilterKind.typeName => ColumnFilter(
      id: 'typeName',
      title: label,
      type: FilterType.singleSelect,
      values: typeOptions,
    ),
    PurchaseColumnFilterKind.date => ColumnFilter(
      id: 'date',
      title: label,
      type: FilterType.date,
    ),
    PurchaseColumnFilterKind.dueDate => ColumnFilter(
      id: 'dueDate',
      title: label,
      type: FilterType.date,
    ),
  };
}

Object? _initialValueForKind({
  required PurchaseColumnFilterKind kind,
  required PurchaseColumnFilterFields columns,
  required String selectedStatus,
}) {
  return switch (kind) {
    PurchaseColumnFilterKind.documentNo =>
      columns.documentNoFilter.trim().isEmpty
          ? null
          : TextColumnFilter(
              operator: TextColumnOperator.contains,
              value: columns.documentNoFilter,
            ),
    PurchaseColumnFilterKind.partyName =>
      columns.selectedParty == 'All Parties'
          ? null
          : SelectColumnFilter(value: columns.selectedParty),
    PurchaseColumnFilterKind.paymentType =>
      columns.selectedPaymentTypes.isEmpty
          ? null
          : MultiSelectColumnFilter(values: columns.selectedPaymentTypes),
    PurchaseColumnFilterKind.amount => _numberFromPurchase(
      columns.amountFilter,
    ),
    PurchaseColumnFilterKind.balanceDue => _numberFromPurchase(
      columns.balanceFilter,
    ),
    PurchaseColumnFilterKind.totalAmount => _numberFromPurchase(
      columns.totalAmountFilter,
    ),
    PurchaseColumnFilterKind.paidAmount => _numberFromPurchase(
      columns.paidAmountFilter,
    ),
    PurchaseColumnFilterKind.receivedPaid => _numberFromPurchase(
      columns.receivedPaidFilter,
    ),
    PurchaseColumnFilterKind.status =>
      selectedStatus == 'All Status'
          ? null
          : SelectColumnFilter(value: selectedStatus),
    PurchaseColumnFilterKind.categoryName =>
      columns.selectedCategory == 'All Categories'
          ? null
          : SelectColumnFilter(value: columns.selectedCategory),
    PurchaseColumnFilterKind.typeName =>
      columns.selectedType == 'All Types'
          ? null
          : SelectColumnFilter(value: columns.selectedType),
    PurchaseColumnFilterKind.date => _dateFromRange(columns.columnDateRange),
    PurchaseColumnFilterKind.dueDate => _dateFromRange(columns.dueDateRange),
  };
}

void _applyResultForKind({
  required PurchaseColumnFilterKind kind,
  required FilterResult? result,
  required PurchaseColumnFilterActions actions,
  required PurchaseColumnFilterFields columns,
}) {
  switch (kind) {
    case PurchaseColumnFilterKind.documentNo:
      final filter = FilterUtils.fromResult(result) as TextColumnFilter?;
      actions.onDocumentNo(filter?.value.trim() ?? '');
    case PurchaseColumnFilterKind.partyName:
      final filter = FilterUtils.fromResult(result) as SelectColumnFilter?;
      actions.onParty(filter?.value ?? 'All Parties');
    case PurchaseColumnFilterKind.paymentType:
      final filter = FilterUtils.fromResult(result) as MultiSelectColumnFilter?;
      actions.onClearPaymentTypes();
      for (final value in filter?.values ?? const <String>{}) {
        actions.onTogglePaymentType(value);
      }
    case PurchaseColumnFilterKind.amount:
      _applyNumeric(
        result,
        onApply: actions.onApplyAmountFilter,
        onClear: actions.onClearAmountFilter,
      );
    case PurchaseColumnFilterKind.balanceDue:
      _applyNumeric(
        result,
        onApply: actions.onApplyBalanceFilter,
        onClear: actions.onClearBalanceFilter,
      );
    case PurchaseColumnFilterKind.totalAmount:
      _applyNumeric(
        result,
        onApply:
            actions.onApplyTotalAmountFilter ?? actions.onApplyAmountFilter,
        onClear:
            actions.onClearTotalAmountFilter ?? actions.onClearAmountFilter,
      );
    case PurchaseColumnFilterKind.paidAmount:
      _applyNumeric(
        result,
        onApply: actions.onApplyPaidAmountFilter ?? actions.onApplyAmountFilter,
        onClear: actions.onClearPaidAmountFilter ?? actions.onClearAmountFilter,
      );
    case PurchaseColumnFilterKind.receivedPaid:
      _applyNumeric(
        result,
        onApply:
            actions.onApplyReceivedPaidFilter ?? actions.onApplyAmountFilter,
        onClear:
            actions.onClearReceivedPaidFilter ?? actions.onClearAmountFilter,
      );
    case PurchaseColumnFilterKind.status:
      final filter = FilterUtils.fromResult(result) as SelectColumnFilter?;
      actions.onStatus(filter?.value ?? 'All Status');
    case PurchaseColumnFilterKind.categoryName:
      final filter = FilterUtils.fromResult(result) as SelectColumnFilter?;
      actions.onCategory?.call(filter?.value ?? 'All Categories');
    case PurchaseColumnFilterKind.typeName:
      final filter = FilterUtils.fromResult(result) as SelectColumnFilter?;
      actions.onType?.call(filter?.value ?? 'All Types');
    case PurchaseColumnFilterKind.date:
      final range = _rangeFromDateResult(result);
      if (range == null) {
        actions.onClearDateRange?.call();
      } else {
        actions.onDateRange?.call(range);
      }
    case PurchaseColumnFilterKind.dueDate:
      final range = _rangeFromDateResult(result);
      if (range == null) {
        actions.onClearDueDateRange?.call();
      } else {
        actions.onDueDateRange?.call(range);
      }
  }
}

NumberColumnFilter? _numberFromPurchase(PurchaseNumericFilter? filter) {
  if (filter == null) return null;
  return NumberColumnFilter(
    operator: switch (filter.operator) {
      PurchaseNumericFilterOperator.equalTo => NumberColumnOperator.equalTo,
      PurchaseNumericFilterOperator.lessThan => NumberColumnOperator.lessThan,
      PurchaseNumericFilterOperator.greaterThan =>
        NumberColumnOperator.greaterThan,
    },
    value: filter.value,
  );
}

void _applyNumeric(
  FilterResult? result, {
  required ValueChanged<PurchaseNumericFilter> onApply,
  required VoidCallback onClear,
}) {
  final filter = FilterUtils.fromResult(result) as NumberColumnFilter?;
  if (filter == null) {
    onClear();
    return;
  }
  onApply(
    PurchaseNumericFilter(
      operator: switch (filter.operator) {
        NumberColumnOperator.equalTo => PurchaseNumericFilterOperator.equalTo,
        NumberColumnOperator.lessThan => PurchaseNumericFilterOperator.lessThan,
        NumberColumnOperator.greaterThan =>
          PurchaseNumericFilterOperator.greaterThan,
      },
      value: filter.value,
    ),
  );
}

DateColumnFilter? _dateFromRange(DateTimeRange? range) {
  if (range == null) return null;
  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(range.end.year, range.end.month, range.end.day);
  if (start == end) {
    return DateColumnFilter(
      operator: DateColumnOperator.equalTo,
      date: start,
    );
  }
  return DateColumnFilter(
    operator: DateColumnOperator.range,
    startDate: start,
    endDate: end,
  );
}

DateTimeRange? _rangeFromDateResult(FilterResult? result) {
  final filter = FilterUtils.fromResult(result) as DateColumnFilter?;
  if (filter == null || !filter.isActive) return null;

  return switch (filter.operator) {
    DateColumnOperator.equalTo => DateTimeRange(
      start: _day(filter.date!),
      end: _day(filter.date!),
    ),
    DateColumnOperator.lessThan => DateTimeRange(
      start: DateTime(2000),
      end: _day(filter.date!).subtract(const Duration(days: 1)),
    ),
    DateColumnOperator.greaterThan => DateTimeRange(
      start: _day(filter.date!).add(const Duration(days: 1)),
      end: DateTime(2100, 12, 31),
    ),
    DateColumnOperator.range => DateTimeRange(
      start: _day(filter.startDate!),
      end: _day(filter.endDate!),
    ),
  };
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
