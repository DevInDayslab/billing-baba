import { and, eq } from 'drizzle-orm';
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
import type { CreateBusinessBody } from './business.schema';
import type { BusinessDetail, BusinessListItem } from './business.types';
import {
  currentFiscalYearLabel,
  resolveStateCode,
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
