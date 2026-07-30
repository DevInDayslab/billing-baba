import { describe, expect, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import { GeneratedDocumentRepository } from '../../../src/modules/generated-documents/generated-document.repository';
import { GeneratedDocumentService } from '../../../src/modules/generated-documents/generated-document.service';
import type { GeneratedDocumentRecord } from '../../../src/modules/generated-documents/generated-document.types';
import { StorageNotFoundError } from '../../../src/modules/storage/storage.errors';
import { StorageService } from '../../../src/modules/storage/storage.service';
import type { MediaAssetRepository } from '../../../src/modules/storage/storage.repository';
import type { StorageProvider } from '../../../src/providers/storage';

const businessId = '11111111-1111-1111-1111-111111111111';
const accountId = '22222222-2222-2222-2222-222222222222';
const sourceId = '33333333-3333-3333-3333-333333333333';

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

class FakeProvider implements StorageProvider {
  readonly name = 'fake';
  readonly bucket = 'billing-baba';
  objects = new Map<string, { contentType: string; contentLength: number }>();
  deleted: string[] = [];

  async createUploadUrl(params: { key: string; mimeType: string }) {
    return {
      url: `https://upload/${params.key}`,
      headers: { 'Content-Type': params.mimeType },
      expiresAt: new Date(Date.now() + 900_000),
    };
  }

  async createDownloadUrl(params: { key: string }) {
    return {
      url: `https://download/${params.key}`,
      expiresAt: new Date(Date.now() + 3_600_000),
    };
  }

  async delete(key: string) {
    this.deleted.push(key);
    this.objects.delete(key);
  }

  async head(key: string) {
    const obj = this.objects.get(key);
    if (!obj) return { exists: false as const };
    return {
      exists: true as const,
      contentType: obj.contentType,
      contentLength: obj.contentLength,
      etag: 'etag',
    };
  }

  async exists(key: string) {
    return this.objects.has(key);
  }

  async copy() {}
  async move() {}

  async getObject(key: string) {
    const obj = this.objects.get(key);
    if (!obj) {
      throw new Error(`Object not found: ${key}`);
    }
    return {
      body: Buffer.alloc(obj.contentLength),
      contentType: obj.contentType,
      contentLength: obj.contentLength,
      etag: 'etag',
    };
  }

  async putObject(params: {
    key: string;
    body: Buffer | Uint8Array;
    mimeType: string;
  }) {
    const body = Buffer.isBuffer(params.body)
      ? params.body
      : Buffer.from(params.body);
    this.objects.set(params.key, {
      contentType: params.mimeType,
      contentLength: body.length,
    });
    return { etag: 'etag', contentLength: body.length };
  }
}

const sampleRow = (
  overrides: Partial<GeneratedDocumentRecord> = {},
): GeneratedDocumentRecord => ({
  id: '44444444-4444-4444-4444-444444444444',
  businessId,
  documentKind: 'invoice_pdf',
  sourceType: 'sale_document',
  sourceId,
  mediaAssetId: '55555555-5555-5555-5555-555555555555',
  sourceVersion: 2,
  fileName: 'invoice.pdf',
  mimeType: 'application/pdf',
  publicToken: 'public-token-value',
  generatedAt: new Date('2026-01-01T00:00:00.000Z'),
  createdAt: new Date('2026-01-01T00:00:00.000Z'),
  updatedAt: new Date('2026-01-01T00:00:00.000Z'),
  createdBy: accountId,
  ...overrides,
});

const membership = {
  hasBusinessMembership: async () => true,
  findAnyAccountId: async () => accountId,
};

const resolveSourceVersion = async () => ({ sourceVersion: 2 });
const noopKindAssert = async () => undefined;

describe('GeneratedDocumentService', () => {
  test('ensureStored returns cached document when source version matches', async () => {
    const repository = {
      findBySource: async () => sampleRow(),
      upsert: async () => sampleRow(),
      findById: async () => sampleRow(),
      findByPublicToken: async () => null,
      softDelete: async () => true,
      getMediaAssetId: async () => '55555555-5555-5555-5555-555555555555',
    } as unknown as GeneratedDocumentRepository;

    const storage = {
      storeFromBuffer: async () => {
        throw new Error('should not upload');
      },
      deleteAsset: async () => undefined,
      resolveBusinessAssetUrl: async () => 'https://signed.example/invoice.pdf',
      getDownloadUrl: async () => ({
        url: 'https://signed.example/invoice.pdf',
        expiresAt: new Date().toISOString(),
        visibility: 'private' as const,
      }),
      getBusinessAssetDownloadUrl: async () => ({
        url: 'https://signed.example/invoice.pdf',
        expiresAt: new Date().toISOString(),
        visibility: 'private' as const,
      }),
    } as unknown as StorageService;

    const service = new GeneratedDocumentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      resolveSourceVersion,
      assertKindMatchesSource: noopKindAssert,
    });

    const result = await service.ensureStored(businessId, accountId, {
      documentKind: 'invoice_pdf',
      sourceType: 'sale_document',
      sourceId,
      fileName: 'invoice.pdf',
      mimeType: 'application/pdf',
      contentBase64: Buffer.from('%PDF-1.4').toString('base64'),
    });

    expect(result.cached).toBe(true);
    expect(result.download_url).toBe('https://signed.example/invoice.pdf');
  });

  test('ensureStored uploads when source version changed', async () => {
    let uploaded = false;
    const repository = {
      findBySource: async () => sampleRow({ sourceVersion: 1 }),
      upsert: async () => sampleRow({ sourceVersion: 2 }),
      findById: async () => sampleRow({ sourceVersion: 2 }),
      findByPublicToken: async () => null,
      softDelete: async () => true,
      getMediaAssetId: async () => '55555555-5555-5555-5555-555555555555',
    } as unknown as GeneratedDocumentRepository;

    const storage = {
      storeFromBuffer: async () => {
        uploaded = true;
        return { id: '66666666-6666-6666-6666-666666666666' };
      },
      deleteAsset: async () => undefined,
      resolveBusinessAssetUrl: async () => 'https://signed.example/new.pdf',
      getDownloadUrl: async () => ({
        url: 'https://signed.example/new.pdf',
        expiresAt: new Date().toISOString(),
        visibility: 'private' as const,
      }),
      getBusinessAssetDownloadUrl: async () => ({
        url: 'https://signed.example/new.pdf',
        expiresAt: new Date().toISOString(),
        visibility: 'private' as const,
      }),
    } as unknown as StorageService;

    const service = new GeneratedDocumentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      resolveSourceVersion,
      assertKindMatchesSource: noopKindAssert,
    });

    const result = await service.ensureStored(businessId, accountId, {
      documentKind: 'invoice_pdf',
      sourceType: 'sale_document',
      sourceId,
      fileName: 'invoice.pdf',
      mimeType: 'application/pdf',
      contentBase64: Buffer.from('%PDF-1.4').toString('base64'),
    });

    expect(uploaded).toBe(true);
    expect(result.cached).toBe(false);
    expect(result.source_version).toBe(2);
  });

  test('getPublicDocument rejects stale cache', async () => {
    const repository = {
      findByPublicToken: async () => sampleRow({ sourceVersion: 1 }),
      findBySource: async () => null,
      upsert: async () => sampleRow(),
      findById: async () => sampleRow(),
      softDelete: async () => true,
      getMediaAssetId: async () => null,
    } as unknown as GeneratedDocumentRepository;

    const service = new GeneratedDocumentService({
      config: baseConfig(),
      repository,
      storage: {
        getBusinessAssetDownloadUrl: async () => ({
          url: 'https://signed.example/invoice.pdf',
          expiresAt: new Date().toISOString(),
          visibility: 'private' as const,
        }),
      } as unknown as StorageService,
      membership,
      resolveSourceVersion,
      assertKindMatchesSource: noopKindAssert,
    });

    await expect(
      service.getPublicDocument('public-token-value'),
    ).rejects.toMatchObject({
      code: 'DOCUMENT_STALE',
    });
  });

  test('ensure generates PDF server-side when cache miss and no client bytes', async () => {
    let uploaded = false;
    const repository = {
      findBySource: async () => null,
      upsert: async () => sampleRow({ sourceVersion: 2 }),
      findById: async () => sampleRow({ sourceVersion: 2 }),
      findByPublicToken: async () => null,
      softDelete: async () => true,
      getMediaAssetId: async () => '55555555-5555-5555-5555-555555555555',
    } as unknown as GeneratedDocumentRepository;

    const storage = {
      storeFromBuffer: async () => {
        uploaded = true;
        return { id: '66666666-6666-6666-6666-666666666666' };
      },
      deleteAsset: async () => undefined,
      resolveBusinessAssetUrl: async () =>
        'https://signed.example/generated.pdf',
      getBusinessAssetDownloadUrl: async () => ({
        url: 'https://signed.example/generated.pdf',
        expiresAt: new Date().toISOString(),
        visibility: 'private' as const,
      }),
    } as unknown as StorageService;

    const pdfGenerator = {
      generate: async () => ({
        buffer: Buffer.from('%PDF-1.4 generated'),
        fileName: 'invoice-test.pdf',
      }),
    };

    const service = new GeneratedDocumentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      resolveSourceVersion,
      assertKindMatchesSource: noopKindAssert,
      pdfGenerator: pdfGenerator as never,
    });

    const result = await service.ensure(businessId, accountId, {
      documentKind: 'invoice_pdf',
      sourceType: 'sale_document',
      sourceId,
    });

    expect(uploaded).toBe(true);
    expect(result.cached).toBe(false);
    expect(result.download_url).toBe('https://signed.example/generated.pdf');
  });

  test('resolveOrCreateSalePdfDownload returns existing signed URL without regenerate', async () => {
    let generateCalls = 0;
    const repository = {
      findBySource: async () => sampleRow(),
      upsert: async () => sampleRow(),
      findById: async () => sampleRow(),
      findByPublicToken: async () => null,
      softDelete: async () => true,
      getMediaAssetId: async () => '55555555-5555-5555-5555-555555555555',
    } as unknown as GeneratedDocumentRepository;

    const service = new GeneratedDocumentService({
      config: baseConfig(),
      repository,
      storage: {
        getBusinessAssetDownloadUrl: async () => ({
          url: 'https://signed.example/existing-invoice.pdf',
          expiresAt: '2026-07-21T13:00:00.000Z',
          visibility: 'private' as const,
          contentLength: 45_000,
        }),
        storeFromBuffer: async () => {
          throw new Error('should not upload');
        },
      } as unknown as StorageService,
      membership,
      resolveSourceVersion,
      assertKindMatchesSource: noopKindAssert,
      pdfGenerator: {
        generate: async () => {
          generateCalls += 1;
          return { buffer: Buffer.from('%PDF'), fileName: 'x.pdf' };
        },
      } as never,
    });

    const result = await service.resolveOrCreateSalePdfDownload(
      businessId,
      accountId,
      sourceId,
      'invoice_pdf',
    );

    expect(generateCalls).toBe(0);
    expect(result.cached).toBe(true);
    expect(result.download_url).toBe(
      'https://signed.example/existing-invoice.pdf',
    );
  });

  test('resolveOrCreateSalePdfDownload generates when storage object missing', async () => {
    let uploaded = false;
    const repository = {
      findBySource: async () => sampleRow(),
      upsert: async () => sampleRow({ sourceVersion: 2 }),
      findById: async () => sampleRow({ sourceVersion: 2 }),
      findByPublicToken: async () => null,
      softDelete: async () => true,
      getMediaAssetId: async () => '55555555-5555-5555-5555-555555555555',
    } as unknown as GeneratedDocumentRepository;

    const service = new GeneratedDocumentService({
      config: baseConfig(),
      repository,
      storage: {
        getBusinessAssetDownloadUrl: async () => {
          throw new StorageNotFoundError('Storage object missing');
        },
        storeFromBuffer: async () => {
          uploaded = true;
          return { id: '66666666-6666-6666-6666-666666666666' };
        },
        deleteAsset: async () => undefined,
        resolveBusinessAssetUrl: async () =>
          'https://signed.example/regenerated.pdf',
      } as unknown as StorageService,
      membership,
      resolveSourceVersion,
      assertKindMatchesSource: noopKindAssert,
      pdfGenerator: {
        generate: async () => ({
          buffer: Buffer.from('%PDF-1.4 professional'),
          fileName: 'invoice-INV.pdf',
        }),
      } as never,
    });

    const result = await service.resolveOrCreateSalePdfDownload(
      businessId,
      accountId,
      sourceId,
      'invoice_pdf',
    );

    expect(uploaded).toBe(true);
    expect(result.cached).toBe(false);
    expect(result.download_url).toBe('https://signed.example/regenerated.pdf');
  });
});
