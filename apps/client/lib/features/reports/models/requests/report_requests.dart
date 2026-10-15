import 'package:billing_baba/features/reports/utils/report_date_bounds.dart';
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
    this.categoryId,
    this.paymentMode,
    this.documentType,
    this.partyGroup,
    this.bankName,
    this.bankAccountId,
    this.taxRate,
    this.loanAccount,
    this.status,
    this.partyType,
    this.inStockOnly = false,
    this.format,
    this.sort,
    this.order,
    this.financialYear,
    this.month,
    this.quarter,
    this.nonTaxAsExempt = false,
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
  final String? categoryId;
  final String? paymentMode;
  final String? documentType;
  final String? partyGroup;
  final String? bankName;
  final String? bankAccountId;
  final String? taxRate;
  final String? loanAccount;
  final String? status;
  final String? partyType;
  final bool inStockOnly;
  final String? format;
  final String? sort;
  final String? order;
  final String? financialYear;
  final String? month;
  final String? quarter;
  final bool nonTaxAsExempt;

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'period': period.apiValue,
      'page': '$page',
      'limit': '$limit',
    };

    if (period == ReportPeriod.custom && from != null && to != null) {
      final bounds = apiDateBoundsFromInclusiveRange(
        DateTimeRange(start: from!, end: to!),
      );
      params['from'] = bounds.$1.toUtc().toIso8601String();
      params['to'] = bounds.$2.toUtc().toIso8601String();
    }
    if (date != null) {
      params['date'] = date!.toUtc().toIso8601String();
    }
    if (q != null && q!.trim().isNotEmpty) params['q'] = q!.trim();
    if (partyId != null) params['party_id'] = partyId!;
    if (godownId != null) params['godown_id'] = godownId!;
    if (itemId != null) params['item_id'] = itemId!;
    if (categoryId != null) params['category_id'] = categoryId!;
    if (paymentMode != null && paymentMode!.isNotEmpty) {
      params['payment_mode'] = paymentMode!;
    }
    if (documentType != null && documentType!.isNotEmpty) {
      params['document_type'] = documentType!;
    }
    if (partyGroup != null && partyGroup!.isNotEmpty) {
      params['party_group'] = partyGroup!;
    }
    if (bankAccountId != null && bankAccountId!.isNotEmpty) {
      params['bank_account_id'] = bankAccountId!;
    }
    if (taxRate != null && taxRate!.isNotEmpty) {
      params['tax_rate'] = taxRate!;
    }
    if (loanAccount != null && loanAccount!.isNotEmpty) {
      params['loan_account'] = loanAccount!;
    }
    if (status != null && status!.isNotEmpty) params['status'] = status!;
    if (partyType != null && partyType!.isNotEmpty) {
      params['party_type'] = partyType!;
    }
    if (inStockOnly) params['in_stock_only'] = 'true';
    if (format != null && format!.isNotEmpty) params['format'] = format!;
    if (sort != null) params['sort'] = sort!;
    if (order != null) params['order'] = order!;
    if (financialYear != null && financialYear!.isNotEmpty) {
      params['financial_year'] = financialYear!;
    }
    if (month != null && month!.isNotEmpty) {
      params['month'] = month!;
    }
    if (quarter != null && quarter!.isNotEmpty) {
      params['quarter'] = quarter!;
    }
    if (nonTaxAsExempt) {
      params['non_tax_as_exempt'] = 'true';
    }
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
    String? categoryId,
    String? paymentMode,
    String? documentType,
    String? partyGroup,
    String? bankName,
    String? bankAccountId,
    String? taxRate,
    String? loanAccount,
    String? status,
    String? partyType,
    bool? inStockOnly,
    String? format,
    String? sort,
    String? order,
    String? financialYear,
    String? month,
    String? quarter,
    bool? nonTaxAsExempt,
    bool clearFinancialYear = false,
    bool clearMonth = false,
    bool clearQuarter = false,
    bool clearPartyId = false,
    bool clearGodownId = false,
    bool clearItemId = false,
    bool clearCategoryId = false,
    bool clearPaymentMode = false,
    bool clearDocumentType = false,
    bool clearPartyGroup = false,
    bool clearBankName = false,
    bool clearBankAccountId = false,
    bool clearTaxRate = false,
    bool clearLoanAccount = false,
    bool clearStatus = false,
    bool clearPartyType = false,
    bool clearFormat = false,
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
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      paymentMode: clearPaymentMode ? null : (paymentMode ?? this.paymentMode),
      documentType: clearDocumentType
          ? null
          : (documentType ?? this.documentType),
      partyGroup: clearPartyGroup ? null : (partyGroup ?? this.partyGroup),
      bankName: clearBankName ? null : (bankName ?? this.bankName),
      bankAccountId: clearBankAccountId
          ? null
          : (bankAccountId ?? this.bankAccountId),
      taxRate: clearTaxRate ? null : (taxRate ?? this.taxRate),
      loanAccount: clearLoanAccount ? null : (loanAccount ?? this.loanAccount),
      status: clearStatus ? null : (status ?? this.status),
      partyType: clearPartyType ? null : (partyType ?? this.partyType),
      inStockOnly: inStockOnly ?? this.inStockOnly,
      format: clearFormat ? null : (format ?? this.format),
      sort: sort ?? this.sort,
      order: order ?? this.order,
      financialYear: clearFinancialYear
          ? null
          : (financialYear ?? this.financialYear),
      month: clearMonth ? null : (month ?? this.month),
      quarter: clearQuarter ? null : (quarter ?? this.quarter),
      nonTaxAsExempt: nonTaxAsExempt ?? this.nonTaxAsExempt,
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
    this.categoryId,
    this.paymentMode,
    this.documentType,
    this.partyGroup,
    this.bankName,
    this.bankAccountId,
    this.taxRate,
    this.loanAccount,
    this.status,
    this.partyType,
    this.inStockOnly = false,
    this.format,
    this.searchQuery = '',
    this.currentPage = 1,
    this.pageSize = 20,
    this.isTableLoading = false,
    this.financialYear,
    this.month,
    this.quarter,
    this.nonTaxAsExempt = false,
  });

  final ReportPeriod period;
  final DateTimeRange? customDateRange;
  final DateTime? selectedDate;
  final String? godownId;
  final String? partyId;
  final String? itemId;
  final String? categoryId;
  final String? paymentMode;
  final String? documentType;
  final String? partyGroup;
  final String? bankName;
  final String? bankAccountId;
  final String? taxRate;
  final String? loanAccount;
  final String? status;
  final String? partyType;
  final bool inStockOnly;
  final String? format;
  final String searchQuery;
  final int currentPage;
  final int pageSize;
  final bool isTableLoading;
  final String? financialYear;
  final String? month;
  final String? quarter;
  final bool nonTaxAsExempt;

  String get periodLabel => period.label;

  /// Resolves the visible date range for UI controls from period + custom range.
  DateTimeRange get effectiveDateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final raw = switch (period) {
      ReportPeriod.custom when customDateRange != null => customDateRange!,
      ReportPeriod.today => DateTimeRange(start: today, end: today),
      ReportPeriod.yesterday => () {
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: yesterday, end: yesterday);
      }(),
      ReportPeriod.thisWeek => () {
        final start = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 6)),
        );
      }(),
      ReportPeriod.lastWeek => () {
        final thisWeekStart = today.subtract(
          Duration(days: today.weekday - 1),
        );
        final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
        return DateTimeRange(
          start: lastWeekStart,
          end: lastWeekStart.add(const Duration(days: 6)),
        );
      }(),
      ReportPeriod.thisMonth => currentMonthDateRange(),
      ReportPeriod.lastMonth => () {
        final firstOfMonth = DateTime(now.year, now.month);
        final lastMonthEnd = firstOfMonth.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: DateTime(lastMonthEnd.year, lastMonthEnd.month),
          end: lastMonthEnd,
        );
      }(),
      ReportPeriod.thisQuarter => () {
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final startMonth = (quarter - 1) * 3 + 1;
        return DateTimeRange(
          start: DateTime(now.year, startMonth),
          end: DateTime(now.year, startMonth + 3, 0),
        );
      }(),
      ReportPeriod.thisYear => DateTimeRange(
        start: DateTime(now.year),
        end: DateTime(now.year, 12, 31),
      ),
      ReportPeriod.allTime => DateTimeRange(
        start: DateTime(2000),
        end: today,
      ),
      ReportPeriod.custom => customDateRange ?? currentMonthDateRange(),
    };

    return clampReportDateRange(raw);
  }

  static DateTimeRange currentMonthDateRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  ReportQuery toQuery({int? page, int? limit, String? format}) {
    final customRange = period == ReportPeriod.custom ? effectiveDateRange : null;
    return ReportQuery(
      period: period,
      from: customRange?.start,
      to: customRange?.end,
      date: selectedDate,
      page: page ?? currentPage,
      limit: limit ?? pageSize,
      q: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
      partyId: partyId,
      godownId: godownId,
      itemId: itemId,
      categoryId: categoryId,
      paymentMode: paymentMode,
      documentType: documentType,
      partyGroup: partyGroup,
      bankName: bankName,
      bankAccountId: bankAccountId,
      taxRate: taxRate,
      loanAccount: loanAccount,
      status: status,
      partyType: partyType,
      inStockOnly: inStockOnly,
      format: format ?? this.format,
      financialYear: financialYear,
      month: month,
      quarter: quarter,
      nonTaxAsExempt: nonTaxAsExempt,
    );
  }

  ReportFiltersState copyWith({
    ReportPeriod? period,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? godownId,
    String? partyId,
    String? itemId,
    String? categoryId,
    String? paymentMode,
    String? documentType,
    String? partyGroup,
    String? bankName,
    String? bankAccountId,
    String? taxRate,
    String? loanAccount,
    String? status,
    String? partyType,
    bool? inStockOnly,
    String? format,
    String? searchQuery,
    int? currentPage,
    int? pageSize,
    bool? isTableLoading,
    String? financialYear,
    String? month,
    String? quarter,
    bool? nonTaxAsExempt,
    bool clearFinancialYear = false,
    bool clearMonth = false,
    bool clearQuarter = false,
    bool clearPartyId = false,
    bool clearGodownId = false,
    bool clearItemId = false,
    bool clearCategoryId = false,
    bool clearPaymentMode = false,
    bool clearDocumentType = false,
    bool clearPartyGroup = false,
    bool clearBankName = false,
    bool clearBankAccountId = false,
    bool clearTaxRate = false,
    bool clearLoanAccount = false,
    bool clearStatus = false,
    bool clearPartyType = false,
    bool clearFormat = false,
  }) {
    return ReportFiltersState(
      period: period ?? this.period,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      godownId: clearGodownId ? null : (godownId ?? this.godownId),
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      itemId: clearItemId ? null : (itemId ?? this.itemId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      paymentMode: clearPaymentMode ? null : (paymentMode ?? this.paymentMode),
      documentType: clearDocumentType
          ? null
          : (documentType ?? this.documentType),
      partyGroup: clearPartyGroup ? null : (partyGroup ?? this.partyGroup),
      bankName: clearBankName ? null : (bankName ?? this.bankName),
      bankAccountId: clearBankAccountId
          ? null
          : (bankAccountId ?? this.bankAccountId),
      taxRate: clearTaxRate ? null : (taxRate ?? this.taxRate),
      loanAccount: clearLoanAccount ? null : (loanAccount ?? this.loanAccount),
      status: clearStatus ? null : (status ?? this.status),
      partyType: clearPartyType ? null : (partyType ?? this.partyType),
      inStockOnly: inStockOnly ?? this.inStockOnly,
      format: clearFormat ? null : (format ?? this.format),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isTableLoading: isTableLoading ?? this.isTableLoading,
      financialYear: clearFinancialYear
          ? null
          : (financialYear ?? this.financialYear),
      month: clearMonth ? null : (month ?? this.month),
      quarter: clearQuarter ? null : (quarter ?? this.quarter),
      nonTaxAsExempt: nonTaxAsExempt ?? this.nonTaxAsExempt,
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
