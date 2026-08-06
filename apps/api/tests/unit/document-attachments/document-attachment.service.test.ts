import { describe, expect, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import { AppError } from '../../../src/shared/errors/app-error';
import { StorageNotFoundError } from '../../../src/modules/storage/storage.errors';
import type { StorageService } from '../../../src/modules/storage/storage.service';
import type { UploadIntent } from '../../../src/modules/storage/storage.types';
import type { DocumentAttachmentRepository } from '../../../src/modules/document-attachments/document-attachment.repository';
import { DocumentAttachmentService } from '../../../src/modules/document-attachments/document-attachment.service';
import { MAX_DOCUMENT_ATTACHMENTS } from '../../../src/modules/document-attachments/document-attachment.constants';

const BIZ = '11111111-1111-1111-1111-111111111111';
const ACC = '22222222-2222-2222-2222-222222222222';
const DOC = '33333333-3333-3333-3333-333333333333';

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

const sampleAttachment = {
  id: '44444444-4444-4444-4444-444444444444',
  business_id: BIZ,
  entity_type: 'sale' as const,
  entity_id: DOC,
  media_asset_id: '55555555-5555-5555-5555-555555555555',
  file_name: 'invoice.pdf',
  file_url: 'https://cdn/invoice.pdf',
  mime_type: 'application/pdf',
  attachment_kind: 'pdf' as const,
  sort_order: 0,
  label: null,
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
};

const membership = {
  hasBusinessMembership: async () => true,
};

const noopEntityAssert = async () => undefined;

describe('DocumentAttachmentService', () => {
  test('createUploadIntent rejects when attachment limit reached', async () => {
    const repository = {
      countByEntity: async () => MAX_DOCUMENT_ATTACHMENTS,
    } as unknown as DocumentAttachmentRepository;

    const service = new DocumentAttachmentService({
      config: baseConfig(),
      repository,
      storage: {} as StorageService,
      membership,
      assertEntityExists: noopEntityAssert,
    });

    await expect(
      service.createUploadIntent(
        BIZ,
        ACC,
        'manager',
        'sale',
        DOC,
        'application/pdf',
        1024,
      ),
    ).rejects.toThrow(AppError);
  });

  test('completeUpload binds asset and replaces previous attachment', async () => {
    let deletedOld = false;

    const repository = {
      countByEntity: async () => 1,
      insert: async () => sampleAttachment,
      findById: async (_biz: string, id: string) => ({
        ...sampleAttachment,
        id,
        media_asset_id:
          id === '99999999-9999-9999-9999-999999999999'
            ? '66666666-6666-6666-6666-666666666666'
            : sampleAttachment.media_asset_id,
      }),
      softDelete: async () => true,
    } as unknown as DocumentAttachmentRepository;

    const storage = {
      completeUpload: async () => ({
        id: '55555555-5555-5555-5555-555555555555',
        businessId: BIZ,
        storageKey: 'key',
        bucket: 'b',
        purpose: 'sales',
        visibility: 'authenticated',
        mimeType: 'application/pdf',
        fileSize: 100,
        etag: 'e',
        checksum: null,
        ownerType: 'sale',
        ownerId: DOC,
        status: 'ready',
        uploadedBy: ACC,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }),
      resolveBusinessAssetUrl: async () => 'https://cdn/new.pdf',
      deleteAsset: async (_b: string, _a: string, assetId: string) => {
        if (assetId === '66666666-6666-6666-6666-666666666666') {
          deletedOld = true;
        }
      },
    } as unknown as StorageService;

    const service = new DocumentAttachmentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      assertEntityExists: noopEntityAssert,
    });

    const result = await service.completeUpload(
      BIZ,
      ACC,
      '77777777-7777-7777-7777-777777777777',
      'manager',
      'sale',
      DOC,
      '88888888-8888-8888-8888-888888888888',
      {
        fileName: 'receipt.pdf',
        replacesAttachmentId: '99999999-9999-9999-9999-999999999999',
      },
    );

    expect(result.media_asset_id).toBe('55555555-5555-5555-5555-555555555555');
    expect(deletedOld).toBe(true);
  });

  test('deleteAttachment deletes storage object', async () => {
    let deleted = false;

    const repository = {
      findById: async () => sampleAttachment,
      softDelete: async () => true,
    } as unknown as DocumentAttachmentRepository;

    const storage = {
      deleteAsset: async () => {
        deleted = true;
      },
    } as unknown as StorageService;

    const service = new DocumentAttachmentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      assertEntityExists: noopEntityAssert,
    });

    await service.deleteAttachment(
      BIZ,
      ACC,
      '77777777-7777-7777-7777-777777777777',
      'manager',
      sampleAttachment.id,
    );
    expect(deleted).toBe(true);
  });

  test('deleteAttachment ignores missing storage object', async () => {
    const repository = {
      findById: async () => sampleAttachment,
      softDelete: async () => true,
    } as unknown as DocumentAttachmentRepository;

    const storage = {
      deleteAsset: async () => {
        throw new StorageNotFoundError();
      },
    } as unknown as StorageService;

    const service = new DocumentAttachmentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      assertEntityExists: noopEntityAssert,
    });

    await expect(
      service.deleteAttachment(
        BIZ,
        ACC,
        '77777777-7777-7777-7777-777777777777',
        'manager',
        sampleAttachment.id,
      ),
    ).resolves.toBeUndefined();
  });

  test('createUploadIntent delegates to storage with sales purpose', async () => {
    let capturedPurpose = '';

    const repository = {
      countByEntity: async () => 0,
    } as unknown as DocumentAttachmentRepository;

    const storage = {
      createUploadIntent: async (
        _b: string,
        _a: string,
        input: { purpose?: string; ownerType?: string | null },
      ): Promise<UploadIntent> => {
        capturedPurpose = input.purpose ?? '';
        expect(input.ownerType).toBe('estimate');
        return {
          intentId: '88888888-8888-8888-8888-888888888888',
          uploadUrl: 'https://upload',
          storageKey: 'key',
          headers: {},
          expiresAt: new Date().toISOString(),
          maxBytes: 10_485_760,
          mimeType: 'image/png',
        };
      },
    } as unknown as StorageService;

    const service = new DocumentAttachmentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      assertEntityExists: noopEntityAssert,
    });

    const intent = await service.createUploadIntent(
      BIZ,
      ACC,
      'manager',
      'estimate',
      DOC,
      'image/png',
      1024,
    );

    expect(intent.intentId).toBe('88888888-8888-8888-8888-888888888888');
    expect(capturedPurpose).toBe('sales');
  });

  test('createUploadIntent uses documents purpose for party attachments', async () => {
    let capturedPurpose = '';

    const repository = {
      countByEntity: async () => 0,
    } as unknown as DocumentAttachmentRepository;

    const storage = {
      createUploadIntent: async (
        _b: string,
        _a: string,
        input: { purpose?: string; ownerType?: string | null },
      ): Promise<UploadIntent> => {
        capturedPurpose = input.purpose ?? '';
        expect(input.ownerType).toBe('party');
        return {
          intentId: '99999999-8888-7777-6666-555555555555',
          uploadUrl: 'https://upload',
          storageKey: 'key',
          headers: {},
          expiresAt: new Date().toISOString(),
          maxBytes: 10_485_760,
          mimeType: 'application/pdf',
        };
      },
    } as unknown as StorageService;

    const service = new DocumentAttachmentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      assertEntityExists: noopEntityAssert,
    });

    const intent = await service.createUploadIntent(
      BIZ,
      ACC,
      'manager',
      'party',
      DOC,
      'application/pdf',
      2048,
    );

    expect(intent.intentId).toBe('99999999-8888-7777-6666-555555555555');
    expect(capturedPurpose).toBe('documents');
  });

  test('staff cannot create attachment upload intent', async () => {
    const repository = {
      countByEntity: async () => 0,
    } as unknown as DocumentAttachmentRepository;

    const service = new DocumentAttachmentService({
      config: baseConfig(),
      repository,
      storage: {} as StorageService,
      membership,
      assertEntityExists: noopEntityAssert,
    });

    await expect(
      service.createUploadIntent(
        BIZ,
        ACC,
        'staff',
        'party',
        DOC,
        'application/pdf',
        100,
      ),
    ).rejects.toThrow(AppError);
  });

  test('staff can view attachment download url', async () => {
    const repository = {
      findById: async () => ({ ...sampleAttachment, entity_type: 'party' as const }),
    } as unknown as DocumentAttachmentRepository;

    const storage = {
      resolveBusinessAssetUrl: async () => 'https://cdn/party-note.pdf',
    } as unknown as StorageService;

    const service = new DocumentAttachmentService({
      config: baseConfig(),
      repository,
      storage,
      membership,
      assertEntityExists: noopEntityAssert,
    });

    const result = await service.getDownloadUrl(
      BIZ,
      ACC,
      'staff',
      sampleAttachment.id,
    );

    expect(result.download_url).toBe('https://cdn/party-note.pdf');
  });
});
