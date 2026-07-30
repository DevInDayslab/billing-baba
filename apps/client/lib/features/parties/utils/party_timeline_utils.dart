import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_timeline_row.dart';

enum PartyKind { customer, supplier, both }

const revenueSalesTypes = <String>{
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
};

const lifecycleSalesDocumentTypes = <String>{
  'estimate',
  'sale_order',
  'delivery_challan',
};

const payablePurchaseDocumentTypes = <String>{'purchase_bill'};

const ledgerSalesDocumentTypes = <String>{
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
  'sales_return',
};

const ledgerPurchaseDocumentTypes = <String>{
  'purchase_bill',
  'purchase_return',
};

PartyKind resolvePartyKind(String partyType) {
  if (partyType == 'supplier') return PartyKind.supplier;
  if (partyType == 'both') return PartyKind.both;
  return PartyKind.customer;
}

bool partyKindMatches(PartyKind partyKind, List<PartyKind> allowed) {
  if (allowed.contains(PartyKind.both)) return true;
  if (partyKind == PartyKind.both) return true;
  return allowed.contains(partyKind);
}

double parseTimelineMoney(String? value) => double.tryParse(value ?? '') ?? 0;

String? resolveInvoicePaymentStatus(double total, double paid) {
  if (total <= 0) return null;
  if (paid >= total) return 'Paid';
  if (paid > 0) return 'Partial';
  return 'Unpaid';
}

String? resolveOverdueStatus(String? dueDate) {
  if (dueDate == null || dueDate.trim().isEmpty) return null;

  final due = DateTime.tryParse('${dueDate.trim()}T00:00:00.000');
  if (due == null) return null;

  final today = DateTime.now();
  final todayUtc = DateTime(today.year, today.month, today.day);
  final dueUtc = DateTime(due.year, due.month, due.day);
  if (!dueUtc.isBefore(todayUtc)) return null;

  final diffDays = todayUtc.difference(dueUtc).inDays.clamp(1, 9999);
  return 'Overdue $diffDays Day${diffDays == 1 ? '' : 's'}';
}

String? resolveSalesDocumentLifecycleStatus(
  String documentType,
  String documentStatus,
) {
  if (!lifecycleSalesDocumentTypes.contains(documentType)) return null;

  return switch (documentStatus) {
    'finalized' => 'Open',
    'converted' => 'Converted',
    'cancelled' => 'Cancelled',
    'draft' => 'Draft',
    _ => null,
  };
}

bool isReceivableSalesDocument(String sourceType) =>
    revenueSalesTypes.contains(sourceType);

List<PartyTimelineRow> applyTimelineFilter(
  List<PartyTimelineRow> rows,
  PartyLedgerFilter filter,
) {
  if (filter == PartyLedgerFilter.all) return rows;
  return rows.where((row) => filter.matches(_toTransaction(row))).toList();
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

String mapTimelineEntryType(PartyTimelineRow row) {
  if (row.source == 'payments') return 'payment';
  if (row.source == 'expenses') return 'expense';
  if (row.sourceType == 'sales_return' || row.sourceType == 'purchase_return') {
    return 'return';
  }
  if (row.source == 'purchase_documents') return 'purchase';
  if (row.source == 'sales_documents' &&
      isReceivableSalesDocument(row.sourceType)) {
    return 'sale';
  }
  return row.sourceType;
}

(double debit, double credit) mapTimelineDebitCredit(PartyTimelineRow row) {
  final total = row.total;

  if (row.source == 'payments') {
    if (row.direction == 'paid') {
      return (total, 0);
    }
    return (0, total);
  }

  if (row.source == 'purchase_documents') {
    if (row.sourceType == 'purchase_return') {
      return (0, total);
    }
    return (total, 0);
  }

  if (row.sourceType == 'sales_return') {
    return (total, 0);
  }

  return (0, total);
}
