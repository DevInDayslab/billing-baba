enum PartyReportSubSection {
  partyStatement('Party Statement'),
  partyWiseProfitLoss('Party wise Profit & Loss'),
  allParties('All parties'),
  partyReportByItem('Party Report By Item'),
  salePurchaseByParty('Sale Purchase By Party'),
  salePurchaseByPartyGroup('Sale Purchase By Party Group');

  const PartyReportSubSection(this.label);

  final String label;
}
