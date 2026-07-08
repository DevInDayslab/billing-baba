import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_column_filter_cell.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
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

class PurchaseColumnFilterActions {
  const PurchaseColumnFilterActions({
    required this.onDocumentNo,
    required this.onParty,
    required this.onPaymentType,
    required this.onAmountRange,
    required this.onBalanceRange,
    required this.onStatus,
    this.onTotalAmountRange,
    this.onPaidAmountRange,
    this.onCategory,
    this.onType,
    this.onReceivedPaidRange,
    this.onDateRange,
    this.onDueDateRange,
  });

  final ValueChanged<String> onDocumentNo;
  final ValueChanged<String> onParty;
  final ValueChanged<String> onPaymentType;
  final void Function({double? min, double? max}) onAmountRange;
  final void Function({double? min, double? max}) onBalanceRange;
  final ValueChanged<String> onStatus;
  final void Function({double? min, double? max})? onTotalAmountRange;
  final void Function({double? min, double? max})? onPaidAmountRange;
  final ValueChanged<String>? onCategory;
  final ValueChanged<String>? onType;
  final void Function({double? min, double? max})? onReceivedPaidRange;
  final ValueChanged<DateTimeRange>? onDateRange;
  final ValueChanged<DateTimeRange>? onDueDateRange;
}

bool purchaseColumnFilterIsActive(
  PurchaseColumnFilterKind kind,
  PurchaseColumnFilterFields columns, {
  String statusAllLabel = 'All Status',
}) {
  return switch (kind) {
    PurchaseColumnFilterKind.date => columns.columnDateRange != null,
    PurchaseColumnFilterKind.dueDate => columns.dueDateRange != null,
    PurchaseColumnFilterKind.documentNo =>
      columns.documentNoFilter.trim().isNotEmpty,
    PurchaseColumnFilterKind.partyName =>
      columns.selectedParty != 'All Parties',
    PurchaseColumnFilterKind.paymentType =>
      columns.selectedPaymentType != 'All Payment Types',
    PurchaseColumnFilterKind.amount =>
      columns.amountMin != null || columns.amountMax != null,
    PurchaseColumnFilterKind.balanceDue =>
      columns.balanceMin != null || columns.balanceMax != null,
    PurchaseColumnFilterKind.status => false,
    PurchaseColumnFilterKind.totalAmount =>
      columns.totalAmountMin != null || columns.totalAmountMax != null,
    PurchaseColumnFilterKind.paidAmount =>
      columns.paidAmountMin != null || columns.paidAmountMax != null,
    PurchaseColumnFilterKind.categoryName =>
      columns.selectedCategory != 'All Categories',
    PurchaseColumnFilterKind.typeName => columns.selectedType != 'All Types',
    PurchaseColumnFilterKind.receivedPaid =>
      columns.receivedPaidMin != null || columns.receivedPaidMax != null,
  };
}

bool purchaseColumnStatusFilterIsActive(
  String selectedStatus, {
  String allLabel = 'All Status',
}) =>
    selectedStatus != allLabel;

Widget purchaseColumnFilterBuildPopup({
  required PurchaseColumnFilterKind kind,
  required PurchaseColumnFilterFields columns,
  required PurchaseColumnFilterActions actions,
  required List<String> partyOptions,
  required List<String> statusOptions,
  required String selectedStatus,
  required VoidCallback dismissAfterSelect,
  String documentNoHint = 'Search',
  String paymentTypeAllLabel = 'All Payment Types',
  List<String>? paymentTypeOptions,
  List<String>? categoryOptions,
  List<String>? typeOptions,
}) {
  final paymentOptions = [
    paymentTypeAllLabel,
    ...(paymentTypeOptions ?? SaleDropdownOptions.paymentTypes),
  ];

  return switch (kind) {
    PurchaseColumnFilterKind.documentNo => PurchaseColumnTextFilterPanel(
      hint: documentNoHint,
      initialValue: columns.documentNoFilter,
      onChanged: actions.onDocumentNo,
      onClear: () => actions.onDocumentNo(''),
    ),
    PurchaseColumnFilterKind.partyName => PurchaseColumnPartyFilterPanel(
      parties: partyOptions,
      selected: columns.selectedParty,
      onSelected: (party) {
        actions.onParty(party);
        dismissAfterSelect();
      },
    ),
    PurchaseColumnFilterKind.paymentType => PurchaseColumnOptionListPanel(
      options: paymentOptions,
      selected: columns.selectedPaymentType,
      onSelected: (value) {
        actions.onPaymentType(value);
        dismissAfterSelect();
      },
    ),
    PurchaseColumnFilterKind.amount => PurchaseColumnNumericRangePanel(
      initialMin: columns.amountMin,
      initialMax: columns.amountMax,
      onChanged: actions.onAmountRange,
      onClear: actions.onAmountRange,
    ),
    PurchaseColumnFilterKind.balanceDue => PurchaseColumnNumericRangePanel(
      initialMin: columns.balanceMin,
      initialMax: columns.balanceMax,
      onChanged: actions.onBalanceRange,
      onClear: actions.onBalanceRange,
    ),
    PurchaseColumnFilterKind.totalAmount => PurchaseColumnNumericRangePanel(
      initialMin: columns.totalAmountMin,
      initialMax: columns.totalAmountMax,
      onChanged: actions.onTotalAmountRange ?? actions.onAmountRange,
      onClear: actions.onTotalAmountRange ?? actions.onAmountRange,
    ),
    PurchaseColumnFilterKind.paidAmount => PurchaseColumnNumericRangePanel(
      initialMin: columns.paidAmountMin,
      initialMax: columns.paidAmountMax,
      onChanged: actions.onPaidAmountRange ?? actions.onAmountRange,
      onClear: actions.onPaidAmountRange ?? actions.onAmountRange,
    ),
    PurchaseColumnFilterKind.receivedPaid => PurchaseColumnNumericRangePanel(
      initialMin: columns.receivedPaidMin,
      initialMax: columns.receivedPaidMax,
      onChanged: actions.onReceivedPaidRange ?? actions.onAmountRange,
      onClear: actions.onReceivedPaidRange ?? actions.onAmountRange,
    ),
    PurchaseColumnFilterKind.status => PurchaseColumnOptionListPanel(
      options: statusOptions,
      selected: selectedStatus,
      onSelected: (value) {
        actions.onStatus(value);
        dismissAfterSelect();
      },
    ),
    PurchaseColumnFilterKind.categoryName => PurchaseColumnOptionListPanel(
      options: categoryOptions ?? const ['All Categories'],
      selected: columns.selectedCategory,
      onSelected: (value) {
        actions.onCategory?.call(value);
        dismissAfterSelect();
      },
    ),
    PurchaseColumnFilterKind.typeName => PurchaseColumnOptionListPanel(
      options: typeOptions ?? const ['All Types'],
      selected: columns.selectedType,
      onSelected: (value) {
        actions.onType?.call(value);
        dismissAfterSelect();
      },
    ),
    PurchaseColumnFilterKind.date ||
    PurchaseColumnFilterKind.dueDate =>
      const SizedBox.shrink(),
  };
}

PurchaseColumnFilterCell purchaseColumnFilterCell({
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
  double gapAfter = 12,
  String documentNoHint = 'Search',
  List<String>? paymentTypeOptions,
  List<String>? categoryOptions,
  List<String>? typeOptions,
}) {
  return PurchaseColumnFilterCell(
    label: label,
    kind: kind,
    headerStyle: headerStyle,
    isActive: isActive,
    width: width,
    alignment: alignment,
    gapAfter: gapAfter,
    initialDateRange: switch (kind) {
      PurchaseColumnFilterKind.date => columns.columnDateRange,
      PurchaseColumnFilterKind.dueDate => columns.dueDateRange,
      _ => null,
    },
    onDateRangeSelected: switch (kind) {
      PurchaseColumnFilterKind.date => actions.onDateRange,
      PurchaseColumnFilterKind.dueDate => actions.onDueDateRange,
      _ => null,
    },
    buildPopupContent: (_, dismissAfterSelect) => purchaseColumnFilterBuildPopup(
      kind: kind,
      columns: columns,
      actions: actions,
      partyOptions: partyOptions,
      statusOptions: statusOptions,
      selectedStatus: selectedStatus,
      dismissAfterSelect: dismissAfterSelect,
      documentNoHint: documentNoHint,
      paymentTypeOptions: paymentTypeOptions,
      categoryOptions: categoryOptions,
      typeOptions: typeOptions,
    ),
  );
}

List<String> purchasePartyOptionsFromNames(Iterable<String> names) {
  final parties = names.toSet().toList()..sort();
  return ['All Parties', ...parties];
}
