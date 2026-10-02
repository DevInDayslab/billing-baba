import { describe, expect, test } from 'bun:test';
import {
  isWalkInPartyId,
  LEGACY_WALK_IN_PARTY_ID,
  walkInPartyIdForBusiness,
} from '../../../src/shared/parties/walk-in-party';

describe('walkInPartyIdForBusiness', () => {
  test('is deterministic per business', () => {
    const businessId = '6a045480-38d0-4a89-8d0f-74e2670807b4';
    expect(walkInPartyIdForBusiness(businessId)).toBe(
      walkInPartyIdForBusiness(businessId),
    );
    expect(walkInPartyIdForBusiness(businessId)).not.toBe(
      walkInPartyIdForBusiness('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
    );
  });

  test('recognizes legacy and scoped walk-in ids', () => {
    const businessId = '6a045480-38d0-4a89-8d0f-74e2670807b4';
    expect(isWalkInPartyId(businessId, LEGACY_WALK_IN_PARTY_ID)).toBe(true);
    expect(
      isWalkInPartyId(businessId, walkInPartyIdForBusiness(businessId)),
    ).toBe(true);
    expect(
      isWalkInPartyId(businessId, 'cccccccc-cccc-cccc-cccc-cccccccccccc'),
    ).toBe(false);
  });
});
