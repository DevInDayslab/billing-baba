import { and, eq, isNull } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { businesses } from '../../db/schema/business/tables';
import {
  accounts,
  refreshTokens,
  users,
} from '../../db/schema/identity/tables';
import type { AccountRecord, BusinessMembership } from './auth.types';

export class AuthRepository {
  constructor(private readonly db: Database) {}

  async findAccountByPhone(phone: string): Promise<AccountRecord | null> {
    const [row] = await this.db
      .select({
        id: accounts.id,
        phone: accounts.phone,
        name: accounts.name,
        createdAt: accounts.createdAt,
        updatedAt: accounts.updatedAt,
      })
      .from(accounts)
      .where(eq(accounts.phone, phone))
      .limit(1);

    return row ?? null;
  }

  async createAccount(phone: string, name?: string): Promise<AccountRecord> {
    const [row] = await this.db
      .insert(accounts)
      .values({ phone, name: name ?? null })
      .returning({
        id: accounts.id,
        phone: accounts.phone,
        name: accounts.name,
        createdAt: accounts.createdAt,
        updatedAt: accounts.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create account');
    }

    return row;
  }

  async updateAccountName(
    accountId: string,
    name: string,
  ): Promise<AccountRecord> {
    const [row] = await this.db
      .update(accounts)
      .set({ name, updatedAt: new Date() })
      .where(eq(accounts.id, accountId))
      .returning({
        id: accounts.id,
        phone: accounts.phone,
        name: accounts.name,
        createdAt: accounts.createdAt,
        updatedAt: accounts.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to update account');
    }

    return row;
  }

  async createBusinessWithOwner(input: {
    accountId: string;
    businessName: string;
    ownerName: string;
    phone: string;
  }): Promise<BusinessMembership> {
    const [business] = await this.db
      .insert(businesses)
      .values({
        name: input.businessName,
        stateCode: '27',
        valuationMethod: 'average',
      })
      .returning({
        id: businesses.id,
        name: businesses.name,
        gstin: businesses.gstin,
      });

    if (!business) {
      throw new Error('Failed to create business');
    }

    const [user] = await this.db
      .insert(users)
      .values({
        businessId: business.id,
        accountId: input.accountId,
        name: input.ownerName,
        phone: input.phone,
        role: 'owner',
      })
      .returning({ id: users.id, role: users.role });

    if (!user) {
      throw new Error('Failed to create owner user');
    }

    return {
      userId: user.id,
      businessId: business.id,
      businessName: business.name,
      role: user.role,
      gstin: business.gstin,
    };
  }

  async findMembershipsByAccountId(
    accountId: string,
  ): Promise<BusinessMembership[]> {
    const rows = await this.db
      .select({
        userId: users.id,
        businessId: businesses.id,
        businessName: businesses.name,
        role: users.role,
        gstin: businesses.gstin,
      })
      .from(users)
      .innerJoin(businesses, eq(users.businessId, businesses.id))
      .where(
        and(
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
          eq(businesses.isDeleted, false),
        ),
      );

    return rows.map((row) => ({
      userId: row.userId,
      businessId: row.businessId,
      businessName: row.businessName,
      role: row.role,
      gstin: row.gstin,
    }));
  }

  async findAccountById(accountId: string): Promise<AccountRecord | null> {
    const [row] = await this.db
      .select({
        id: accounts.id,
        phone: accounts.phone,
        name: accounts.name,
        createdAt: accounts.createdAt,
        updatedAt: accounts.updatedAt,
      })
      .from(accounts)
      .where(eq(accounts.id, accountId))
      .limit(1);

    return row ?? null;
  }

  async createRefreshToken(input: {
    accountId: string;
    userId?: string;
    tokenHash: string;
    expiresAt: Date;
  }): Promise<void> {
    await this.db.insert(refreshTokens).values({
      accountId: input.accountId,
      userId: input.userId ?? null,
      tokenHash: input.tokenHash,
      expiresAt: input.expiresAt,
    });
  }

  async findRefreshTokenByHash(tokenHash: string) {
    const [row] = await this.db
      .select()
      .from(refreshTokens)
      .where(
        and(
          eq(refreshTokens.tokenHash, tokenHash),
          isNull(refreshTokens.revokedAt),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async revokeRefreshToken(tokenHash: string): Promise<void> {
    await this.db
      .update(refreshTokens)
      .set({ revokedAt: new Date() })
      .where(eq(refreshTokens.tokenHash, tokenHash));
  }

  async revokeRefreshTokenById(id: string): Promise<void> {
    await this.db
      .update(refreshTokens)
      .set({ revokedAt: new Date() })
      .where(eq(refreshTokens.id, id));
  }
}
