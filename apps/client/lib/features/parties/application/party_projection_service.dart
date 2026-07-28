import 'package:billing_baba/features/parties/data/party_ledger_local_data_source.dart';
import 'package:billing_baba/features/parties/data/party_timeline_sources.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_projection_model.dart';
import 'package:billing_baba/features/parties/models/party_timeline_row.dart';
import 'package:billing_baba/features/parties/utils/party_timeline_utils.dart';

class _LedgerEntryDraft {
  const _LedgerEntryDraft({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.entryType,
    required this.debit,
    required this.credit,
    this.referenceId,
    this.referenceType,
  });

  final String id;
  final String date;
  final DateTime createdAt;
  final String entryType;
  final double debit;
  final double credit;
  final String? referenceId;
  final String? referenceType;
}

class PartyProjectionService {
  PartyProjectionService(this._local);

  final PartyLedgerLocalDataSource _local;

  final Map<String, PartyProjection> _cache = {};

  void invalidateCache({String? partyId}) {
    if (partyId == null) {
      _cache.clear();
      _outstandingIndexCache.clear();
      return;
    }
    _cache.removeWhere((key, _) => key.endsWith(':$partyId'));
    _outstandingIndexCache.clear();
  }

  final Map<String, Map<String, double>> _outstandingIndexCache = {};

  /// Computes projected outstanding balances for all parties in one pass.
  Future<Map<String, double>> buildOutstandingIndex({
    required String businessId,
  }) async {
    final cacheKey = businessId;
    final cached = _outstandingIndexCache[cacheKey];
    if (cached != null) return cached;

    final salesDocs = await _local.listAllSalesDocuments(businessId);
    final purchaseDocs = await _local.listAllPurchaseDocuments(businessId);

    final salesByParty = <String, List<PartyDocumentSnapshot>>{};
    for (final doc in salesDocs) {
      final partyId = _partyIdFromSalesDoc(doc);
      if (partyId == null) continue;
      salesByParty.putIfAbsent(partyId, () => []).add(doc);
    }

    final purchaseByParty = <String, List<PartyDocumentSnapshot>>{};
    for (final doc in purchaseDocs) {
      final partyId = _partyIdFromPurchaseDoc(doc);
      if (partyId == null) continue;
      purchaseByParty.putIfAbsent(partyId, () => []).add(doc);
    }

    final partyIds = {...salesByParty.keys, ...purchaseByParty.keys};
    final index = <String, double>{};

    for (final partyId in partyIds) {
      final party = await _local.getParty(partyId);
      if (party == null) continue;
      final openingBalance = parseTimelineMoney(party.openingBalance);
      final entries = _buildLedgerEntries(
        salesByParty[partyId] ?? const [],
        purchaseByParty[partyId] ?? const [],
      );
      index[partyId] = _computeOutstanding(openingBalance, entries);
    }

    _outstandingIndexCache[cacheKey] = index;
    return index;
  }

  String? _partyIdFromSalesDoc(PartyDocumentSnapshot doc) => doc.partyId;

  String? _partyIdFromPurchaseDoc(PartyDocumentSnapshot doc) => doc.partyId;

  Future<PartyProjection> buildProjection({
    required String businessId,
    required String partyId,
    PartyLedgerFilter filter = PartyLedgerFilter.all,
  }) async {
    final cacheKey = '$businessId:$partyId:${filter.name}';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final party = await _local.getParty(partyId);
    if (party == null) {
      throw StateError('Party not found in local database');
    }

    final partyKind = resolvePartyKind(party.partyType);
    final ctx = (
      businessId: businessId,
      partyId: partyId,
      partyKind: partyKind,
      dataSource: _local,
    );

    final sourceRows = await Future.wait(
      partyTimelineSources.map((source) => source.fetch(ctx)),
    );

    final timeline = sourceRows.expand((rows) => rows).toList();
    timeline.sort((a, b) {
      final createdCompare = b.createdAt.compareTo(a.createdAt);
      if (createdCompare != 0) return createdCompare;
      return b.documentDate.compareTo(a.documentDate);
    });

    final salesDocs = await _local.listSalesDocumentsForParty(
      businessId: businessId,
      partyId: partyId,
    );
    final purchaseDocs = await _local.listPurchaseDocumentsForParty(
      businessId: businessId,
      partyId: partyId,
    );

    final openingBalance = parseTimelineMoney(party.openingBalance);
    final ledgerEntries = _buildLedgerEntries(salesDocs, purchaseDocs);
    final outstanding = _computeOutstanding(openingBalance, ledgerEntries);
    final documentTotals = _computeDocumentTotals(salesDocs, purchaseDocs);

    DateTime? lastTransactionDate;
    for (final entry in ledgerEntries) {
      final parsed = DateTime.tryParse('${entry.date}T00:00:00.000');
      if (parsed == null) continue;
      if (lastTransactionDate == null || parsed.isAfter(lastTransactionDate)) {
        lastTransactionDate = parsed;
      }
    }

    final filteredTimeline = applyTimelineFilter(timeline, filter);
    final transactions = filteredTimeline.map(_toTransaction).toList();

    final creditLimit = double.tryParse(party.creditLimit);

    final summary = PartyLedgerSummaryModel(
      openingBalance: openingBalance,
      outstanding: outstanding,
      receiveAmount: outstanding > 0 ? outstanding : 0,
      payableAmount: outstanding < 0 ? -outstanding : 0,
      creditLimit: creditLimit,
      isActive: party.isActive,
      lastTransactionDate: lastTransactionDate,
      totalSales: documentTotals.totalSales,
      totalPurchases: documentTotals.totalPurchases,
      totalPayments: documentTotals.totalPayments,
    );

    final ledger = PartyLedgerModel(
      partyId: partyId,
      summary: summary,
      transactions: transactions,
    );

    final invoiceCount = salesDocs
        .where(
          (doc) =>
              doc.status == 'finalized' &&
              revenueSalesTypes.contains(doc.documentType),
        )
        .length;
    final invoiceTotal = documentTotals.totalSales;
    final averageInvoice = invoiceCount > 0 ? invoiceTotal / invoiceCount : 0;

    final returnTotal =
        salesDocs
            .where((doc) => doc.documentType == 'sales_return')
            .fold<double>(
              0,
              (sum, doc) => sum + parseTimelineMoney(doc.totalAmount),
            ) +
        purchaseDocs
            .where((doc) => doc.documentType == 'purchase_return')
            .fold<double>(
              0,
              (sum, doc) => sum + parseTimelineMoney(doc.totalAmount),
            );

    final pendingAmount = timeline.fold<double>(
      0,
      (sum, row) => sum + row.balance,
    );

    final lastActivity = timeline.isEmpty
        ? null
        : timeline
              .map((row) => row.createdAt)
              .reduce((a, b) => a.isAfter(b) ? a : b);

    final projection = PartyProjection(
      partyId: partyId,
      ledger: ledger,
      outstanding: outstanding,
      receivable: summary.receiveAmount,
      payable: summary.payableAmount,
      openingBalance: openingBalance,
      currentBalance: outstanding,
      lastTransaction: lastTransactionDate,
      transactionCount: timeline.length,
      totalSales: documentTotals.totalSales,
      totalPurchases: documentTotals.totalPurchases,
      totalPayments: documentTotals.totalPayments,
      totalReturns: returnTotal,
      averageInvoiceValue: averageInvoice.toDouble(),
      pendingAmount: pendingAmount,
      lastActivity: lastActivity,
      syncStatus: PartyProjectionSyncStatus.local,
    );

    _cache[cacheKey] = projection;
    return projection;
  }

  Future<PartyLedgerModel> buildLedger({
    required String businessId,
    required String partyId,
    PartyLedgerFilter filter = PartyLedgerFilter.all,
  }) async {
    final projection = await buildProjection(
      businessId: businessId,
      partyId: partyId,
      filter: filter,
    );
    return projection.ledger;
  }

  List<_LedgerEntryDraft> _buildLedgerEntries(
    List<PartyDocumentSnapshot> salesDocs,
    List<PartyDocumentSnapshot> purchaseDocs,
  ) {
    final entries = <_LedgerEntryDraft>[];

    for (final doc in salesDocs) {
      if (doc.status != 'finalized') continue;
      if (!ledgerSalesDocumentTypes.contains(doc.documentType)) continue;

      final total = parseTimelineMoney(doc.totalAmount);
      final paid = parseTimelineMoney(doc.paidAmount);
      final isReturn = doc.documentType == 'sales_return';

      entries.add(
        _LedgerEntryDraft(
          id: 'sale:${doc.id}',
          date: doc.documentDate,
          createdAt: doc.createdAt,
          entryType: isReturn ? 'return' : 'sale',
          debit: isReturn ? 0 : total,
          credit: isReturn ? total : 0,
          referenceId: doc.id,
          referenceType: 'sales_documents',
        ),
      );

      if (paid > 0) {
        entries.add(
          _LedgerEntryDraft(
            id: 'sale-pay:${doc.id}',
            date: doc.documentDate,
            createdAt: doc.createdAt,
            entryType: 'payment',
            debit: 0,
            credit: paid,
            referenceId: doc.id,
            referenceType: 'sales_documents',
          ),
        );
      }
    }

    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (!ledgerPurchaseDocumentTypes.contains(doc.documentType)) continue;

      final total = parseTimelineMoney(doc.totalAmount);
      final paid = parseTimelineMoney(doc.paidAmount);
      final isReturn = doc.documentType == 'purchase_return';

      entries.add(
        _LedgerEntryDraft(
          id: 'purchase:${doc.id}',
          date: doc.documentDate,
          createdAt: doc.createdAt,
          entryType: isReturn ? 'return' : 'purchase',
          debit: isReturn ? total : 0,
          credit: isReturn ? 0 : total,
          referenceId: doc.id,
          referenceType: 'purchase_documents',
        ),
      );

      if (paid > 0) {
        entries.add(
          _LedgerEntryDraft(
            id: 'purchase-pay:${doc.id}',
            date: doc.documentDate,
            createdAt: doc.createdAt,
            entryType: 'payment',
            debit: paid,
            credit: 0,
            referenceId: doc.id,
            referenceType: 'purchase_documents',
          ),
        );
      }
    }

    return entries;
  }

  double _computeOutstanding(
    double openingBalance,
    List<_LedgerEntryDraft> entries,
  ) {
    final delta = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.debit - entry.credit,
    );
    return openingBalance + delta;
  }

  ({
    double totalSales,
    double totalPurchases,
    double totalPayments,
  })
  _computeDocumentTotals(
    List<PartyDocumentSnapshot> salesDocs,
    List<PartyDocumentSnapshot> purchaseDocs,
  ) {
    var totalSales = 0.0;
    var totalPayments = 0.0;

    for (final doc in salesDocs) {
      if (doc.status != 'finalized') continue;
      if (revenueSalesTypes.contains(doc.documentType)) {
        totalSales += parseTimelineMoney(doc.totalAmount);
      }
      totalPayments += parseTimelineMoney(doc.paidAmount);
    }

    var totalPurchases = 0.0;
    for (final doc in purchaseDocs) {
      if (doc.status != 'finalized') continue;
      if (doc.documentType == 'purchase_bill') {
        totalPurchases += parseTimelineMoney(doc.totalAmount);
      }
    }

    return (
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalPayments: totalPayments,
    );
  }

  PartyLedgerTransactionModel _toTransaction(PartyTimelineRow row) {
    final mapped = mapTimelineDebitCredit(row);
    return PartyLedgerTransactionModel(
      id: row.id,
      date: row.documentDate,
      createdAt: row.createdAt,
      type: row.type,
      entryType: mapTimelineEntryType(row),
      source: row.source,
      sourceType: row.sourceType,
      referenceId: row.referenceId,
      referenceType: row.referenceType,
      referenceNumber: row.referenceNumber,
      documentDate: row.documentDate,
      dueDate: row.dueDate != null
          ? DateTime.tryParse('${row.dueDate}T00:00:00.000')
          : null,
      total: row.total,
      balance: row.balance,
      status: row.status,
      debit: mapped.$1,
      credit: mapped.$2,
      balanceAfter: row.balance,
      direction: row.direction,
      paymentStatus: row.paymentStatus,
    );
  }
}
