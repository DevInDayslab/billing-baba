import 'package:flutter/material.dart';

enum ReportPeriod {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  thisYear,
  allTime,
  custom;

  String get label => switch (this) {
    ReportPeriod.today => 'Today',
    ReportPeriod.yesterday => 'Yesterday',
    ReportPeriod.thisWeek => 'This Week',
    ReportPeriod.lastWeek => 'Last Week',
    ReportPeriod.thisMonth => 'This Month',
    ReportPeriod.lastMonth => 'Last Month',
    ReportPeriod.thisQuarter => 'This Quarter',
    ReportPeriod.thisYear => 'This Year',
    ReportPeriod.allTime => 'All Time',
    ReportPeriod.custom => 'Custom',
  };

  String get apiValue => switch (this) {
    ReportPeriod.today => 'today',
    ReportPeriod.yesterday => 'yesterday',
    ReportPeriod.thisWeek => 'this_week',
    ReportPeriod.lastWeek => 'last_week',
    ReportPeriod.thisMonth => 'this_month',
    ReportPeriod.lastMonth => 'last_month',
    ReportPeriod.thisQuarter => 'this_quarter',
    ReportPeriod.thisYear => 'this_year',
    ReportPeriod.allTime => 'all_time',
    ReportPeriod.custom => 'custom',
  };

  static ReportPeriod fromLabel(String label) => switch (label) {
    'Today' => ReportPeriod.today,
    'Yesterday' => ReportPeriod.yesterday,
    'This Week' => ReportPeriod.thisWeek,
    'Last Week' => ReportPeriod.lastWeek,
    'This Month' => ReportPeriod.thisMonth,
    'Last Month' => ReportPeriod.lastMonth,
    'This Quarter' => ReportPeriod.thisQuarter,
    'This Year' => ReportPeriod.thisYear,
    'All Time' => ReportPeriod.allTime,
    'Custom' => ReportPeriod.custom,
    _ => ReportPeriod.thisMonth,
  };
}

class ReportQuery {
  const ReportQuery({
    this.period = ReportPeriod.thisMonth,
    this.from,
    this.to,
    this.date,
    this.page = 1,
    this.limit = 20,
    this.q,
    this.partyId,
    this.godownId,
    this.itemId,
    this.sort,
    this.order,
  });

  final ReportPeriod period;
  final DateTime? from;
  final DateTime? to;
  final DateTime? date;
  final int page;
  final int limit;
  final String? q;
  final String? partyId;
  final String? godownId;
  final String? itemId;
  final String? sort;
  final String? order;

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'period': period.apiValue,
      'page': '$page',
      'limit': '$limit',
    };

    if (period == ReportPeriod.custom) {
      if (from != null) params['from'] = from!.toUtc().toIso8601String();
      if (to != null) params['to'] = to!.toUtc().toIso8601String();
    }
    if (date != null) {
      params['date'] = date!.toUtc().toIso8601String();
    }
    if (q != null && q!.trim().isNotEmpty) params['q'] = q!.trim();
    if (partyId != null) params['party_id'] = partyId!;
    if (godownId != null) params['godown_id'] = godownId!;
    if (itemId != null) params['item_id'] = itemId!;
    if (sort != null) params['sort'] = sort!;
    if (order != null) params['order'] = order!;
    return params;
  }

  ReportQuery copyWith({
    ReportPeriod? period,
    DateTime? from,
    DateTime? to,
    DateTime? date,
    int? page,
    int? limit,
    String? q,
    String? partyId,
    String? godownId,
    String? itemId,
    String? sort,
    String? order,
    bool clearPartyId = false,
    bool clearGodownId = false,
    bool clearItemId = false,
    bool clearSearch = false,
  }) {
    return ReportQuery(
      period: period ?? this.period,
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      q: clearSearch ? null : (q ?? this.q),
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      godownId: clearGodownId ? null : (godownId ?? this.godownId),
      itemId: clearItemId ? null : (itemId ?? this.itemId),
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }
}

class ReportFiltersState {
  const ReportFiltersState({
    this.period = ReportPeriod.thisMonth,
    this.customDateRange,
    this.selectedDate,
    this.godownId,
    this.partyId,
    this.itemId,
    this.searchQuery = '',
    this.currentPage = 1,
    this.pageSize = 20,
  });

  final ReportPeriod period;
  final DateTimeRange? customDateRange;
  final DateTime? selectedDate;
  final String? godownId;
  final String? partyId;
  final String? itemId;
  final String searchQuery;
  final int currentPage;
  final int pageSize;

  String get periodLabel => period.label;

  ReportQuery toQuery({int? page, int? limit}) {
    return ReportQuery(
      period: period,
      from: customDateRange?.start,
      to: customDateRange?.end,
      date: selectedDate,
      page: page ?? currentPage,
      limit: limit ?? pageSize,
      q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
      partyId: partyId,
      godownId: godownId,
      itemId: itemId,
    );
  }

  ReportFiltersState copyWith({
    ReportPeriod? period,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    DateTime? selectedDate,
    String? godownId,
    String? partyId,
    String? itemId,
    String? searchQuery,
    int? currentPage,
    int? pageSize,
    bool clearPartyId = false,
    bool clearGodownId = false,
    bool clearItemId = false,
  }) {
    return ReportFiltersState(
      period: period ?? this.period,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedDate: selectedDate ?? this.selectedDate,
      godownId: clearGodownId ? null : (godownId ?? this.godownId),
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      itemId: clearItemId ? null : (itemId ?? this.itemId),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class ReportPaginationMeta {
  const ReportPaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ReportPaginationMeta.fromJson(Map<String, dynamic> json) {
    return ReportPaginationMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
