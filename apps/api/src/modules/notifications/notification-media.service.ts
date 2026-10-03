import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { BusinessRepository } from '../business/business.repository';
import type {
  GeneratedDocumentKind,
  GeneratedDocumentSourceType,
} from '../generated-documents/generated-document.constants';
import { resolveGeneratedSourceVersion } from '../generated-documents/generated-document.entity-resolver';
import { GeneratedDocumentRepository } from '../generated-documents/generated-document.repository';
import type { SourceVersionSnapshot } from '../generated-documents/generated-document.types';
import { StorageService } from '../storage/storage.service';

export type SourceVersionResolver = (
  businessId: string,
  sourceType: GeneratedDocumentSourceType,
  sourceId: string,
) => Promise<SourceVersionSnapshot>;

export type NotificationMediaServiceDeps = {
  config: AppConfig;
  storage?: StorageService;
  brandingRepository?: BusinessRepository;
  generatedDocuments?: GeneratedDocumentRepository;
  resolveSourceVersion?: SourceVersionResolver;
};

export function generatedKindForSalesDocumentType(
  documentType: string,
): GeneratedDocumentKind | null {
  switch (documentType) {
    case 'estimate':
      return 'estimate_pdf';
    case 'delivery_challan':
      return 'delivery_challan_pdf';
    case 'tax_invoice':
    case 'bill_of_supply':
    case 'normal_invoice':
    case 'pos':
    case 'sales_return':
      return 'invoice_pdf';
    default:
      return null;
  }
}

/**
 * Resolves StorageService download URLs for WhatsApp media attachments.
 * Business modules call this — never upload from NotificationService.
 */
export class NotificationMediaService {
  private readonly storage: StorageService;
  private readonly brandingRepository: BusinessRepository;
  private readonly generatedDocuments: GeneratedDocumentRepository;
  private readonly resolveSourceVersion: SourceVersionResolver;
  private readonly config: AppConfig;

  constructor(deps: NotificationMediaServiceDeps) {
    this.config = deps.config;
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });

    if (deps.brandingRepository && deps.generatedDocuments) {
      this.brandingRepository = deps.brandingRepository;
      this.generatedDocuments = deps.generatedDocuments;
    } else {
      const db = getDb();
      if (!db) {
        throw new AppError(
          'DATABASE_NOT_CONFIGURED',
          'Database is not configured',
          503,
        );
      }
      this.brandingRepository =
        deps.brandingRepository ?? new BusinessRepository(db);
      this.generatedDocuments =
        deps.generatedDocuments ?? new GeneratedDocumentRepository(db);
    }

    this.resolveSourceVersion =
      deps.resolveSourceVersion ??
      (async (businessId, sourceType, sourceId) => {
        const db = getDb();
        if (!db) {
          throw new AppError(
            'DATABASE_NOT_CONFIGURED',
            'Database is not configured',
            503,
          );
        }
        return resolveGeneratedSourceVersion(
          db,
          businessId,
          sourceType,
          sourceId,
        );
      });
  }

  async resolveBrandingLogoUrl(
    businessId: string,
    fallbackUrl?: string | null,
  ): Promise<string | null> {
    const bindings =
      await this.brandingRepository.getBrandingBindings(businessId);
    if (!bindings.logoMediaAssetId) {
      return fallbackUrl ?? null;
    }
    try {
      return await this.storage
        .getBusinessAssetDownloadUrl(businessId, bindings.logoMediaAssetId)
        .then((r) => r.url);
    } catch {
      return fallbackUrl ?? null;
    }
  }

  async resolveSaleDocumentPdfUrl(
    businessId: string,
    invoiceId: string,
    documentType: string,
  ): Promise<string | null> {
    const kind = generatedKindForSalesDocumentType(documentType);
    if (!kind) return null;

    const row = await this.generatedDocuments.findBySource(
      businessId,
      kind,
      'sale_document',
      invoiceId,
    );
    if (!row?.mediaAssetId) return null;

    try {
      const current = await this.resolveSourceVersion(
        businessId,
        'sale_document',
        invoiceId,
      );
      if (row.sourceVersion !== current.sourceVersion) {
        return null;
      }
    } catch {
      return null;
    }

    try {
      const download = await this.storage.getBusinessAssetDownloadUrl(
        businessId,
        row.mediaAssetId,
      );
      return download.url;
    } catch {
      return null;
    }
  }

  async resolvePaymentReceiptPdfUrl(
    businessId: string,
    paymentId: string,
  ): Promise<string | null> {
    const row = await this.generatedDocuments.findBySource(
      businessId,
      'receipt_pdf',
      'payment',
      paymentId,
    );
    if (!row?.mediaAssetId) return null;

    try {
      const current = await this.resolveSourceVersion(
        businessId,
        'payment',
        paymentId,
      );
      if (row.sourceVersion !== current.sourceVersion) {
        return null;
      }
      const download = await this.storage.getBusinessAssetDownloadUrl(
        businessId,
        row.mediaAssetId,
      );
      return download.url;
    } catch {
      return null;
    }
  }

  /**
   * Public path for website PDF download (redirects to signed object URL).
   */
  buildPublicGeneratedFilePath(publicToken: string): string {
    return `${this.config.apiPrefix}/public/generated-documents/${publicToken}/file`;
  }

  async resolvePublicSaleDocumentPdfMeta(
    businessId: string,
    invoiceId: string,
    documentType: string,
  ): Promise<{ publicToken: string; downloadPath: string } | null> {
    const kind = generatedKindForSalesDocumentType(documentType);
    if (!kind) return null;

    const row = await this.generatedDocuments.findBySource(
      businessId,
      kind,
      'sale_document',
      invoiceId,
    );
    if (!row?.mediaAssetId) return null;

    try {
      const current = await this.resolveSourceVersion(
        businessId,
        'sale_document',
        invoiceId,
      );
      if (row.sourceVersion !== current.sourceVersion) {
        return null;
      }
    } catch {
      return null;
    }

    return {
      publicToken: row.publicToken,
      downloadPath: this.buildPublicGeneratedFilePath(row.publicToken),
    };
  }
}
