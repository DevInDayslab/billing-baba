import { describe, expect, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import {
  StorageNotFoundError,
  StorageUploadFailedError,
  StorageValidationError,
} from '../../../src/modules/storage/storage.errors';
import type { MediaAssetRepository } from '../../../src/modules/storage/storage.repository';
import { StorageService } from '../../../src/modules/storage/storage.service';
import type { MediaAssetRow } from '../../../src/modules/storage/storage.types';
import { buildStoragePath } from '../../../src/modules/storage/storage-path.builder';
import type {
  CreateDownloadUrlParams,
  CreateUploadUrlParams,
  HeadObjectResult,
  StorageProvider,
} from '../../../src/providers/storage';

function baseConfig(overrides: Partial<AppConfig> = {}): AppConfig {
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
    ...overrides,
  };
}

class FakeProvider implements StorageProvider {
  readonly name = 'fake';
  readonly bucket = 'billing-baba';
  objects = new Map<
    string,
    {
      contentType: string;
      contentLength: number;
      etag: string;
      body?: Buffer;
    }
  >();
  deleted: string[] = [];

  async createUploadUrl(params: CreateUploadUrlParams) {
    return {
      url: `https://s3.example.com/upload/${params.key}`,
      headers: { 'Content-Type': params.mimeType },
      expiresAt: new Date(Date.now() + 900_000),
    };
  }

  async createDownloadUrl(params: CreateDownloadUrlParams) {
    return {
      url: `https://s3.example.com/download/${params.key}?sig=1`,
      expiresAt: new Date(Date.now() + 3_600_000),
    };
  }

  async delete(key: string) {
    this.deleted.push(key);
    this.objects.delete(key);
  }

  async head(key: string): Promise<HeadObjectResult> {
    const obj = this.objects.get(key);
    if (!obj) return { exists: false };
    return {
      exists: true,
      contentType: obj.contentType,
      contentLength: obj.contentLength,
      etag: obj.etag,
    };
  }

  async exists(key: string) {
    return this.objects.has(key);
  }

  async copy() {
    /* no-op for tests */
  }

  async move() {
    /* no-op for tests */
  }

  async getObject(key: string) {
    const obj = this.objects.get(key);
    if (!obj?.body) {
      throw new Error(`Object not found: ${key}`);
    }
    return {
      body: obj.body,
      contentType: obj.contentType,
      contentLength: obj.contentLength,
      etag: obj.etag,
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
      etag: 'fake-etag',
      body,
    });
    return { etag: 'fake-etag', contentLength: body.length };
  }
}

class FakeRepository {
  rows = new Map<string, MediaAssetRow>();
  membershipOk = true;

  async hasBusinessMembership() {
    return this.membershipOk;
  }

  async insert(
    values: Parameters<MediaAssetRepository['insert']>[0],
  ): Promise<MediaAssetRow> {
    const now = new Date();
    const row: MediaAssetRow = {
      id: values.id,
      businessId: values.businessId,
      storageKey: values.storageKey,
      bucket: values.bucket,
      purpose: values.purpose,
      visibility: values.visibility,
      mimeType: values.mimeType,
      fileSize: values.fileSize,
      etag: null,
      checksum: values.checksum ?? null,
      ownerType: values.ownerType ?? null,
      ownerId: values.ownerId ?? null,
      status: values.status,
      uploadedBy: values.uploadedBy ?? null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      isDeleted: false,
    };
    this.rows.set(row.id, row);
    return row;
  }

  async findById(businessId: string, id: string) {
    const row = this.rows.get(id);
    if (!row || row.businessId !== businessId || row.isDeleted) return null;
    return row;
  }

  async markReady(
    businessId: string,
    id: string,
    values: { etag: string | null; fileSize: number; mimeType?: string },
  ) {
    const row = await this.findById(businessId, id);
    if (!row || row.status !== 'pending') return null;
    const updated: MediaAssetRow = {
      ...row,
      status: 'ready',
      etag: values.etag,
      fileSize: values.fileSize,
      mimeType: values.mimeType ?? row.mimeType,
      updatedAt: new Date(),
    };
    this.rows.set(id, updated);
    return updated;
  }

  async softDelete(businessId: string, id: string) {
    const row = await this.findById(businessId, id);
    if (!row) return null;
    const updated: MediaAssetRow = {
      ...row,
      isDeleted: true,
      deletedAt: new Date(),
      updatedAt: new Date(),
    };
    this.rows.set(id, updated);
    return updated;
  }
}

function createService(
  repo: FakeRepository,
  provider: FakeProvider,
  config?: Partial<AppConfig>,
) {
  return new StorageService({
    config: baseConfig(config),
    repository: repo as unknown as MediaAssetRepository,
    provider,
  });
}

describe('buildStoragePath', () => {
  test('builds env/businesses/purpose/asset.ext path', () => {
    const key = buildStoragePath({
      environment: 'production',
      businessId: 'biz-1',
      purpose: 'branding',
      assetId: 'asset-1',
      mimeType: 'image/png',
    });
    expect(key).toBe('production/businesses/biz-1/branding/asset-1.png');
  });

  test('includes owner segments when provided', () => {
    const key = buildStoragePath({
      environment: 'test',
      businessId: 'biz-1',
      purpose: 'items',
      assetId: 'asset-1',
      mimeType: 'image/jpeg',
      ownerType: 'item',
      ownerId: 'item-1',
    });
    expect(key).toBe('test/businesses/biz-1/items/item/item-1/asset-1.jpg');
  });

  test('rejects unsupported MIME', () => {
    expect(() =>
      buildStoragePath({
        environment: 'test',
        businessId: 'biz-1',
        purpose: 'other',
        assetId: 'a',
        mimeType: 'text/plain',
      }),
    ).toThrow(StorageValidationError);
  });
});

describe('StorageService validation', () => {
  test('rejects disallowed MIME on upload intent', async () => {
    const service = createService(new FakeRepository(), new FakeProvider());
    await expect(
      service.createUploadIntent('biz', 'acct', {
        purpose: 'items',
        visibility: 'private',
        mimeType: 'application/zip',
        fileSize: 100,
      }),
    ).rejects.toBeInstanceOf(StorageValidationError);
  });

  test('rejects oversized file', async () => {
    const service = createService(new FakeRepository(), new FakeProvider(), {
      storageMaxFileBytes: 1000,
    });
    await expect(
      service.createUploadIntent('biz', 'acct', {
        purpose: 'items',
        visibility: 'private',
        mimeType: 'image/png',
        fileSize: 1001,
      }),
    ).rejects.toBeInstanceOf(StorageValidationError);
  });
});

describe('StorageService upload lifecycle', () => {
  test('createUploadIntent returns presigned URL and pending row', async () => {
    const repo = new FakeRepository();
    const provider = new FakeProvider();
    const service = createService(repo, provider);

    const intent = await service.createUploadIntent('biz', 'acct', {
      purpose: 'branding',
      visibility: 'private',
      mimeType: 'image/png',
      fileSize: 2048,
    });

    expect(intent.intentId).toBeTruthy();
    expect(intent.uploadUrl).toContain('https://s3.example.com/upload/');
    expect(intent.mimeType).toBe('image/png');
    expect(intent.headers['Content-Type']).toBe('image/png');

    const row = repo.rows.get(intent.intentId);
    expect(row?.status).toBe('pending');
    expect(row?.storageKey).toBe(intent.storageKey);
  });

  test('completeUpload marks ready after successful HEAD', async () => {
    const repo = new FakeRepository();
    const provider = new FakeProvider();
    const service = createService(repo, provider);

    const intent = await service.createUploadIntent('biz', 'acct', {
      purpose: 'items',
      visibility: 'private',
      mimeType: 'image/webp',
      fileSize: 500,
      ownerType: 'item',
      ownerId: '11111111-1111-1111-1111-111111111111',
    });

    provider.objects.set(intent.storageKey, {
      contentType: 'image/webp',
      contentLength: 500,
      etag: 'abc123',
    });

    const asset = await service.completeUpload('biz', 'acct', intent.intentId);
    expect(asset.status).toBe('ready');
    expect(asset.etag).toBe('abc123');
    expect(asset.fileSize).toBe(500);
  });

  test('completeUpload fails when object missing', async () => {
    const repo = new FakeRepository();
    const provider = new FakeProvider();
    const service = createService(repo, provider);

    const intent = await service.createUploadIntent('biz', 'acct', {
      purpose: 'expenses',
      visibility: 'private',
      mimeType: 'application/pdf',
      fileSize: 100,
    });

    await expect(
      service.completeUpload('biz', 'acct', intent.intentId),
    ).rejects.toBeInstanceOf(StorageUploadFailedError);
  });

  test('getDownloadUrl returns signed URL for private assets', async () => {
    const repo = new FakeRepository();
    const provider = new FakeProvider();
    const service = createService(repo, provider);

    const intent = await service.createUploadIntent('biz', 'acct', {
      purpose: 'documents',
      visibility: 'private',
      mimeType: 'application/pdf',
      fileSize: 100,
    });
    provider.objects.set(intent.storageKey, {
      contentType: 'application/pdf',
      contentLength: 100,
      etag: 'e1',
    });
    await service.completeUpload('biz', 'acct', intent.intentId);

    const download = await service.getDownloadUrl(
      'biz',
      'acct',
      intent.intentId,
    );
    expect(download.visibility).toBe('private');
    expect(download.url).toContain('download/');
    expect(download.expiresAt).toBeTruthy();
  });

  test('getDownloadUrl returns public URL for public assets', async () => {
    const repo = new FakeRepository();
    const provider = new FakeProvider();
    const service = createService(repo, provider);

    const intent = await service.createUploadIntent('biz', 'acct', {
      purpose: 'branding',
      visibility: 'public',
      mimeType: 'image/png',
      fileSize: 100,
    });
    provider.objects.set(intent.storageKey, {
      contentType: 'image/png',
      contentLength: 100,
      etag: 'e2',
    });
    await service.completeUpload('biz', 'acct', intent.intentId);

    const download = await service.getDownloadUrl(
      'biz',
      'acct',
      intent.intentId,
    );
    expect(download.visibility).toBe('public');
    expect(download.url).toStartWith('https://cdn.example.com/');
    expect(download.expiresAt).toBeNull();
  });

  test('delete soft-deletes and removes object', async () => {
    const repo = new FakeRepository();
    const provider = new FakeProvider();
    const service = createService(repo, provider);

    const intent = await service.createUploadIntent('biz', 'acct', {
      purpose: 'other',
      visibility: 'private',
      mimeType: 'image/jpeg',
      fileSize: 100,
    });
    provider.objects.set(intent.storageKey, {
      contentType: 'image/jpeg',
      contentLength: 100,
      etag: 'e3',
    });
    await service.completeUpload('biz', 'acct', intent.intentId);
    await service.deleteAsset('biz', 'acct', intent.intentId);

    expect(provider.deleted).toContain(intent.storageKey);
    await expect(
      service.getAsset('biz', 'acct', intent.intentId),
    ).rejects.toBeInstanceOf(StorageNotFoundError);
  });

  test('replace soft-deletes old and creates new intent', async () => {
    const repo = new FakeRepository();
    const provider = new FakeProvider();
    const service = createService(repo, provider);

    const intent = await service.createUploadIntent('biz', 'acct', {
      purpose: 'branding',
      visibility: 'public',
      mimeType: 'image/png',
      fileSize: 100,
    });
    provider.objects.set(intent.storageKey, {
      contentType: 'image/png',
      contentLength: 100,
      etag: 'e4',
    });
    await service.completeUpload('biz', 'acct', intent.intentId);

    const next = await service.replaceAsset('biz', 'acct', intent.intentId, {
      mimeType: 'image/webp',
      fileSize: 200,
    });

    expect(next.intentId).not.toBe(intent.intentId);
    expect(next.mimeType).toBe('image/webp');
    expect(provider.deleted).toContain(intent.storageKey);
  });
});
