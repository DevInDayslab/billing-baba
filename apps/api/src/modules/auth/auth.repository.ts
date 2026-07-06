import { and, eq, isNull } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { businesses } from '../../db/schema/business/tables';
import {
  accounts,
  refreshTokens,
  users,
} from '../../db/schema/identity/tables';
import { categories, godowns } from '../../db/schema/inventory/tables';
import {
  DEV_BUSINESS_ADDRESS,
  DEV_BUSINESS_GSTIN,
  DEV_BUSINESS_NAME,
  DEV_BUSINESS_PHONE,
  DEV_BUSINESS_STATE_CODE,
} from '../../shared/dev-demo.constants';
import type { AccountRecord, BusinessMembership } from './auth.types';

export class AuthRepository {
  constructor(private readonly db: Database) {}

  async findAccountByPhone(phone: string): Promise<AccountRecord | null> {
    const [row] = await this.db
      .select({
        id: accounts.id,
        phone: accounts.phone,
        name: accounts.name,
        email: accounts.email,
        avatarUrl: accounts.avatarUrl,
        timezone: accounts.timezone,
        language: accounts.language,
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
        email: accounts.email,
        avatarUrl: accounts.avatarUrl,
        timezone: accounts.timezone,
        language: accounts.language,
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
        email: accounts.email,
        avatarUrl: accounts.avatarUrl,
        timezone: accounts.timezone,
        language: accounts.language,
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
    return this.db.transaction(async (tx) => {
      const [business] = await tx
        .insert(businesses)
        .values({
          name: input.businessName,
          stateCode: DEV_BUSINESS_STATE_CODE,
          valuationMethod: 'average',
          gstin:
            input.businessName === DEV_BUSINESS_NAME
              ? DEV_BUSINESS_GSTIN
              : null,
          phone:
            input.businessName === DEV_BUSINESS_NAME
              ? DEV_BUSINESS_PHONE
              : input.phone,
          address:
            input.businessName === DEV_BUSINESS_NAME
              ? DEV_BUSINESS_ADDRESS
              : null,
        })
        .returning({
          id: businesses.id,
          name: businesses.name,
          gstin: businesses.gstin,
        });

      if (!business) {
        throw new Error('Failed to create business');
      }

      const [user] = await tx
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

      await tx.insert(godowns).values({
        businessId: business.id,
        name: 'Main Warehouse',
        isDefault: true,
      });

      await tx.insert(categories).values([
        { businessId: business.id, name: 'General' },
        { businessId: business.id, name: 'Services' },
      ]);

      return {
        userId: user.id,
        businessId: business.id,
        businessName: business.name,
        role: user.role,
        gstin: business.gstin,
      };
    });
  }

  async ensureInventorySeeds(businessId: string): Promise<void> {
    const activeGodowns = await this.db
      .select({ id: godowns.id, isDefault: godowns.isDefault })
      .from(godowns)
      .where(
        and(eq(godowns.businessId, businessId), eq(godowns.isDeleted, false)),
      );

    if (activeGodowns.length === 0) {
      await this.db.insert(godowns).values({
        businessId,
        name: 'Main Warehouse',
        isDefault: true,
      });
    } else if (!activeGodowns.some((row) => row.isDefault)) {
      const firstGodown = activeGodowns[0];
      if (firstGodown) {
        await this.db
          .update(godowns)
          .set({ isDefault: true, updatedAt: new Date() })
          .where(eq(godowns.id, firstGodown.id));
      }
    }

    const [category] = await this.db
      .select({ id: categories.id })
      .from(categories)
      .where(
        and(
          eq(categories.businessId, businessId),
          eq(categories.isDeleted, false),
        ),
      )
      .limit(1);

    if (!category) {
      await this.db.insert(categories).values([
        { businessId, name: 'General' },
        { businessId, name: 'Services' },
      ]);
    }
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
        email: accounts.email,
        avatarUrl: accounts.avatarUrl,
        timezone: accounts.timezone,
        language: accounts.language,
        createdAt: accounts.createdAt,
        updatedAt: accounts.updatedAt,
      })
      .from(accounts)
      .where(eq(accounts.id, accountId))
      .limit(1);

    return row ?? null;
  }

  async ensureAccountProfile(
    accountId: string,
    phone: string,
  ): Promise<AccountRecord> {
    const existing = await this.findAccountById(accountId);
    if (!existing) {
      throw new Error('Account not found');
    }

    const displayName = existing.name ?? phone.slice(-10);

    const [row] = await this.db
      .update(accounts)
      .set({
        name: displayName,
        timezone: existing.timezone || 'Asia/Kolkata',
        language: existing.language || 'en',
        updatedAt: new Date(),
      })
      .where(eq(accounts.id, accountId))
      .returning({
        id: accounts.id,
        phone: accounts.phone,
        name: accounts.name,
        email: accounts.email,
        avatarUrl: accounts.avatarUrl,
        timezone: accounts.timezone,
        language: accounts.language,
        createdAt: accounts.createdAt,
        updatedAt: accounts.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to ensure account profile');
    }

    return row;
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
