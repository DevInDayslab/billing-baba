import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { SalesServiceBase } from './sales.base-service';
import { SalesDocumentRepository } from './sales-document.repository';
import type {
  BrandSwapBody,
  ConvertSalesDocumentBody,
  CreatePosSessionBody,
  CreateSalesDocumentBody,
  CreateSalesLineBody,
  FinalizeSalesDocumentBody,
  ListPosSessionsQuery,
  ListSalesDocumentsQuery,
  UpdatePosSessionBody,
  UpdateSalesDocumentBody,
  UpdateSalesLineBody,
} from './sales-document.schema';
import type {
  FinalizeSalesDocumentResponse,
  PosSessionRecord,
  SalesDocumentLineRecord,
  SalesDocumentRecord,
} from './sales-document.types';
import { finalizeSalesDocument } from './sales-finalize.service';
import {
  calculateLineTax,
  resolveTaxType,
  sumDocumentTotals,
} from './sales-tax.service';

export class SalesDocumentService extends SalesServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: SalesDocumentRepository;

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
    this.repository = new SalesDocumentRepository(db);
  }

  async listDocuments(
    businessId: string,
    accountId: string,
    query: ListSalesDocumentsQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      documentType: query.document_type,
      status: query.status,
      partyId: query.party_id,
      posSessionId: query.pos_session_id,
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
  ): Promise<SalesDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const document = await this.repository.findById(
      businessId,
      documentId,
      true,
    );
    if (!document) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }

    return document;
  }

  async createDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateSalesDocumentBody,
  ): Promise<SalesDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    if (input.party_id) {
      await this.assertPartyValid(businessId, input.party_id);
    }

    if (input.converted_from_id) {
      const source = await this.repository.findRowById(
        businessId,
        input.converted_from_id,
      );
      if (!source) {
        throw new AppError('NOT_FOUND', 'Source document not found', 404);
      }
    }

    return this.repository.create({
      businessId,
      documentType: input.document_type,
      documentSeries: input.document_series,
      partyId: input.party_id ?? null,
      isGstFormal: input.is_gst_formal,
      partyStateCode: input.party_state_code ?? null,
      documentDate: input.document_date
        ? new Date(input.document_date)
        : undefined,
      convertedFromId: input.converted_from_id ?? null,
      posSessionId: input.pos_session_id ?? null,
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
    input: UpdateSalesDocumentBody,
  ): Promise<SalesDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertDraftDocument(businessId, documentId);

    if (input.party_id) {
      await this.assertPartyValid(businessId, input.party_id);
    }

    const updated = await this.repository.update(businessId, documentId, {
      partyId: input.party_id,
      isGstFormal: input.is_gst_formal,
      partyStateCode: input.party_state_code,
      documentDate: input.document_date
        ? new Date(input.document_date)
        : undefined,
      documentSeries: input.document_series,
      notes: input.notes,
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
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
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }
  }

  async listLines(
    businessId: string,
    accountId: string,
    documentId: string,
  ): Promise<SalesDocumentLineRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);

    const document = await this.repository.findById(businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }

    const lines = await this.repository.listLines(businessId, documentId);
    return lines.map((line) => ({
      id: line.id,
      item_id: line.itemId,
      quantity: line.quantity,
      unit: line.unit,
      unit_price: line.unitPrice,
      market_price: line.marketPrice,
      discount_amount: line.discountAmount,
      tax_type: line.taxType as SalesDocumentLineRecord['tax_type'],
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
    input: CreateSalesLineBody,
  ): Promise<SalesDocumentLineRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const document = await this.assertDraftDocument(businessId, documentId);

    await this.assertItemValid(businessId, input.item_id);

    const tax = await this.computeLineTax(businessId, document, input);

    const line = await this.repository.createLine({
      businessId,
      salesDocumentId: documentId,
      itemId: input.item_id,
      quantity: input.quantity,
      unit: input.unit,
      unitPrice: input.unit_price,
      marketPrice: input.market_price ?? null,
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

    await this.recalculateDocumentTotals(businessId, documentId);
    return line;
  }

  async updateLine(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    lineId: string,
    input: UpdateSalesLineBody,
  ): Promise<SalesDocumentLineRecord> {
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
      sort_order: input.sort_order,
    };

    const tax = await this.computeLineTax(businessId, document, merged);

    const updated = await this.repository.updateLine(businessId, lineId, {
      itemId: merged.item_id,
      quantity: merged.quantity,
      unit: merged.unit,
      unitPrice: merged.unit_price,
      marketPrice: input.market_price,
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

    await this.recalculateDocumentTotals(businessId, documentId);
    return updated;
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

    const deleted = await this.repository.softDeleteLine(
      businessId,
      documentId,
      lineId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Line not found', 404);
    }

    await this.recalculateDocumentTotals(businessId, documentId);
  }

  async finalizeDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    input: FinalizeSalesDocumentBody,
  ): Promise<FinalizeSalesDocumentResponse> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await finalizeSalesDocument(this.db, this.repository, {
      businessId,
      documentId,
      userId,
      godownId: input.godown_id,
    });

    return {
      success: true,
      message: 'Document finalized',
      document_number: result.documentNumber,
      status: 'finalized',
    };
  }

  async cancelDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
  ): Promise<SalesDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const document = await this.repository.findRowById(businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
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
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }

    return cancelled;
  }

  async convertDocument(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    input: ConvertSalesDocumentBody,
  ): Promise<SalesDocumentRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const source = await this.repository.findById(
      businessId,
      documentId,
      true,
    );
    if (!source) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }

    if (source.status !== 'finalized' && source.status !== 'draft') {
      throw new AppError(
        'INVALID_CONVERSION',
        'Source document cannot be converted',
        422,
      );
    }

    const isGstFormal =
      input.apply_gst ||
      input.target_type === 'tax_invoice' ||
      input.target_type === 'bill_of_supply';

    const newDoc = await this.repository.create({
      businessId,
      documentType: input.target_type,
      documentSeries: source.document_series,
      partyId: source.party_id,
      isGstFormal,
      partyStateCode: source.party_state_code,
      documentDate: new Date(),
      convertedFromId: documentId,
      notes: source.notes,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });

    if (source.lines) {
      for (const line of source.lines) {
        await this.repository.createLine({
          businessId,
          salesDocumentId: newDoc.id,
          itemId: line.item_id,
          quantity: line.quantity,
          unit: line.unit,
          unitPrice: line.unit_price,
          marketPrice: line.market_price,
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

      await this.recalculateDocumentTotals(businessId, newDoc.id);
    }

    if (source.status === 'finalized') {
      await this.repository.markConverted(
        businessId,
        documentId,
        userId ?? null,
      );
    }

    return this.getDocument(businessId, accountId, newDoc.id);
  }

  async brandSwap(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    documentId: string,
    input: BrandSwapBody,
  ): Promise<{ swapped_lines: number }> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertDraftDocument(businessId, documentId);

    const swapped = await this.repository.swapLineItemBrands(
      businessId,
      documentId,
      input.brand_id,
      userId ?? null,
    );

    return { swapped_lines: swapped };
  }

  async listPosSessions(
    businessId: string,
    accountId: string,
    query: ListPosSessionsQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.listPosSessions(
      businessId,
      query.page,
      query.limit,
      query.sort,
      query.order,
    );

    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async createPosSession(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreatePosSessionBody,
  ): Promise<PosSessionRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    if (!userId) {
      throw new AppError('UNAUTHORIZED', 'User ID required', 401);
    }

    return this.repository.createPosSession(
      businessId,
      userId,
      input.opening_cash ?? null,
    );
  }

  async getPosSession(
    businessId: string,
    accountId: string,
    sessionId: string,
  ): Promise<PosSessionRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const session = await this.repository.findPosSession(businessId, sessionId);
    if (!session) {
      throw new AppError('NOT_FOUND', 'POS session not found', 404);
    }

    return session;
  }

  async updatePosSession(
    businessId: string,
    accountId: string,
    sessionId: string,
    input: UpdatePosSessionBody,
  ): Promise<PosSessionRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const updated = await this.repository.closePosSession(
      businessId,
      sessionId,
      input.ended_at ? new Date(input.ended_at) : new Date(),
      input.closing_cash ?? null,
    );

    if (!updated) {
      throw new AppError('NOT_FOUND', 'POS session not found', 404);
    }

    return updated;
  }

  async listPosSessionDocuments(
    businessId: string,
    accountId: string,
    sessionId: string,
    query: ListSalesDocumentsQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const session = await this.repository.findPosSession(businessId, sessionId);
    if (!session) {
      throw new AppError('NOT_FOUND', 'POS session not found', 404);
    }

    return this.listDocuments(businessId, accountId, {
      ...query,
      document_type: 'pos',
      pos_session_id: sessionId,
    });
  }

  private async assertDraftDocument(
    businessId: string,
    documentId: string,
  ): Promise<SalesDocumentRecord> {
    const document = await this.repository.findById(businessId, documentId);
    if (!document) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
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

  private async assertPartyValid(
    businessId: string,
    partyId: string,
  ): Promise<void> {
    const party = await this.repository.findParty(businessId, partyId);
    if (!party) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
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
    document: SalesDocumentRecord,
    input: {
      quantity: string;
      unit_price: string;
      discount_amount?: string;
      tax_type?: string;
      tax_rate?: string;
    },
  ) {
    const businessState = await this.repository.getBusinessStateCode(businessId);
    const taxType = resolveTaxType(
      document.is_gst_formal,
      businessState,
      document.party_state_code,
    );

    const effectiveTaxType =
      input.tax_type && input.tax_type !== 'none'
        ? (input.tax_type as SalesDocumentLineRecord['tax_type'])
        : taxType;

    const tax = calculateLineTax({
      quantity: input.quantity,
      unitPrice: input.unit_price,
      discountAmount: input.discount_amount ?? '0',
      taxType: effectiveTaxType,
      taxRate: input.tax_rate ?? '0',
    });

    return {
      taxType: effectiveTaxType,
      ...tax,
    };
  }

  private async recalculateDocumentTotals(
    businessId: string,
    documentId: string,
  ): Promise<void> {
    const lines = await this.repository.listLines(businessId, documentId);
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

    await this.repository.updateTotals(businessId, documentId, totals);
  }
}
