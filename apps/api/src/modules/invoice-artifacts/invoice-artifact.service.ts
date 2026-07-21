import { randomUUID } from 'node:crypto';
import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { GeneratedDocumentService } from '../generated-documents/generated-document.service';
import { InvoiceShareRepository } from '../invoice-share/invoice-share.repository';
import {
  buildInvoiceShareUrl,
  dueAmount,
  formatDisplayDate,
} from '../invoice-share/invoice-share.utils';
import {
  generatedKindForSalesDocumentType,
  NotificationMediaService,
} from '../notifications/notification-media.service';
import { StorageNotFoundError } from '../storage/storage.errors';
import { StorageService } from '../storage/storage.service';
import { InvoicePreviewRenderer } from './invoice-preview.renderer';
import type {
  InvoiceShareMetadata,
  PaymentQrResult,
  TemporaryPreviewUpload,
} from './invoice-artifact.types';
import { PaymentQrService } from './payment-qr.service';

export type InvoiceArtifactServiceDeps = {
  config: AppConfig;
  generatedDocuments?: GeneratedDocumentService;
  storage?: StorageService;
  repository?: InvoiceShareRepository;
  mediaService?: NotificationMediaService;
  previewRenderer?: InvoicePreviewRenderer;
  paymentQr?: PaymentQrService;
};

function requireDb() {
  const db = getDb();
  if (!db) {
    throw new AppError(
      'DATABASE_NOT_CONFIGURED',
      'Database is not configured',
      503,
    );
  }
  return db;
}

/**
 * Owns invoice PDF cache, temporary WhatsApp preview images, payment QR,
 * and share metadata. Business modules must not generate invoice images directly.
 */
export class InvoiceArtifactService {
  private readonly config: AppConfig;
  private readonly generatedDocuments: GeneratedDocumentService;
  private readonly storage: StorageService;
  private readonly repository: InvoiceShareRepository;
  private readonly mediaService: NotificationMediaService;
  private readonly previewRenderer: InvoicePreviewRenderer;
  private readonly paymentQr: PaymentQrService;

  constructor(deps: InvoiceArtifactServiceDeps) {
    this.config = deps.config;
    this.generatedDocuments =
      deps.generatedDocuments ??
      new GeneratedDocumentService({ config: deps.config });
    this.storage = deps.storage ?? new StorageService({ config: deps.config });
    this.repository =
      deps.repository ?? new InvoiceShareRepository(requireDb());
    this.mediaService =
      deps.mediaService ??
      new NotificationMediaService({ config: deps.config });
    this.previewRenderer = deps.previewRenderer ?? new InvoicePreviewRenderer();
    this.paymentQr = deps.paymentQr ?? new PaymentQrService();
  }

  async ensurePdf(
    businessId: string,
    accountId: string,
    invoiceId: string,
    documentType: string,
  ) {
    const kind = generatedKindForSalesDocumentType(documentType);
    if (!kind) {
      throw new AppError(
        'PDF_GENERATION_UNSUPPORTED',
        'This document type cannot generate a PDF',
        400,
      );
    }

    return this.generatedDocuments.ensure(businessId, accountId, {
      documentKind: kind,
      sourceType: 'sale_document',
      sourceId: invoiceId,
    });
  }

  /**
   * Public Download PDF: reuse stored canonical invoice.pdf when present,
   * otherwise generate the professional PDF once and store it.
   */
  async resolveCanonicalPdfDownload(
    businessId: string,
    accountId: string,
    invoiceId: string,
    documentType: string,
  ): Promise<{
    download_url: string;
    file_name: string;
    expires_at: string | null;
    cached: boolean;
  }> {
    const kind = generatedKindForSalesDocumentType(documentType);
    if (!kind) {
      throw new AppError(
        'PDF_GENERATION_UNSUPPORTED',
        'This document type cannot generate a PDF',
        400,
      );
    }

    return this.generatedDocuments.resolveOrCreateSalePdfDownload(
      businessId,
      accountId,
      invoiceId,
      kind,
    );
  }

  async resolvePdfDownloadPath(
    businessId: string,
    invoiceId: string,
    documentType: string,
  ): Promise<string | null> {
    const meta = await this.mediaService.resolvePublicSaleDocumentPdfMeta(
      businessId,
      invoiceId,
      documentType,
    );
    return meta?.downloadPath ?? null;
  }

  async generatePreview(
    businessId: string,
    accountId: string,
    invoiceId: string,
  ): Promise<Buffer> {
    const document = await this.repository.findSalesDocument(
      businessId,
      invoiceId,
    );
    if (!document) {
      throw new AppError('NOT_FOUND', 'Invoice not found', 404);
    }

    const company = await this.repository.findBusiness(businessId);
    if (!company) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    const party = document.partyId
      ? await this.repository.findParty(businessId, document.partyId)
      : null;

    const [lines, paidAmount, loyalty] = await Promise.all([
      this.repository.listLinesWithItems(businessId, invoiceId),
      this.repository.getPaidAmount(businessId, invoiceId),
      this.repository.getLoyaltyForSale(
        businessId,
        invoiceId,
        document.partyId,
      ),
    ]);

    let logoBuffer: Buffer | null = null;
    if (company.logoMediaAssetId) {
      try {
        logoBuffer = await this.storage.getObjectBuffer(
          businessId,
          accountId,
          company.logoMediaAssetId,
        );
      } catch {
        logoBuffer = null;
      }
    }

    const invoiceNumber =
      document.documentNumber ??
      `${document.documentSeries}-${document.id.slice(0, 8)}`;

    return this.previewRenderer.render({
      companyName: company.name,
      companyAddress: company.address,
      companyPhone: company.phone,
      companyGstin: company.gstin,
      logoBuffer,
      invoiceNumber,
      invoiceDate: formatDisplayDate(document.documentDate),
      customerName: party?.name ?? 'Walk-in customer',
      customerPhone: party?.mobile ?? null,
      lines: lines.map((line) => ({
        itemName: line.itemName,
        quantity: line.quantity,
        unit: line.unit,
        unitPrice: line.unitPrice,
        lineTotal: line.lineTotal,
      })),
      totalAmount: document.totalAmount,
      paidAmount,
      dueAmount: dueAmount(document.totalAmount, paidAmount),
      loyalty: loyalty
        ? {
            earnedPoints: loyalty.earned_points,
            redeemedPoints: loyalty.redeemed_points,
            pointsAvailable: loyalty.points_available,
          }
        : null,
    });
  }

  async uploadTemporaryPreview(
    businessId: string,
    accountId: string,
    invoiceId: string,
    buffer: Buffer,
  ): Promise<TemporaryPreviewUpload> {
    const previewId = randomUUID();
    const storageKey = [
      this.config.environment,
      'businesses',
      businessId,
      'sales',
      invoiceId,
      'previews',
      `${previewId}.png`,
    ].join('/');

    const asset = await this.storage.storeFromBuffer(businessId, accountId, {
      purpose: 'sales',
      visibility: 'private',
      mimeType: 'image/png',
      buffer,
      ownerType: 'invoice_preview',
      ownerId: invoiceId,
      extension: 'png',
      storageKeyOverride: storageKey,
      policy: {
        allowedMimes: ['image/png'],
        maxBytes: 5 * 1024 * 1024,
      },
    });

    const download = await this.storage.getBusinessAssetDownloadUrl(
      businessId,
      asset.id,
    );

    return {
      mediaAssetId: asset.id,
      downloadUrl: download.url,
      expiresAt: download.expiresAt,
    };
  }

  async deleteTemporaryArtifacts(
    businessId: string,
    accountId: string,
    mediaAssetId: string,
  ): Promise<void> {
    try {
      await this.storage.deleteAsset(businessId, accountId, mediaAssetId);
    } catch (error) {
      if (!(error instanceof StorageNotFoundError)) {
        // Best-effort cleanup — lifecycle rules cover leftovers.
        console.warn('Failed to delete temporary invoice preview', {
          mediaAssetId,
          error: error instanceof Error ? error.message : 'unknown',
        });
      }
    }
  }

  generateShareMetadata(input: {
    token: string;
    invoiceNumber: string;
    dueAmount: string;
    expiresAt: Date | null;
  }): InvoiceShareMetadata {
    return {
      token: input.token,
      shareUrl: buildInvoiceShareUrl(this.config.websiteUrl, input.token),
      expiresAt: input.expiresAt?.toISOString() ?? null,
      invoiceNumber: input.invoiceNumber,
      dueAmount: input.dueAmount,
    };
  }

  async generatePaymentQr(
    businessId: string,
    invoiceId: string,
  ): Promise<PaymentQrResult | null> {
    const document = await this.repository.findSalesDocument(
      businessId,
      invoiceId,
    );
    if (!document) return null;

    const company = await this.repository.findBusiness(businessId);
    if (!company?.upiId) return null;

    const paidAmount = await this.repository.getPaidAmount(
      businessId,
      invoiceId,
    );
    const balance = dueAmount(document.totalAmount, paidAmount);
    if (!(Number.parseFloat(balance) > 0)) return null;

    const invoiceNumber =
      document.documentNumber ??
      `${document.documentSeries}-${document.id.slice(0, 8)}`;

    return this.paymentQr.generate({
      upiId: company.upiId,
      companyName: company.name,
      dueAmount: balance,
      invoiceNumber,
    });
  }
}
