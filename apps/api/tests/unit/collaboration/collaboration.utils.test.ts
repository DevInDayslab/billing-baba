import { describe, expect, test } from 'bun:test';
import { generateInvitationToken } from '../../../src/modules/collaboration/collaboration.repository';
import {
  isEmail,
  normalizePhone,
  parseContact,
  relationshipFromRole,
  roleDisplayLabel,
} from '../../../src/modules/collaboration/collaboration.utils';

describe('collaboration.utils', () => {
  test('normalizePhone formats Indian 10-digit numbers', () => {
    expect(normalizePhone('9876543210')).toBe('+919876543210');
    expect(normalizePhone('+91 98765 43210')).toBe('+919876543210');
  });

  test('parseContact distinguishes email and phone', () => {
    expect(parseContact('user@example.com')).toEqual({
      phone: null,
      email: 'user@example.com',
    });
    expect(parseContact('9876543210').phone).toBe('+919876543210');
  });

  test('isEmail validates addresses', () => {
    expect(isEmail('user@example.com')).toBe(true);
    expect(isEmail('not-an-email')).toBe(false);
  });

  test('relationshipFromRole maps secondary admin', () => {
    expect(relationshipFromRole('secondary_admin')).toBe('secondary_admin');
    expect(relationshipFromRole('biller')).toBe('member');
  });

  test('roleDisplayLabel returns human-readable labels', () => {
    expect(roleDisplayLabel('biller')).toBe('Biller');
    expect(roleDisplayLabel('accountant_edit_access')).toBe(
      'CA / Accountant (Edit Access)',
    );
  });
});

describe('generateInvitationToken', () => {
  test('generates unique 6-char alphanumeric codes', () => {
    const a = generateInvitationToken();
    const b = generateInvitationToken();
    expect(a).toHaveLength(6);
    expect(b).toHaveLength(6);
    expect(a).not.toBe(b);
    expect(/^[A-Z2-9]+$/.test(a)).toBe(true);
  });
});
