import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileHomeState {
  const MobileHomeState({
    this.activeView = MobileHomeView.businessOverview,
    this.searchQuery = '',
    this.transactionTypeFilters = const {},
  });

  final MobileHomeView activeView;
  final String searchQuery;
  final Set<MobileHomeTransactionFilterType> transactionTypeFilters;

  MobileHomeState copyWith({
    MobileHomeView? activeView,
    String? searchQuery,
    Set<MobileHomeTransactionFilterType>? transactionTypeFilters,
  }) {
    return MobileHomeState(
      activeView: activeView ?? this.activeView,
      searchQuery: searchQuery ?? this.searchQuery,
      transactionTypeFilters:
          transactionTypeFilters ?? this.transactionTypeFilters,
    );
  }
}

final mobileHomeControllerProvider =
    NotifierProvider<MobileHomeController, MobileHomeState>(
      MobileHomeController.new,
    );

class MobileHomeController extends Notifier<MobileHomeState> {
  @override
  MobileHomeState build() => const MobileHomeState();

  void setView(MobileHomeView view) {
    state = state.copyWith(activeView: view);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTransactionTypeFilters(
    Set<MobileHomeTransactionFilterType> filters,
  ) {
    state = state.copyWith(transactionTypeFilters: filters);
  }
}

List<MobileHomeTransactionItem> filterHomeTransactions(
  List<MobileHomeTransactionItem> items,
  String query, {
  Set<MobileHomeTransactionFilterType> typeFilters = const {},
  DateTimeRange? dateRange,
}) {
  var result = items;

  if (typeFilters.isNotEmpty) {
    result = result
        .where((item) => typeFilters.contains(item.filterType))
        .toList();
  }

  if (dateRange != null) {
    result = filterHomeTransactionsByDate(result, dateRange);
  }

  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return result;

  return result.where((item) {
    final haystack = [
      item.partyName,
      item.documentNumber,
      item.statusLabel,
      item.dateLabel,
      item.timeLabel,
      item.title,
      item.totalLabel,
    ].join(' ').toLowerCase();
    return haystack.contains(normalized);
  }).toList();
}

List<MobileHomeTransactionItem> filterHomeTransactionsByDate(
  List<MobileHomeTransactionItem> items,
  DateTimeRange range,
) {
  final start = DateTime(
    range.start.year,
    range.start.month,
    range.start.day,
  );
  final end = DateTime(range.end.year, range.end.month, range.end.day);

  return items.where((item) {
    final date = item.transactionDate;
    if (date == null) return true;
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }).toList();
}

DateTimeRange dateRangeForHomeQuickPeriod(
  MobileHomeTransactionQuickPeriod period,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return switch (period) {
    MobileHomeTransactionQuickPeriod.today => DateTimeRange(
      start: today,
      end: today,
    ),
    MobileHomeTransactionQuickPeriod.week => DateTimeRange(
      start: today.subtract(Duration(days: today.weekday - 1)),
      end: today,
    ),
    MobileHomeTransactionQuickPeriod.month => DateTimeRange(
      start: DateTime(today.year, today.month),
      end: today,
    ),
    MobileHomeTransactionQuickPeriod.custom => DateTimeRange(
      start: today,
      end: today,
    ),
  };
}

enum MobileHomeTransactionQuickPeriod {
  today('Today'),
  week('Week'),
  month('Month'),
  custom('Custom');

  const MobileHomeTransactionQuickPeriod(this.label);

  final String label;
}
