/// Filters the party list by customer/supplier role.
enum PartyTypeFilter {
  all,
  customer,
  supplier;

  String get label => switch (this) {
    PartyTypeFilter.all => 'All',
    PartyTypeFilter.customer => 'Customers',
    PartyTypeFilter.supplier => 'Suppliers',
  };

  bool matches(String partyType) => switch (this) {
    PartyTypeFilter.all => true,
    PartyTypeFilter.customer => partyType == 'customer' || partyType == 'both',
    PartyTypeFilter.supplier => partyType == 'supplier' || partyType == 'both',
  };
}
