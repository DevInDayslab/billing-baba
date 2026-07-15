import { and, desc, eq, gte, ilike, lt, or } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { parties } from '../../../db/schema/crm/tables';
import { items } from '../../../db/schema/inventory/tables';
import { purchaseDocuments } from '../../../db/schema/purchases/tables';
import {
  salesDocumentLines,
  salesDocuments,
} from '../../../db/schema/sales/tables';
import type { ReportExtendedQuery } from '../reports.schema';
import type {
  PaginatedRowsPayload,
  ReportOrderItemRow,
  ReportOrderRow,
} from '../reports.types';
import { paginateSlice, resolveRange, toPeriodMeta } from './reports.helpers';

export class OrderReportsRepository {
  constructor(private readonly db: Database) {}

  async getSalePurchaseOrders(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: PaginatedRowsPayload<ReportOrderRow>; total: number }> {
    const range = resolveRange(query);

    const saleFilters = [
      eq(salesDocuments.businessId, businessId),
      eq(salesDocuments.isDeleted, false),
      eq(salesDocuments.documentType, 'sale_order'),
      gte(salesDocuments.documentDate, range.from),
      lt(salesDocuments.documentDate, range.to),
    ];
    if (query.status) {
      saleFilters.push(eq(salesDocuments.status, query.status as never));
    }
    if (query.party_id) {
      saleFilters.push(eq(salesDocuments.partyId, query.party_id));
    }

    const purchaseFilters = [
      eq(purchaseDocuments.businessId, businessId),
      eq(purchaseDocuments.isDeleted, false),
      eq(purchaseDocuments.documentType, 'purchase_order'),
      gte(purchaseDocuments.documentDate, range.from),
      lt(purchaseDocuments.documentDate, range.to),
    ];
    if (query.status) {
      purchaseFilters.push(eq(purchaseDocuments.status, query.status as never));
    }
    if (query.party_id) {
      purchaseFilters.push(eq(purchaseDocuments.partyId, query.party_id));
    }

    const [saleRows, purchaseRows] = await Promise.all([
      this.db
        .select({
          date: salesDocuments.documentDate,
          orderNo: salesDocuments.documentNumber,
          partyName: parties.name,
          status: salesDocuments.status,
          amount: salesDocuments.totalAmount,
        })
        .from(salesDocuments)
        .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
        .where(and(...saleFilters)),
      this.db
        .select({
          date: purchaseDocuments.documentDate,
          orderNo: purchaseDocuments.documentNumber,
          partyName: parties.name,
          dueDate: purchaseDocuments.dueDate,
          status: purchaseDocuments.status,
          amount: purchaseDocuments.totalAmount,
        })
        .from(purchaseDocuments)
        .innerJoin(parties, eq(purchaseDocuments.partyId, parties.id))
        .where(and(...purchaseFilters)),
    ]);

    const mapped: ReportOrderRow[] = [
      ...saleRows.map((row) => ({
        date: row.date.toISOString(),
        order_no: row.orderNo ?? '',
        party_name: row.partyName ?? '',
        due_date: row.date.toISOString(),
        status: row.status,
        type: 'sale',
        amount: row.amount ?? '0',
      })),
      ...purchaseRows.map((row) => ({
        date: row.date.toISOString(),
        order_no: row.orderNo ?? '',
        party_name: row.partyName ?? '',
        due_date: row.dueDate
          ? new Date(row.dueDate).toISOString()
          : row.date.toISOString(),
        status: row.status,
        type: 'purchase',
        amount: row.amount ?? '0',
      })),
    ].sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getSalePurchaseOrderItems(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportOrderItemRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const saleRows = await this.db
      .select({
        itemName: items.name,
        orderNo: salesDocuments.documentNumber,
        partyName: parties.name,
        quantity: salesDocumentLines.quantity,
        amount: salesDocumentLines.lineTotal,
      })
      .from(salesDocumentLines)
      .innerJoin(
        salesDocuments,
        eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
      )
      .innerJoin(items, eq(salesDocumentLines.itemId, items.id))
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.documentType, 'sale_order'),
          eq(salesDocumentLines.isDeleted, false),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .orderBy(desc(salesDocuments.documentDate));

    const mapped = saleRows.map((row) => ({
      item_name: row.itemName ?? '',
      order_no: row.orderNo ?? '',
      party_name: row.partyName ?? '',
      quantity: row.quantity ?? '0',
      amount: row.amount ?? '0',
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }
}
