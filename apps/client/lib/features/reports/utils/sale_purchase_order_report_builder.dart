import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:flutter/material.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/shared/utils/reporting_period_range.dart';

double _parseAmount(String? raw) => double.tryParse(raw ?? '') ?? 0;

bool _matchesTypeFilter(String rowType, String? documentTypeFilter) {
  if (documentTypeFilter == null || documentTypeFilter.isEmpty) {
    return true;
  }
  return rowType == documentTypeFilter;
}

ReportOrderRow _saleOrderRow(
  SalesDocumentDto doc,
  Map<String, String> partyNames,
) {
  final partyName = partyNames[doc.partyId ?? ''] ?? '';
  final amount = _parseAmount(doc.totalAmount);
  final advance = _parseAmount(doc.paidAmount);
  final balance = (amount - advance).clamp(0.0, double.infinity).toDouble();
  final date = parseDocumentCalendarDay(doc.documentDate) ?? DateTime.now();
  final dueDate = date;

  return ReportOrderRow(
    date: date,
    orderNo: doc.documentNumber?.trim().isNotEmpty == true
        ? doc.documentNumber!.trim()
        : doc.documentSeries,
    partyName: partyName,
    dueDate: dueDate,
    status: doc.status,
    type: 'sale',
    amount: amount,
    advance: advance,
    balance: balance,
  );
}

ReportOrderRow _purchaseOrderRow(
  PurchaseDocumentDto doc,
  Map<String, String> partyNames,
) {
  final partyName = partyNames[doc.partyId] ?? '';
  final amount = _parseAmount(doc.totalAmount);
  final advance = _parseAmount(doc.paidAmount);
  final balance = (amount - advance).clamp(0.0, double.infinity).toDouble();
  final date = parseDocumentCalendarDay(doc.documentDate) ?? DateTime.now();
  final dueDate = doc.dueDate != null
      ? (parseDocumentCalendarDay(doc.dueDate!) ?? date)
      : date;

  return ReportOrderRow(
    date: date,
    orderNo: doc.documentNumber?.trim().isNotEmpty == true
        ? doc.documentNumber!.trim()
        : doc.documentSeries,
    partyName: partyName,
    dueDate: dueDate,
    status: doc.status,
    type: 'purchase',
    amount: amount,
    advance: advance,
    balance: balance,
  );
}

bool _matchesOrderQuery(ReportOrderRow row, ReportQuery query) {
  if (query.status != null &&
      query.status!.isNotEmpty &&
      row.status != query.status) {
    return false;
  }
  if (!_matchesTypeFilter(row.type, query.documentType)) {
    return false;
  }
  final partyQuery = query.q?.trim().toLowerCase();
  if (partyQuery != null && partyQuery.isNotEmpty) {
    if (!row.partyName.toLowerCase().contains(partyQuery) &&
        !row.orderNo.toLowerCase().contains(partyQuery)) {
      return false;
    }
  }
  return true;
}

SalePurchaseOrdersReportData buildLocalSalePurchaseOrdersReport({
  required List<SalesDocumentDto> saleOrders,
  required List<PurchaseDocumentDto> purchaseOrders,
  required Map<String, String> partyNames,
  required ReportQuery query,
}) {
  final range = dateRangeForReportQuery(query);
  final rows = <ReportOrderRow>[];

  if (_matchesTypeFilter('sale', query.documentType)) {
    for (final doc in saleOrders) {
      if (!_inRange(doc.documentDate, range)) continue;
      if (query.partyId != null &&
          query.partyId!.isNotEmpty &&
          doc.partyId != query.partyId) {
        continue;
      }
      final row = _saleOrderRow(doc, partyNames);
      if (!_matchesOrderQuery(row, query)) continue;
      rows.add(row);
    }
  }

  if (_matchesTypeFilter('purchase', query.documentType)) {
    for (final doc in purchaseOrders) {
      if (!_inRange(doc.documentDate, range)) continue;
      if (query.partyId != null &&
          query.partyId!.isNotEmpty &&
          doc.partyId != query.partyId) {
        continue;
      }
      final row = _purchaseOrderRow(doc, partyNames);
      if (!_matchesOrderQuery(row, query)) continue;
      rows.add(row);
    }
  }

  rows.sort((a, b) => b.date.compareTo(a.date));

  var totalAmount = 0.0;
  for (final row in rows) {
    totalAmount += row.amount;
  }

  final page = query.page < 1 ? 1 : query.page;
  final limit = query.limit < 1 ? 20 : query.limit;
  final start = (page - 1) * limit;
  final pageRows = start >= rows.length
      ? const <ReportOrderRow>[]
      : rows.skip(start).take(limit).toList();

  return SalePurchaseOrdersReportData(
    rows: pageRows,
    totalAmount: totalAmount,
    meta: ReportPaginationMeta(
      page: page,
      limit: limit,
      total: rows.length,
      totalPages: rows.isEmpty ? 0 : (rows.length / limit).ceil(),
    ),
  );
}

bool _inRange(String documentDate, DateTimeRange range) {
  final day = parseDocumentCalendarDay(documentDate);
  if (day == null) return false;
  return isCalendarDayInRange(day, range);
}
