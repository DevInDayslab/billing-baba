import { describe, expect, mock, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import type { GstinVerificationResponseDto } from '../../../src/modules/gstin/gstin.dto';
import { GstinService } from '../../../src/modules/gstin/gstin.service';
import type { GstinVerificationProvider } from '../../../src/modules/gstin/gstverify.provider';
import { AppError } from '../../../src/shared/errors/app-error';

const VALID_GSTIN = '27AABCU9603R1ZN';

function baseConfig(overrides: Partial<AppConfig> = {}): AppConfig {
  return {
    appName: 'test',
    version: '0.0.0',
    host: '0.0.0.0',
    port: 3000,
    apiPrefix: '/api/v1',
    environment: 'test',
    logLevel: 'silent',
    enableDevLogin: false,
    corsOrigins: [],
    websiteUrl: 'https://billingbaba.com',
    invitationExpiryDays: 7,
    notificationProvider: 'console',
    invoiceShareExpiryDays: 90,
    notificationIdempotencyTtlHours: 24,
    storageConfigured: false,
    s3Region: 'auto',
    s3ForcePathStyle: true,
    s3Ssl: true,
    storageMaxFileBytes: 10_485_760,
    storageUploadUrlTtlSeconds: 900,
    storageDownloadUrlTtlSeconds: 3600,
    ...overrides,
  };
}

function providerResponse(
  gstin: string = VALID_GSTIN,
): GstinVerificationResponseDto {
  return {
    success: true,
    cached: true,
    credits_remaining: 42,
    data: {
      gstin,
      legal_name: 'PROVIDER COMPANY PRIVATE LIMITED',
      trade_name: 'Provider Co',
      status: 'Active',
      constitution: 'Private Limited Company',
      taxpayer_type: 'Regular',
      registration_date: '15/03/2018',
      state: 'Gujarat',
      pan: 'BBBBB1111B',
      address: '456 Provider Lane, Ahmedabad - 380001',
      nature_of_business: ['Wholesale Business'],
    },
  };
}

function createMockProvider(
  impl: GstinVerificationProvider['verify'],
): GstinVerificationProvider {
  return { verify: mock(impl) };
}

describe('GstinService', () => {
  test('verifyGSTIN returns mock when API key is missing', async () => {
    const service = new GstinService(baseConfig());
    const result = await service.verifyGSTIN(VALID_GSTIN);

    expect(result.success).toBe(true);
    expect(result.cached).toBe(false);
    expect(result.credits_remaining).toBe(99);
    expect(result.data.gstin).toBe(VALID_GSTIN);
    expect(result.data.legal_name).toBe('EXAMPLE COMPANY PRIVATE LIMITED');
    expect(result.data.status).toBe('Active');
  });

  test('verifyGSTIN returns mock when API key is whitespace', async () => {
    const service = new GstinService(baseConfig({ gstverifyApiKey: '   ' }));
    const result = await service.verifyGSTIN(VALID_GSTIN);

    expect(result.credits_remaining).toBe(99);
    expect(result.data.legal_name).toBe('EXAMPLE COMPANY PRIVATE LIMITED');
  });

  test('verifyGSTIN calls provider when API key is configured', async () => {
    const provider = createMockProvider(async (gstin) =>
      providerResponse(gstin),
    );
    const service = new GstinService(
      baseConfig({
        gstverifyApiKey: 'test-key',
        environment: 'production',
      }),
      provider,
    );

    const result = await service.verifyGSTIN(VALID_GSTIN);

    expect(provider.verify).toHaveBeenCalledWith(VALID_GSTIN, 'test-key');
    expect(result.credits_remaining).toBe(42);
    expect(result.cached).toBe(true);
    expect(result.data.legal_name).toBe('PROVIDER COMPANY PRIVATE LIMITED');
  });

  test('verifyGSTIN throws for invalid gstin', async () => {
    const service = new GstinService(baseConfig());

    try {
      await service.verifyGSTIN('INVALID');
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(400);
      expect(appError.code).toBe('VALIDATION_ERROR');
    }
  });

  test('verifyGSTIN propagates provider auth error in production', async () => {
    const provider = createMockProvider(async () => {
      throw new AppError(
        'GST_VERIFY_AUTH_FAILED',
        'GST verification service authentication failed.',
        401,
      );
    });
    const service = new GstinService(
      baseConfig({
        gstverifyApiKey: 'bad-key',
        environment: 'production',
      }),
      provider,
    );

    try {
      await service.verifyGSTIN(VALID_GSTIN);
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(401);
      expect(appError.message).toBe(
        'GST verification service authentication failed.',
      );
    }
  });

  test('verifyGSTIN maps credits exhausted to 503 in production', async () => {
    const provider = createMockProvider(async () => {
      throw new AppError(
        'GST_VERIFY_UNAVAILABLE',
        'GST verification service is temporarily unavailable.',
        503,
      );
    });
    const service = new GstinService(
      baseConfig({
        gstverifyApiKey: 'test-key',
        environment: 'production',
      }),
      provider,
    );

    try {
      await service.verifyGSTIN(VALID_GSTIN);
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(503);
      expect(appError.message).toBe(
        'GST verification service is temporarily unavailable.',
      );
    }
  });

  test('verifyGSTIN maps invalid GSTIN from provider to 400 in production', async () => {
    const provider = createMockProvider(async () => {
      throw new AppError('VALIDATION_ERROR', 'Invalid GSTIN.', 400);
    });
    const service = new GstinService(
      baseConfig({
        gstverifyApiKey: 'test-key',
        environment: 'production',
      }),
      provider,
    );

    try {
      await service.verifyGSTIN(VALID_GSTIN);
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(400);
      expect(appError.message).toBe('Invalid GSTIN.');
    }
  });

  test('verifyGSTIN propagates rate limit error in production', async () => {
    const provider = createMockProvider(async () => {
      throw new AppError(
        'GST_VERIFY_RATE_LIMITED',
        'Too many verification requests.',
        429,
      );
    });
    const service = new GstinService(
      baseConfig({
        gstverifyApiKey: 'test-key',
        environment: 'production',
      }),
      provider,
    );

    try {
      await service.verifyGSTIN(VALID_GSTIN);
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(429);
      expect(appError.message).toBe('Too many verification requests.');
    }
  });

  test('verifyGSTIN falls back to mock in development when provider fails', async () => {
    const provider = createMockProvider(async () => {
      throw new AppError(
        'GST_VERIFY_UNAVAILABLE',
        'GST verification service unavailable.',
        503,
      );
    });
    const service = new GstinService(
      baseConfig({
        gstverifyApiKey: 'test-key',
        environment: 'development',
      }),
      provider,
    );

    const result = await service.verifyGSTIN(VALID_GSTIN);

    expect(result.credits_remaining).toBe(99);
    expect(result.data.legal_name).toBe('EXAMPLE COMPANY PRIVATE LIMITED');
  });
});
