import 'package:billing_baba/features/parties/utils/party_group_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mergePartyGroupNames dedupes case-insensitively', () {
    expect(
      mergePartyGroupNames(['Retail', 'retail', 'Wholesale']),
      ['Retail', 'Wholesale'],
    );
  });

  test('mergePartyGroupNames keeps first casing and sorts', () {
    expect(
      mergePartyGroupNames(['zeta', 'Alpha', 'alpha']),
      ['Alpha', 'zeta'],
    );
  });

  test('partyGroupNameExists is case-insensitive', () {
    expect(partyGroupNameExists(['Retail'], 'retail'), isTrue);
    expect(partyGroupNameExists(['Retail'], 'Wholesale'), isFalse);
  });
}
