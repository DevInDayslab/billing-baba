import { describe, expect, test } from 'bun:test';
import { applyHiddenLedgerVisibility } from '../../../src/shared/hidden-ledger/party-hidden-ledger';
import { canViewHiddenLedger } from '../../../src/shared/hidden-ledger/hidden-ledger-access';
import type { PartyRecord } from '../../../src/modules/parties/party.types';

const sampleParty: PartyRecord = {
  id: 'party-1',
  name: 'Test Party',
  mobile: null,
  email: null,
  party_type: 'customer',
  party_category: null,
  pricing_tier: 'tier_1',
  default_price_tier: 'tier_1',
  gstin: null,
  state_code: null,
  state: null,
  area_id: null,
  credit_limit: '0',
  opening_balance: '0',
  balance: '0',
  hidden_ledger_balance: '150.00',
  is_active: true,
  notes: null,
  profile_image_url: null,
  profile_media_asset_id: null,
  created_at: '2026-01-01T00:00:00.000Z',
  updated_at: '2026-01-01T00:00:00.000Z',
};

describe('hidden ledger access', () => {
  test('owner and manager may view hidden ledger', () => {
    expect(canViewHiddenLedger('owner')).toBe(true);
    expect(canViewHiddenLedger('manager')).toBe(true);
  });

  test('staff roles cannot view hidden ledger', () => {
    expect(canViewHiddenLedger('staff')).toBe(false);
    expect(canViewHiddenLedger(undefined)).toBe(false);
  });
});

describe('applyHiddenLedgerVisibility', () => {
  test('keeps hidden_ledger_balance for authorized roles', () => {
    const visible = applyHiddenLedgerVisibility(sampleParty, 'owner');
    expect(visible.hidden_ledger_balance).toBe('150.00');
  });

  test('strips hidden_ledger_balance for staff roles', () => {
    const visible = applyHiddenLedgerVisibility(sampleParty, 'staff');
    expect(visible.hidden_ledger_balance).toBeUndefined();
    expect(visible.name).toBe('Test Party');
  });
});
