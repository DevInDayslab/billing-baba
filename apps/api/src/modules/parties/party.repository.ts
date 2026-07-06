import { and, asc, count, desc, eq, ilike, ne, or, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { ledgerEntries, payments } from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import { users } from '../../db/schema/identity/tables';
import { expenses, purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import type {
  ListPartiesParams,
  PartyInsertValues,
  PartyRecord,
  PartyUpdateValues,
} from './party.types';
import { resolveStateName } from './party.utils';

type PartyRow = {
  id: string;
  name: string;
  mobile: string | null;
  email: string | null;
  partyType: 'customer' | 'supplier' | 'both';
  partyCategory:
    | 'customer'
    | 'retailer'
    | 'wholesaler'
    | 'manufacturer'
    | 'custom'
    | null;
  pricingTier: 'tier_1' | 'tier_2' | 'tier_3';
  gstin: string | null;
  stateCode: string | null;
  areaId: string | null;
  creditLimit: string;
  openingBalance: string;
  isActive: boolean;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
};

export class PartyRepository {
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

  async findActiveMobileConflict(
    businessId: string,
    mobile: string,
    excludePartyId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(parties.businessId, businessId),
      eq(parties.mobile, mobile),
      eq(parties.isDeleted, false),
    ];

    if (excludePartyId) {
      conditions.push(ne(parties.id, excludePartyId));
    }

    const [row] = await this.db
      .select({ id: parties.id })
      .from(parties)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async findActiveGstinConflict(
    businessId: string,
    gstin: string,
    excludePartyId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(parties.businessId, businessId),
      eq(parties.gstin, gstin),
      eq(parties.isDeleted, false),
    ];

    if (excludePartyId) {
      conditions.push(ne(parties.id, excludePartyId));
    }

    const [row] = await this.db
      .select({ id: parties.id })
      .from(parties)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async list(params: ListPartiesParams): Promise<{
    rows: PartyRecord[];
    total: number;
  }> {
    const filters = [
      eq(parties.businessId, params.businessId),
      eq(parties.isDeleted, false),
    ];

    if (params.partyType) {
      filters.push(eq(parties.partyType, params.partyType));
    }

    if (params.isActive !== undefined) {
      filters.push(eq(parties.isActive, params.isActive));
    }

    if (params.q) {
      const pattern = `%${params.q}%`;
      const searchCondition = or(
        ilike(parties.name, pattern),
        ilike(parties.mobile, pattern),
        ilike(parties.gstin, pattern),
      );
      if (searchCondition) {
        filters.push(searchCondition);
      }
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(parties)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? parties.createdAt
        : params.sort === 'opening_balance'
          ? parties.openingBalance
          : parties.name;

    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);

    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        mobile: parties.mobile,
        email: parties.email,
        partyType: parties.partyType,
        partyCategory: parties.partyCategory,
        pricingTier: parties.pricingTier,
        gstin: parties.gstin,
        stateCode: parties.stateCode,
        areaId: parties.areaId,
        creditLimit: parties.creditLimit,
        openingBalance: parties.openingBalance,
        isActive: parties.isActive,
        notes: parties.notes,
        createdAt: parties.createdAt,
        updatedAt: parties.updatedAt,
      })
      .from(parties)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => this.toRecord(row)),
      total,
    };
  }

  async findById(
    businessId: string,
    partyId: string,
  ): Promise<PartyRecord | null> {
    const [row] = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        mobile: parties.mobile,
        email: parties.email,
        partyType: parties.partyType,
        partyCategory: parties.partyCategory,
        pricingTier: parties.pricingTier,
        gstin: parties.gstin,
        stateCode: parties.stateCode,
        areaId: parties.areaId,
        creditLimit: parties.creditLimit,
        openingBalance: parties.openingBalance,
        isActive: parties.isActive,
        notes: parties.notes,
        createdAt: parties.createdAt,
        updatedAt: parties.updatedAt,
      })
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? this.toRecord(row) : null;
  }

  async create(values: PartyInsertValues): Promise<PartyRecord> {
    const [row] = await this.db
      .insert(parties)
      .values({
        businessId: values.businessId,
        name: values.name,
        mobile: values.mobile,
        email: values.email,
        partyType: values.partyType,
        partyCategory: values.partyCategory ?? null,
        pricingTier: values.pricingTier,
        gstin: values.gstin,
        stateCode: values.stateCode,
        areaId: values.areaId ?? null,
        creditLimit: values.creditLimit,
        openingBalance: values.openingBalance,
        notes: values.notes,
        isActive: values.isActive,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: parties.id,
        name: parties.name,
        mobile: parties.mobile,
        email: parties.email,
        partyType: parties.partyType,
        partyCategory: parties.partyCategory,
        pricingTier: parties.pricingTier,
        gstin: parties.gstin,
        stateCode: parties.stateCode,
        areaId: parties.areaId,
        creditLimit: parties.creditLimit,
        openingBalance: parties.openingBalance,
        isActive: parties.isActive,
        notes: parties.notes,
        createdAt: parties.createdAt,
        updatedAt: parties.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create party');
    }

    return this.toRecord(row);
  }

  async update(
    businessId: string,
    partyId: string,
    values: PartyUpdateValues,
  ): Promise<PartyRecord | null> {
    const [row] = await this.db
      .update(parties)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.mobile !== undefined ? { mobile: values.mobile } : {}),
        ...(values.email !== undefined ? { email: values.email } : {}),
        ...(values.partyType !== undefined
          ? { partyType: values.partyType }
          : {}),
        ...(values.partyCategory !== undefined
          ? { partyCategory: values.partyCategory }
          : {}),
        ...(values.pricingTier !== undefined
          ? { pricingTier: values.pricingTier }
          : {}),
        ...(values.gstin !== undefined ? { gstin: values.gstin } : {}),
        ...(values.stateCode !== undefined
          ? { stateCode: values.stateCode }
          : {}),
        ...(values.areaId !== undefined ? { areaId: values.areaId } : {}),
        ...(values.creditLimit !== undefined
          ? { creditLimit: values.creditLimit }
          : {}),
        ...(values.openingBalance !== undefined
          ? { openingBalance: values.openingBalance }
          : {}),
        ...(values.notes !== undefined ? { notes: values.notes } : {}),
        ...(values.isActive !== undefined ? { isActive: values.isActive } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${parties.syncVersion} + 1`,
      })
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .returning({
        id: parties.id,
        name: parties.name,
        mobile: parties.mobile,
        email: parties.email,
        partyType: parties.partyType,
        partyCategory: parties.partyCategory,
        pricingTier: parties.pricingTier,
        gstin: parties.gstin,
        stateCode: parties.stateCode,
        areaId: parties.areaId,
        creditLimit: parties.creditLimit,
        openingBalance: parties.openingBalance,
        isActive: parties.isActive,
        notes: parties.notes,
        createdAt: parties.createdAt,
        updatedAt: parties.updatedAt,
      });

    return row ? this.toRecord(row) : null;
  }

  async softDelete(
    businessId: string,
    partyId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(parties)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${parties.syncVersion} + 1`,
      })
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .returning({ id: parties.id });

    return Boolean(row);
  }

  async countDocumentDependencies(
    businessId: string,
    partyId: string,
  ): Promise<number> {
    const [salesCount] = await this.db
      .select({ total: count() })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.partyId, partyId),
          eq(salesDocuments.isDeleted, false),
        ),
      );

    const [purchaseCount] = await this.db
      .select({ total: count() })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.partyId, partyId),
          eq(purchaseDocuments.isDeleted, false),
        ),
      );

    const [expenseCount] = await this.db
      .select({ total: count() })
      .from(expenses)
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.partyId, partyId),
          eq(expenses.isDeleted, false),
        ),
      );

    const [paymentCount] = await this.db
      .select({ total: count() })
      .from(payments)
      .where(
        and(
          eq(payments.businessId, businessId),
          eq(payments.partyId, partyId),
          eq(payments.isDeleted, false),
        ),
      );

    const [ledgerCount] = await this.db
      .select({ total: count() })
      .from(ledgerEntries)
      .where(
        and(
          eq(ledgerEntries.businessId, businessId),
          eq(ledgerEntries.partyId, partyId),
        ),
      );

    return (
      Number(salesCount?.total ?? 0) +
      Number(purchaseCount?.total ?? 0) +
      Number(expenseCount?.total ?? 0) +
      Number(paymentCount?.total ?? 0) +
      Number(ledgerCount?.total ?? 0)
    );
  }

  private toRecord(row: PartyRow): PartyRecord {
    const openingBalance = row.openingBalance ?? '0';

    return {
      id: row.id,
      name: row.name,
      mobile: row.mobile,
      email: row.email,
      party_type: row.partyType,
      party_category: row.partyCategory,
      pricing_tier: row.pricingTier,
      gstin: row.gstin,
      state_code: row.stateCode,
      state: row.stateCode ? resolveStateName(row.stateCode) : null,
      area_id: row.areaId,
      credit_limit: row.creditLimit,
      opening_balance: openingBalance,
      balance: openingBalance,
      is_active: row.isActive,
      notes: row.notes,
      created_at: row.createdAt.toISOString(),
      updated_at: row.updatedAt.toISOString(),
    };
  }
}
