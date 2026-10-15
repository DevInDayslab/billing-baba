import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:flutter/material.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/shared/utils/reporting_period_range.dart';

double _parseAmount(String? raw) => double.tryParse(raw ?? '') ?? 0;

bool _inReportRange(String expenseDate, DateTimeRange range) {
  final day = parseDocumentCalendarDay(expenseDate);
  if (day == null) return false;
  return isCalendarDayInRange(day, range);
}

double _resolveBalanceDue(ExpenseDto expense) {
  final amount = _parseAmount(expense.amount);
  final balanceDue = expense.balanceDue;
  if (balanceDue != null && balanceDue.isNotEmpty) {
    return _parseAmount(balanceDue);
  }
  final paymentMode = expense.paymentMode?.trim();
  if (paymentMode != null && paymentMode.isNotEmpty) {
    return 0;
  }
  return amount;
}

ExpenseReportPaymentStatus _resolveStatus(ExpenseDto expense) {
  final balance = _resolveBalanceDue(expense);
  if (balance <= 0) {
    return ExpenseReportPaymentStatus.paid;
  }
  final paymentMode = expense.paymentMode?.trim();
  if (paymentMode != null && paymentMode.isNotEmpty) {
    return ExpenseReportPaymentStatus.partial;
  }
  return ExpenseReportPaymentStatus.pending;
}

String? _paymentTypeLabel(String? paymentMode) {
  final raw = paymentMode?.trim();
  if (raw == null || raw.isEmpty) return null;
  return switch (raw.toLowerCase()) {
    'cash' => 'Cash',
    'upi' => 'UPI',
    'cheque' => 'Cheque',
    'bank_transfer' => 'Bank Transfer',
    'card' => 'Card',
    _ => raw,
  };
}

String _expenseNo(ExpenseDto expense) {
  final reference = expense.referenceNumber?.trim();
  if (reference != null && reference.isNotEmpty) return reference;
  return expense.id.length >= 8 ? expense.id.substring(0, 8) : expense.id;
}

String _partyName(ExpenseDto expense, Map<String, String> partyNames) {
  final direct = expense.partyName?.trim();
  if (direct != null && direct.isNotEmpty) return direct;
  final partyId = expense.partyId;
  if (partyId != null && partyId.isNotEmpty) {
    return partyNames[partyId] ?? '';
  }
  return '';
}

ReportExpenseRow _toExpenseRow(
  ExpenseDto expense,
  Map<String, String> partyNames,
) {
  final date = parseDocumentCalendarDay(expense.expenseDate) ?? DateTime.now();
  final dueDateRaw = expense.dueDate;
  return ReportExpenseRow(
    id: expense.id,
    date: date,
    expenseNo: _expenseNo(expense),
    partyName: _partyName(expense, partyNames),
    category: expense.categoryName?.trim() ?? '',
    paymentType: _paymentTypeLabel(expense.paymentMode),
    amount: _parseAmount(expense.amount),
    balanceDue: _resolveBalanceDue(expense),
    dueDate: dueDateRaw != null && dueDateRaw.isNotEmpty
        ? DateTime.tryParse(dueDateRaw)
        : null,
    status: _resolveStatus(expense),
  );
}

bool _matchesExpenseQuery(
  ExpenseDto expense,
  ReportQuery query,
  DateTimeRange range,
) {
  if (!_inReportRange(expense.expenseDate, range)) return false;

  if (query.categoryId != null &&
      query.categoryId!.isNotEmpty &&
      expense.categoryId != query.categoryId) {
    return false;
  }
  if (query.partyId != null &&
      query.partyId!.isNotEmpty &&
      expense.partyId != query.partyId) {
    return false;
  }
  if (query.paymentMode != null && query.paymentMode!.isNotEmpty) {
    final mode = expense.paymentMode?.trim().toLowerCase() ?? '';
    if (mode != query.paymentMode!.trim().toLowerCase()) return false;
  }

  final q = query.q?.trim().toLowerCase();
  if (q != null && q.isNotEmpty) {
    final description = expense.description?.toLowerCase() ?? '';
    final reference = expense.referenceNumber?.toLowerCase() ?? '';
    if (!description.contains(q) && !reference.contains(q)) {
      return false;
    }
  }
  return true;
}

ReportPaginationMeta _paginateMeta({
  required int page,
  required int limit,
  required int total,
}) {
  final safePage = page < 1 ? 1 : page;
  final safeLimit = limit < 1 ? 20 : limit;
  return ReportPaginationMeta(
    page: safePage,
    limit: safeLimit,
    total: total,
    totalPages: total == 0 ? 0 : (total / safeLimit).ceil(),
  );
}

ExpensesReportData? buildLocalExpensesReport({
  required List<ExpenseDto> expenses,
  required Map<String, String> partyNames,
  required ReportQuery query,
}) {
  final range = dateRangeForReportQuery(query);
  final rows = <ReportExpenseRow>[];

  for (final expense in expenses) {
    if (!_matchesExpenseQuery(expense, query, range)) continue;
    rows.add(_toExpenseRow(expense, partyNames));
  }

  if (rows.isEmpty) return null;

  rows.sort((a, b) => b.date.compareTo(a.date));

  var totalAmount = 0.0;
  for (final row in rows) {
    totalAmount += row.amount;
  }

  final page = query.page < 1 ? 1 : query.page;
  final limit = query.limit < 1 ? 20 : query.limit;
  final start = (page - 1) * limit;
  final pageRows = start >= rows.length
      ? const <ReportExpenseRow>[]
      : rows.skip(start).take(limit).toList();

  return ExpensesReportData(
    rows: pageRows,
    totalAmount: totalAmount,
    meta: _paginateMeta(page: page, limit: limit, total: rows.length),
  );
}

ExpenseByCategoryReportData? buildLocalExpenseByCategoryReport({
  required List<ExpenseDto> expenses,
  required List<ExpenseCategoryDto> categories,
  required ReportQuery query,
}) {
  final range = dateRangeForReportQuery(query);
  final categoryMeta = {
    for (final category in categories)
      category.id: (
        name: category.name,
        type: category.categoryType,
      ),
  };

  final grouped =
      <
        String,
        ({
          String categoryId,
          String category,
          String categoryType,
          double amount,
          int count,
        })
      >{};

  for (final expense in expenses) {
    if (!_matchesExpenseQuery(expense, query, range)) continue;
    final meta = categoryMeta[expense.categoryId];
    final categoryName =
        expense.categoryName?.trim() ?? meta?.name ?? 'Uncategorized';
    final categoryType = meta?.type ?? 'direct';
    final amount = _parseAmount(expense.amount);
    final existing = grouped[expense.categoryId];
    if (existing == null) {
      grouped[expense.categoryId] = (
        categoryId: expense.categoryId,
        category: categoryName,
        categoryType: categoryType,
        amount: amount,
        count: 1,
      );
    } else {
      grouped[expense.categoryId] = (
        categoryId: existing.categoryId,
        category: existing.category,
        categoryType: existing.categoryType,
        amount: existing.amount + amount,
        count: existing.count + 1,
      );
    }
  }

  if (grouped.isEmpty) return null;

  final rows = grouped.values
      .map(
        (entry) => ReportExpenseCategoryRow(
          categoryId: entry.categoryId,
          category: entry.category,
          categoryType: entry.categoryType,
          amount: entry.amount,
          count: entry.count,
        ),
      )
      .toList();
  rows.sort((a, b) => b.amount.compareTo(a.amount));

  return ExpenseByCategoryReportData(rows: rows);
}

String _resolveExpenseItemName(
  ExpenseDto expense,
  Map<String, String> catalogItemNames,
) {
  final itemId = expense.expenseItemId;
  if (itemId != null && itemId.isNotEmpty) {
    final catalogName = catalogItemNames[itemId];
    if (catalogName != null && catalogName.isNotEmpty) {
      return catalogName;
    }
  }
  final description = expense.description?.trim();
  if (description != null && description.isNotEmpty) {
    return description;
  }
  return 'Expense';
}

ExpenseByItemReportData? buildLocalExpenseByItemReport({
  required List<ExpenseDto> expenses,
  required List<ExpenseItemDto> catalogItems,
  required ReportQuery query,
}) {
  final range = dateRangeForReportQuery(query);
  final catalogItemNames = {for (final item in catalogItems) item.id: item.name};
  final grouped =
      <
        String,
        ({
          String itemName,
          String category,
          String categoryId,
          double amount,
          int count,
        })
      >{};

  for (final expense in expenses) {
    if (!_matchesExpenseQuery(expense, query, range)) continue;
    final resolvedName = _resolveExpenseItemName(expense, catalogItemNames);
    final category = expense.categoryName?.trim() ?? '';
    final key = '$resolvedName|$category|${expense.categoryId}';
    final amount = _parseAmount(expense.amount);
    final existing = grouped[key];
    if (existing == null) {
      grouped[key] = (
        itemName: resolvedName,
        category: category,
        categoryId: expense.categoryId,
        amount: amount,
        count: 1,
      );
    } else {
      grouped[key] = (
        itemName: existing.itemName,
        category: existing.category,
        categoryId: existing.categoryId,
        amount: existing.amount + amount,
        count: existing.count + 1,
      );
    }
  }

  if (grouped.isEmpty) return null;

  final rows = grouped.values
      .map(
        (entry) => ReportExpenseItemRow(
          itemName: entry.itemName,
          category: entry.category,
          amount: entry.amount,
          count: entry.count,
          categoryId: entry.categoryId,
        ),
      )
      .toList();
  rows.sort((a, b) => b.amount.compareTo(a.amount));

  return ExpenseByItemReportData(rows: rows);
}
