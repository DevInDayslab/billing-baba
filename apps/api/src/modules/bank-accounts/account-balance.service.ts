import { and, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { accountMovements, bankAccounts } from '../../db/schema/bank-accounts/tables';
import { parseMoneyToPaise, formatPaise, addPaise } from '../gst-reports/core/gst-money';
import { startOfDayIstFromDateKey } from './domain/balance-at';

export class AccountBalanceService {
  constructor(private readonly db: Database) {}

  async balancesForBusiness(businessId: string, asOf = new Date()) {
    const accounts = await this.db
      .select()
      .from(bankAccounts)
      .where(
        and(
          eq(bankAccounts.businessId, businessId),
          eq(bankAccounts.isDeleted, false),
        ),
      );

    const results = [];
    for (const account of accounts) {
      const cutoff = startOfDayIstFromDateKey(account.openingBalanceAsOf);
      const [movementNet] = await this.db
        .select({
          net: sql<string>`COALESCE(SUM(
            CASE
              WHEN ${accountMovements.direction} = 'deposit'
              THEN ${accountMovements.amount}::numeric
              ELSE -${accountMovements.amount}::numeric
            END
          ), 0)`,
        })
        .from(accountMovements)
        .where(
          and(
            eq(accountMovements.businessId, businessId),
            eq(accountMovements.bankAccountId, account.id),
            eq(accountMovements.isDeleted, false),
            sql`${accountMovements.occurredAt} >= ${cutoff}`,
            sql`${accountMovements.occurredAt} < ${asOf}`,
          ),
        );

      const balance = addPaise(
        parseMoneyToPaise(account.openingBalance),
        parseMoneyToPaise(movementNet?.net ?? '0'),
      );
      results.push({
        account_id: account.id,
        type: account.type,
        display_name: account.displayName,
        is_active: account.isActive,
        balance: formatPaise(balance),
      });
    }
    return results;
  }

  async totalBankBalance(businessId: string, asOf = new Date()): Promise<string> {
    const rows = await this.balancesForBusiness(businessId, asOf);
    let total = parseMoneyToPaise('0');
    for (const row of rows) {
      if (row.type === 'bank') {
        total = addPaise(total, parseMoneyToPaise(row.balance));
      }
    }
    return formatPaise(total);
  }
}
