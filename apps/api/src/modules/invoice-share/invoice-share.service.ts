import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { normalizeIndianMobile } from '../../shared/utils/phone-number';
import { OutstandingRepository } from '../accounting/outstanding.repository';
import { InvoiceArtifactService } from '../invoice-artifacts/invoice-artifact.service';
import type { NotificationService } from '../notifications/notification.service';
import { NotificationMediaService } from '../notifications/notification-media.service';
import { getSharedNotificationService } from '../notifications/notification-service.factory';
import {
  GeneratedDocumentService,
} from '../generated-documents/generated-document.service';
import { generatedKindForSalesDocumentType } from '../notifications/notification-media.service';
import { MediaAssetRepository } from '../storage/storage.repository';
import { InvoiceShareRepository } from './invoice-share.repository';
import type {
  InvoiceShareLinkDto,
  NotifyDispatchDto,
  PaymentQrJsonDto,
  PublicInvoiceDto,
} from './invoice-share.types';
import {
  buildInvoiceShareUrl,
  dueAmount,
  formatDisplayDate,
  generateInvoiceShareToken,
  paymentStatusFromAmounts,
} from './invoice-share.utils';

function requireValidPhone(raw: string | null | undefined): string {
  if (!raw?.trim()) {
    throw new AppError(
      'PHONE_REQUIRED',
      'Customer phone number is required',
      400,
    );
  }
  const result = normalizeIndianMobile(raw);
  if (!result.ok) {
    throw new AppError('INVALID_PHONE', result.error.message, 400);
  }
  return result.e164;
}

export type InvoiceShareServiceDeps = {
  config: AppConfig;
  repository?: InvoiceShareRepository;
  notificationService?: NotificationService;
  mediaService?: NotificationMediaService;
  generatedDocuments?: GeneratedDocumentService;
  artifacts?: InvoiceArtifactService;
};

export class InvoiceShareService {
  private readonly repository: InvoiceShareRepository;
  private readonly outstandingRepository: OutstandingRepository;
  private readonly notificationService: NotificationService;
  private readonly mediaService: NotificationMediaService;
  private readonly generatedDocuments: GeneratedDocumentService;
  private readonly artifacts: InvoiceArtifactService;
  private readonly config: AppConfig;

  constructor(
    config: AppConfig,
    deps: Omit<InvoiceShareServiceDeps, 'config'> = {},
  ) {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = deps.repository ?? new InvoiceShareRepository(db);
    this.outstandingRepository = new OutstandingRepository(db);
    this.notificationService =
      deps.notificationService ?? getSharedNotificationService(config);
    this.mediaService =
      deps.mediaService ?? new NotificationMediaService({ config });
    this.generatedDocuments =
      deps.generatedDocuments ?? new GeneratedDocumentService({ config });
    this.artifacts =
      deps.artifacts ??
      new InvoiceArtifactService({
        config,
        generatedDocuments: this.generatedDocuments,
        mediaService: this.mediaService,
        repository: this.repository,
      });
    this.config = config;
  }

  /** @deprecated Use constructor(config, deps) */
  static create(
    config: AppConfig,
    notificationService?: NotificationService,
  ): InvoiceShareService {
    return new InvoiceShareService(config, { notificationService });
  }

  async ensureShareLink(
    businessId: string,
    invoiceId: string,
    accountId: string,
  ): Promise<InvoiceShareLinkDto> {
    const document = await this.repository.findSalesDocument(
      businessId,
      invoiceId,
    );
    if (!document) {
      throw new AppError('NOT_FOUND', 'Invoice not found', 404);
    }

    if (document.status === 'draft' || document.status === 'cancelled') {
      throw new AppError(
        'INVOICE_NOT_SHAREABLE',
        'Only finalized invoices can be shared',
        409,
      );
    }

    const existing = await this.repository.findActiveTokenForInvoice(
      invoiceId,
      businessId,
    );
    if (existing) {
      return {
        token: existing.token,
        invoice_id: existing.invoiceId,
        share_url: buildInvoiceShareUrl(this.config.websiteUrl, existing.token),
        expires_at: existing.expiresAt?.toISOString() ?? null,
      };
    }

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + this.config.invoiceShareExpiryDays);

    const token = generateInvoiceShareToken();
    const created = await this.repository.createToken({
      token,
      invoiceId,
      businessId,
      expiresAt,
      createdBy: accountId,
    });

    if (!created) {
      throw new AppError(
        'INVOICE_SHARE_FAILED',
        'Could not create invoice share token',
        500,
      );
    }

    return {
      token: created.token,
      invoice_id: created.invoiceId,
      share_url: buildInvoiceShareUrl(this.config.websiteUrl, created.token),
      expires_at: created.expiresAt?.toISOString() ?? null,
    };
  }

  async revokeShareLink(
    businessId: string,
    invoiceId: string,
  ): Promise<{ revoked: boolean }> {
    const document = await this.repository.findSalesDocument(
      businessId,
      invoiceId,
    );
    if (!document) {
      throw new AppError('NOT_FOUND', 'Invoice not found', 404);
    }

    const existing = await this.repository.findActiveTokenForInvoice(
      invoiceId,
      businessId,
    );
    if (!existing) {
      return { revoked: false };
    }

    await this.repository.revokeToken(existing.id);
    return { revoked: true };
  }

  async regenerateShareLink(
    businessId: string,
    invoiceId: string,
    accountId: string,
  ): Promise<InvoiceShareLinkDto> {
    const document = await this.repository.findSalesDocument(
      businessId,
      invoiceId,
    );
    if (!document) {
      throw new AppError('NOT_FOUND', 'Invoice not found', 404);
    }

    if (document.status === 'draft' || document.status === 'cancelled') {
      throw new AppError(
        'INVOICE_NOT_SHAREABLE',
        'Only finalized invoices can be shared',
        409,
      );
    }

    await this.repository.revokeActiveTokensForInvoice(invoiceId, businessId);

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + this.config.invoiceShareExpiryDays);

    const token = generateInvoiceShareToken();
    const created = await this.repository.createToken({
      token,
      invoiceId,
      businessId,
      expiresAt,
      createdBy: accountId,
    });

    if (!created) {
      throw new AppError(
        'INVOICE_SHARE_FAILED',
        'Could not create invoice share token',
        500,
      );
    }

    return {
      token: created.token,
      invoice_id: created.invoiceId,
      share_url: buildInvoiceShareUrl(this.config.websiteUrl, created.token),
      expires_at: created.expiresAt?.toISOString() ?? null,
    };
  }

  private assertShareTokenActive(share: {
    expiresAt: Date | null;
    revokedAt: Date | null;
  }): void {
    if (share.revokedAt) {
      throw new AppError(
        'INVOICE_SHARE_REVOKED',
        'This invoice link has been revoked',
        410,
      );
    }
    if (share.expiresAt && share.expiresAt.getTime() < Date.now()) {
      throw new AppError(
        'INVOICE_SHARE_EXPIRED',
        'This invoice link has expired',
        410,
      );
    }
  }

  async getPublicInvoice(token: string): Promise<PublicInvoiceDto> {
    const share = await this.repository.findTokenByValue(token);
    if (!share) {
      throw new AppError('INVOICE_NOT_FOUND', 'Invoice not found', 404);
    }

    this.assertShareTokenActive(share);

    const document = await this.repository.findSalesDocument(
      share.businessId,
      share.invoiceId,
    );
    if (!document) {
      throw new AppError('INVOICE_NOT_FOUND', 'Invoice not found', 404);
    }

    if (document.status === 'draft' || document.status === 'cancelled') {
      throw new AppError('INVOICE_NOT_FOUND', 'Invoice not found', 404);
    }

    const company = await this.repository.findBusiness(share.businessId);
    if (!company) {
      throw new AppError('INVOICE_NOT_FOUND', 'Invoice not found', 404);
    }

    const party = document.partyId
      ? await this.repository.findParty(share.businessId, document.partyId)
      : null;

    const [lines, paidAmount, loyalty] = await Promise.all([
      this.repository.listLinesWithItems(share.businessId, share.invoiceId),
      this.repository.getPaidAmount(share.businessId, share.invoiceId),
      this.repository.getLoyaltyForSale(
        share.businessId,
        share.invoiceId,
        document.partyId,
      ),
    ]);

    const balance = dueAmount(document.totalAmount, paidAmount);
    const paymentStatus = paymentStatusFromAmounts(
      document.totalAmount,
      paidAmount,
    );
    const scanToPayEnabled =
      Boolean(company.upiId?.trim()) && Number.parseFloat(balance) > 0;

    const logoUrl = await this.mediaService.resolveBrandingLogoUrl(
      share.businessId,
    );

    const shareUrl = buildInvoiceShareUrl(this.config.websiteUrl, share.token);
    const expiresAt = share.expiresAt?.toISOString() ?? null;
    const pdfDownloadPath = `${this.config.apiPrefix}/public/invoices/${share.token}/download`;

    return {
      token: share.token,
      invoice: {
        document_number: document.documentNumber,
        document_series: document.documentSeries,
        document_type: document.documentType,
        document_date: document.documentDate.toISOString(),
        status: document.status,
        notes: document.notes,
        subtotal: document.subtotal,
        discount_total: document.discountTotal,
        tax_amount: document.taxAmount,
        total_amount: document.totalAmount,
        paid_amount: paidAmount,
        due_amount: balance,
        payment_status: paymentStatus,
        loyalty,
      },
      company: {
        name: company.name,
        gstin: company.gstin,
        address: company.address,
        phone: company.phone,
        email: company.email,
        state_code: company.stateCode,
        logo_url: logoUrl,
        upi_id: company.upiId ?? null,
      },
      customer: party
        ? {
            name: party.name,
            mobile: party.mobile,
            email: party.email,
            gstin: party.gstin,
            state_code: party.stateCode,
          }
        : null,
      lines: lines.map((line) => ({
        item_name: line.itemName,
        quantity: line.quantity,
        unit: line.unit,
        unit_price: line.unitPrice,
        discount_amount: line.discountAmount,
        tax_type: line.taxType,
        tax_rate: line.taxRate,
        cgst_amount: line.cgstAmount,
        sgst_amount: line.sgstAmount,
        igst_amount: line.igstAmount,
        line_total: line.lineTotal,
      })),
      payment: {
        upi_id: company.upiId ?? null,
        due_amount: balance,
        scan_to_pay_enabled: scanToPayEnabled,
      },
      share: {
        url: shareUrl,
        token: share.token,
        expires_at: expiresAt,
      },
      share_url: shareUrl,
      expires_at: expiresAt,
      pdf_download_path: pdfDownloadPath,
    };
  }

  async getPaymentQr(
    token: string,
  ): Promise<{ png: Buffer; json: PaymentQrJsonDto }> {
    const share = await this.repository.findTokenByValue(token);
    if (!share) {
      throw new AppError('INVOICE_NOT_FOUND', 'Invoice not found', 404);
    }
    this.assertShareTokenActive(share);

    const qr = await this.artifacts.generatePaymentQr(
      share.businessId,
      share.invoiceId,
    );
    if (!qr) {
      throw new AppError(
        'PAYMENT_QR_UNAVAILABLE',
        'Scan to Pay is not available for this invoice',
        404,
      );
    }

    return {
      png: qr.buffer,
      json: {
        qr_data_url: qr.dataUrl,
        amount: qr.amount,
        merchant: qr.merchant,
        upi_id: qr.upiId,
        invoice_number: qr.invoiceNumber,
        upi_payload: qr.upiPayload,
      },
    };
  }

  /**
   * Canonical Download PDF for the public invoice page.
   * Returns a signed storage URL — never regenerates when invoice.pdf already exists.
   */
  async getPublicInvoiceDownload(token: string): Promise<{
    download_url: string;
    file_name: string;
    expires_at: string | null;
    cached: boolean;
  }> {
    const share = await this.repository.findTokenByValue(token);
    if (!share) {
      throw new AppError('INVOICE_NOT_FOUND', 'Invoice not found', 404);
    }
    this.assertShareTokenActive(share);

    const document = await this.repository.findSalesDocument(
      share.businessId,
      share.invoiceId,
    );
    if (!document) {
      throw new AppError('INVOICE_NOT_FOUND', 'Invoice not found', 404);
    }
    if (document.status === 'draft' || document.status === 'cancelled') {
      throw new AppError('INVOICE_NOT_FOUND', 'Invoice not found', 404);
    }

    let actorId = share.createdBy;
    if (!actorId) {
      const db = getDb();
      if (!db) {
        throw new AppError(
          'DATABASE_NOT_CONFIGURED',
          'Database is not configured',
          503,
        );
      }
      actorId = await new MediaAssetRepository(db).findAnyAccountId(
        share.businessId,
      );
    }

    if (!actorId) {
      throw new AppError(
        'PDF_GENERATION_FAILED',
        'No business member available to prepare the invoice PDF',
        503,
      );
    }

    return this.artifacts.resolveCanonicalPdfDownload(
      share.businessId,
      actorId,
      share.invoiceId,
      document.documentType,
    );
  }

  async notifySaleInvoice(
    businessId: string,
    invoiceId: string,
    accountId: string,
    phoneOverride?: string,
  ): Promise<NotifyDispatchDto> {
    const link = await this.ensureShareLink(businessId, invoiceId, accountId);
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

    const phone = requireValidPhone(phoneOverride ?? party?.mobile);

    const invoiceNumber =
      document.documentNumber ??
      `${document.documentSeries}-${document.id.slice(0, 8)}`;

    const kind = generatedKindForSalesDocumentType(document.documentType);
    if (!kind) {
      return {
        notified: false,
        share_url: link.share_url,
        token: link.token,
        error: {
          code: 'PDF_GENERATION_UNSUPPORTED',
          message: 'This document type cannot be sent with an invoice preview',
        },
      };
    }

    try {
      await this.artifacts.ensurePdf(
        businessId,
        accountId,
        invoiceId,
        document.documentType,
      );
    } catch (error) {
      const message =
        error instanceof AppError
          ? error.message
          : 'Failed to generate invoice PDF';
      return {
        notified: false,
        share_url: link.share_url,
        token: link.token,
        error: {
          code: 'PDF_GENERATION_FAILED',
          message,
        },
      };
    }

    let previewUpload: {
      mediaAssetId: string;
      downloadUrl: string;
    } | null = null;

    try {
      const previewBuffer = await this.artifacts.generatePreview(
        businessId,
        accountId,
        invoiceId,
      );
      previewUpload = await this.artifacts.uploadTemporaryPreview(
        businessId,
        accountId,
        invoiceId,
        previewBuffer,
      );
    } catch (error) {
      const message =
        error instanceof AppError
          ? error.message
          : 'Failed to generate invoice preview image';
      return {
        notified: false,
        share_url: link.share_url,
        token: link.token,
        error: {
          code: 'PREVIEW_GENERATION_FAILED',
          message,
        },
      };
    }

    if (!previewUpload?.downloadUrl) {
      return {
        notified: false,
        share_url: link.share_url,
        token: link.token,
        error: {
          code: 'PREVIEW_GENERATION_FAILED',
          message: 'Invoice preview could not be prepared for WhatsApp delivery',
        },
      };
    }

    const result = await this.notificationService.sendSaleInvoice(
      { phone },
      {
        customerName: party?.name ?? 'Customer',
        invoiceNumber,
        amount: document.totalAmount,
        invoiceUrl: link.share_url,
        companyName: company.name,
        invoiceId: document.id,
        mediaUrl: previewUpload.downloadUrl,
      },
      {
        idempotencyKey: `invoice:${invoiceId}`,
        companyId: businessId,
      },
    );

    if (result.success) {
      await this.artifacts.deleteTemporaryArtifacts(
        businessId,
        accountId,
        previewUpload.mediaAssetId,
      );
    }

    return {
      notified: result.success,
      deduped: result.deduped === true,
      share_url: link.share_url,
      token: link.token,
      media_attached: Boolean(previewUpload.downloadUrl && result.success),
      error: result.error
        ? { code: result.error.code, message: result.error.message }
        : undefined,
    };
  }

  async notifyPaymentReminder(
    businessId: string,
    accountId: string,
    input: {
      partyId: string;
      salesDocumentId?: string;
      phone?: string;
      dueDate?: string;
    },
  ): Promise<NotifyDispatchDto> {
    const party = await this.repository.findParty(businessId, input.partyId);
    if (!party) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    const company = await this.repository.findBusiness(businessId);
    if (!company) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    const phone = requireValidPhone(input.phone ?? party.mobile);

    // Always remind against party outstanding (Vyapar parity) — not a single invoice.
    const balanceRaw = await this.outstandingRepository.getPartyBalance(
      businessId,
      input.partyId,
    );
    const balance = Number.parseFloat(balanceRaw ?? '0');
    if (!(balance > 0)) {
      throw new AppError(
        'NO_OUTSTANDING_BALANCE',
        'This party has no outstanding balance',
        409,
      );
    }
    const outstanding = balance.toFixed(4);

    let shareUrl: string | undefined;
    let token: string | undefined;
    let invoiceNumber: string | null = null;
    let invoiceId: string | null = null;

    if (input.salesDocumentId) {
      const document = await this.repository.findSalesDocument(
        businessId,
        input.salesDocumentId,
      );
      if (!document) {
        throw new AppError('NOT_FOUND', 'Invoice not found', 404);
      }
      if (document.partyId !== input.partyId) {
        throw new AppError(
          'INVOICE_PARTY_MISMATCH',
          'Invoice does not belong to this party',
          400,
        );
      }
      const link = await this.ensureShareLink(
        businessId,
        input.salesDocumentId,
        accountId,
      );
      shareUrl = link.share_url;
      token = link.token;
      invoiceNumber = document.documentNumber;
      invoiceId = document.id;
    }

    // Explicit user send — unique key so the first click is never skipped as deduped.
    const result = await this.notificationService.sendPaymentReminder(
      { phone },
      {
        customerName: party.name,
        companyName: company.name,
        amount: outstanding,
        companyPhone: company.phone,
        dueDate: input.dueDate ?? formatDisplayDate(new Date()),
        invoiceUrl: shareUrl,
        invoiceNumber,
        invoiceId,
      },
      {
        idempotencyKey: `reminder:party:${input.partyId}:${crypto.randomUUID()}`,
        companyId: businessId,
      },
    );

    return {
      notified: result.success,
      deduped: result.deduped === true,
      share_url: shareUrl,
      token,
      error: result.error
        ? { code: result.error.code, message: result.error.message }
        : undefined,
    };
  }
}
