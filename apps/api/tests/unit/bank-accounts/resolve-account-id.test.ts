import { describe, expect, test } from 'bun:test';
import { decideResolveAccount } from '../../../src/modules/bank-accounts/domain/resolve-account-id-decision';

describe('decideResolveAccount', () => {
  test('uses provided account when set', () => {
    const id = '00000000-0000-4000-8000-000000000001';
    expect(decideResolveAccount('upi', id)).toEqual({
      kind: 'use_provided',
      accountId: id,
    });
  });

  test('cash mode resolves to cash account', () => {
    expect(decideResolveAccount('cash', null)).toEqual({ kind: 'use_cash' });
  });

  test('non-cash without id uses default bank', () => {
    expect(decideResolveAccount('card', null)).toEqual({
      kind: 'use_default_bank',
    });
  });
});
