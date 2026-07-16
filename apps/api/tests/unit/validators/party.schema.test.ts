import { describe, expect, test } from 'bun:test';
import { createPartyBodySchema } from '../../../src/modules/parties/party.schema';

describe('party.schema', () => {
  test('accepts a valid party payload', () => {
    const result = createPartyBodySchema.safeParse({
      name: 'Acme Traders',
      party_type: 'customer',
      mobile: '9876543210',
      email: 'billing@acme.test',
      gstin: '27AABCU9603R1ZM',
      opening_balance: '100.50',
    });

    expect(result.success).toBe(true);
  });

  test('rejects invalid GSTIN and email', () => {
    const result = createPartyBodySchema.safeParse({
      name: 'Acme Traders',
      email: 'not-an-email',
      gstin: 'BAD-GSTIN',
    });

    expect(result.success).toBe(false);
  });

  test('requires a party name', () => {
    const result = createPartyBodySchema.safeParse({
      name: '   ',
    });

    expect(result.success).toBe(false);
  });
});
