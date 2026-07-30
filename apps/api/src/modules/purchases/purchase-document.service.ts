import { getDb } from '../../db/client';
import { ensureDocumentSequence } from '../../shared/documents/document-numbering.service';
import {
  calculateLineTax,
  resolveTaxType,
  sumDocumentTotals,
} from '../../shared/documents/document-tax.service';
import { AppError } from '../../shared/errors/app-error';
import { PaymentRepository } from '../accounting/payment.repository';
import { DEFAULT_SERIES_BY_TYPE } from './purchase.constants';
import { assertValidConversion } from './purchase-convert.rules';
import { PurchaseDocumentRepository } from './purchase-document.repository';
import type {
  ConvertPurchaseDocumentBody,
  CreatePurchaseDocumentBody,
  CreatePurchaseLineBody,
  FinalizePurchaseDocumentBody,
  ListPurchaseDocumentsQuery,
  UpdatePurchaseDocumentBody,
  UpdatePurchaseLineBody,
} from './purchase-document.schema';
import type {
  FinalizePurchaseDocumentResponse,
  PurchaseDocumentLineRecord,
  PurchaseDocumentRecord,
  PurchaseDocumentType,
} from './purchase-document.types';
import { finalizePurchaseDocument } from './purchase-finalize.service';
import { PurchasesServiceBase } from './purchases.base-service';

export class PurchaseDocumentService extends PurchasesServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: PurchaseDocumentRepository;

  constructor() {
    super();
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = db;
    this.repository = new PurchaseDocumentRepository(db);
  }

  async listDocuments(
    businessId: string,
    accountId: string,
    query: ListPurchaseDocumentsQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      documentType: query.document_type,
      status: query.status,
      partyId: query.party_id,
      from: query.from ? new Date(query.from) : undefined,
      to: query.to ? new Date(query.to) : undefined,
      q: query.q,
      sort: query.sort,
      order: query.order,
    });

    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getDocument(
    businessId: string,
    accountId: string,
    documentId: string,
  ): Promise<PurchaseDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const document = await this.repository.findById(
      businessId,
      documentId,
      true,
    );
    if (!document) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    return document;
  }

  async createDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreatePurchaseDocumentBody,
  ): Promise<PurchaseDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertSupplierParty(businessId, input.party_id);

    if (input.converted_from_id) {
      const source = await this.repository.findRowById(
        businessId,
        input.converted_from_id,
      );
      if (!source) {
        throw new AppError('NOT_FOUND', 'Source document not found', 404);
      }
    }

    await ensureDocumentSequence(
      this.db,
      businessId,
      input.document_series,
      input.document_series,
    );

    return this.repository.create({
      businessId,
      documentType: input.document_type,
      documentSeries: input.document_series,
      partyId: input.party_id,
      isGstFormal: input.is_gst_formal,
      partyStateCode: input.party_state_code ?? null,
      documentDate: input.document_date
        ? new Date(input.document_date)
        : undefined,
      convertedFromId: input.converted_from_id ?? null,
      supplierInvoiceNumber: input.supplier_invoice_number ?? null,
      dueDate: input.due_date ?? null,
      notes: input.notes ?? null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    input: UpdatePurchaseDocumentBody,
  ): Promise<PurchaseDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertDraftDocument(businessId, documentId);

    if (input.party_id) {
      await this.assertSupplierParty(businessId, input.party_id);
    }

    const updated = await this.repository.update(businessId, documentId, {
      partyId: input.party_id,
      isGstFormal: input.is_gst_formal,
      partyStateCode: input.party_state_code,
      documentDate: input.document_date
        ? new Date(input.document_date)
        : undefined,
      documentSeries: input.document_series,
      supplierInvoiceNumber: input.supplier_invoice_number,
      dueDate: input.due_date,
      notes: input.notes,
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    return updated;
  }

  async deleteDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertDraftDocument(businessId, documentId);

    const deleted = await this.repository.softDelete(
      businessId,
      documentId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }
  }

  async listLines(
    businessId: string,
    accountId: string,
    documentId: string,
  ): Promise<PurchaseDocumentLineRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);

    const document = await this.repository.findById(businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    const lines = await this.repository.listLines(businessId, documentId);
    return lines.map((line) => ({
      id: line.id,
      item_id: line.itemId,
      quantity: line.quantity,
      unit: line.unit,
      unit_price: line.unitPrice,
      discount_amount: line.discountAmount,
      tax_type: line.taxType as PurchaseDocumentLineRecord['tax_type'],
      tax_rate: line.taxRate,
      cgst_amount: line.cgstAmount,
      sgst_amount: line.sgstAmount,
      igst_amount: line.igstAmount,
      line_total: line.lineTotal,
      sort_order: line.sortOrder,
    }));
  }

  async addLine(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    input: CreatePurchaseLineBody,
  ): Promise<PurchaseDocumentLineRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const document = await this.assertDraftDocument(businessId, documentId);

    await this.assertItemValid(businessId, input.item_id);

    const tax = await this.computeLineTax(businessId, document, input);

    return this.db.transaction(async (tx) => {
      const repo = new PurchaseDocumentRepository(
        tx as unknown as typeof this.db,
      );
      const line = await repo.createLine({
        businessId,
        purchaseDocumentId: documentId,
        itemId: input.item_id,
        quantity: input.quantity,
        unit: input.unit,
        unitPrice: input.unit_price,
        discountAmount: input.discount_amount ?? '0',
        taxType: tax.taxType,
        taxRate: input.tax_rate ?? '0',
        cgstAmount: tax.cgstAmount,
        sgstAmount: tax.sgstAmount,
        igstAmount: tax.igstAmount,
        lineTotal: tax.lineTotal,
        sortOrder: input.sort_order,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      await this.recalculateDocumentTotals(businessId, documentId, repo);
      return line;
    });
  }

  async updateLine(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    lineId: string,
    input: UpdatePurchaseLineBody,
  ): Promise<PurchaseDocumentLineRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const document = await this.assertDraftDocument(businessId, documentId);

    const existing = await this.repository.findLineById(
      businessId,
      documentId,
      lineId,
    );
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Line not found', 404);
    }

    if (input.item_id) {
      await this.assertItemValid(businessId, input.item_id);
    }

    const merged = {
      item_id: input.item_id ?? existing.itemId,
      quantity: input.quantity ?? existing.quantity,
      unit: input.unit ?? existing.unit,
      unit_price: input.unit_price ?? existing.unitPrice,
      discount_amount: input.discount_amount ?? existing.discountAmount,
      tax_type: input.tax_type ?? existing.taxType,
      tax_rate: input.tax_rate ?? existing.taxRate,
      tax_inclusive: input.tax_inclusive ?? false,
      sort_order: input.sort_order,
    };

    const tax = await this.computeLineTax(businessId, document, merged);

    return this.db.transaction(async (tx) => {
      const repo = new PurchaseDocumentRepository(
        tx as unknown as typeof this.db,
      );
      const updated = await repo.updateLine(businessId, lineId, {
        itemId: merged.item_id,
        quantity: merged.quantity,
        unit: merged.unit,
        unitPrice: merged.unit_price,
        discountAmount: merged.discount_amount,
        taxType: tax.taxType,
        taxRate: merged.tax_rate,
        cgstAmount: tax.cgstAmount,
        sgstAmount: tax.sgstAmount,
        igstAmount: tax.igstAmount,
        lineTotal: tax.lineTotal,
        sortOrder: merged.sort_order,
        updatedBy: userId ?? null,
      });

      if (!updated) {
        throw new AppError('NOT_FOUND', 'Line not found', 404);
      }

      await this.recalculateDocumentTotals(businessId, documentId, repo);
      return updated;
    });
  }

  async deleteLine(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    lineId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertDraftDocument(businessId, documentId);

    await this.db.transaction(async (tx) => {
      const repo = new PurchaseDocumentRepository(
        tx as unknown as typeof this.db,
      );
      const deleted = await repo.softDeleteLine(
        businessId,
        documentId,
        lineId,
        userId ?? null,
      );

      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Line not found', 404);
      }

      await this.recalculateDocumentTotals(businessId, documentId, repo);
    });
  }

  async finalizeDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    input: FinalizePurchaseDocumentBody,
  ): Promise<FinalizePurchaseDocumentResponse> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await finalizePurchaseDocument(this.db, this.repository, {
      businessId,
      documentId,
      userId,
      godownId: input.godown_id,
      payment: input.payment
        ? {
            amount: input.payment.amount,
            paymentMode: input.payment.payment_mode,
            shortPaymentHandling: input.payment.short_payment_handling ?? null,
            shortfallAmount: input.payment.shortfall_amount ?? null,
            paymentDate: input.payment.payment_date,
          }
        : undefined,
    });

    return {
      success: true,
      message: 'Document finalized',
      document_number: result.documentNumber,
      status: 'finalized',
      paid_amount: result.paidAmount,
      payment_mode: result.paymentMode,
    };
  }

  async cancelDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
  ): Promise<PurchaseDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const document = await this.repository.findRowById(businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    if (document.status !== 'finalized') {
      throw new AppError(
        'DOCUMENT_NOT_EDITABLE',
        'Only finalized documents can be cancelled',
        409,
      );
    }

    const cancelled = await this.repository.cancel(
      businessId,
      documentId,
      userId ?? null,
    );

    if (!cancelled) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    return cancelled;
  }

  async convertDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    input: ConvertPurchaseDocumentBody,
  ): Promise<PurchaseDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const source = await this.repository.findById(businessId, documentId, true);
    if (!source) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    if (source.status === 'converted' || source.status === 'cancelled') {
      throw new AppError(
        'INVALID_CONVERSION',
        'Source document cannot be converted',
        422,
      );
    }

    if (source.status !== 'finalized' && source.status !== 'draft') {
      throw new AppError(
        'INVALID_CONVERSION',
        'Source document cannot be converted',
        422,
      );
    }

    assertValidConversion(
      source.document_type as PurchaseDocumentType,
      input.target_type,
    );

    await this.assertSupplierParty(businessId, source.party_id);

    if (source.lines) {
      for (const line of source.lines) {
        await this.assertItemValid(businessId, line.item_id);
      }
    }

    const newDocId = await this.db.transaction(async (tx) => {
      const repo = new PurchaseDocumentRepository(
        tx as unknown as typeof this.db,
      );

      const newDoc = await repo.create({
        businessId,
        documentType: input.target_type,
        documentSeries:
          DEFAULT_SERIES_BY_TYPE[input.target_type] ?? source.document_series,
        partyId: source.party_id,
        isGstFormal: source.is_gst_formal,
        partyStateCode: source.party_state_code,
        documentDate: new Date(),
        convertedFromId: documentId,
        supplierInvoiceNumber: source.supplier_invoice_number,
        dueDate: source.due_date,
        notes: source.notes,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      if (source.lines) {
        for (const line of source.lines) {
          await repo.createLine({
            businessId,
            purchaseDocumentId: newDoc.id,
            itemId: line.item_id,
            quantity: line.quantity,
            unit: line.unit,
            unitPrice: line.unit_price,
            discountAmount: line.discount_amount,
            taxType: line.tax_type,
            taxRate: line.tax_rate,
            cgstAmount: line.cgst_amount,
            sgstAmount: line.sgst_amount,
            igstAmount: line.igst_amount,
            lineTotal: line.line_total,
            sortOrder: line.sort_order,
            createdBy: userId ?? null,
            updatedBy: userId ?? null,
          });
        }

        await this.recalculateDocumentTotals(businessId, newDoc.id, repo);
      }

      if (
        source.status === 'finalized' &&
        source.document_type === 'purchase_order' &&
        input.target_type === 'purchase_bill'
      ) {
        await repo.markConverted(businessId, documentId, userId ?? null);
      }

      return newDoc.id;
    });

    return this.getDocument(businessId, accountId, newDocId);
  }

  async getPaymentHistory(
    businessId: string,
    accountId: string,
    documentId: string,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const document = await this.repository.findById(businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    const paymentRepository = new PaymentRepository(this.db);
    const rows = await paymentRepository.listPaymentHistoryForPurchaseDocument(
      businessId,
      documentId,
    );

    return { data: rows };
  }

  private async assertDraftDocument(
    businessId: string,
    documentId: string,
  ): Promise<PurchaseDocumentRecord> {
    const document = await this.repository.findById(businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    if (document.status !== 'draft') {
      throw new AppError(
        'DOCUMENT_NOT_EDITABLE',
        'Only draft documents can be modified',
        409,
      );
    }

    return document;
  }

  private async assertSupplierParty(
    businessId: string,
    partyId: string,
  ): Promise<void> {
    const party = await this.repository.findParty(businessId, partyId);
    if (!party) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    if (party.partyType === 'customer') {
      throw new AppError(
        'VALIDATION_ERROR',
        'Purchase documents require a supplier party',
        422,
        { party_id: ['Party must be a supplier or both'] },
      );
    }
  }

  private async assertItemValid(
    businessId: string,
    itemId: string,
  ): Promise<void> {
    const item = await this.repository.findItem(businessId, itemId);
    if (!item) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }
  }

  private async computeLineTax(
    businessId: string,
    document: PurchaseDocumentRecord,
    input: {
      quantity: string;
      unit_price: string;
      discount_amount?: string;
      tax_type?: string;
      tax_rate?: string;
      tax_inclusive?: boolean;
    },
  ) {
    const businessState =
      await this.repository.getBusinessStateCode(businessId);
    const taxType = resolveTaxType(
      document.is_gst_formal,
      businessState,
      document.party_state_code,
    );

    const effectiveTaxType =
      input.tax_type && input.tax_type !== 'none'
        ? (input.tax_type as PurchaseDocumentLineRecord['tax_type'])
        : taxType;

    const tax = calculateLineTax({
      quantity: input.quantity,
      unitPrice: input.unit_price,
      discountAmount: input.discount_amount ?? '0',
      taxType: effectiveTaxType,
      taxRate: input.tax_rate ?? '0',
      taxInclusive: input.tax_inclusive ?? false,
    });

    return {
      taxType: effectiveTaxType,
      ...tax,
    };
  }

  private async recalculateDocumentTotals(
    businessId: string,
    documentId: string,
    repository: PurchaseDocumentRepository = this.repository,
  ): Promise<void> {
    const lines = await repository.listLines(businessId, documentId);
    const totals = sumDocumentTotals(
      lines.map((line) => ({
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        discountAmount: line.discountAmount,
        cgstAmount: line.cgstAmount,
        sgstAmount: line.sgstAmount,
        igstAmount: line.igstAmount,
        lineTotal: line.lineTotal,
      })),
    );

    await repository.updateTotals(businessId, documentId, totals);
  }
}
