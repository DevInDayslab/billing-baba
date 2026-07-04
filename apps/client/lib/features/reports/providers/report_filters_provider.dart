import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_filters_provider.g.dart';

@Riverpod(keepAlive: true)
class ReportFilters extends _$ReportFilters {
  @override
  ReportFiltersState build() => const ReportFiltersState();

  void setPeriod(ReportPeriod period) {
    state = state.copyWith(period: period, currentPage: 1);
  }

  void setCustomDateRange(DateTimeRange range) {
    state = state.copyWith(
      period: ReportPeriod.custom,
      customDateRange: range,
      currentPage: 1,
    );
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date, currentPage: 1);
  }

  void setPartyId(String? partyId) {
    state = state.copyWith(
      partyId: partyId,
      clearPartyId: partyId == null,
      currentPage: 1,
    );
  }

  void setGodownId(String? godownId) {
    state = state.copyWith(
      godownId: godownId,
      clearGodownId: godownId == null,
      currentPage: 1,
    );
  }

  void setItemId(String? itemId) {
    state = state.copyWith(
      itemId: itemId,
      clearItemId: itemId == null,
      currentPage: 1,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void resetPage() {
    state = state.copyWith(currentPage: 1);
  }
}
