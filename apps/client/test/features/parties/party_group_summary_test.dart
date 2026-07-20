import 'package:billing_baba/features/parties/models/party_group_summary.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PartyGroupSummary', () {
    test('fromGroup counts members and balances from unfiltered parties', () {
      const parties = [
        PartyModel(
          id: '1',
          name: 'Alpha',
          phone: '9000000001',
          partyGroup: 'Distributors',
          balance: 100,
        ),
        PartyModel(
          id: '2',
          name: 'Beta',
          phone: '9000000002',
          partyGroup: 'Distributors',
          balance: -50,
        ),
        PartyModel(
          id: '3',
          name: 'Gamma',
          phone: '9000000003',
          partyGroup: 'Retailers',
          balance: 0,
        ),
      ];

      final distributors = PartyGroupSummary.fromGroup('Distributors', parties);
      expect(distributors.partyCount, 2);
      expect(distributors.totalReceivable, 100);
      expect(distributors.totalPayable, 50);
      expect(distributors.netBalance, 50);

      final retailers = PartyGroupSummary.fromGroup('Retailers', parties);
      expect(retailers.partyCount, 1);
      expect(retailers.netBalance, 0);
    });

    test('fromGroup trims party group names when matching', () {
      const parties = [
        PartyModel(
          id: '1',
          name: 'Alpha',
          phone: '9000000001',
          partyGroup: '  Wholesale  ',
          balance: 10,
        ),
      ];

      final summary = PartyGroupSummary.fromGroup('Wholesale', parties);
      expect(summary.partyCount, 1);
    });
  });
}
