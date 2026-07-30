import 'package:billing_baba/features/hidden_ledger/models/hidden_ledger_entry.dart';

class PaginatedHiddenLedgerEntries {
  const PaginatedHiddenLedgerEntries({
    required this.entries,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<HiddenLedgerEntryModel> entries;
  final int page;
  final int limit;
  final int total;

  int get totalPages => limit == 0 ? 1 : (total / limit).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
