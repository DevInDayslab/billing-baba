import { describe, expect, test } from 'bun:test';
import { mapTwilioError } from '../../../src/providers/notification/twilio-whatsapp-provider';
import { toSafeNotificationErrorMessage } from '../../../src/modules/notifications/notification-logging';

describe('mapTwilioError', () => {
  test('maps authentication failures', () => {
    const error = mapTwilioError({ status: 401, code: 20003, message: 'Authenticate' });
    expect(error.code).toBe('AUTHENTICATION');
    expect(error.retryable).toBe(false);
  });

  test('maps rate limits', () => {
    const error = mapTwilioError({ status: 429, code: 20429, message: 'Too many requests' });
    expect(error.code).toBe('RATE_LIMITED');
    expect(error.retryable).toBe(true);
  });

  test('maps WhatsApp session window (63016)', () => {
    const error = mapTwilioError({
      status: 400,
      code: 63016,
      message: 'Failed to send freeform message because you are outside the allowed window',
    });
    expect(error.code).toBe('SESSION_WINDOW');
    expect(error.retryable).toBe(false);
    expect(toSafeNotificationErrorMessage('SESSION_WINDOW')).toContain(
      'chat window',
    );
  });

  test('maps invalid numbers', () => {
    const error = mapTwilioError({
      status: 400,
      code: 21211,
      message: "The 'To' number is not a valid phone number",
    });
    expect(error.code).toBe('INVALID_NUMBER');
    expect(error.retryable).toBe(false);
  });

  test('maps network timeouts', () => {
    const error = mapTwilioError(new Error('connect ETIMEDOUT'));
    expect(error.code).toBe('NETWORK_ERROR');
    expect(error.retryable).toBe(true);
  });

  test('maps 5xx as retryable provider error', () => {
    const error = mapTwilioError({ status: 503, message: 'Service Unavailable' });
    expect(error.code).toBe('PROVIDER_ERROR');
    expect(error.retryable).toBe(true);
  });
});

describe('toSafeNotificationErrorMessage', () => {
  test('never echoes raw provider text', () => {
    expect(toSafeNotificationErrorMessage('INVALID_NUMBER')).not.toContain('Twilio');
    expect(toSafeNotificationErrorMessage('AUTHENTICATION')).toContain('authentication');
  });
});
