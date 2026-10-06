import { describe, expect, mock, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import type { GeneratedDocumentService } from '../../../src/modules/generated-documents/generated-document.service';
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

function finalizedDocument() {
  return {
    id: invoiceId,
    businessId,
    partyId: '44444444-4444-4444-4444-444444444444',
    documentType: 'tax_invoice',
    documentNumber: 'INV-1',
    documentSeries: 'INV',
    totalAmount: '100.00',
    status: 'finalized',
  };
}

function shareRepository() {
  return {
    findSalesDocument: async () => finalizedDocument(),
    findBusiness: async () => ({ name: 'Acme', upiId: 'shop@upi' }),
    findParty: async () => ({ name: 'Customer', mobile: '+919876543210' }),
    findActiveTokenForInvoice: async () => ({
      token: 'share-token',
      invoiceId,
      expiresAt: new Date('2027-01-01T00:00:00.000Z'),
      revokedAt: null,
    }),
  };
}

describe('InvoiceShareService.notifySaleInvoice', () => {
  test('does not send WhatsApp media when PDF ensure fails', async () => {
    const sendSaleInvoice = mock(async () => ({
      success: true,
      deduped: false,
    }));

    const service = new InvoiceShareService(baseConfig(), {
      repository: shareRepository() as never,
      notificationService: {
        sendSaleInvoice,
      } as never,
      mediaService: {} as never,
      generatedDocuments: {
        ensure: async () => {
          throw new AppError('PDF_GENERATION_FAILED', 'Generation failed', 500);
        },
      } as unknown as GeneratedDocumentService,
      artifacts: {
        ensurePdf: async () => {
          throw new AppError('PDF_GENERATION_FAILED', 'Generation failed', 500);
        },
      } as unknown as InvoiceArtifactService,
    });

    const result = await service.notifySaleInvoice(
      businessId,
      invoiceId,
      accountId,
    );

    expect(result.notified).toBe(false);
    expect(result.error?.code).toBe('PDF_GENERATION_FAILED');
    expect(sendSaleInvoice).not.toHaveBeenCalled();
  });

  test('does not send WhatsApp when preview generation fails', async () => {
    const sendSaleInvoice = mock(async () => ({
      success: true,
      deduped: false,
    }));

    const service = new InvoiceShareService(baseConfig(), {
      repository: shareRepository() as never,
      notificationService: {
        sendSaleInvoice,
      } as never,
      mediaService: {} as never,
      artifacts: {
        ensurePdf: async () => ({ cached: true }),
        generatePreview: async () => {
          throw new Error('render failed');
        },
      } as unknown as InvoiceArtifactService,
    });

    const result = await service.notifySaleInvoice(
      businessId,
      invoiceId,
      accountId,
    );

    expect(result.notified).toBe(false);
    expect(result.error?.code).toBe('PREVIEW_GENERATION_FAILED');
    expect(sendSaleInvoice).not.toHaveBeenCalled();
  });

  test('sends PNG preview URL and deletes temporary artifact on success', async () => {
    const sendSaleInvoice = mock(async () => ({
      success: true,
      deduped: false,
    }));
    const deleteTemporaryArtifacts = mock(async () => undefined);
    let ensured = false;

    const service = new InvoiceShareService(baseConfig(), {
      repository: shareRepository() as never,
      notificationService: {
        sendSaleInvoice,
      } as never,
      mediaService: {} as never,
      artifacts: {
        ensurePdf: async () => {
          ensured = true;
          return { cached: true };
        },
        generatePreview: async () => Buffer.from('png'),
        uploadTemporaryPreview: async () => ({
          mediaAssetId: 'preview-asset',
          downloadUrl: 'https://cdn.example.com/preview.png',
          expiresAt: null,
        }),
        deleteTemporaryArtifacts,
      } as unknown as InvoiceArtifactService,
    });

    const result = await service.notifySaleInvoice(
      businessId,
      invoiceId,
      accountId,
    );

    expect(ensured).toBe(true);
    expect(result.notified).toBe(true);
    expect(result.media_attached).toBe(true);
    expect(sendSaleInvoice).toHaveBeenCalled();
    const call = sendSaleInvoice.mock.calls[0] as unknown as [
      unknown,
      { mediaUrl: string },
    ];
    expect(call[1].mediaUrl).toBe('https://cdn.example.com/preview.png');
    expect(deleteTemporaryArtifacts).toHaveBeenCalledWith(
      businessId,
      accountId,
      'preview-asset',
    );
  });
});
