enum PartyListFilter {
  all,
  toReceive,
  toPay,
  active,
  inactive;

  String get label => switch (this) {
    PartyListFilter.all => 'All',
    PartyListFilter.toReceive => 'To Receive',
    PartyListFilter.toPay => 'To Pay',
    PartyListFilter.active => 'Active',
    PartyListFilter.inactive => 'Inactive',
  };
}
