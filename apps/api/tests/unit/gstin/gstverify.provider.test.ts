import { describe, expect, mock, test } from 'bun:test';
import { GstVerifyProvider } from '../../../src/modules/gstin/gstverify.provider';
import { AppError } from '../../../src/shared/errors/app-error';

const VALID_GSTIN = '27AABCU9603R1ZN';

describe('GstVerifyProvider', () => {
  const originalFetch = globalThis.fetch;

  test('maps successful provider response', async () => {
    const providerBody = {
      success: true,
      cached: false,
      credits_remaining: 88,
      data: {
        gstin: VALID_GSTIN,
        legal_name: 'MAPPED COMPANY PRIVATE LIMITED',
        trade_name: 'Mapped Co',
        status: 'Active',
        constitution: 'Private Limited Company',
        taxpayer_type: 'Regular',
        registration_date: '01/07/2017',
        state: 'Maharashtra',
        pan: 'AAAAA0000A',
        address: '123 Business Park, Mumbai - 400001',
        nature_of_business: ['Supplier of Services'],
      },
    };

    globalThis.fetch = mock(async () =>
      new Response(JSON.stringify(providerBody), {
        status: 200,
        headers: { 'content-type': 'application/json' },
      }),
    ) as unknown as typeof fetch;

    const provider = new GstVerifyProvider();
    const result = await provider.verify(VALID_GSTIN, 'test-api-key');

    expect(result.success).toBe(true);
    expect(result.credits_remaining).toBe(88);
    expect(result.data.legal_name).toBe('MAPPED COMPANY PRIVATE LIMITED');

    globalThis.fetch = originalFetch;
  });

  test('maps 401 to auth failed error', async () => {
    globalThis.fetch = mock(async () => new Response('', { status: 401 })) as unknown as typeof fetch;

    const provider = new GstVerifyProvider();

    try {
      await provider.verify(VALID_GSTIN, 'bad-key');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(401);
      expect(appError.message).toBe(
        'GST verification service authentication failed.',
      );
    }

    globalThis.fetch = originalFetch;
  });

  test('maps 402 to temporarily unavailable error', async () => {
    globalThis.fetch = mock(async () => new Response('', { status: 402 })) as unknown as typeof fetch;

    const provider = new GstVerifyProvider();

    try {
      await provider.verify(VALID_GSTIN, 'test-key');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(503);
      expect(appError.message).toBe(
        'GST verification service is temporarily unavailable.',
      );
    }

    globalThis.fetch = originalFetch;
  });

  test('maps 422 to invalid GSTIN error', async () => {
    globalThis.fetch = mock(async () => new Response('', { status: 422 })) as unknown as typeof fetch;

    const provider = new GstVerifyProvider();

    try {
      await provider.verify(VALID_GSTIN, 'test-key');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(400);
      expect(appError.message).toBe('Invalid GSTIN.');
    }

    globalThis.fetch = originalFetch;
  });

  test('maps 429 to rate limited error', async () => {
    globalThis.fetch = mock(async () => new Response('', { status: 429 })) as unknown as typeof fetch;

    const provider = new GstVerifyProvider();

    try {
      await provider.verify(VALID_GSTIN, 'test-key');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(429);
      expect(appError.message).toBe('Too many verification requests.');
    }

    globalThis.fetch = originalFetch;
  });

  test('maps 5xx to unavailable error', async () => {
    globalThis.fetch = mock(async () => new Response('', { status: 503 })) as unknown as typeof fetch;

    const provider = new GstVerifyProvider();

    try {
      await provider.verify(VALID_GSTIN, 'test-key');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(503);
      expect(appError.message).toBe('GST verification service unavailable.');
    }

    globalThis.fetch = originalFetch;
  });

  test('maps network failure to unavailable error', async () => {
    globalThis.fetch = mock(async () => {
      throw new Error('network error');
    }) as unknown as typeof fetch;

    const provider = new GstVerifyProvider();

    try {
      await provider.verify(VALID_GSTIN, 'test-key');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(503);
      expect(appError.message).toBe('GST verification service unavailable.');
    }

    globalThis.fetch = originalFetch;
  });
});
