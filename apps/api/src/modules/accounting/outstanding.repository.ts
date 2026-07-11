import { and, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { aggregatePartyLedgerBalances } from '../../shared/reporting/party-ledger';
import type {
  OutstandingSummary,
  PartyOutstandingBalance,
} from './outstanding.types';

/**
 * Ledger sign convention (customer/supplier running balance):
 * balance = opening_balance + SUM(debit) - SUM(credit)
 * Positive → receivable; negative → payable.
 *
 * Uses aggregatePartyLedgerBalances from the shared party-ledger engine.
 */
export class OutstandingRepository {
  constructor(private readonly db: Database) {}

  async getOutstandingSummary(businessId: string): Promise<OutstandingSummary> {
    const balances = await aggregatePartyLedgerBalances(this.db, businessId);

    let totalReceivable = 0;
    let receivablePartyCount = 0;
    let totalPayable = 0;
    let payablePartyCount = 0;

    for (const row of balances) {
      const balance = Number(row.balance);
      if (balance > 0) {
        totalReceivable += balance;
        receivablePartyCount += 1;
      } else if (balance < 0) {
        totalPayable += Math.abs(balance);
        payablePartyCount += 1;
      }
    }

    return {
      total_receivable: totalReceivable.toFixed(4),
      receivable_party_count: receivablePartyCount,
      total_payable: totalPayable.toFixed(4),
      payable_party_count: payablePartyCount,
    };
  }

  async listPartyBalances(
    businessId: string,
  ): Promise<PartyOutstandingBalance[]> {
    return aggregatePartyLedgerBalances(this.db, businessId);
  }

  async getPartyBalance(
    businessId: string,
    partyId: string,
  ): Promise<string | null> {
    const balances = await this.listPartyBalances(businessId);
    const match = balances.find((row) => row.party_id === partyId);
    return match?.balance ?? null;
  }
}
