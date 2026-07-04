import { and, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { ledgerEntries } from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import type {
  OutstandingSummary,
  PartyOutstandingBalance,
} from './outstanding.types';

/**
 * Ledger sign convention (customer/supplier running balance):
 * balance = opening_balance + SUM(debit) - SUM(credit)
 * Positive → receivable; negative → payable.
 */
export class OutstandingRepository {
  constructor(private readonly db: Database) {}

  private partyBalanceSubquery(businessId: string) {
    return this.db
      .select({
        partyId: parties.id,
        balance: sql<string>`(
          ${parties.openingBalance}::numeric
          + COALESCE((
            SELECT SUM(${ledgerEntries.debit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
          ), 0)
          - COALESCE((
            SELECT SUM(${ledgerEntries.credit}::numeric)
            FROM ${ledgerEntries}
            WHERE ${ledgerEntries.businessId} = ${businessId}
              AND ${ledgerEntries.partyId} = ${parties.id}
          ), 0)
        )`.as('balance'),
      })
      .from(parties)
      .where(
        and(eq(parties.businessId, businessId), eq(parties.isDeleted, false)),
      )
      .as('party_balances');
  }

  async getOutstandingSummary(businessId: string): Promise<OutstandingSummary> {
    const balances = this.partyBalanceSubquery(businessId);

    const [row] = await this.db
      .select({
        totalReceivable: sql<string>`COALESCE(SUM(
          CASE WHEN ${balances.balance}::numeric > 0
            THEN ${balances.balance}::numeric ELSE 0 END
        ), 0)`,
        receivablePartyCount: sql<number>`COUNT(*) FILTER (
          WHERE ${balances.balance}::numeric > 0
        )::int`,
        totalPayable: sql<string>`COALESCE(SUM(
          CASE WHEN ${balances.balance}::numeric < 0
            THEN ABS(${balances.balance}::numeric) ELSE 0 END
        ), 0)`,
        payablePartyCount: sql<number>`COUNT(*) FILTER (
          WHERE ${balances.balance}::numeric < 0
        )::int`,
      })
      .from(balances);

    return {
      total_receivable: row?.totalReceivable ?? '0',
      receivable_party_count: Number(row?.receivablePartyCount ?? 0),
      total_payable: row?.totalPayable ?? '0',
      payable_party_count: Number(row?.payablePartyCount ?? 0),
    };
  }

  async listPartyBalances(
    businessId: string,
  ): Promise<PartyOutstandingBalance[]> {
    const balances = this.partyBalanceSubquery(businessId);

    const rows = await this.db
      .select({
        partyId: balances.partyId,
        balance: balances.balance,
      })
      .from(balances);

    return rows.map((row) => ({
      party_id: row.partyId,
      balance: row.balance ?? '0',
    }));
  }
}
