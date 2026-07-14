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
  UpdateDocumentSequenceBody,
} from './sales-document.schema';
import { assertValidConversion } from './sales-convert.rules';
import {
  currentFiscalYear,
  ensureDocumentSequence,
} from './sales-numbering.service';
import type {
  FinalizeSalesDocumentResponse,
  PosSessionRecord,
  SalesDocumentLineRecord,
  SalesDocumentRecord,
  SalesDocumentType,
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

    const summary = await this.repository.aggregateListSummary({
      businessId,
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
      summary: {
        total_amount: summary.total_amount ?? '0',
        received_amount: summary.received_amount ?? '0',
        balance_amount: summary.balance_amount ?? '0',
      },
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

    if (input.pos_session_id) {
      await this.assertPosSessionValid(businessId, input.pos_session_id);
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

    return this.db.transaction(async (tx) => {
      const repo = new SalesDocumentRepository(tx as unknown as typeof this.db);
      const line = await repo.createLine({
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

    return this.db.transaction(async (tx) => {
      const repo = new SalesDocumentRepository(tx as unknown as typeof this.db);
      const updated = await repo.updateLine(businessId, lineId, {
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
      const repo = new SalesDocumentRepository(tx as unknown as typeof this.db);
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
    input: FinalizeSalesDocumentBody,
  ): Promise<FinalizeSalesDocumentResponse> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await finalizeSalesDocument(this.db, this.repository, {
      businessId,
      documentId,
      userId,
      godownId: input.godown_id,
      loyaltyPointsRedeemed: input.loyalty_points_redeemed ?? '0',
    });

    return {
      success: true,
      message: 'Document finalized',
      document_number: result.documentNumber,
      status: 'finalized',
      ...(result.loyalty ? { loyalty: result.loyalty } : {}),
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
      source.document_type as SalesDocumentType,
      input.target_type,
    );

    if (source.party_id) {
      await this.assertPartyValid(businessId, source.party_id);
    }

    if (source.lines) {
      for (const line of source.lines) {
        await this.assertItemValid(businessId, line.item_id);
      }
    }

    const isGstFormal =
      input.apply_gst ||
      input.target_type === 'tax_invoice' ||
      input.target_type === 'bill_of_supply';

    const shouldRecalculateGst =
      input.apply_gst ||
      input.target_type === 'tax_invoice' ||
      input.target_type === 'bill_of_supply';

    const newDocId = await this.db.transaction(async (tx) => {
      const repo = new SalesDocumentRepository(tx as unknown as typeof this.db);

      const newDoc = await repo.create({
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

      const newDocumentRecord: SalesDocumentRecord = {
        ...newDoc,
        is_gst_formal: isGstFormal,
      };

      if (source.lines) {
        for (const line of source.lines) {
          let taxType = line.tax_type;
          let taxRate = line.tax_rate;
          let cgstAmount = line.cgst_amount;
          let sgstAmount = line.sgst_amount;
          let igstAmount = line.igst_amount;
          let lineTotal = line.line_total;

          if (shouldRecalculateGst) {
            const tax = await this.computeLineTax(businessId, newDocumentRecord, {
              quantity: line.quantity,
              unit_price: line.unit_price,
              discount_amount: line.discount_amount,
              tax_rate: line.tax_rate,
            });
            taxType = tax.taxType;
            taxRate = line.tax_rate;
            cgstAmount = tax.cgstAmount;
            sgstAmount = tax.sgstAmount;
            igstAmount = tax.igstAmount;
            lineTotal = tax.lineTotal;
          }

          await repo.createLine({
            businessId,
            salesDocumentId: newDoc.id,
            itemId: line.item_id,
            quantity: line.quantity,
            unit: line.unit,
            unitPrice: line.unit_price,
            marketPrice: line.market_price,
            discountAmount: line.discount_amount,
            taxType,
            taxRate,
            cgstAmount,
            sgstAmount,
            igstAmount,
            lineTotal,
            sortOrder: line.sort_order,
            createdBy: userId ?? null,
            updatedBy: userId ?? null,
          });
        }

        await this.recalculateDocumentTotals(businessId, newDoc.id, repo);
      }

      if (source.status === 'finalized') {
        await repo.markConverted(businessId, documentId, userId ?? null);
      }

      return newDoc.id;
    });

    return this.getDocument(businessId, accountId, newDocId);
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

  async listDocumentSequences(businessId: string, accountId: string) {
    await this.assertBusinessAccess(businessId, accountId);

    const fiscalYear = currentFiscalYear();
    const data = await this.repository.listDocumentSequences(
      businessId,
      fiscalYear,
    );

    return { data };
  }

  async updateDocumentSequence(
    businessId: string,
    accountId: string,
    sequenceId: string,
    input: UpdateDocumentSequenceBody,
  ) {
    await this.assertBusinessAccess(businessId, accountId);

    const updated = await this.repository.updateDocumentSequence(
      businessId,
      sequenceId,
      {
        prefix: input.prefix,
        nextNumber: input.next_number,
      },
    );

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Document sequence not found', 404);
    }

    return updated;
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

  private async assertGodownValid(
    businessId: string,
    godownId: string,
  ): Promise<void> {
    const exists = await this.repository.godownExists(businessId, godownId);
    if (!exists) {
      throw new AppError('NOT_FOUND', 'Godown not found', 404);
    }
  }

  private async assertPosSessionValid(
    businessId: string,
    sessionId: string,
  ): Promise<void> {
    const exists = await this.repository.openPosSessionExists(
      businessId,
      sessionId,
    );
    if (!exists) {
      throw new AppError(
        'VALIDATION_ERROR',
        'POS session not found or already closed',
        422,
      );
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
    repository: SalesDocumentRepository = this.repository,
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
