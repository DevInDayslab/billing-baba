import { and, eq, gte, inArray, lt, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { businesses } from '../../../db/schema/business/tables';
import { parties } from '../../../db/schema/crm/tables';
import { items } from '../../../db/schema/inventory/tables';
import {
  purchaseDocumentLines,
  purchaseDocuments,
} from '../../../db/schema/purchases/tables';
import {
  salesDocumentLines,
  salesDocuments,
} from '../../../db/schema/sales/tables';
import type { ResolvedReportPeriod } from '../../../shared/reporting/report-period';
import {
  GST_CREDIT_NOTE_TYPE,
  GST_DEBIT_NOTE_TYPE,
  GST_INCLUDED_PURCHASE_TYPES,
  GST_INCLUDED_SALE_TYPES,
  GST_PURCHASE_BILL_TYPE,
} from '../core/constants';
import type {
  GstDataset,
  GstItemContext,
  GstLineModel,
  GstPartyContext,
  GstPurchaseDocumentModel,
  GstSalesDocumentModel,
} from '../core/models';

function mapParty(row: {
  id: string | null;
  name: string | null;
  gstin: string | null;
  stateCode: string | null;
}): GstPartyContext {
  return {
    id: row.id,
    name: row.name,
    gstin: row.gstin,
    stateCode: row.stateCode,
  };
}

function mapItem(row: {
  id: string;
  name: string;
  itemType: string;
  hsnCode: string | null;
}): GstItemContext {
  return {
    id: row.id,
    name: row.name,
    itemType: row.itemType === 'service' ? 'service' : 'product',
    hsnCode: row.hsnCode,
  };
}

function mapLine(
  row: {
    id: string;
    itemId: string;
    quantity: string;
    unit: string;
    unitPrice: string;
    discountAmount: string;
    taxType: string;
    taxRate: string;
    cgstAmount: string;
    sgstAmount: string;
    igstAmount: string;
    cessRate: string;
    cessAmount: string;
    lineTotal: string;
  },
  item: GstItemContext,
): GstLineModel {
  return {
    id: row.id,
    itemId: row.itemId,
    quantity: row.quantity,
    unit: row.unit,
    unitPrice: row.unitPrice,
    discountAmount: row.discountAmount,
    taxType: row.taxType,
    taxRate: row.taxRate,
    cgstAmount: row.cgstAmount,
    sgstAmount: row.sgstAmount,
    igstAmount: row.igstAmount,
    cessRate: row.cessRate ?? '0',
    cessAmount: row.cessAmount ?? '0',
    lineTotal: row.lineTotal,
    item,
  };
}

export class GstDataRepository {
  constructor(private readonly db: Database) {}

  async loadDataset(
    businessId: string,
    range: ResolvedReportPeriod,
  ): Promise<GstDataset> {
    const [business] = await this.db
      .select({
        id: businesses.id,
        gstin: businesses.gstin,
        stateCode: businesses.stateCode,
      })
      .from(businesses)
      .where(eq(businesses.id, businessId))
      .limit(1);

    if (!business) {
      throw new Error('Business not found');
    }

    const saleHeaders = await this.db
      .select({
        id: salesDocuments.id,
        documentType: salesDocuments.documentType,
        status: salesDocuments.status,
        documentNumber: salesDocuments.documentNumber,
        documentSeries: salesDocuments.documentSeries,
        documentDate: salesDocuments.documentDate,
        partyId: salesDocuments.partyId,
        partyStateCode: salesDocuments.partyStateCode,
        supplyType: salesDocuments.supplyType,
        subtotal: salesDocuments.subtotal,
        totalAmount: salesDocuments.totalAmount,
        isGstFormal: salesDocuments.isGstFormal,
        originalDocumentId: salesDocuments.originalDocumentId,
        originalDocumentNumber: salesDocuments.originalDocumentNumber,
        originalDocumentDate: salesDocuments.originalDocumentDate,
        convertedFromId: salesDocuments.convertedFromId,
        partyName: parties.name,
        partyGstin: parties.gstin,
        partyState: parties.stateCode,
      })
      .from(salesDocuments)
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...GST_INCLUDED_SALE_TYPES]),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      );

    const purchaseHeaders = await this.db
      .select({
        id: purchaseDocuments.id,
        documentType: purchaseDocuments.documentType,
        status: purchaseDocuments.status,
        documentNumber: purchaseDocuments.documentNumber,
        documentSeries: purchaseDocuments.documentSeries,
        documentDate: purchaseDocuments.documentDate,
        partyId: purchaseDocuments.partyId,
        partyStateCode: purchaseDocuments.partyStateCode,
        totalAmount: purchaseDocuments.totalAmount,
        isGstFormal: purchaseDocuments.isGstFormal,
        originalDocumentId: purchaseDocuments.originalDocumentId,
        originalDocumentNumber: purchaseDocuments.originalDocumentNumber,
        originalDocumentDate: purchaseDocuments.originalDocumentDate,
        partyName: parties.name,
        partyGstin: parties.gstin,
        partyState: parties.stateCode,
      })
      .from(purchaseDocuments)
      .innerJoin(parties, eq(purchaseDocuments.partyId, parties.id))
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          inArray(purchaseDocuments.documentType, [
            ...GST_INCLUDED_PURCHASE_TYPES,
          ]),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
        ),
      );

    const cancelledStats = await this.db
      .select({
        documentSeries: salesDocuments.documentSeries,
        count: sql<number>`count(*)::int`,
      })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'cancelled'),
          inArray(salesDocuments.documentType, [...GST_INCLUDED_SALE_TYPES]),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .groupBy(salesDocuments.documentSeries);

    const saleIds = saleHeaders.map((h) => h.id);
    const purchaseIds = purchaseHeaders.map((h) => h.id);

    const saleLines =
      saleIds.length === 0
        ? []
        : await this.db
            .select({
              id: salesDocumentLines.id,
              salesDocumentId: salesDocumentLines.salesDocumentId,
              itemId: salesDocumentLines.itemId,
              quantity: salesDocumentLines.quantity,
              unit: salesDocumentLines.unit,
              unitPrice: salesDocumentLines.unitPrice,
              discountAmount: salesDocumentLines.discountAmount,
              taxType: salesDocumentLines.taxType,
              taxRate: salesDocumentLines.taxRate,
              cgstAmount: salesDocumentLines.cgstAmount,
              sgstAmount: salesDocumentLines.sgstAmount,
              igstAmount: salesDocumentLines.igstAmount,
              cessRate: salesDocumentLines.cessRate,
              cessAmount: salesDocumentLines.cessAmount,
              lineTotal: salesDocumentLines.lineTotal,
              itemName: items.name,
              itemType: items.itemType,
              hsnCode: items.hsnCode,
            })
            .from(salesDocumentLines)
            .innerJoin(items, eq(salesDocumentLines.itemId, items.id))
            .where(
              and(
                eq(salesDocumentLines.businessId, businessId),
                eq(salesDocumentLines.isDeleted, false),
                inArray(salesDocumentLines.salesDocumentId, saleIds),
              ),
            );

    const purchaseLines =
      purchaseIds.length === 0
        ? []
        : await this.db
            .select({
              id: purchaseDocumentLines.id,
              purchaseDocumentId: purchaseDocumentLines.purchaseDocumentId,
              itemId: purchaseDocumentLines.itemId,
              quantity: purchaseDocumentLines.quantity,
              unit: purchaseDocumentLines.unit,
              unitPrice: purchaseDocumentLines.unitPrice,
              discountAmount: purchaseDocumentLines.discountAmount,
              taxType: purchaseDocumentLines.taxType,
              taxRate: purchaseDocumentLines.taxRate,
              cgstAmount: purchaseDocumentLines.cgstAmount,
              sgstAmount: purchaseDocumentLines.sgstAmount,
              igstAmount: purchaseDocumentLines.igstAmount,
              cessRate: purchaseDocumentLines.cessRate,
              cessAmount: purchaseDocumentLines.cessAmount,
              lineTotal: purchaseDocumentLines.lineTotal,
              itemName: items.name,
              itemType: items.itemType,
              hsnCode: items.hsnCode,
            })
            .from(purchaseDocumentLines)
            .innerJoin(items, eq(purchaseDocumentLines.itemId, items.id))
            .where(
              and(
                eq(purchaseDocumentLines.businessId, businessId),
                eq(purchaseDocumentLines.isDeleted, false),
                inArray(purchaseDocumentLines.purchaseDocumentId, purchaseIds),
              ),
            );

    const saleLinesByDoc = new Map<string, GstLineModel[]>();
    for (const row of saleLines) {
      const item = mapItem({
        id: row.itemId,
        name: row.itemName,
        itemType: row.itemType,
        hsnCode: row.hsnCode,
      });
      const line = mapLine(row, item);
      const list = saleLinesByDoc.get(row.salesDocumentId) ?? [];
      list.push(line);
      saleLinesByDoc.set(row.salesDocumentId, list);
    }

    const purchaseLinesByDoc = new Map<string, GstLineModel[]>();
    for (const row of purchaseLines) {
      const item = mapItem({
        id: row.itemId,
        name: row.itemName,
        itemType: row.itemType,
        hsnCode: row.hsnCode,
      });
      const line = mapLine(row, item);
      const list = purchaseLinesByDoc.get(row.purchaseDocumentId) ?? [];
      list.push(line);
      purchaseLinesByDoc.set(row.purchaseDocumentId, list);
    }

    const sales: GstSalesDocumentModel[] = saleHeaders.map((h) => ({
      id: h.id,
      documentType: h.documentType,
      status: h.status,
      documentNumber: h.documentNumber,
      documentSeries: h.documentSeries,
      documentDate: h.documentDate,
      party: mapParty({
        id: h.partyId,
        name: h.partyName,
        gstin: h.partyGstin,
        stateCode: h.partyState,
      }),
      partyStateCode: h.partyStateCode,
      supplyType: h.supplyType ?? 'domestic',
      subtotal: h.subtotal,
      totalAmount: h.totalAmount,
      isGstFormal: h.isGstFormal,
      originalDocumentId: h.originalDocumentId,
      originalDocumentNumber: h.originalDocumentNumber,
      originalDocumentDate: h.originalDocumentDate,
      convertedFromId: h.convertedFromId,
      lines: saleLinesByDoc.get(h.id) ?? [],
      isCreditNote: h.documentType === GST_CREDIT_NOTE_TYPE,
    }));

    const purchases: GstPurchaseDocumentModel[] = purchaseHeaders.map((h) => ({
      id: h.id,
      documentType: h.documentType,
      status: h.status,
      documentNumber: h.documentNumber,
      documentSeries: h.documentSeries,
      documentDate: h.documentDate,
      party: mapParty({
        id: h.partyId,
        name: h.partyName,
        gstin: h.partyGstin,
        stateCode: h.partyState,
      }),
      partyStateCode: h.partyStateCode,
      totalAmount: h.totalAmount,
      isGstFormal: h.isGstFormal,
      originalDocumentId: h.originalDocumentId,
      originalDocumentNumber: h.originalDocumentNumber,
      originalDocumentDate: h.originalDocumentDate,
      lines: purchaseLinesByDoc.get(h.id) ?? [],
      isDebitNote: h.documentType === GST_DEBIT_NOTE_TYPE,
    }));

    return {
      business: {
        id: business.id,
        gstin: business.gstin,
        stateCode: business.stateCode,
      },
      sales,
      purchases,
      cancelledBySeries: cancelledStats.map((row) => ({
        documentSeries: row.documentSeries,
        count: row.count,
      })),
    };
  }
}
