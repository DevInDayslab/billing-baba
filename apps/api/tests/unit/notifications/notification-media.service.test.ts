import { describe, expect, mock, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import type { BusinessRepository } from '../../../src/modules/business/business.repository';
import type { GeneratedDocumentRepository } from '../../../src/modules/generated-documents/generated-document.repository';
import {
  generatedKindForSalesDocumentType,
  NotificationMediaService,
} from '../../../src/modules/notifications/notification-media.service';
import type { StorageService } from '../../../src/modules/storage/storage.service';

const businessId = '11111111-1111-1111-1111-111111111111';
const invoiceId = '33333333-3333-3333-3333-333333333333';
const mediaAssetId = '55555555-5555-5555-5555-555555555555';

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

function createService(overrides: {
  storage?: Partial<StorageService>;
  brandingRepository?: Partial<BusinessRepository>;
  generatedDocuments?: Partial<GeneratedDocumentRepository>;
  resolveSourceVersion?: () => Promise<{ sourceVersion: number }>;
}) {
  const storage = {
    getBusinessAssetDownloadUrl: mock(async () => ({
      url: 'https://cdn.example.com/signed.pdf',
      expiresAt: new Date().toISOString(),
    })),
    ...overrides.storage,
  } as unknown as StorageService;

  const brandingRepository = {
    getBrandingBindings: mock(async () => ({
      logoMediaAssetId: null,
      signatureMediaAssetId: null,
    })),
    ...overrides.brandingRepository,
  } as unknown as BusinessRepository;

  const generatedDocuments = {
    findBySource: mock(async () => null),
    ...overrides.generatedDocuments,
  } as unknown as GeneratedDocumentRepository;

  return new NotificationMediaService({
    config: baseConfig(),
    storage,
    brandingRepository,
    generatedDocuments,
    resolveSourceVersion:
      overrides.resolveSourceVersion ?? (async () => ({ sourceVersion: 3 })),
  });
}

describe('generatedKindForSalesDocumentType', () => {
  test('maps sales document types to generated PDF kinds', () => {
    expect(generatedKindForSalesDocumentType('estimate')).toBe('estimate_pdf');
    expect(generatedKindForSalesDocumentType('delivery_challan')).toBe(
      'delivery_challan_pdf',
    );
    expect(generatedKindForSalesDocumentType('tax_invoice')).toBe(
      'invoice_pdf',
    );
    expect(generatedKindForSalesDocumentType('sale_order')).toBeNull();
  });
});

describe('NotificationMediaService', () => {
  test('resolveBrandingLogoUrl returns signed URL when logo asset exists', async () => {
    const service = createService({
      brandingRepository: {
        getBrandingBindings: async () => ({
          logoMediaAssetId: mediaAssetId,
          signatureMediaAssetId: null,
          stampMediaAssetId: null,
          upiQrMediaAssetId: null,
        }),
      } as unknown as BusinessRepository,
    });

    const url = await service.resolveBrandingLogoUrl(businessId);
    expect(url).toBe('https://cdn.example.com/signed.pdf');
  });

  test('resolveBrandingLogoUrl returns fallback when no logo asset', async () => {
    const service = createService({});
    const url = await service.resolveBrandingLogoUrl(
      businessId,
      'https://fallback.example/logo.png',
    );
    expect(url).toBe('https://fallback.example/logo.png');
  });

  test('resolveSaleDocumentPdfUrl returns null when cache version is stale', async () => {
    const service = createService({
      generatedDocuments: {
        findBySource: async () =>
          ({
            mediaAssetId,
            sourceVersion: 1,
            publicToken: 'tok',
          }) as never,
      } as unknown as GeneratedDocumentRepository,
      resolveSourceVersion: async () => ({ sourceVersion: 2 }),
    });

    const url = await service.resolveSaleDocumentPdfUrl(
      businessId,
      invoiceId,
      'tax_invoice',
    );
    expect(url).toBeNull();
  });

  test('resolveSaleDocumentPdfUrl returns signed URL for current cache', async () => {
    const service = createService({
      generatedDocuments: {
        findBySource: async () =>
          ({
            mediaAssetId,
            sourceVersion: 3,
            publicToken: 'tok',
          }) as never,
      } as unknown as GeneratedDocumentRepository,
      resolveSourceVersion: async () => ({ sourceVersion: 3 }),
    });

    const url = await service.resolveSaleDocumentPdfUrl(
      businessId,
      invoiceId,
      'estimate',
    );
    expect(url).toBe('https://cdn.example.com/signed.pdf');
  });

  test('buildPublicGeneratedFilePath returns API redirect path', () => {
    const service = createService({});
    expect(service.buildPublicGeneratedFilePath('abc123')).toBe(
      '/api/v1/public/generated-documents/abc123/file',
    );
  });

  test('resolvePublicSaleDocumentPdfMeta returns download path for website', async () => {
    const service = createService({
      generatedDocuments: {
        findBySource: async () =>
          ({
            mediaAssetId,
            sourceVersion: 3,
            publicToken: 'public-tok',
          }) as never,
      } as unknown as GeneratedDocumentRepository,
      resolveSourceVersion: async () => ({ sourceVersion: 3 }),
    });

    const meta = await service.resolvePublicSaleDocumentPdfMeta(
      businessId,
      invoiceId,
      'delivery_challan',
    );
    expect(meta).toEqual({
      publicToken: 'public-tok',
      downloadPath: '/api/v1/public/generated-documents/public-tok/file',
    });
  });
});
