import { and, eq, ne, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { businesses } from '../../db/schema/business/tables';
import { users } from '../../db/schema/identity/tables';
import {
  businessSettings,
  documentNumberSequences,
} from '../../db/schema/settings/tables';
import {
  categories,
  godowns,
} from '../../db/schema/inventory/tables';
import { expenseCategories } from '../../db/schema/purchases/tables';
import type {
  CreateBusinessBody,
  UpdateBusinessProfileBody,
} from './business.schema';
import type {
  BusinessDetail,
  BusinessListItem,
  BusinessProfile,
} from './business.types';
import {
  currentFiscalYearLabel,
  resolveStateCode,
  resolveStateName,
} from './business.utils';

export class BusinessRepository {
  constructor(private readonly db: Database) {}

  async listByAccountId(accountId: string): Promise<BusinessListItem[]> {
    const rows = await this.db
      .select({
        id: businesses.id,
        name: businesses.name,
        role: users.role,
        gstin: businesses.gstin,
        phone: businesses.phone,
        email: businesses.email,
        stateCode: businesses.stateCode,
        address: businesses.address,
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
      id: row.id,
      name: row.name,
      role: row.role,
      gstin: row.gstin,
      phone: row.phone,
      email: row.email,
      state_code: row.stateCode,
      address: row.address,
      is_shared: row.role !== 'owner',
    }));
  }

  async getProfile(
    businessId: string,
    accountId: string,
  ): Promise<BusinessProfile | null> {
    const [membership] = await this.db
      .select({ id: users.id })
      .from(users)
      .innerJoin(businesses, eq(users.businessId, businesses.id))
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
          eq(businesses.isDeleted, false),
        ),
      )
      .limit(1);

    if (!membership) {
      return null;
    }

    const [business] = await this.db
      .select({
        id: businesses.id,
        name: businesses.name,
        gstin: businesses.gstin,
        stateCode: businesses.stateCode,
        address: businesses.address,
        phone: businesses.phone,
        email: businesses.email,
        businessType: businesses.businessType,
        businessCategory: businesses.businessCategory,
        pincode: businesses.pincode,
        currency: businesses.currency,
        timezone: businesses.timezone,
        language: businesses.language,
        logoUrl: businesses.logoUrl,
        signatureUrl: businesses.signatureUrl,
      })
      .from(businesses)
      .where(
        and(eq(businesses.id, businessId), eq(businesses.isDeleted, false)),
      )
      .limit(1);

    if (!business) {
      return null;
    }

    const [owner] = await this.db
      .select({ name: users.name })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.role, 'owner'),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    return this.toProfile(business, owner?.name ?? null);
  }

  async updateProfile(
    businessId: string,
    accountId: string,
    input: UpdateBusinessProfileBody,
  ): Promise<BusinessProfile | null> {
    return this.db.transaction(async (tx) => {
      const [membership] = await tx
        .select({ id: users.id })
        .from(users)
        .innerJoin(businesses, eq(users.businessId, businesses.id))
        .where(
          and(
            eq(users.businessId, businessId),
            eq(users.accountId, accountId),
            eq(users.isActive, true),
            eq(users.isDeleted, false),
            eq(businesses.isDeleted, false),
          ),
        )
        .limit(1);

      if (!membership) {
        return null;
      }

      const gstin = input.gstin?.trim() || null;
      if (gstin) {
        const [conflict] = await tx
          .select({ id: businesses.id })
          .from(businesses)
          .where(
            and(
              eq(businesses.gstin, gstin),
              ne(businesses.id, businessId),
              eq(businesses.isDeleted, false),
            ),
          )
          .limit(1);

        if (conflict) {
          throw new Error('GSTIN_ALREADY_EXISTS');
        }
      }

      const stateCode = input.state
        ? resolveStateCode(input.state)
        : undefined;

      const [updated] = await tx
        .update(businesses)
        .set({
          name: input.name.trim(),
          gstin,
          phone: input.phone?.trim() || null,
          email: input.email?.trim() || null,
          address: input.address?.trim() || null,
          businessType: input.business_type?.trim() || null,
          businessCategory: input.business_category?.trim() || null,
          pincode: input.pincode?.trim() || null,
          ...(stateCode ? { stateCode } : {}),
          updatedAt: new Date(),
          syncVersion: sql`${businesses.syncVersion} + 1`,
        })
        .where(
          and(eq(businesses.id, businessId), eq(businesses.isDeleted, false)),
        )
        .returning({
          id: businesses.id,
          name: businesses.name,
          gstin: businesses.gstin,
          stateCode: businesses.stateCode,
          address: businesses.address,
          phone: businesses.phone,
          email: businesses.email,
          businessType: businesses.businessType,
          businessCategory: businesses.businessCategory,
          pincode: businesses.pincode,
          currency: businesses.currency,
          timezone: businesses.timezone,
          language: businesses.language,
          logoUrl: businesses.logoUrl,
          signatureUrl: businesses.signatureUrl,
        });

      if (!updated) {
        return null;
      }

      const [owner] = await tx
        .select({ name: users.name })
        .from(users)
        .where(
          and(
            eq(users.businessId, businessId),
            eq(users.role, 'owner'),
            eq(users.isDeleted, false),
          ),
        )
        .limit(1);

      return this.toProfile(updated, owner?.name ?? null);
    });
  }

  private toProfile(
    business: {
      id: string;
      name: string;
      gstin: string | null;
      stateCode: string;
      address: string | null;
      phone: string | null;
      email: string | null;
      businessType: string | null;
      businessCategory: string | null;
      pincode: string | null;
      currency: string;
      timezone: string;
      language: string;
      logoUrl: string | null;
      signatureUrl: string | null;
    },
    ownerName: string | null,
  ): BusinessProfile {
    return {
      id: business.id,
      name: business.name,
      owner_name: ownerName,
      phone: business.phone,
      email: business.email,
      gstin: business.gstin,
      business_type: business.businessType,
      business_category: business.businessCategory,
      state: resolveStateName(business.stateCode),
      pincode: business.pincode,
      currency: business.currency,
      address: business.address,
      timezone: business.timezone,
      language: business.language,
      logo_url: business.logoUrl,
      signature_url: business.signatureUrl,
    };
  }

  async createWithBootstrap(
    accountId: string,
    input: CreateBusinessBody,
    accountPhone: string,
  ): Promise<BusinessDetail> {
    const stateCode = resolveStateCode(input.state, input.state_code);
    const ownerName = input.owner_name?.trim() || input.name.trim();
    const ownerPhone = input.phone?.trim() || accountPhone;
    const fiscalYear = currentFiscalYearLabel();

    return this.db.transaction(async (tx) => {
      const [business] = await tx
        .insert(businesses)
        .values({
          name: input.name.trim(),
          gstin: input.gstin?.trim() || null,
          stateCode,
          address: input.address?.trim() || null,
          phone: input.phone?.trim() || null,
          email: input.email?.trim() || null,
          businessType: input.business_type?.trim() || null,
          currency: input.currency?.trim() || 'INR',
          valuationMethod: 'average',
        })
        .returning({
          id: businesses.id,
          name: businesses.name,
          gstin: businesses.gstin,
          phone: businesses.phone,
          email: businesses.email,
          stateCode: businesses.stateCode,
          address: businesses.address,
        });

      if (!business) {
        throw new Error('Failed to create business');
      }

      const [owner] = await tx
        .insert(users)
        .values({
          businessId: business.id,
          accountId,
          name: ownerName,
          phone: ownerPhone,
          email: input.email?.trim() || null,
          role: 'owner',
        })
        .returning({ role: users.role });

      if (!owner) {
        throw new Error('Failed to create owner membership');
      }

      await tx.insert(businessSettings).values({
        businessId: business.id,
        valuationMethod: 'average',
        defaultTaxType: 'none',
        invoiceTerms: input.currency
          ? `Currency: ${input.currency.trim()}`
          : null,
        enablePriceConflictAlerts: true,
        creditLimitAction: 'warn',
      });

      await tx.insert(godowns).values({
        businessId: business.id,
        name: 'Main Warehouse',
        isDefault: true,
      });

      await tx.insert(documentNumberSequences).values({
        businessId: business.id,
        documentSeries: 'INV',
        prefix: 'INV',
        nextNumber: 1,
        fiscalYear,
      });

      await tx.insert(expenseCategories).values([
        { businessId: business.id, name: 'Rent', isSystem: true },
        { businessId: business.id, name: 'Utilities', isSystem: true },
        { businessId: business.id, name: 'Salaries', isSystem: true },
      ]);

      await tx.insert(categories).values([
        { businessId: business.id, name: 'General' },
        { businessId: business.id, name: 'Services' },
      ]);

      return {
        id: business.id,
        name: business.name,
        role: owner.role,
        gstin: business.gstin,
        phone: business.phone,
        email: business.email,
        state_code: business.stateCode,
        address: business.address,
        is_shared: false,
      };
    });
  }
}
