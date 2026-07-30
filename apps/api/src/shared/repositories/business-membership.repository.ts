import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { users } from '../../db/schema/identity/tables';

export class BusinessMembershipRepository {
  constructor(private readonly db: Database) {}

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

  async findAnyAccountId(businessId: string): Promise<string | null> {
    const [membership] = await this.db
      .select({ accountId: users.accountId })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    return membership?.accountId ?? null;
  }
}
