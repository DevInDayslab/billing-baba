class HiddenLedgerFilters {
  const HiddenLedgerFilters({
    this.partyId,
    this.status,
    this.from,
    this.to,
    this.searchQuery = '',
    this.invoiceNumber = '',
    this.page = 1,
    this.limit = 20,
  });

  final String? partyId;
  final String? status;
  final DateTime? from;
  final DateTime? to;
  final String searchQuery;
  final String invoiceNumber;
  final int page;
  final int limit;

  HiddenLedgerFilters copyWith({
    String? partyId,
    bool clearPartyId = false,
    String? status,
    bool clearStatus = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
    String? searchQuery,
    String? invoiceNumber,
    int? page,
    int? limit,
  }) {
    return HiddenLedgerFilters(
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      status: clearStatus ? null : (status ?? this.status),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      searchQuery: searchQuery ?? this.searchQuery,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
