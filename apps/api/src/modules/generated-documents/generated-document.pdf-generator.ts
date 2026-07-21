import PDFDocument from 'pdfkit';
import type { AppConfig } from '../../config/app_config';
import type { Database } from '../../db/client';
import { businesses, parties, payments } from '../../db/schema';
import { and, eq } from 'drizzle-orm';
import { AppError } from '../../shared/errors/app-error';
import {
  InvoiceDocumentPdfRenderer,
  type InvoiceDocumentModel,
} from '../invoice-artifacts/invoice-document.pdf-renderer';
import { PaymentQrService } from '../invoice-artifacts/payment-qr.service';
import { InvoiceShareRepository } from '../invoice-share/invoice-share.repository';
import {
  dueAmount,
  formatDisplayDate,
  paymentStatusFromAmounts,
} from '../invoice-share/invoice-share.utils';
import { generatedKindForSalesDocumentType } from '../notifications/notification-media.service';
import { MediaAssetRepository } from '../storage/storage.repository';
import { StorageService } from '../storage/storage.service';
import type {
  GeneratedDocumentKind,
  GeneratedDocumentSourceType,
} from './generated-document.constants';

export type GeneratedDocumentPdfGeneratorDeps = {
  db: Database;
  config?: AppConfig;
  invoiceShareRepository?: InvoiceShareRepository;
  storage?: StorageService;
  mediaAssets?: MediaAssetRepository;
  paymentQr?: PaymentQrService;
  invoiceDocumentRenderer?: InvoiceDocumentPdfRenderer;
};

function defaultFileName(
  kind: GeneratedDocumentKind,
  label: string,
): string {
  const safe = label.replace(/[^\w.-]+/g, '_').slice(0, 80);
  return `${kind.replace('_pdf', '')}-${safe || 'document'}.pdf`;
}

/** Plain layout for payment receipts only. Sale invoices use InvoiceDocumentPdfRenderer. */
async function renderSimplePdf(
  title: string,
  sections: Array<{ heading?: string; lines: string[] }>,
): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 48, size: 'A4' });
    const chunks: Buffer[] = [];
    doc.on('data', (chunk: Buffer) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    doc.fontSize(18).text(title, { align: 'center' });
    doc.moveDown();

    for (const section of sections) {
      if (section.heading) {
        doc.fontSize(12).text(section.heading, { underline: true });
        doc.moveDown(0.5);
      }
      doc.fontSize(10);
      for (const line of section.lines) {
        doc.text(line);
      }
      doc.moveDown();
    }

    doc.end();
  });
}

export class GeneratedDocumentPdfGenerator {
  private readonly db: Database;
  private readonly invoiceShare: InvoiceShareRepository;
  private readonly storage: StorageService | null;
  private readonly mediaAssets: MediaAssetRepository;
  private readonly paymentQr: PaymentQrService;
  private readonly invoiceDocumentRenderer: InvoiceDocumentPdfRenderer;

  constructor(deps: GeneratedDocumentPdfGeneratorDeps) {
    this.db = deps.db;
    this.invoiceShare =
      deps.invoiceShareRepository ?? new InvoiceShareRepository(deps.db);
    this.mediaAssets = deps.mediaAssets ?? new MediaAssetRepository(deps.db);
    this.storage =
      deps.storage ??
      (deps.config ? new StorageService({ config: deps.config }) : null);
    this.paymentQr = deps.paymentQr ?? new PaymentQrService();
    this.invoiceDocumentRenderer =
      deps.invoiceDocumentRenderer ?? new InvoiceDocumentPdfRenderer();
  }

  resolveKindForSalesDocument(documentType: string): GeneratedDocumentKind | null {
    return generatedKindForSalesDocumentType(documentType);
  }

  defaultFileNameFor(
    kind: GeneratedDocumentKind,
    sourceType: GeneratedDocumentSourceType,
    sourceId: string,
    label?: string,
  ): string {
    return defaultFileName(kind, label ?? `${sourceType}-${sourceId.slice(0, 8)}`);
  }

  async generate(
    businessId: string,
    documentKind: GeneratedDocumentKind,
    sourceType: GeneratedDocumentSourceType,
    sourceId: string,
  ): Promise<{ buffer: Buffer; fileName: string }> {
    switch (sourceType) {
      case 'sale_document':
        return this.generateSaleDocumentPdf(
          businessId,
          sourceId,
          documentKind,
        );
      case 'payment':
        if (documentKind !== 'receipt_pdf') {
          throw new AppError(
            'VALIDATION_ERROR',
            'Payment sources only support receipt_pdf',
            400,
          );
        }
        return this.generateReceiptPdf(businessId, sourceId);
      default:
        throw new AppError(
          'PDF_GENERATION_UNSUPPORTED',
          `Server PDF generation is not supported for ${sourceType}`,
          422,
        );
    }
  }

  private async generateSaleDocumentPdf(
    businessId: string,
    invoiceId: string,
    documentKind: GeneratedDocumentKind,
  ): Promise<{ buffer: Buffer; fileName: string }> {
    const document = await this.invoiceShare.findSalesDocument(
      businessId,
      invoiceId,
    );
    if (!document) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }

    const expectedKind = this.resolveKindForSalesDocument(document.documentType);
    if (!expectedKind || expectedKind !== documentKind) {
      throw new AppError(
        'VALIDATION_ERROR',
        'document_kind does not match sales document type',
        400,
      );
    }

    const company = await this.invoiceShare.findBusiness(businessId);
    if (!company) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    const party = document.partyId
      ? await this.invoiceShare.findParty(businessId, document.partyId)
      : null;

    const [lines, paidAmount, loyalty] = await Promise.all([
      this.invoiceShare.listLinesWithItems(businessId, invoiceId),
      this.invoiceShare.getPaidAmount(businessId, invoiceId),
      this.invoiceShare.getLoyaltyForSale(
        businessId,
        invoiceId,
        document.partyId,
      ),
    ]);

    const docNumber =
      document.documentNumber ??
      `${document.documentSeries}-${document.id.slice(0, 8)}`;
    const balance = dueAmount(document.totalAmount, paidAmount);
    const paymentStatus = paymentStatusFromAmounts(
      document.totalAmount,
      paidAmount,
    );

    const logoSrc = await this.loadLogoDataUrl(
      businessId,
      company.logoMediaAssetId,
    );

    let qrDataUrl: string | null = null;
    let qrAmount: string | null = null;
    let qrUpiId: string | null = null;
    let qrMerchant: string | null = null;
    if (company.upiId?.trim() && Number.parseFloat(balance) > 0) {
      const qr = await this.paymentQr.generate({
        upiId: company.upiId,
        companyName: company.name,
        dueAmount: balance,
        invoiceNumber: docNumber,
      });
      if (qr) {
        qrDataUrl = qr.dataUrl;
        qrAmount = qr.amount;
        qrUpiId = qr.upiId;
        qrMerchant = qr.merchant;
      }
    }

    const model: InvoiceDocumentModel = {
      companyName: company.name,
      companyAddress: company.address,
      companyPhone: company.phone,
      companyEmail: company.email ?? null,
      companyGstin: company.gstin,
      logoSrc,
      invoiceNumber: docNumber,
      invoiceDate: formatDisplayDate(document.documentDate),
      paymentStatus,
      customerName: party?.name ?? null,
      customerPhone: party?.mobile ?? null,
      customerEmail: party?.email ?? null,
      customerGstin: party?.gstin ?? null,
      lines: lines.map((line) => {
        const tax =
          Number.parseFloat(line.cgstAmount) +
          Number.parseFloat(line.sgstAmount) +
          Number.parseFloat(line.igstAmount);
        return {
          itemName: line.itemName,
          quantity: line.quantity,
          unit: line.unit,
          unitPrice: line.unitPrice,
          lineTotal: line.lineTotal,
          taxAmount: String(tax),
          discountAmount: line.discountAmount,
        };
      }),
      subtotal: document.subtotal,
      discountTotal: document.discountTotal,
      taxAmount: document.taxAmount,
      totalAmount: document.totalAmount,
      paidAmount,
      dueAmount: balance,
      notes: document.notes,
      loyalty: loyalty
        ? {
            earnedPoints: loyalty.earned_points,
            redeemedPoints: loyalty.redeemed_points,
          }
        : null,
      qrDataUrl,
      qrAmount,
      qrUpiId,
      qrMerchant,
    };

    const buffer = await this.invoiceDocumentRenderer.render(model);

    return {
      buffer,
      fileName: defaultFileName(documentKind, docNumber),
    };
  }

  private async loadLogoDataUrl(
    businessId: string,
    logoMediaAssetId: string | null,
  ): Promise<string | null> {
    if (!this.storage || !logoMediaAssetId) return null;
    try {
      const asset = await this.mediaAssets.findById(
        businessId,
        logoMediaAssetId,
      );
      if (!asset?.storageKey || asset.status !== 'ready') return null;
      const buffer = await this.storage.getObjectBufferByKey(asset.storageKey);
      const mime = asset.mimeType || 'image/png';
      return `data:${mime};base64,${buffer.toString('base64')}`;
    } catch {
      return null;
    }
  }

  private async generateReceiptPdf(
    businessId: string,
    paymentId: string,
  ): Promise<{ buffer: Buffer; fileName: string }> {
    const [payment] = await this.db
      .select()
      .from(payments)
      .where(
        and(
          eq(payments.id, paymentId),
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
        ),
      )
      .limit(1);

    if (!payment) {
      throw new AppError('NOT_FOUND', 'Payment not found', 404);
    }

    const [company] = await this.db
      .select({
        name: businesses.name,
        address: businesses.address,
        gstin: businesses.gstin,
        phone: businesses.phone,
      })
      .from(businesses)
      .where(
        and(eq(businesses.id, businessId), eq(businesses.isDeleted, false)),
      )
      .limit(1);

    if (!company) {
      throw new AppError('NOT_FOUND', 'Company not found', 404);
    }

    const [party] = await this.db
      .select({
        name: parties.name,
        mobile: parties.mobile,
      })
      .from(parties)
      .where(
        and(
          eq(parties.id, payment.partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    const buffer = await renderSimplePdf('Payment Receipt', [
      {
        heading: company.name,
        lines: [company.address ?? '', company.phone ?? ''].filter(Boolean),
      },
      {
        heading: 'Receipt',
        lines: [
          `Payment ID: ${payment.id}`,
          `Date: ${payment.paymentDate.toISOString().slice(0, 10)}`,
          `Amount: ${payment.amount}`,
          `Direction: ${payment.direction}`,
          `Mode: ${payment.paymentMode}`,
        ],
      },
      party
        ? {
            heading: 'Party',
            lines: [party.name, party.mobile ?? ''].filter(Boolean),
          }
        : { lines: [] },
    ]);

    return {
      buffer,
      fileName: defaultFileName('receipt_pdf', payment.id.slice(0, 8)),
    };
  }
}
