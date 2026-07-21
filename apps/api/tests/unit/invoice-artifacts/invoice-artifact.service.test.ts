import { describe, expect, mock, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import { InvoiceArtifactService } from '../../../src/modules/invoice-artifacts/invoice-artifact.service';

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

function sampleGeneratedDocumentResponse() {
  return {
    id: 'doc-1',
    document_kind: 'invoice_pdf' as const,
    source_type: 'sale_document' as const,
    source_id: invoiceId,
    source_version: 1,
    file_name: 'invoice.pdf',
    mime_type: 'application/pdf',
    public_token: 'public-token',
    cached: true,
    generated_at: '2026-01-01T00:00:00.000Z',
  };
}

describe('InvoiceArtifactService', () => {
  test('ensurePdf delegates to GeneratedDocumentService', async () => {
    const ensure = mock(async () => sampleGeneratedDocumentResponse());

    const service = new InvoiceArtifactService({
      config: baseConfig(),
      generatedDocuments: { ensure } as never,
      repository: {} as never,
      storage: {} as never,
      mediaService: {} as never,
    });

    const result = await service.ensurePdf(
      businessId,
      accountId,
      invoiceId,
      'tax_invoice',
    );

    expect(ensure).toHaveBeenCalledWith(businessId, accountId, {
      documentKind: 'invoice_pdf',
      sourceType: 'sale_document',
      sourceId: invoiceId,
    });
    expect(result).toEqual(sampleGeneratedDocumentResponse());
  });

  test('uploadTemporaryPreview stores under sales/{saleId}/previews/', async () => {
    const storeFromBuffer = mock(async () => ({ id: 'asset-1' }));
    const getBusinessAssetDownloadUrl = mock(async () => ({
      url: 'https://cdn.example.com/preview.png',
      expiresAt: null,
    }));

    const service = new InvoiceArtifactService({
      config: baseConfig(),
      generatedDocuments: {} as never,
      repository: {} as never,
      mediaService: {} as never,
      storage: {
        storeFromBuffer,
        getBusinessAssetDownloadUrl,
        deleteAsset: async () => undefined,
      } as never,
    });

    const uploaded = await service.uploadTemporaryPreview(
      businessId,
      accountId,
      invoiceId,
      Buffer.from('png'),
    );

    expect(uploaded.mediaAssetId).toBe('asset-1');
    expect(uploaded.downloadUrl).toContain('preview.png');
    expect(storeFromBuffer).toHaveBeenCalled();
    const call = storeFromBuffer.mock.calls[0] as unknown as [
      string,
      string,
      { storageKeyOverride: string; ownerType: string },
    ];
    expect(call[2].ownerType).toBe('invoice_preview');
    expect(call[2].storageKeyOverride).toContain(
      `sales/${invoiceId}/previews/`,
    );
    expect(call[2].storageKeyOverride.endsWith('.png')).toBe(true);
  });

  test('deleteTemporaryArtifacts best-effort deletes storage asset', async () => {
    const deleteAsset = mock(async () => undefined);
    const service = new InvoiceArtifactService({
      config: baseConfig(),
      generatedDocuments: {} as never,
      repository: {} as never,
      mediaService: {} as never,
      storage: { deleteAsset } as never,
    });

    await service.deleteTemporaryArtifacts(businessId, accountId, 'asset-1');
    expect(deleteAsset).toHaveBeenCalledWith(businessId, accountId, 'asset-1');
  });

  test('generateShareMetadata builds website URL', () => {
    const service = new InvoiceArtifactService({
      config: baseConfig(),
      generatedDocuments: {} as never,
      repository: {} as never,
      mediaService: {} as never,
      storage: {} as never,
    });

    const meta = service.generateShareMetadata({
      token: 'abc',
      invoiceNumber: 'INV-1',
      dueAmount: '10.0000',
      expiresAt: new Date('2027-01-01T00:00:00.000Z'),
    });

    expect(meta.shareUrl).toBe('https://billingbaba.com/invoice/abc');
    expect(meta.invoiceNumber).toBe('INV-1');
  });
});
