import PDFDocument from 'pdfkit';
import type { Database } from '../../db/client';
import { businesses, parties, payments, salesDocuments } from '../../db/schema';
import { and, eq } from 'drizzle-orm';
import { AppError } from '../../shared/errors/app-error';
import { InvoiceShareRepository } from '../invoice-share/invoice-share.repository';
import { generatedKindForSalesDocumentType } from '../notifications/notification-media.service';
import type {
  GeneratedDocumentKind,
  GeneratedDocumentSourceType,
} from './generated-document.constants';

export type GeneratedDocumentPdfGeneratorDeps = {
  db: Database;
  invoiceShareRepository?: InvoiceShareRepository;
};

function documentTitleForKind(kind: GeneratedDocumentKind): string {
  switch (kind) {
    case 'estimate_pdf':
      return 'Estimate';
    case 'delivery_challan_pdf':
      return 'Delivery Challan';
    case 'receipt_pdf':
      return 'Payment Receipt';
    default:
      return 'Tax Invoice';
  }
}

function defaultFileName(
  kind: GeneratedDocumentKind,
  label: string,
): string {
  const safe = label.replace(/[^\w.-]+/g, '_').slice(0, 80);
  return `${kind.replace('_pdf', '')}-${safe || 'document'}.pdf`;
}

async function renderPdf(
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

  constructor(deps: GeneratedDocumentPdfGeneratorDeps) {
    this.db = deps.db;
    this.invoiceShare =
      deps.invoiceShareRepository ?? new InvoiceShareRepository(deps.db);
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

    const [lines, paidAmount] = await Promise.all([
      this.invoiceShare.listLinesWithItems(businessId, invoiceId),
      this.invoiceShare.getPaidAmount(businessId, invoiceId),
    ]);

    const docNumber =
      document.documentNumber ??
      `${document.documentSeries}-${document.id.slice(0, 8)}`;
    const title = documentTitleForKind(documentKind);

    const lineRows = lines.map(
      (line) =>
        `${line.itemName} | ${line.quantity} ${line.unit} x ${line.unitPrice} = ${line.lineTotal}`,
    );

    const buffer = await renderPdf(title, [
      {
        heading: company.name,
        lines: [
          company.address ?? '',
          company.gstin ? `GSTIN: ${company.gstin}` : '',
          company.phone ? `Phone: ${company.phone}` : '',
        ].filter(Boolean),
      },
      {
        heading: 'Document',
        lines: [
          `Number: ${docNumber}`,
          `Date: ${document.documentDate.toISOString().slice(0, 10)}`,
          `Status: ${document.status}`,
        ],
      },
      party
        ? {
            heading: 'Customer',
            lines: [
              party.name,
              party.mobile ?? '',
              party.gstin ? `GSTIN: ${party.gstin}` : '',
            ].filter(Boolean),
          }
        : {
            heading: 'Customer',
            lines: ['Walk-in customer'],
          },
      {
        heading: 'Line items',
        lines: lineRows.length > 0 ? lineRows : ['No line items'],
      },
      {
        heading: 'Totals',
        lines: [
          `Subtotal: ${document.subtotal}`,
          `Discount: ${document.discountTotal}`,
          `Tax: ${document.taxAmount}`,
          `Total: ${document.totalAmount}`,
          `Paid: ${paidAmount}`,
        ],
      },
      document.notes
        ? { heading: 'Notes', lines: [document.notes] }
        : { lines: [] },
    ]);

    return {
      buffer,
      fileName: defaultFileName(documentKind, docNumber),
    };
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

    const buffer = await renderPdf('Payment Receipt', [
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
