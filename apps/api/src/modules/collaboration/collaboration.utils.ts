import type { CollaborationRole } from './collaboration.types';

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function isEmail(value: string): boolean {
  return EMAIL_REGEX.test(value.trim());
}

export function normalizePhone(value: string): string {
  const trimmed = value.trim().replace(/[\s-]/g, '');
  if (trimmed.startsWith('+')) {
    return trimmed;
  }
  if (trimmed.startsWith('91') && trimmed.length === 12) {
    return `+${trimmed}`;
  }
  if (/^\d{10}$/.test(trimmed)) {
    return `+91${trimmed}`;
  }
  return trimmed;
}

export function parseContact(phoneOrEmail: string): {
  phone: string | null;
  email: string | null;
} {
  const trimmed = phoneOrEmail.trim();
  if (isEmail(trimmed)) {
    return { phone: null, email: trimmed.toLowerCase() };
  }
  return { phone: normalizePhone(trimmed), email: null };
}

export function formatPhoneOrEmail(
  phone: string | null,
  email: string | null,
): string {
  return phone ?? email ?? '';
}

export function deriveInvitationChannel(
  _phone: string | null,
  email: string | null,
): 'sms' | 'whatsapp' | 'email' {
  if (email) return 'email';
  return 'sms';
}

export function roleDisplayLabel(role: CollaborationRole): string {
  const labels: Record<CollaborationRole, string> = {
    secondary_admin: 'Secondary Admin',
    salesman: 'Salesman',
    biller: 'Biller',
    biller_and_salesman: 'Biller and Salesman',
    accountant: 'CA / Accountant',
    accountant_edit_access: 'CA / Accountant (Edit Access)',
    stock_keeper: 'Stock Keeper',
  };
  return labels[role];
}

export function relationshipFromRole(
  role: CollaborationRole,
): 'secondary_admin' | 'member' {
  return role === 'secondary_admin' ? 'secondary_admin' : 'member';
}

export function addDays(date: Date, days: number): Date {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

export function isExpired(expiresAt: Date, now = new Date()): boolean {
  return expiresAt.getTime() < now.getTime();
}
