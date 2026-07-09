import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime purchaseFilterStartOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool purchaseFilterIsWithinDateRange(DateTime value, DateTimeRange range) {
  final date = purchaseFilterStartOfDay(value);
  final start = purchaseFilterStartOfDay(range.start);
  final end = purchaseFilterStartOfDay(range.end);
  return !date.isBefore(start) && !date.isAfter(end);
}

bool purchaseFilterMatchesGlobalSearch(
  String query,
  List<String> fields,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return true;
  return fields.any((field) => field.toLowerCase().contains(normalized));
}

bool purchaseFilterMatchesText(String query, String value) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return true;
  return value.toLowerCase().contains(normalized);
}

bool purchaseFilterMatchesParty(String selected, String value) {
  if (selected == 'All Parties') return true;
  return value == selected;
}

bool purchaseFilterMatchesOption(String selected, String allLabel, String value) {
  if (selected == allLabel) return true;
  return value == selected;
}

bool purchaseFilterMatchesPaymentTypes(Set<String> selected, String value) {
  if (selected.isEmpty) return true;
  return selected.contains(value);
}

bool purchaseFilterMatchesNumericRange(
  double value, {
  double? min,
  double? max,
}) {
  if (min != null && value < min) return false;
  if (max != null && value > max) return false;
  return true;
}

enum PurchaseNumericFilterOperator {
  equalTo('Equal To'),
  lessThan('Less Than'),
  greaterThan('Greater Than');

  const PurchaseNumericFilterOperator(this.label);

  final String label;
}

class PurchaseNumericFilter {
  const PurchaseNumericFilter({
    required this.operator,
    required this.value,
  });

  final PurchaseNumericFilterOperator operator;
  final double value;

  bool matches(double amount) => switch (operator) {
    PurchaseNumericFilterOperator.equalTo => amount == value,
    PurchaseNumericFilterOperator.lessThan => amount < value,
    PurchaseNumericFilterOperator.greaterThan => amount > value,
  };
}

bool purchaseFilterMatchesNumericFilter(
  double value,
  PurchaseNumericFilter? filter,
) {
  if (filter == null) return true;
  return filter.matches(value);
}

class PurchaseListPageSlice<T> {
  const PurchaseListPageSlice({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

PurchaseListPageSlice<T> purchaseFilterPaginate<T>(
  List<T> filtered,
  int currentPage,
  int pageSize,
) {
  if (filtered.isEmpty) {
    return const PurchaseListPageSlice(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    );
  }

  final totalItems = filtered.length;
  final totalPages = (totalItems / pageSize).ceil();
  final page = currentPage.clamp(1, totalPages);
  final start = (page - 1) * pageSize;
  final end = (start + pageSize).clamp(0, totalItems);

  return PurchaseListPageSlice(
    items: filtered.sublist(start, end),
    currentPage: page,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

List<T> purchaseFilterItemsFromAsync<T>(
  AsyncValue<({List<T> items, int currentPage, int totalPages, int totalItems})>
      async,
) {
  return async.when(
    data: (({List<T> items, int currentPage, int totalPages, int totalItems}) page) =>
        page.items,
    loading: () => <T>[],
    error: (_, _) => <T>[],
  );
}

/// Common column-filter fields shared across purchase list modules.
class PurchaseColumnFilterFields {
  const PurchaseColumnFilterFields({
    this.columnDateRange,
    this.documentNoFilter = '',
    this.selectedParty = 'All Parties',
    this.selectedPaymentTypes = const {},
    this.amountFilter,
    this.balanceFilter,
    this.dueDateRange,
    this.totalAmountFilter,
    this.paidAmountFilter,
    this.selectedCategory = 'All Categories',
    this.selectedType = 'All Types',
    this.receivedPaidFilter,
  });

  final DateTimeRange? columnDateRange;
  final String documentNoFilter;
  final String selectedParty;
  final Set<String> selectedPaymentTypes;
  final PurchaseNumericFilter? amountFilter;
  final PurchaseNumericFilter? balanceFilter;
  final DateTimeRange? dueDateRange;
  final PurchaseNumericFilter? totalAmountFilter;
  final PurchaseNumericFilter? paidAmountFilter;
  final String selectedCategory;
  final String selectedType;
  final PurchaseNumericFilter? receivedPaidFilter;

  bool get hasColumnFilters =>
      columnDateRange != null ||
      documentNoFilter.trim().isNotEmpty ||
      selectedParty != 'All Parties' ||
      selectedPaymentTypes.isNotEmpty ||
      amountFilter != null ||
      balanceFilter != null ||
      dueDateRange != null ||
      totalAmountFilter != null ||
      paidAmountFilter != null ||
      selectedCategory != 'All Categories' ||
      selectedType != 'All Types' ||
      receivedPaidFilter != null;

  PurchaseColumnFilterFields copyWith({
    DateTimeRange? columnDateRange,
    bool clearColumnDateRange = false,
    String? documentNoFilter,
    String? selectedParty,
    Set<String>? selectedPaymentTypes,
    bool clearPaymentTypes = false,
    PurchaseNumericFilter? amountFilter,
    bool clearAmountFilter = false,
    PurchaseNumericFilter? balanceFilter,
    bool clearBalanceFilter = false,
    DateTimeRange? dueDateRange,
    bool clearDueDateRange = false,
    PurchaseNumericFilter? totalAmountFilter,
    bool clearTotalAmountFilter = false,
    PurchaseNumericFilter? paidAmountFilter,
    bool clearPaidAmountFilter = false,
    String? selectedCategory,
    String? selectedType,
    PurchaseNumericFilter? receivedPaidFilter,
    bool clearReceivedPaidFilter = false,
  }) {
    return PurchaseColumnFilterFields(
      columnDateRange: clearColumnDateRange
          ? null
          : (columnDateRange ?? this.columnDateRange),
      documentNoFilter: documentNoFilter ?? this.documentNoFilter,
      selectedParty: selectedParty ?? this.selectedParty,
      selectedPaymentTypes: clearPaymentTypes
          ? const {}
          : (selectedPaymentTypes ?? this.selectedPaymentTypes),
      amountFilter:
          clearAmountFilter ? null : (amountFilter ?? this.amountFilter),
      balanceFilter:
          clearBalanceFilter ? null : (balanceFilter ?? this.balanceFilter),
      dueDateRange: clearDueDateRange
          ? null
          : (dueDateRange ?? this.dueDateRange),
      totalAmountFilter: clearTotalAmountFilter
          ? null
          : (totalAmountFilter ?? this.totalAmountFilter),
      paidAmountFilter: clearPaidAmountFilter
          ? null
          : (paidAmountFilter ?? this.paidAmountFilter),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedType: selectedType ?? this.selectedType,
      receivedPaidFilter: clearReceivedPaidFilter
          ? null
          : (receivedPaidFilter ?? this.receivedPaidFilter),
    );
  }
}
