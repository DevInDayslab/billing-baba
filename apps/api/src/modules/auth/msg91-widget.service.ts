import { AppError } from '../../shared/errors/app-error';

const MSG91_VERIFY_URL =
  'https://control.msg91.com/api/v5/widget/verifyAccessToken';

const TEN_DIGIT_MSISDN = /^\d{10}$/;

function normalizeToTenDigits(raw: string): string | undefined {
  const digits = raw.replace(/\D/g, '');
  if (digits.length >= 12 && digits.startsWith('91')) {
    const rest = digits.slice(2);
    return rest.length === 10 ? rest : undefined;
  }
  if (digits.length === 10) return digits;
  if (digits.length === 11 && digits.startsWith('0')) return digits.slice(1);
  return undefined;
}

function extractMobileFromPlainCandidate(value: unknown): string | undefined {
  if (typeof value !== 'string') return undefined;
  const trimmed = value.trim();
  if (!trimmed) return undefined;
  if (trimmed.includes('.') && trimmed.split('.').length >= 3) return undefined;
  const normalized = normalizeToTenDigits(trimmed);
  if (normalized && TEN_DIGIT_MSISDN.test(normalized)) return normalized;
  return undefined;
}

function extractMobileValue(data: unknown): string | undefined {
  if (data == null) return undefined;
  if (typeof data === 'number') {
    return extractMobileValue(String(data));
  }
  if (typeof data === 'string') {
    return extractMobileFromPlainCandidate(data);
  }
  if (typeof data !== 'object') return undefined;

  const record = data as Record<string, unknown>;
  const fromMessage = extractMobileFromPlainCandidate(record.message);
  if (fromMessage) return fromMessage;

  const directKeys = [
    'mobile',
    'Mobile',
    'phone',
    'Phone',
    'identifier',
    'number',
    'msisdn',
    'mobile_no',
    'MobileNumber',
    'phone_number',
    'PhoneNumber',
    'customerPhone',
  ];
  for (const key of directKeys) {
    const value = record[key];
    if (value !== undefined && value !== null) {
      const found = extractMobileValue(value);
      if (found) return found;
    }
  }

  for (const nested of [
    record.data,
    record.result,
    record.user,
    record.contact,
    record.payload,
  ]) {
    if (nested !== undefined && nested !== null) {
      const found = extractMobileValue(nested);
      if (found) return found;
    }
  }

  return undefined;
}

function decodeJwtPayload(jwtStr: string): Record<string, unknown> | undefined {
  const trimmed = jwtStr.trim();
  const parts = trimmed.split('.');
  if (parts.length < 2 || !parts[1]) return undefined;
  try {
    const base64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    const padded = base64.padEnd(
      base64.length + ((4 - (base64.length % 4)) % 4),
      '=',
    );
    const json = Buffer.from(padded, 'base64').toString('utf8');
    const parsed = JSON.parse(json) as unknown;
    if (parsed && typeof parsed === 'object') {
      return parsed as Record<string, unknown>;
    }
    return undefined;
  } catch {
    return undefined;
  }
}

function tryMobileFromWidgetJwt(jwtStr: string): string | undefined {
  const payload = decodeJwtPayload(jwtStr);
  if (!payload) return undefined;

  const directKeys = [
    'mobile',
    'phone',
    'identifier',
    'customerIdentifier',
    'customer_identifier',
    'msisdn',
    'contact',
    'mobileno',
    'MobileNo',
    'mobile_no',
    'customerPhone',
    'phone_number',
    'PhoneNumber',
    'sub',
  ];
  for (const key of directKeys) {
    const found = extractMobileValue(payload[key]);
    if (found && TEN_DIGIT_MSISDN.test(found)) return found;
  }

  for (const nested of [
    payload.customer,
    payload.user,
    payload.data,
    payload.payload,
  ]) {
    if (nested !== undefined && nested !== null) {
      const found = extractMobileValue(nested);
      if (found && TEN_DIGIT_MSISDN.test(found)) return found;
    }
  }

  return undefined;
}

function extractMsg91Code(data: unknown): number | undefined {
  if (data == null || typeof data !== 'object') return undefined;
  const record = data as Record<string, unknown>;
  const raw =
    record.code ?? record.Code ?? record.error_code ?? record.errorCode;
  if (typeof raw === 'number' && Number.isFinite(raw)) return raw;
  if (typeof raw === 'string') {
    const parsed = Number.parseInt(raw, 10);
    return Number.isFinite(parsed) ? parsed : undefined;
  }
  return undefined;
}

function extractErrorMessage(data: unknown): string | undefined {
  if (data && typeof data === 'object' && 'message' in data) {
    const message = (data as { message?: unknown }).message;
    if (typeof message === 'string' && message.length > 0) {
      if (extractMobileFromPlainCandidate(message)) return undefined;
      return message;
    }
  }
  return undefined;
}

function isAccessTokenAlreadyVerified(data: unknown): boolean {
  const code = extractMsg91Code(data);
  if (code === 702 || code === 703) return true;
  const message = extractErrorMessage(data)?.toLowerCase() ?? '';
  return (
    message.includes('access-token already verified') ||
    message.includes('access token already verified') ||
    message.includes('already verified')
  );
}

function isSuccessfulPayload(data: unknown, httpStatus: number): boolean {
  if (httpStatus >= 400) return false;
  if (data == null || typeof data !== 'object') return false;
  const record = data as Record<string, unknown>;
  const type = String(record.type ?? '').toLowerCase();
  if (type === 'error' || type === 'fail') return false;
  if (record.hasError === true) return false;
  if (record.success === false) return false;
  if (record.success === true) return true;
  const status = String(record.status ?? '').toLowerCase();
  if (status === 'success') return true;
  if (type === 'success') return true;
  if (extractMobileValue(data)) return true;
  return false;
}

function resolvePhoneHint(phoneHint: string | undefined): string | undefined {
  if (!phoneHint) return undefined;
  const normalized = normalizeToTenDigits(phoneHint.trim());
  if (normalized && TEN_DIGIT_MSISDN.test(normalized)) return normalized;
  return undefined;
}

function mobileFromAlreadyVerifiedToken(
  accessToken: string,
  responseData: unknown,
  phoneHint?: string,
): string | undefined {
  if (!isAccessTokenAlreadyVerified(responseData)) return undefined;

  const fromJwt = tryMobileFromWidgetJwt(accessToken.trim());
  if (fromJwt) return fromJwt;

  const payload = decodeJwtPayload(accessToken);
  const requestId = payload?.requestId ?? payload?.request_id;
  if (typeof requestId !== 'string' || requestId.trim().length < 8) {
    return resolvePhoneHint(phoneHint);
  }

  return resolvePhoneHint(phoneHint);
}

export function toAccountPhone(tenDigit: string): string {
  return tenDigit.startsWith('91') && tenDigit.length === 12
    ? tenDigit
    : `91${tenDigit}`;
}

export function phoneLookupVariants(phone: string): string[] {
  const digits = phone.replace(/\D/g, '');
  const tenDigit =
    digits.length === 12 && digits.startsWith('91')
      ? digits.slice(2)
      : digits.length === 10
        ? digits
        : digits;
  return Array.from(
    new Set([tenDigit, `91${tenDigit}`, `+91${tenDigit}`, digits]),
  );
}

export async function verifyMsg91WidgetAccessToken(
  accessToken: string,
  authKey: string,
  phoneHint?: string,
): Promise<string> {
  const token = accessToken.trim();
  if (!token) {
    throw new AppError('VALIDATION_ERROR', 'Access token is empty.', 400);
  }

  const response = await fetch(MSG91_VERIFY_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      accept: 'application/json',
    },
    body: JSON.stringify({
      authkey: authKey,
      'access-token': token,
    }),
  });

  let body: unknown;
  try {
    body = await response.json();
  } catch {
    throw new AppError(
      'MSG91_VERIFICATION_FAILED',
      'MSG91 verification failed.',
      401,
    );
  }

  if (response.status >= 400) {
    const recovered = mobileFromAlreadyVerifiedToken(token, body, phoneHint);
    if (recovered) {
      return toAccountPhone(recovered);
    }
    throw new AppError(
      'MSG91_VERIFICATION_FAILED',
      extractErrorMessage(body) ?? 'MSG91 verification failed.',
      401,
    );
  }

  const ok = isSuccessfulPayload(body, response.status);
  const mobile = extractMobileValue(body);

  if (ok && mobile && TEN_DIGIT_MSISDN.test(mobile)) {
    return toAccountPhone(mobile);
  }

  if (response.status < 400 && ok) {
    const fromClientJwt = tryMobileFromWidgetJwt(token);
    if (fromClientJwt) {
      return toAccountPhone(fromClientJwt);
    }

    if (body && typeof body === 'object') {
      const messageField = (body as Record<string, unknown>).message;
      if (typeof messageField === 'string' && messageField.includes('.')) {
        const fromWireJwt = tryMobileFromWidgetJwt(messageField);
        if (fromWireJwt) {
          return toAccountPhone(fromWireJwt);
        }
      }
    }
  }

  const hinted = resolvePhoneHint(phoneHint);
  if (hinted && (ok || isAccessTokenAlreadyVerified(body))) {
    return toAccountPhone(hinted);
  }

  const recoveredSoft = mobileFromAlreadyVerifiedToken(token, body, phoneHint);
  if (recoveredSoft) {
    return toAccountPhone(recoveredSoft);
  }

  if (ok) {
    const fromJwt = tryMobileFromWidgetJwt(token);
    if (fromJwt) {
      return toAccountPhone(fromJwt);
    }
    if (hinted) {
      return toAccountPhone(hinted);
    }
  }

  throw new AppError(
    'MSG91_VERIFICATION_FAILED',
    extractErrorMessage(body) ?? 'MSG91 verification failed.',
    401,
  );
}
