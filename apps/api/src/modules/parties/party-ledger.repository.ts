import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { parties } from '../../db/schema/crm/tables';
import {
  buildPartyLedgerReport,
  logPartyLedgerDebug,
  type PartyLedgerFilter,
  resolveLedgerTypeLabel,
} from '../../shared/reporting/party-ledger';
import { buildPartyTimeline } from '../../shared/reporting/party-timeline';
import type { PartyTimelineRow } from '../../shared/reporting/party-timeline/party-timeline.types';
import {
  mapTimelineDebitCredit,
  mapTimelineEntryType,
} from '../../shared/reporting/party-timeline/party-timeline.utils';
import type {
  PartyLedgerPayload,
  PartyLedgerSummaryRecord,
  PartyLedgerTransactionRecord,
} from './party-ledger.types';

function normalizeMoney(value: number): string {
  return value.toFixed(2);
}

function toLedgerTransactionRecord(
  row: PartyTimelineRow,
): PartyLedgerTransactionRecord {
  const { debit, credit } = mapTimelineDebitCredit(row);

  const record: PartyLedgerTransactionRecord = {
    id: row.id,
    date: row.documentDate.toISOString().slice(0, 10),
    created_at: row.createdAt.toISOString(),
    type: row.type,
    entry_type: mapTimelineEntryType(row),
    source: row.source,
    source_type: row.sourceType,
    reference_id: row.referenceId,
    reference_type: row.referenceType,
    reference_number: row.referenceNumber,
    description: null,
    document_date: row.documentDate.toISOString(),
    total: row.total,
    balance: row.balance,
    due_date: row.dueDate,
    status: row.status,
    debit,
    credit,
    balance_after: row.balance,
    payment_status: row.paymentStatus ?? null,
  };

  if (row.direction) {
    record.direction = row.direction;
  }

  return record;
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
        partyType: parties.partyType,
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
      from: options.from,
      to: options.to,
      excludeAutoFinalizePayments: true,
    });

    const timeline = await buildPartyTimeline(
      this.db,
      businessId,
      partyId,
      partyRow.partyType,
      options,
    );

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

    const transactions = timeline.map(toLedgerTransactionRecord);

    return {
      party_id: partyId,
      summary,
      transactions,
    };
  }
}
