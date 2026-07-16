import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { parties } from '../../db/schema/crm/tables';
import {
  buildPartyLedgerReport,
  logPartyLedgerDebug,
  type PartyLedgerFilter,
  resolveLedgerTypeLabel,
} from '../../shared/reporting/party-ledger';
import type {
  PartyLedgerPayload,
  PartyLedgerSummaryRecord,
  PartyLedgerTransactionRecord,
} from './party-ledger.types';

function normalizeMoney(value: number): string {
  return value.toFixed(2);
}

export class PartyLedgerRepository {
  constructor(private readonly db: Database) {}

  async getPartyLedger(
    businessId: string,
    partyId: string,
    options: {
      filter?: PartyLedgerFilter;
      from?: string;
      to?: string;
    } = {},
  ): Promise<PartyLedgerPayload | null> {
    const [partyRow] = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        creditLimit: parties.creditLimit,
        isActive: parties.isActive,
      })
      .from(parties)
      .where(
        and(
          eq(parties.businessId, businessId),
          eq(parties.id, partyId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    if (!partyRow) {
      return null;
    }

    const report = await buildPartyLedgerReport(this.db, businessId, partyId, {
      filter: options.filter,
      from: options.from,
      to: options.to,
    });

    logPartyLedgerDebug(partyRow.name, report);

    const summary: PartyLedgerSummaryRecord = {
      opening_balance: normalizeMoney(report.summary.openingBalance),
      outstanding: normalizeMoney(report.summary.outstanding),
      receive_amount: normalizeMoney(report.summary.receiveAmount),
      payable_amount: normalizeMoney(report.summary.payableAmount),
      credit_limit: partyRow.creditLimit ?? null,
      status: partyRow.isActive ? 'active' : 'inactive',
      last_transaction_date: report.summary.lastTransactionDate,
      total_sales: normalizeMoney(report.summary.totalSales),
      total_purchases: normalizeMoney(report.summary.totalPurchases),
      total_payments: normalizeMoney(report.summary.totalPayments),
    };

    const transactions: PartyLedgerTransactionRecord[] = report.entries.map(
      (entry) => {
        const typeLabel = resolveLedgerTypeLabel(
          entry.entryType,
          entry.salesDocumentType,
          entry.purchaseDocumentType,
          entry.paymentDirection,
        );

        const record: PartyLedgerTransactionRecord = {
          id: entry.id,
          date: entry.date,
          created_at: entry.createdAt.toISOString(),
          type: typeLabel,
          entry_type: entry.entryType,
          reference_id: entry.referenceId,
          reference_type: entry.referenceType,
          reference_number: entry.referenceNumber,
          description: entry.description,
          debit: entry.debit,
          credit: entry.credit,
          balance_after: normalizeMoney(
            report.runningBalances.get(entry.id) ?? report.openingBalance,
          ),
        };

        if (entry.entryType === 'payment' && entry.paymentDirection) {
          record.direction = entry.paymentDirection;
        }

        return record;
      },
    );

    return {
      party_id: partyId,
      summary,
      transactions,
    };
  }
}
