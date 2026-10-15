import { and, asc, eq, gte, ilike, inArray, lt, or, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { payments } from '../../../db/schema/accounting/tables';
import { parties } from '../../../db/schema/crm/tables';
import type { ReportExtendedQuery } from '../reports.schema';
import type { BankStatementPayload } from '../reports.types';
import { resolveRange, toPeriodMeta } from './reports.helpers';

export class BusinessReportsRepository {
  constructor(private readonly db: Database) {}

  /**
   * @deprecated Use `GET /reports/business/bank-statement` with `bank_account_id` instead.
   * Legacy payment-name filter; kept for older clients.
   */
  async getBankStatement(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<BankStatementPayload> {
    const range = resolveRange(query);
    const bankModes = ['bank_transfer', 'cheque'] as const;

    const paymentFilters = [
      eq(payments.businessId, businessId),
      eq(payments.isDeleted, false),
      inArray(payments.paymentMode, [...bankModes]),
      gte(payments.paymentDate, range.from),
      lt(payments.paymentDate, range.to),
    ];

    if (query.bank_name) {
      paymentFilters.push(
        or(
          ilike(payments.referenceNumber, `%${query.bank_name}%`),
          ilike(payments.notes, `%${query.bank_name}%`),
        )!,
      );
    }

    const [openingRow] = await this.db
      .select({
        net: sql<string>`COALESCE(SUM(
          CASE
            WHEN ${payments.direction} = 'received' THEN ${payments.amount}::numeric
            ELSE -${payments.amount}::numeric
          END
        ), 0)`,
      })
      .from(payments)
      .where(
        and(
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
          inArray(payments.paymentMode, [...bankModes]),
          lt(payments.paymentDate, range.from),
        ),
      );

    const paymentRows = await this.db
      .select({
        date: payments.paymentDate,
        description: payments.notes,
        refNo: payments.referenceNumber,
        direction: payments.direction,
        amount: payments.amount,
        partyName: parties.name,
      })
      .from(payments)
      .innerJoin(parties, eq(payments.partyId, parties.id))
      .where(and(...paymentFilters))
      .orderBy(asc(payments.paymentDate), asc(payments.createdAt));

    let balance = Number(openingRow?.net ?? 0);
    const rows = [
      {
        date: range.from.toISOString(),
        description: 'Opening balance',
        ref_no: '-',
        money_in: '0',
        money_out: '0',
        balance: String(balance),
        is_opening: true,
      },
      ...paymentRows.map((row) => {
        const amount = Number(row.amount ?? 0);
        const isIn = row.direction === 'received';
        const moneyIn = isIn ? amount : 0;
        const moneyOut = isIn ? 0 : amount;
        balance += moneyIn - moneyOut;
        return {
          date: row.date.toISOString(),
          description: row.description ?? row.partyName ?? 'Bank transaction',
          ref_no: row.refNo ?? row.partyName ?? '-',
          money_in: String(moneyIn),
          money_out: String(moneyOut),
          balance: String(balance),
          is_opening: false,
        };
      }),
    ];

    return {
      period: toPeriodMeta(range),
      bank_name: query.bank_name ?? null,
      rows,
    };
  }
}
