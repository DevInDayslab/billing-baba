enum GlobalSearchResultType {
  party,
  item,
  saleInvoice,
  purchaseBill,
  expense,
  payment,
}

class GlobalSearchResult {
  const GlobalSearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.route,
    this.statusLabel,
  });

  final GlobalSearchResultType type;
  final String id;
  final String title;
  final String subtitle;

  /// Optional route override (e.g. payment in vs payment out).
  final String? route;

  /// Optional payment/document status shown beside the subtitle.
  final String? statusLabel;
}
