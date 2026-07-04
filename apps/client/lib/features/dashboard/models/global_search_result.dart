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
  });

  final GlobalSearchResultType type;
  final String id;
  final String title;
  final String subtitle;
}
