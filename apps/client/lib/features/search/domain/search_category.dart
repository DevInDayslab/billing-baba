/// Grouping for search result sections.
enum SearchCategory {
  page,
  command,
}

/// How a search item is executed when selected.
enum SearchActionKind {
  routeGo,
  routePush,
  showAddPartyDialog,
  showAddItemDialog,
  showPaymentInDialog,
  showPaymentOutDialog,
  openReport,
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
