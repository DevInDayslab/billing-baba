/// Grouping for search result sections.
enum SearchCategory {
  page,
  command,
}

/// How a search command is executed when selected.
enum SearchActionKind {
  routeGo,
  routePush,
  showAddPartyDialog,
  showAddItemDialog,
  showPaymentInDialog,
  showPaymentOutDialog,
  openReportsGst,
  switchCompany,
}

/// Section labels shown in the search dialog.
enum SearchSectionKind {
  recentPages('Recent Pages'),
  suggestedPages('Suggested Pages'),
  pages('Pages'),
  commands('Commands');

  const SearchSectionKind(this.label);

  final String label;
}
