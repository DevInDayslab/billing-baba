import 'package:billing_baba/features/parties/models/party_model.dart';

class PartyGroupSummary {
  const PartyGroupSummary({
    required this.name,
    required this.partyCount,
    required this.totalReceivable,
    required this.totalPayable,
    required this.netBalance,
  });

  factory PartyGroupSummary.fromGroup(
    String groupName,
    List<PartyModel> parties,
  ) {
    final members = parties
        .where((party) => party.partyGroup.trim() == groupName)
        .toList();

    var totalReceivable = 0.0;
    var totalPayable = 0.0;
    for (final party in members) {
      if (party.hasReceivable) {
        totalReceivable += party.balance;
      } else if (party.hasPayable) {
        totalPayable += party.balance.abs();
      }
    }

    return PartyGroupSummary(
      name: groupName,
      partyCount: members.length,
      totalReceivable: totalReceivable,
      totalPayable: totalPayable,
      netBalance: totalReceivable - totalPayable,
    );
  }

  final String name;
  final int partyCount;
  final double totalReceivable;
  final double totalPayable;
  final double netBalance;
}
