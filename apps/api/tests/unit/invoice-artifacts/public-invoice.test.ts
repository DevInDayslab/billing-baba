import { describe, expect, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import { AppError } from '../../../src/shared/errors/app-error';
import { InvoiceArtifactService } from '../../../src/modules/invoice-artifacts/invoice-artifact.service';
import { InvoiceShareService } from '../../../src/modules/invoice-share/invoice-share.service';

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

describe('Public invoice + payment QR', () => {
  test('getPublicInvoice includes payment and share metadata', async () => {
    const service = new InvoiceShareService(baseConfig(), {
      repository: {
        findTokenByValue: async () => ({
          token: 'public-token',
          invoiceId,
          businessId,
          expiresAt: new Date('2027-01-01'),
          revokedAt: null,
          createdBy: accountId,
        }),
        findSalesDocument: async () => ({
          id: invoiceId,
          businessId,
          partyId: null,
          documentType: 'tax_invoice',
          documentNumber: 'INV-9',
          documentSeries: 'INV',
          documentDate: new Date('2026-07-20'),
          status: 'finalized',
          notes: null,
          subtotal: '100.0000',
          discountTotal: '0.0000',
          taxAmount: '0.0000',
          totalAmount: '100.0000',
        }),
        findBusiness: async () => ({
          id: businessId,
          name: 'Acme',
          gstin: null,
          address: null,
          phone: null,
          email: null,
          stateCode: '07',
          upiId: 'shop@upi',
          logoMediaAssetId: null,
        }),
        listLinesWithItems: async () => [],
        getPaidAmount: async () => '0',
        getLoyaltyForSale: async () => null,
      } as never,
      mediaService: {
        resolveBrandingLogoUrl: async () => null,
      } as never,
      artifacts: {
        resolveCanonicalPdfDownload: async () => ({
          download_url: 'https://signed.example/invoice.pdf',
          file_name: 'invoice.pdf',
          expires_at: null,
          cached: true,
        }),
      } as unknown as InvoiceArtifactService,
    });

    const data = await service.getPublicInvoice('public-token');

    expect(data.payment.scan_to_pay_enabled).toBe(true);
    expect(data.payment.upi_id).toBe('shop@upi');
    expect(data.share.url).toContain('/invoice/public-token');
    expect(data.pdf_download_path).toBe(
      '/api/v1/public/invoices/public-token/download',
    );
    expect(data.invoice.loyalty).toBeNull();
  });

  test('getPublicInvoiceDownload returns signed URL without regenerating when cached', async () => {
    let resolveCalls = 0;
    const service = new InvoiceShareService(baseConfig(), {
      repository: {
        findTokenByValue: async () => ({
          token: 'public-token',
          invoiceId,
          businessId,
          expiresAt: new Date('2027-01-01'),
          revokedAt: null,
          createdBy: accountId,
        }),
        findSalesDocument: async () => ({
          id: invoiceId,
          businessId,
          partyId: null,
          documentType: 'tax_invoice',
          documentNumber: 'INV-9',
          documentSeries: 'INV',
          documentDate: new Date('2026-07-20'),
          status: 'finalized',
          notes: null,
          subtotal: '100.0000',
          discountTotal: '0.0000',
          taxAmount: '0.0000',
          totalAmount: '100.0000',
        }),
      } as never,
      artifacts: {
        resolveCanonicalPdfDownload: async () => {
          resolveCalls += 1;
          return {
            download_url: 'https://signed.example/generated/invoice.pdf',
            file_name: 'invoice-INV-9.pdf',
            expires_at: '2026-07-21T13:00:00.000Z',
            cached: true,
          };
        },
      } as unknown as InvoiceArtifactService,
    });

    const data = await service.getPublicInvoiceDownload('public-token');
    expect(resolveCalls).toBe(1);
    expect(data.cached).toBe(true);
    expect(data.download_url).toContain('invoice.pdf');
  });

  test('getPaymentQr returns 404 when QR unavailable', async () => {
    const service = new InvoiceShareService(baseConfig(), {
      repository: {
        findTokenByValue: async () => ({
          token: 'public-token',
          invoiceId,
          businessId,
          expiresAt: new Date('2027-01-01'),
          revokedAt: null,
          createdBy: accountId,
        }),
      } as never,
      artifacts: {
        generatePaymentQr: async () => null,
      } as unknown as InvoiceArtifactService,
      mediaService: {} as never,
    });

    try {
      await service.getPaymentQr('public-token');
      expect.unreachable('should throw');
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      expect((error as AppError).code).toBe('PAYMENT_QR_UNAVAILABLE');
      expect((error as AppError).statusCode).toBe(404);
    }
  });
});
