import 'package:billing_baba/features/parties/utils/walk_in_party_ids.dart';
import 'package:billing_baba/features/pos/pos_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const businessId = '6a045480-38d0-4a89-8d0f-74e2670807b4';

  group('walkInPartyIdForBusiness', () {
    test('is deterministic per business', () {
      expect(
        walkInPartyIdForBusiness(businessId),
        walkInPartyIdForBusiness(businessId),
      );
      expect(
        walkInPartyIdForBusiness(businessId),
        isNot(walkInPartyIdForBusiness('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb')),
      );
    });
  });

  group('isWalkInPartyId', () {
    test('recognizes legacy and scoped walk-in ids', () {
      expect(isWalkInPartyId(businessId, PosConstants.walkInPartyId), isTrue);
      expect(
        isWalkInPartyId(businessId, walkInPartyIdForBusiness(businessId)),
        isTrue,
      );
      expect(
        isWalkInPartyId(businessId, 'cccccccc-cccc-cccc-cccc-cccccccccccc'),
        isFalse,
      );
    });
  });
}
