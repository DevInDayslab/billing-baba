import 'package:billing_baba/features/parties/data/party_ledger_local_data_source.dart';
import 'package:billing_baba/features/parties/models/party_timeline_row.dart';
import 'package:billing_baba/features/parties/utils/party_timeline_labels.dart';
import 'package:billing_baba/features/parties/utils/party_timeline_utils.dart';

typedef PartyTimelineFetchContext = ({
  String businessId,
  String partyId,
  PartyKind partyKind,
  PartyLedgerLocalDataSource dataSource,
});

/// Extensible hook for future command-synced document types (quotation, PO, etc.).
abstract class PartyTimelineSource {
  const PartyTimelineSource();

  List<PartyKind> get partyKinds;

  Future<List<PartyTimelineRow>> fetch(PartyTimelineFetchContext ctx);
}

class SalesDocumentsTimelineSource extends PartyTimelineSource {
  const SalesDocumentsTimelineSource();

  @override
  List<PartyKind> get partyKinds => const [PartyKind.customer, PartyKind.both];

  @override
  Future<List<PartyTimelineRow>> fetch(PartyTimelineFetchContext ctx) async {
    if (!partyKindMatches(ctx.partyKind, partyKinds)) return const [];

    final docs = await ctx.dataSource.listSalesDocumentsForParty(
      businessId: ctx.businessId,
      partyId: ctx.partyId,
    );

    return docs.map(_mapRow).toList();
  }

  PartyTimelineRow _mapRow(PartyDocumentSnapshot row) {
    final total = parseTimelineMoney(row.totalAmount);
    final paid = parseTimelineMoney(row.paidAmount);
    final isInvoice = isReceivableSalesDocument(row.documentType);
    final isReturn = row.documentType == 'sales_return';
    final balance =
        (isInvoice || isReturn ? (total - paid).clamp(0, total) : total)
            .toDouble();

    final paymentStatus = isInvoice || isReturn
        ? resolveInvoicePaymentStatus(total, paid)
        : null;

    final lifecycleStatus = resolveSalesDocumentLifecycleStatus(
      row.documentType,
      row.status,
    );

    final status = lifecycleStatus ?? paymentStatus;

    return PartyTimelineRow(
      id: row.id,
      source: 'sales_documents',
      sourceType: row.documentType,
      type: resolveTimelineTypeLabel(
        source: 'sales_documents',
        sourceType: row.documentType,
        documentSeries: row.documentSeries,
      ),
      referenceId: row.id,
      referenceType: 'sales_documents',
      referenceNumber: row.documentNumber,
      createdAt: row.createdAt.toLocal(),
      documentDate: _parseDocumentDate(row.documentDate),
      total: total,
      balance: balance,
      status: status,
      paymentStatus: paymentStatus,
    );
  }
}

class PurchaseDocumentsTimelineSource extends PartyTimelineSource {
  const PurchaseDocumentsTimelineSource();

  @override
  List<PartyKind> get partyKinds => const [PartyKind.supplier, PartyKind.both];

  @override
  Future<List<PartyTimelineRow>> fetch(PartyTimelineFetchContext ctx) async {
    if (!partyKindMatches(ctx.partyKind, partyKinds)) return const [];

    final docs = await ctx.dataSource.listPurchaseDocumentsForParty(
      businessId: ctx.businessId,
      partyId: ctx.partyId,
    );

    return docs.map(_mapRow).toList();
  }

  PartyTimelineRow _mapRow(PartyDocumentSnapshot row) {
    final total = parseTimelineMoney(row.totalAmount);
    final paid = parseTimelineMoney(row.paidAmount);
    final isBill = payablePurchaseDocumentTypes.contains(row.documentType);
    final isReturn = row.documentType == 'purchase_return';
    final balance =
        (isBill || isReturn ? (total - paid).clamp(0, total) : total)
            .toDouble();

    final paymentStatus = isBill || isReturn
        ? resolveInvoicePaymentStatus(total, paid)
        : null;

    var status = paymentStatus;
    if (isBill && paymentStatus == 'Unpaid' && row.dueDate != null) {
      status = resolveOverdueStatus(row.dueDate) ?? paymentStatus;
    }

    return PartyTimelineRow(
      id: row.id,
      source: 'purchase_documents',
      sourceType: row.documentType,
      type: resolveTimelineTypeLabel(
        source: 'purchase_documents',
        sourceType: row.documentType,
      ),
      referenceId: row.id,
      referenceType: 'purchase_documents',
      referenceNumber: row.documentNumber,
      createdAt: row.createdAt.toLocal(),
      documentDate: _parseDocumentDate(row.documentDate),
      dueDate: row.dueDate,
      total: total,
      balance: balance,
      status: status,
      paymentStatus: paymentStatus,
    );
  }
}

/// Register additional sources here as modules gain command-sync coverage.
const partyTimelineSources = <PartyTimelineSource>[
  SalesDocumentsTimelineSource(),
  PurchaseDocumentsTimelineSource(),
];

DateTime _parseDocumentDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return DateTime.now();
  return DateTime.tryParse('${trimmed}T00:00:00.000') ??
      DateTime.tryParse(trimmed) ??
      DateTime.now();
}
