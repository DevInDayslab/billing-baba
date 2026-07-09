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
      columns.selectedPaymentTypes.isNotEmpty,
    PurchaseColumnFilterKind.amount => columns.amountFilter != null,
    PurchaseColumnFilterKind.balanceDue => columns.balanceFilter != null,
    PurchaseColumnFilterKind.status => false,
    PurchaseColumnFilterKind.totalAmount => columns.totalAmountFilter != null,
    PurchaseColumnFilterKind.paidAmount => columns.paidAmountFilter != null,
    PurchaseColumnFilterKind.categoryName =>
      columns.selectedCategory != 'All Categories',
    PurchaseColumnFilterKind.typeName => columns.selectedType != 'All Types',
    PurchaseColumnFilterKind.receivedPaid =>
      columns.receivedPaidFilter != null,
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
  required VoidCallback dismiss,
  required VoidCallback dismissAfterSelect,
  String documentNoHint = 'Search',
  List<String>? paymentTypeOptions,
  List<String>? categoryOptions,
  List<String>? typeOptions,
}) {
  final paymentOptions = paymentTypeOptions ?? SaleDropdownOptions.paymentTypes;

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
    PurchaseColumnFilterKind.paymentType =>
      PurchaseColumnPaymentTypeCheckboxPanel(
        options: paymentOptions,
        selected: columns.selectedPaymentTypes,
        onToggle: actions.onTogglePaymentType,
        onClear: actions.onClearPaymentTypes,
      ),
    PurchaseColumnFilterKind.amount => PurchaseColumnAdvancedNumericFilterPanel(
      valueLabel: 'Amount',
      initialFilter: columns.amountFilter,
      onApply: (filter) {
        actions.onApplyAmountFilter(filter);
        dismiss();
      },
      onClear: () {
        actions.onClearAmountFilter();
        dismiss();
      },
    ),
    PurchaseColumnFilterKind.balanceDue =>
      PurchaseColumnAdvancedNumericFilterPanel(
        valueLabel: 'Balance Due',
        initialFilter: columns.balanceFilter,
        onApply: (filter) {
          actions.onApplyBalanceFilter(filter);
          dismiss();
        },
        onClear: () {
          actions.onClearBalanceFilter();
          dismiss();
        },
      ),
    PurchaseColumnFilterKind.totalAmount =>
      PurchaseColumnAdvancedNumericFilterPanel(
        valueLabel: 'Total Amount',
        initialFilter: columns.totalAmountFilter,
        onApply: (filter) {
          (actions.onApplyTotalAmountFilter ?? actions.onApplyAmountFilter)(
            filter,
          );
          dismiss();
        },
        onClear: () {
          (actions.onClearTotalAmountFilter ?? actions.onClearAmountFilter)();
          dismiss();
        },
      ),
    PurchaseColumnFilterKind.paidAmount =>
      PurchaseColumnAdvancedNumericFilterPanel(
        valueLabel: 'Paid',
        initialFilter: columns.paidAmountFilter,
        onApply: (filter) {
          (actions.onApplyPaidAmountFilter ?? actions.onApplyAmountFilter)(
            filter,
          );
          dismiss();
        },
        onClear: () {
          (actions.onClearPaidAmountFilter ?? actions.onClearAmountFilter)();
          dismiss();
        },
      ),
    PurchaseColumnFilterKind.receivedPaid =>
      PurchaseColumnAdvancedNumericFilterPanel(
        valueLabel: 'Received/Paid',
        initialFilter: columns.receivedPaidFilter,
        onApply: (filter) {
          (actions.onApplyReceivedPaidFilter ?? actions.onApplyAmountFilter)(
            filter,
          );
          dismiss();
        },
        onClear: () {
          (actions.onClearReceivedPaidFilter ?? actions.onClearAmountFilter)();
          dismiss();
        },
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
  double gapAfter = 0,
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
    buildPopupContent: (dismiss, dismissAfterSelect) =>
        purchaseColumnFilterBuildPopup(
          kind: kind,
          columns: columns,
          actions: actions,
          partyOptions: partyOptions,
          statusOptions: statusOptions,
          selectedStatus: selectedStatus,
          dismiss: dismiss,
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
