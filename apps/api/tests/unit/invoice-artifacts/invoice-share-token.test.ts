import { describe, expect, mock, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import type { InvoiceArtifactService } from '../../../src/modules/invoice-artifacts/invoice-artifact.service';
import { InvoiceShareService } from '../../../src/modules/invoice-share/invoice-share.service';
import { AppError } from '../../../src/shared/errors/app-error';

function baseConfig(): AppConfig {
  return {
    appName: 'test',
    version: '0.0.0',
    host: '0.0.0.0',
    port: 3000,
    apiPrefix: '/api/v1',
    environment: 'test',
    logLevel: 'silent',
    enableDevLogin: true,
    corsOrigins: [],
    websiteUrl: 'https://billingbaba.com',
    invitationExpiryDays: 7,
    notificationProvider: 'console',
    invoiceShareExpiryDays: 90,
    notificationIdempotencyTtlHours: 24,
    storageConfigured: true,
    s3Endpoint: 'https://s3.example.com',
    s3Bucket: 'billing-baba',
    s3Region: 'auto',
    s3AccessKeyId: 'key',
    s3SecretAccessKey: 'secret',
    s3ForcePathStyle: true,
    s3Ssl: true,
    s3PublicBaseUrl: 'https://cdn.example.com',
    storageMaxFileBytes: 10_485_760,
    storageUploadUrlTtlSeconds: 900,
    storageDownloadUrlTtlSeconds: 3600,
  };
}

const businessId = '11111111-1111-1111-1111-111111111111';
const accountId = '22222222-2222-2222-2222-222222222222';
const invoiceId = '33333333-3333-3333-3333-333333333333';

describe('InvoiceShareService token lifecycle', () => {
  test('getPublicInvoice returns 410 for revoked tokens', async () => {
    const service = new InvoiceShareService(baseConfig(), {
      repository: {
        findTokenByValue: async () => ({
          token: 'revoked-token',
          invoiceId,
          businessId,
          expiresAt: new Date('2027-01-01'),
          revokedAt: new Date('2026-01-01'),
          createdBy: accountId,
        }),
      } as never,
      artifacts: {} as unknown as InvoiceArtifactService,
      mediaService: {} as never,
    });

    try {
      await service.getPublicInvoice('revoked-token');
      expect.unreachable('should throw');
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      expect((error as AppError).code).toBe('INVOICE_SHARE_REVOKED');
      expect((error as AppError).statusCode).toBe(410);
    }
  });

  test('getPublicInvoice returns 410 for expired tokens', async () => {
    const service = new InvoiceShareService(baseConfig(), {
      repository: {
        findTokenByValue: async () => ({
          token: 'expired-token',
          invoiceId,
          businessId,
          expiresAt: new Date('2020-01-01'),
          revokedAt: null,
          createdBy: accountId,
        }),
      } as never,
      artifacts: {} as unknown as InvoiceArtifactService,
      mediaService: {} as never,
    });

    try {
      await service.getPublicInvoice('expired-token');
      expect.unreachable('should throw');
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      expect((error as AppError).code).toBe('INVOICE_SHARE_EXPIRED');
      expect((error as AppError).statusCode).toBe(410);
    }
  });

  test('regenerateShareLink revokes old and creates new token', async () => {
    const revokeActiveTokensForInvoice = mock(async () => undefined);
    const createToken = mock(async () => ({
      token: 'new-token',
      invoiceId,
      businessId,
      expiresAt: new Date('2027-01-01'),
    }));

    const service = new InvoiceShareService(baseConfig(), {
      repository: {
        findSalesDocument: async () => ({
          id: invoiceId,
          status: 'finalized',
        }),
        revokeActiveTokensForInvoice,
        createToken,
      } as never,
      artifacts: {} as unknown as InvoiceArtifactService,
      mediaService: {} as never,
    });

    const result = await service.regenerateShareLink(
      businessId,
      invoiceId,
      accountId,
    );

    expect(revokeActiveTokensForInvoice).toHaveBeenCalledWith(
      invoiceId,
      businessId,
    );
    expect(createToken).toHaveBeenCalled();
    expect(result.token).toBe('new-token');
    expect(result.share_url).toContain('/invoice/new-token');
  });
});
