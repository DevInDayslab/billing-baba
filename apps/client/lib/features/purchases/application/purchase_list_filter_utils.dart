import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';DateTime purchaseFilterStartOfDay(DateTime date) =>
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

bool purchaseFilterMatchesNumericRange(
  double value, {
  double? min,
  double? max,
}) {
  if (min != null && value < min) return false;
  if (max != null && value > max) return false;
  return true;
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
    this.selectedPaymentType = 'All Payment Types',
    this.amountMin,
    this.amountMax,
    this.balanceMin,
    this.balanceMax,
    this.dueDateRange,
    this.totalAmountMin,
    this.totalAmountMax,
    this.paidAmountMin,
    this.paidAmountMax,
    this.selectedCategory = 'All Categories',
    this.selectedType = 'All Types',
    this.receivedPaidMin,
    this.receivedPaidMax,
  });

  final DateTimeRange? columnDateRange;
  final String documentNoFilter;
  final String selectedParty;
  final String selectedPaymentType;
  final double? amountMin;
  final double? amountMax;
  final double? balanceMin;
  final double? balanceMax;
  final DateTimeRange? dueDateRange;
  final double? totalAmountMin;
  final double? totalAmountMax;
  final double? paidAmountMin;
  final double? paidAmountMax;
  final String selectedCategory;
  final String selectedType;
  final double? receivedPaidMin;
  final double? receivedPaidMax;

  bool get hasColumnFilters =>
      columnDateRange != null ||
      documentNoFilter.trim().isNotEmpty ||
      selectedParty != 'All Parties' ||
      selectedPaymentType != 'All Payment Types' ||
      amountMin != null ||
      amountMax != null ||
      balanceMin != null ||
      balanceMax != null ||
      dueDateRange != null ||
      totalAmountMin != null ||
      totalAmountMax != null ||
      paidAmountMin != null ||
      paidAmountMax != null ||
      selectedCategory != 'All Categories' ||
      selectedType != 'All Types' ||
      receivedPaidMin != null ||
      receivedPaidMax != null;

  PurchaseColumnFilterFields copyWith({
    DateTimeRange? columnDateRange,
    bool clearColumnDateRange = false,
    String? documentNoFilter,
    String? selectedParty,
    String? selectedPaymentType,
    double? amountMin,
    double? amountMax,
    bool clearAmountRange = false,
    double? balanceMin,
    double? balanceMax,
    bool clearBalanceRange = false,
    DateTimeRange? dueDateRange,
    bool clearDueDateRange = false,
    double? totalAmountMin,
    double? totalAmountMax,
    bool clearTotalAmountRange = false,
    double? paidAmountMin,
    double? paidAmountMax,
    bool clearPaidAmountRange = false,
    String? selectedCategory,
    String? selectedType,
    double? receivedPaidMin,
    double? receivedPaidMax,
    bool clearReceivedPaidRange = false,
  }) {
    return PurchaseColumnFilterFields(
      columnDateRange: clearColumnDateRange
          ? null
          : (columnDateRange ?? this.columnDateRange),
      documentNoFilter: documentNoFilter ?? this.documentNoFilter,
      selectedParty: selectedParty ?? this.selectedParty,
      selectedPaymentType: selectedPaymentType ?? this.selectedPaymentType,
      amountMin: clearAmountRange ? null : (amountMin ?? this.amountMin),
      amountMax: clearAmountRange ? null : (amountMax ?? this.amountMax),
      balanceMin: clearBalanceRange ? null : (balanceMin ?? this.balanceMin),
      balanceMax: clearBalanceRange ? null : (balanceMax ?? this.balanceMax),
      dueDateRange: clearDueDateRange
          ? null
          : (dueDateRange ?? this.dueDateRange),
      totalAmountMin: clearTotalAmountRange
          ? null
          : (totalAmountMin ?? this.totalAmountMin),
      totalAmountMax: clearTotalAmountRange
          ? null
          : (totalAmountMax ?? this.totalAmountMax),
      paidAmountMin: clearPaidAmountRange
          ? null
          : (paidAmountMin ?? this.paidAmountMin),
      paidAmountMax: clearPaidAmountRange
          ? null
          : (paidAmountMax ?? this.paidAmountMax),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedType: selectedType ?? this.selectedType,
      receivedPaidMin: clearReceivedPaidRange
          ? null
          : (receivedPaidMin ?? this.receivedPaidMin),
      receivedPaidMax: clearReceivedPaidRange
          ? null
          : (receivedPaidMax ?? this.receivedPaidMax),
    );
  }
}
