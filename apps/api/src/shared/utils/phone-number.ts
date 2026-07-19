/**
 * Canonical Indian mobile phone normalization for outbound messaging.
 * All notification paths must use this — never build WhatsApp addresses elsewhere.
 */

export type PhoneNormalizeErrorCode = 'EMPTY' | 'INVALID_FORMAT' | 'NOT_MOBILE';

export type PhoneNormalizeSuccess = {
  ok: true;
  e164: string;
};

export type PhoneNormalizeFailure = {
  ok: false;
  error: {
    code: PhoneNormalizeErrorCode;
    message: string;
  };
};

export type PhoneNormalizeResult =
  | PhoneNormalizeSuccess
  | PhoneNormalizeFailure;

const INDIAN_MOBILE_BODY = /^[6-9]\d{9}$/;
const E164_GENERIC = /^\+[1-9]\d{7,14}$/;

/**
 * Normalize common Indian mobile formats to E.164 (+91XXXXXXXXXX).
 *
 * Accepts: 8920108002, 08920108002, 918920108002, 98920108002,
 * +918920108002, 91 89201 08002, +91 89201-08002, etc.
 */
export function normalizeIndianMobile(input: string): PhoneNormalizeResult {
  if (input == null || typeof input !== 'string') {
    return {
      ok: false,
      error: {
        code: 'EMPTY',
        message: 'Phone number is required',
      },
    };
  }

  let digits = input.trim().replace(/[\s\-().]/g, '');

  if (!digits) {
    return {
      ok: false,
      error: {
        code: 'EMPTY',
        message: 'Phone number is required',
      },
    };
  }

  if (digits.startsWith('+')) {
    digits = digits.slice(1);
  }

  if (!/^\d+$/.test(digits)) {
    return {
      ok: false,
      error: {
        code: 'INVALID_FORMAT',
        message: 'Phone number contains invalid characters',
      },
    };
  }

  // Trunk prefix: 08920108002 or 098920108002
  if (digits.startsWith('0')) {
    digits = digits.slice(1);
  }

  // Country code without plus: 918920108002
  if (digits.startsWith('91') && digits.length >= 12) {
    digits = digits.slice(2);
  }

  // If still longer than 10 (e.g. 98920108002), take last 10 when valid mobile
  if (digits.length > 10) {
    const last10 = digits.slice(-10);
    if (INDIAN_MOBILE_BODY.test(last10)) {
      digits = last10;
    }
  }

  if (digits.length !== 10 || !INDIAN_MOBILE_BODY.test(digits)) {
    return {
      ok: false,
      error: {
        code: digits.length === 10 ? 'NOT_MOBILE' : 'INVALID_FORMAT',
        message:
          digits.length === 10
            ? 'Phone number must be a valid Indian mobile (starting with 6-9)'
            : 'Phone number could not be normalized to a valid Indian mobile',
      },
    };
  }

  return {
    ok: true,
    e164: `+91${digits}`,
  };
}

/**
 * Backward-compatible helper. Returns E.164 on success, or '' when invalid.
 * Prefer normalizeIndianMobile for new code that needs structured errors.
 */
export function normalizePhone(value: string): string {
  const result = normalizeIndianMobile(value);
  return result.ok ? result.e164 : '';
}

/** Mask E.164 for logs: +918920108002 → +91******8002 */
export function maskPhoneE164(e164: string): string {
  const trimmed = e164.trim();
  if (trimmed.length < 8) {
    return '****';
  }
  const prefix = trimmed.startsWith('+')
    ? trimmed.slice(0, 3)
    : trimmed.slice(0, 2);
  const suffix = trimmed.slice(-4);
  return `${prefix}******${suffix}`;
}

/**
 * Build Twilio WhatsApp address from an E.164 (or already-prefixed) number.
 * Only the Twilio provider should call this.
 *
 * - Indian recipients: validated via normalizeIndianMobile
 * - Twilio from-numbers (e.g. US sandbox +1415…): any valid E.164 accepted
 */
export function toWhatsAppAddress(phone: string): string {
  const trimmed = phone.trim();
  const raw = trimmed.toLowerCase().startsWith('whatsapp:')
    ? trimmed.slice('whatsapp:'.length).trim()
    : trimmed;

  const indian = normalizeIndianMobile(raw);
  if (indian.ok) {
    return `whatsapp:${indian.e164}`;
  }

  let e164 = raw;
  if (!e164.startsWith('+')) {
    e164 = `+${e164.replace(/\D/g, '')}`;
  }
  if (!E164_GENERIC.test(e164)) {
    throw new Error(indian.error.message);
  }
  return `whatsapp:${e164}`;
}

export function isValidIndianMobile(value: string): boolean {
  return normalizeIndianMobile(value).ok;
}

export function isValidE164(value: string): boolean {
  return E164_GENERIC.test(value.trim());
}
