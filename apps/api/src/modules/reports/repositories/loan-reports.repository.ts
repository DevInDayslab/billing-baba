import { and, asc, desc, eq, gte, ilike, lt, lte } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { ledgerEntries } from '../../../db/schema/accounting/tables';
import { parties } from '../../../db/schema/crm/tables';
import type { LoanStatementQuery } from '../reports.schema';
import type { LoanStatementPayload } from '../reports.types';
import { isUuid, resolveRange, toPeriodMeta } from './reports.helpers';

export class LoanReportsRepository {
  constructor(private readonly db: Database) {}

  async getLoanStatement(
    businessId: string,
    query: LoanStatementQuery,
  ): Promise<LoanStatementPayload> {
    const range = resolveRange(query);
    const loanAccount = query.loan_account;

    let partyId = loanAccount;
    if (!isUuid(loanAccount)) {
      const [party] = await this.db
        .select({ id: parties.id })
        .from(parties)
        .where(
          and(
            eq(parties.businessId, businessId),
            eq(parties.isDeleted, false),
            ilike(parties.name, loanAccount),
          ),
        )
        .limit(1);
      partyId = party?.id ?? loanAccount;
    }

    const [openingRow] = await this.db
      .select({
        balance: ledgerEntries.balanceAfter,
      })
      .from(ledgerEntries)
      .where(
        and(
          eq(ledgerEntries.businessId, businessId),
          eq(ledgerEntries.partyId, partyId),
          lt(ledgerEntries.entryDate, range.from.toISOString().slice(0, 10)),
        ),
      )
      .orderBy(desc(ledgerEntries.entryDate), desc(ledgerEntries.createdAt))
      .limit(1);

    const entries = await this.db
      .select({
        date: ledgerEntries.entryDate,
        description: ledgerEntries.description,
        refType: ledgerEntries.referenceType,
        debit: ledgerEntries.debit,
        credit: ledgerEntries.credit,
        balance: ledgerEntries.balanceAfter,
      })
      .from(ledgerEntries)
      .where(
        and(
          eq(ledgerEntries.businessId, businessId),
          eq(ledgerEntries.partyId, partyId),
          gte(ledgerEntries.entryDate, range.from.toISOString().slice(0, 10)),
          lte(ledgerEntries.entryDate, range.to.toISOString().slice(0, 10)),
        ),
      )
      .orderBy(asc(ledgerEntries.entryDate), asc(ledgerEntries.createdAt));

    let balance = Number(openingRow?.balance ?? 0);
    const rows = [
      {
        date: range.from.toISOString(),
        description: 'Opening balance',
        ref_no: '-',
        debit: '0',
        credit: '0',
        balance: String(balance),
        is_opening: true,
      },
      ...entries.map((entry) => {
        balance = Number(entry.balance ?? balance);
        return {
          date: new Date(entry.date).toISOString(),
          description: entry.description,
          ref_no: entry.refType ?? '-',
          debit: entry.debit ?? '0',
          credit: entry.credit ?? '0',
          balance: entry.balance ?? String(balance),
          is_opening: false,
        };
      }),
    ];

    return {
      period: toPeriodMeta(range),
      loan_account: loanAccount,
      party_id: partyId,
      rows,
    };
  }
}
