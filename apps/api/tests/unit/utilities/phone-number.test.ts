import { describe, expect, test } from 'bun:test';
import {
  maskPhoneE164,
  normalizeIndianMobile,
  toWhatsAppAddress,
} from '../../../src/shared/utils/phone-number';

describe('normalizeIndianMobile', () => {
  const cases: Array<[string, string]> = [
    ['8920108002', '+918920108002'],
    ['98920108002', '+918920108002'],
    ['+918920108002', '+918920108002'],
    ['08920108002', '+918920108002'],
    ['91 89201 08002', '+918920108002'],
    ['+91 89201-08002', '+918920108002'],
    ['098920108002', '+918920108002'],
    ['9876543210', '+919876543210'],
  ];

  for (const [input, expected] of cases) {
    test(`normalizes ${JSON.stringify(input)}`, () => {
      const result = normalizeIndianMobile(input);
      expect(result.ok).toBe(true);
      if (result.ok) {
        expect(result.e164).toBe(expected);
      }
    });
  }

  test('rejects empty', () => {
    const result = normalizeIndianMobile('   ');
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error.code).toBe('EMPTY');
  });

  test('rejects landline-like numbers starting with 2', () => {
    const result = normalizeIndianMobile('2123456789');
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error.code).toBe('NOT_MOBILE');
  });

  test('rejects garbage', () => {
    const result = normalizeIndianMobile('not-a-phone');
    expect(result.ok).toBe(false);
  });
});

describe('maskPhoneE164', () => {
  test('masks middle digits', () => {
    expect(maskPhoneE164('+918920108002')).toBe('+91******8002');
  });
});

describe('toWhatsAppAddress', () => {
  test('prefixes Indian E.164', () => {
    expect(toWhatsAppAddress('+918920108002')).toBe('whatsapp:+918920108002');
  });

  test('allows Twilio sandbox US numbers as from', () => {
    expect(toWhatsAppAddress('+14155238886')).toBe('whatsapp:+14155238886');
  });
});
