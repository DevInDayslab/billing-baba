import { and, eq, gte, inArray, isNull, lte, sql } from 'drizzle-orm';
import { parseMoney } from '../inventory/inventory.utils';
import type { Database } from '../../db/client';
import { withholdingTaxEntries } from '../../db/schema/withholding/tables';

export type WithholdingEntryFilter = {
  businessId: string;
  from: Date;
  to: Date;
  kind: 'tds' | 'tcs';
  direction: 'payable' | 'receivable';
};

export class WithholdingTaxEntryRepository {
  constructor(private readonly db: Database) {}

  async upsertForSource(
    values: typeof withholdingTaxEntries.$inferInsert,
  ): Promise<void> {
    await this.db
      .delete(withholdingTaxEntries)
      .where(
        and(
          eq(withholdingTaxEntries.businessId, values.businessId),
          eq(withholdingTaxEntries.sourceType, values.sourceType),
          eq(withholdingTaxEntries.sourceId, values.sourceId),
          eq(withholdingTaxEntries.kind, values.kind),
        ),
      );

    if (parseMoney(values.taxAmount) <= 0) {
      return;
    }

    await this.db.insert(withholdingTaxEntries).values(values);
  }

  async listInPeriod(filter: WithholdingEntryFilter) {
    return this.db
      .select()
      .from(withholdingTaxEntries)
      .where(
        and(
          eq(withholdingTaxEntries.businessId, filter.businessId),
          eq(withholdingTaxEntries.isDeleted, false),
          eq(withholdingTaxEntries.kind, filter.kind),
          eq(withholdingTaxEntries.direction, filter.direction),
          gte(withholdingTaxEntries.entryDate, filter.from),
          lte(withholdingTaxEntries.entryDate, filter.to),
        ),
      )
      .orderBy(withholdingTaxEntries.entryDate);
  }

  async listTcsCollections(businessId: string, from: Date, to: Date) {
    return this.db
      .select()
      .from(withholdingTaxEntries)
      .where(
        and(
          eq(withholdingTaxEntries.businessId, businessId),
          eq(withholdingTaxEntries.isDeleted, false),
          eq(withholdingTaxEntries.kind, 'tcs'),
          eq(withholdingTaxEntries.direction, 'receivable'),
          gte(withholdingTaxEntries.entryDate, from),
          lte(withholdingTaxEntries.entryDate, to),
        ),
      )
      .orderBy(withholdingTaxEntries.entryDate);
  }

  async sumPendingByParty(
    filter: WithholdingEntryFilter,
  ): Promise<
    {
      partyId: string | null;
      partyName: string | null;
      partyPan: string | null;
      entryCount: number;
      baseAmount: string;
      taxAmount: string;
      pending: string;
    }[]
  > {
    const rows = await this.db
      .select({
        partyId: withholdingTaxEntries.partyId,
        partyName: withholdingTaxEntries.partyName,
        partyPan: withholdingTaxEntries.partyPan,
        entryCount: sql<number>`count(*)::int`,
        baseAmount: sql<string>`COALESCE(SUM(${withholdingTaxEntries.baseAmount}::numeric), 0)::text`,
        taxAmount: sql<string>`COALESCE(SUM(${withholdingTaxEntries.taxAmount}::numeric), 0)::text`,
        pending: sql<string>`COALESCE(SUM(CASE WHEN ${withholdingTaxEntries.depositId} IS NULL THEN ${withholdingTaxEntries.taxAmount}::numeric ELSE 0 END), 0)::text`,
      })
      .from(withholdingTaxEntries)
      .where(
        and(
          eq(withholdingTaxEntries.businessId, filter.businessId),
          eq(withholdingTaxEntries.isDeleted, false),
          eq(withholdingTaxEntries.kind, filter.kind),
          eq(withholdingTaxEntries.direction, filter.direction),
          gte(withholdingTaxEntries.entryDate, filter.from),
          lte(withholdingTaxEntries.entryDate, filter.to),
        ),
      )
      .groupBy(
        withholdingTaxEntries.partyId,
        withholdingTaxEntries.partyName,
        withholdingTaxEntries.partyPan,
      );

    return rows;
  }

  async markDeposited(
    businessId: string,
    entryIds: string[],
    depositId: string,
  ): Promise<void> {
    if (entryIds.length === 0) return;
    await this.db
      .update(withholdingTaxEntries)
      .set({ depositId, updatedAt: new Date() })
      .where(
        and(
          eq(withholdingTaxEntries.businessId, businessId),
          isNull(withholdingTaxEntries.depositId),
          inArray(withholdingTaxEntries.id, entryIds),
        ),
      );
  }
}
