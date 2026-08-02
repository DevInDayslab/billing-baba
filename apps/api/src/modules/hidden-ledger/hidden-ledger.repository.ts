import {
  and,
  asc,
  count,
  desc,
  eq,
  gte,
  ilike,
  inArray,
  lte,
  or,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  hiddenLedgerEntries,
  hiddenLedgerRecoveryRecords,
  parties,
  users,
} from '../../db/schema';
import { salesDocuments } from '../../db/schema/sales/tables';
import { normalizeMoney, parseMoney } from '../inventory/inventory.utils';
import type {
  CreateHiddenLedgerEntryValues,
  CreateHiddenLedgerRecoveryValues,
  HiddenLedgerEntryRecord,
  HiddenLedgerEntryStatus,
  HiddenLedgerPartySummary,
  HiddenLedgerRecoveryRecord,
} from './hidden-ledger.types';

type HiddenLedgerEntryRow = typeof hiddenLedgerEntries.$inferSelect;
type HiddenLedgerRecoveryRow = typeof hiddenLedgerRecoveryRecords.$inferSelect;

function resolveEntryStatus(
  amount: string,
  recoveredAmount: string,
): HiddenLedgerEntryStatus {
  const total = parseMoney(amount);
  const recovered = parseMoney(recoveredAmount);
  if (recovered <= 0) return 'pending';
  if (recovered >= total) return 'recovered';
  return 'partial';
}

function toEntryRecord(
  row: HiddenLedgerEntryRow,
  extras?: { partyName?: string; invoiceNumber?: string | null },
): HiddenLedgerEntryRecord {
  return {
    id: row.id,
    party_id: row.partyId,
    party_name: extras?.partyName,
    sale_id: row.saleId,
    invoice_id: row.invoiceId,
    invoice_number: extras?.invoiceNumber ?? null,
    amount: row.amount,
    recovered_amount: row.recoveredAmount,
    remaining_amount: row.remainingAmount,
    status: row.status,
    created_by: row.createdBy,
    created_at: row.createdAt.toISOString(),
  };
}

function toRecoveryRecord(
  row: HiddenLedgerRecoveryRow,
): HiddenLedgerRecoveryRecord {
  return {
    id: row.id,
    ledger_entry_id: row.ledgerEntryId,
    sale_id: row.saleId,
    recovered_amount: row.recoveredAmount,
    recovered_by: row.recoveredBy,
    created_at: row.createdAt.toISOString(),
  };
}

export class HiddenLedgerRepository {
  constructor(private readonly db: Database) {}

  async createEntry(
    values: CreateHiddenLedgerEntryValues,
  ): Promise<HiddenLedgerEntryRecord> {
    const [row] = await this.db
      .insert(hiddenLedgerEntries)
      .values({
        businessId: values.businessId,
        partyId: values.partyId,
        saleId: values.saleId ?? null,
        invoiceId: values.invoiceId ?? null,
        amount: values.amount,
        recoveredAmount: '0',
        remainingAmount: values.amount,
        status: 'pending',
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create hidden ledger entry');
    }

    return toEntryRecord(row);
  }

  async findEntryById(
    businessId: string,
    entryId: string,
  ): Promise<HiddenLedgerEntryRecord | null> {
    const [row] = await this.db
      .select({
        entry: hiddenLedgerEntries,
        partyName: parties.name,
        invoiceNumber: salesDocuments.documentNumber,
      })
      .from(hiddenLedgerEntries)
      .innerJoin(parties, eq(hiddenLedgerEntries.partyId, parties.id))
      .leftJoin(
        salesDocuments,
        eq(hiddenLedgerEntries.invoiceId, salesDocuments.id),
      )
      .where(
        and(
          eq(hiddenLedgerEntries.id, entryId),
          eq(hiddenLedgerEntries.businessId, businessId),
          eq(hiddenLedgerEntries.isDeleted, false),
        ),
      )
      .limit(1);

    return row
      ? toEntryRecord(row.entry, {
          partyName: row.partyName,
          invoiceNumber: row.invoiceNumber,
        })
      : null;
  }

  async listEntries(params: {
    businessId: string;
    page: number;
    limit: number;
    partyId?: string;
    status?: HiddenLedgerEntryStatus;
    from?: Date;
    to?: Date;
    q?: string;
    invoiceNumber?: string;
    sort: 'created_at' | 'amount';
    order: 'asc' | 'desc';
  }): Promise<{ rows: HiddenLedgerEntryRecord[]; total: number }> {
    const filters = [
      eq(hiddenLedgerEntries.businessId, params.businessId),
      eq(hiddenLedgerEntries.isDeleted, false),
    ];

    if (params.partyId) {
      filters.push(eq(hiddenLedgerEntries.partyId, params.partyId));
    }
    if (params.status) {
      filters.push(eq(hiddenLedgerEntries.status, params.status));
    }
    if (params.from) {
      filters.push(gte(hiddenLedgerEntries.createdAt, params.from));
    }
    if (params.to) {
      filters.push(lte(hiddenLedgerEntries.createdAt, params.to));
    }
    if (params.invoiceNumber) {
      filters.push(
        ilike(salesDocuments.documentNumber, `%${params.invoiceNumber}%`),
      );
    }
    if (params.q) {
      const pattern = `%${params.q}%`;
      filters.push(
        or(
          ilike(parties.name, pattern),
          ilike(salesDocuments.documentNumber, pattern),
        )!,
      );
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(hiddenLedgerEntries)
      .innerJoin(parties, eq(hiddenLedgerEntries.partyId, parties.id))
      .leftJoin(
        salesDocuments,
        eq(hiddenLedgerEntries.invoiceId, salesDocuments.id),
      )
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'amount'
        ? hiddenLedgerEntries.amount
        : hiddenLedgerEntries.createdAt;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        entry: hiddenLedgerEntries,
        partyName: parties.name,
        invoiceNumber: salesDocuments.documentNumber,
      })
      .from(hiddenLedgerEntries)
      .innerJoin(parties, eq(hiddenLedgerEntries.partyId, parties.id))
      .leftJoin(
        salesDocuments,
        eq(hiddenLedgerEntries.invoiceId, salesDocuments.id),
      )
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) =>
        toEntryRecord(row.entry, {
          partyName: row.partyName,
          invoiceNumber: row.invoiceNumber,
        }),
      ),
      total,
    };
  }

  async listRecoveries(
    businessId: string,
    entryId: string,
    page: number,
    limit: number,
  ): Promise<{ rows: HiddenLedgerRecoveryRecord[]; total: number }> {
    const whereClause = and(
      eq(hiddenLedgerRecoveryRecords.businessId, businessId),
      eq(hiddenLedgerRecoveryRecords.ledgerEntryId, entryId),
      eq(hiddenLedgerRecoveryRecords.isDeleted, false),
    );

    const countResult = await this.db
      .select({ total: count() })
      .from(hiddenLedgerRecoveryRecords)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);
    const offset = (page - 1) * limit;

    const rows = await this.db
      .select()
      .from(hiddenLedgerRecoveryRecords)
      .where(whereClause)
      .orderBy(desc(hiddenLedgerRecoveryRecords.createdAt))
      .limit(limit)
      .offset(offset);

    return { rows: rows.map(toRecoveryRecord), total };
  }

  async sumRecoveriesForSale(
    businessId: string,
    saleId: string,
  ): Promise<number> {
    const [aggregate] = await this.db
      .select({
        total: sql<string>`coalesce(sum(${hiddenLedgerRecoveryRecords.recoveredAmount})::numeric, 0)::text`,
      })
      .from(hiddenLedgerRecoveryRecords)
      .where(
        and(
          eq(hiddenLedgerRecoveryRecords.businessId, businessId),
          eq(hiddenLedgerRecoveryRecords.saleId, saleId),
          eq(hiddenLedgerRecoveryRecords.isDeleted, false),
        ),
      );

    return parseMoney(aggregate?.total ?? '0');
  }

  async listRecoverableEntries(
    businessId: string,
    partyId: string,
  ): Promise<HiddenLedgerEntryRecord[]> {
    const rows = await this.db
      .select()
      .from(hiddenLedgerEntries)
      .where(
        and(
          eq(hiddenLedgerEntries.businessId, businessId),
          eq(hiddenLedgerEntries.partyId, partyId),
          eq(hiddenLedgerEntries.isDeleted, false),
          inArray(hiddenLedgerEntries.status, ['pending', 'partial']),
        ),
      )
      .orderBy(asc(hiddenLedgerEntries.createdAt));

    return rows.map((row) => toEntryRecord(row));
  }

  /** Reserved for Phase 2 recovery flows. */
  async createRecoveryRecord(
    values: CreateHiddenLedgerRecoveryValues,
  ): Promise<HiddenLedgerRecoveryRecord> {
    const [row] = await this.db
      .insert(hiddenLedgerRecoveryRecords)
      .values({
        businessId: values.businessId,
        ledgerEntryId: values.ledgerEntryId,
        saleId: values.saleId ?? null,
        recoveredAmount: values.recoveredAmount,
        recoveredBy: values.recoveredBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create hidden ledger recovery record');
    }

    return toRecoveryRecord(row);
  }

  /** Reserved for Phase 2 recovery flows. */
  async applyRecoveryToEntry(params: {
    businessId: string;
    entryId: string;
    recoveryAmount: string;
    updatedBy?: string | null;
  }): Promise<HiddenLedgerEntryRecord | null> {
    const entry = await this.findEntryById(params.businessId, params.entryId);
    if (!entry) return null;

    const nextRecovered =
      parseMoney(entry.recovered_amount) + parseMoney(params.recoveryAmount);
    const total = parseMoney(entry.amount);
    if (nextRecovered > total) {
      throw new Error('Recovery amount exceeds entry outstanding balance');
    }

    const remaining = Math.max(0, total - nextRecovered);
    const status = resolveEntryStatus(
      entry.amount,
      normalizeMoney(nextRecovered),
    );

    const [row] = await this.db
      .update(hiddenLedgerEntries)
      .set({
        recoveredAmount: normalizeMoney(nextRecovered),
        remainingAmount: normalizeMoney(remaining),
        status,
        updatedAt: new Date(),
        updatedBy: params.updatedBy ?? null,
        syncVersion: sql`${hiddenLedgerEntries.syncVersion} + 1`,
      })
      .where(
        and(
          eq(hiddenLedgerEntries.id, params.entryId),
          eq(hiddenLedgerEntries.businessId, params.businessId),
          eq(hiddenLedgerEntries.isDeleted, false),
          inArray(hiddenLedgerEntries.status, ['pending', 'partial']),
        ),
      )
      .returning();

    return row ? toEntryRecord(row) : null;
  }

  async getPartySummary(
    businessId: string,
    partyId: string,
  ): Promise<HiddenLedgerPartySummary | null> {
    const [party] = await this.db
      .select({ hiddenLedgerBalance: parties.hiddenLedgerBalance })
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    if (!party) return null;

    const [aggregate] = await this.db
      .select({
        pendingEntries: sql<number>`count(*) filter (where ${hiddenLedgerEntries.status} != 'recovered')::int`,
        totalRemaining: sql<string>`coalesce(sum(${hiddenLedgerEntries.remainingAmount})::numeric, 0)::text`,
      })
      .from(hiddenLedgerEntries)
      .where(
        and(
          eq(hiddenLedgerEntries.businessId, businessId),
          eq(hiddenLedgerEntries.partyId, partyId),
          eq(hiddenLedgerEntries.isDeleted, false),
        ),
      );

    return {
      party_id: partyId,
      hidden_ledger_balance: party.hiddenLedgerBalance,
      pending_entries: Number(aggregate?.pendingEntries ?? 0),
      total_remaining: aggregate?.totalRemaining ?? '0',
    };
  }

  async updatePartyHiddenLedgerBalance(
    businessId: string,
    partyId: string,
    amount: string,
    updatedBy?: string | null,
  ): Promise<void> {
    await this.db
      .update(parties)
      .set({
        hiddenLedgerBalance: amount,
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${parties.syncVersion} + 1`,
      })
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      );
  }

  async findPartyHiddenLedgerBalance(
    businessId: string,
    partyId: string,
  ): Promise<string | null> {
    const [row] = await this.db
      .select({ hiddenLedgerBalance: parties.hiddenLedgerBalance })
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    return row?.hiddenLedgerBalance ?? null;
  }

  async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    const [membership] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(membership);
  }
}
