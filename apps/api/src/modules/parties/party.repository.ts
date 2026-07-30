import {
  and,
  asc,
  count,
  desc,
  eq,
  ilike,
  inArray,
  ne,
  or,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import { payments } from '../../db/schema/accounting/tables';
import { parties, partyPhones } from '../../db/schema/crm/tables';
import { users } from '../../db/schema/identity/tables';
import { purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import type { PricingTier } from '../../shared/pricing/pricing-tier';
import { OutstandingRepository } from '../accounting/outstanding.repository';
import type {
  ListPartiesParams,
  PartyDeleteReferences,
  PartyInsertValues,
  PartyRecord,
  PartyUpdateValues,
} from './party.types';
import { resolveStateName } from './party.utils';

type PartyRow = {
  id: string;
  name: string;
  legalName: string | null;
  alias: string | null;
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
  partyGroup: string | null;
  areaCode: string | null;
  pricingTier: PricingTier;
  gstin: string | null;
  stateCode: string | null;
  areaId: string | null;
  creditLimit: string;
  openingBalance: string;
  hiddenLedgerBalance: string;
  isActive: boolean;
  notes: string | null;
  profileImageUrl: string | null;
  profileMediaAssetId: string | null;
  createdAt: Date;
  updatedAt: Date;
};

const partySelectColumns = {
  id: parties.id,
  name: parties.name,
  legalName: parties.legalName,
  alias: parties.alias,
  mobile: parties.mobile,
  email: parties.email,
  partyType: parties.partyType,
  partyCategory: parties.partyCategory,
  partyGroup: parties.partyGroup,
  areaCode: parties.areaCode,
  pricingTier: parties.pricingTier,
  gstin: parties.gstin,
  stateCode: parties.stateCode,
  areaId: parties.areaId,
  creditLimit: parties.creditLimit,
  openingBalance: parties.openingBalance,
  hiddenLedgerBalance: parties.hiddenLedgerBalance,
  isActive: parties.isActive,
  notes: parties.notes,
  profileImageUrl: parties.profileImageUrl,
  profileMediaAssetId: parties.profileMediaAssetId,
  createdAt: parties.createdAt,
  updatedAt: parties.updatedAt,
};

export class PartyRepository {
  private readonly outstandingRepository: OutstandingRepository;

  constructor(private readonly db: Database) {
    this.outstandingRepository = new OutstandingRepository(db);
  }

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
    const partyConflict = await this.findActivePartyMobileConflict(
      businessId,
      mobile,
      excludePartyId,
    );
    if (partyConflict) return partyConflict;

    return this.findActiveAdditionalPhoneConflict(
      businessId,
      mobile,
      excludePartyId,
    );
  }

  private async findActivePartyMobileConflict(
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

  private async findActiveAdditionalPhoneConflict(
    businessId: string,
    mobile: string,
    excludePartyId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(partyPhones.businessId, businessId),
      eq(partyPhones.mobile, mobile),
      eq(partyPhones.isDeleted, false),
    ];

    if (excludePartyId) {
      conditions.push(ne(partyPhones.partyId, excludePartyId));
    }

    const [row] = await this.db
      .select({ partyId: partyPhones.partyId })
      .from(partyPhones)
      .where(and(...conditions))
      .limit(1);

    return row?.partyId ?? null;
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
      const phoneMatches = this.db
        .select({ partyId: partyPhones.partyId })
        .from(partyPhones)
        .where(
          and(
            eq(partyPhones.businessId, params.businessId),
            eq(partyPhones.isDeleted, false),
            ilike(partyPhones.mobile, pattern),
          ),
        );

      const searchCondition = or(
        ilike(parties.name, pattern),
        ilike(parties.legalName, pattern),
        ilike(parties.alias, pattern),
        ilike(parties.mobile, pattern),
        ilike(parties.gstin, pattern),
        sql`${parties.id} IN (${phoneMatches})`,
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
      .select(partySelectColumns)
      .from(parties)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    const balanceMap = await this.loadBalanceMap(params.businessId);
    const phonesMap = await this.loadAdditionalPhonesMap(
      params.businessId,
      rows.map((row) => row.id),
    );

    return {
      rows: rows.map((row) =>
        this.toRecord(row, balanceMap.get(row.id), {
          includeHiddenLedgerBalance: true,
          additionalPhones: phonesMap.get(row.id),
        }),
      ),
      total,
    };
  }

  async findById(
    businessId: string,
    partyId: string,
  ): Promise<PartyRecord | null> {
    const [row] = await this.db
      .select(partySelectColumns)
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) return null;

    const balance = await this.outstandingRepository.getPartyBalance(
      businessId,
      partyId,
    );
    const additionalPhones = await this.listAdditionalPhones(
      businessId,
      partyId,
    );

    return this.toRecord(row, balance ?? undefined, {
      includeHiddenLedgerBalance: true,
      additionalPhones,
    });
  }

  async create(values: PartyInsertValues): Promise<PartyRecord> {
    const [row] = await this.db
      .insert(parties)
      .values({
        businessId: values.businessId,
        name: values.name,
        legalName: values.legalName ?? null,
        alias: values.alias ?? null,
        mobile: values.mobile,
        email: values.email,
        partyType: values.partyType,
        partyCategory: values.partyCategory ?? null,
        partyGroup: values.partyGroup ?? null,
        areaCode: values.areaCode ?? null,
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
      .returning(partySelectColumns);

    if (!row) {
      throw new Error('Failed to create party');
    }

    return this.toRecord(row, values.openingBalance, {
      includeHiddenLedgerBalance: true,
      additionalPhones: [],
    });
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
        ...(values.legalName !== undefined
          ? { legalName: values.legalName }
          : {}),
        ...(values.alias !== undefined ? { alias: values.alias } : {}),
        ...(values.mobile !== undefined ? { mobile: values.mobile } : {}),
        ...(values.email !== undefined ? { email: values.email } : {}),
        ...(values.partyType !== undefined
          ? { partyType: values.partyType }
          : {}),
        ...(values.partyCategory !== undefined
          ? { partyCategory: values.partyCategory }
          : {}),
        ...(values.partyGroup !== undefined
          ? { partyGroup: values.partyGroup }
          : {}),
        ...(values.areaCode !== undefined ? { areaCode: values.areaCode } : {}),
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
        ...(values.hiddenLedgerBalance !== undefined
          ? { hiddenLedgerBalance: values.hiddenLedgerBalance }
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
      .returning(partySelectColumns);

    if (!row) return null;

    const balance = await this.outstandingRepository.getPartyBalance(
      businessId,
      partyId,
    );
    const additionalPhones = await this.listAdditionalPhones(
      businessId,
      partyId,
    );

    return this.toRecord(row, balance ?? undefined, {
      includeHiddenLedgerBalance: true,
      additionalPhones,
    });
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

  async countDeleteReferences(
    businessId: string,
    partyId: string,
  ): Promise<PartyDeleteReferences> {
    const salesFilter = and(
      eq(salesDocuments.businessId, businessId),
      eq(salesDocuments.partyId, partyId),
      eq(salesDocuments.isDeleted, false),
    );

    const purchaseFilter = and(
      eq(purchaseDocuments.businessId, businessId),
      eq(purchaseDocuments.partyId, partyId),
      eq(purchaseDocuments.isDeleted, false),
    );

    const [salesRow, purchaseRow, paymentRow] = await Promise.all([
      this.db
        .select({
          sales: sql<number>`count(*) filter (where ${salesDocuments.documentType} != 'sales_return')::int`,
          salesReturns: sql<number>`count(*) filter (where ${salesDocuments.documentType} = 'sales_return')::int`,
        })
        .from(salesDocuments)
        .where(salesFilter)
        .then((rows) => rows[0]),
      this.db
        .select({
          purchases: sql<number>`count(*) filter (where ${purchaseDocuments.documentType} != 'purchase_return')::int`,
          purchaseReturns: sql<number>`count(*) filter (where ${purchaseDocuments.documentType} = 'purchase_return')::int`,
        })
        .from(purchaseDocuments)
        .where(purchaseFilter)
        .then((rows) => rows[0]),
      this.db
        .select({ total: count() })
        .from(payments)
        .where(
          and(
            eq(payments.businessId, businessId),
            eq(payments.partyId, partyId),
            eq(payments.isDeleted, false),
          ),
        )
        .then((rows) => rows[0]),
    ]);

    return {
      sales: Number(salesRow?.sales ?? 0),
      purchases: Number(purchaseRow?.purchases ?? 0),
      payments: Number(paymentRow?.total ?? 0),
      salesReturns: Number(salesRow?.salesReturns ?? 0),
      purchaseReturns: Number(purchaseRow?.purchaseReturns ?? 0),
    };
  }

  async replaceAdditionalPhones(
    businessId: string,
    partyId: string,
    mobiles: string[],
    updatedBy?: string | null,
  ): Promise<void> {
    await this.db
      .update(partyPhones)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${partyPhones.syncVersion} + 1`,
      })
      .where(
        and(
          eq(partyPhones.businessId, businessId),
          eq(partyPhones.partyId, partyId),
          eq(partyPhones.isDeleted, false),
        ),
      );

    if (mobiles.length === 0) return;

    await this.db.insert(partyPhones).values(
      mobiles.map((mobile, index) => ({
        businessId,
        partyId,
        mobile,
        sortOrder: index,
        createdBy: updatedBy ?? null,
        updatedBy: updatedBy ?? null,
      })),
    );
  }

  private async listAdditionalPhones(
    businessId: string,
    partyId: string,
  ): Promise<string[]> {
    const rows = await this.db
      .select({ mobile: partyPhones.mobile })
      .from(partyPhones)
      .where(
        and(
          eq(partyPhones.businessId, businessId),
          eq(partyPhones.partyId, partyId),
          eq(partyPhones.isDeleted, false),
        ),
      )
      .orderBy(asc(partyPhones.sortOrder), asc(partyPhones.createdAt));

    return rows.map((row) => row.mobile);
  }

  private async loadAdditionalPhonesMap(
    businessId: string,
    partyIds: string[],
  ): Promise<Map<string, string[]>> {
    const map = new Map<string, string[]>();
    if (partyIds.length === 0) return map;

    const rows = await this.db
      .select({
        partyId: partyPhones.partyId,
        mobile: partyPhones.mobile,
        sortOrder: partyPhones.sortOrder,
      })
      .from(partyPhones)
      .where(
        and(
          eq(partyPhones.businessId, businessId),
          inArray(partyPhones.partyId, partyIds),
          eq(partyPhones.isDeleted, false),
        ),
      )
      .orderBy(asc(partyPhones.sortOrder), asc(partyPhones.createdAt));

    for (const row of rows) {
      const existing = map.get(row.partyId) ?? [];
      existing.push(row.mobile);
      map.set(row.partyId, existing);
    }

    return map;
  }

  private async loadBalanceMap(
    businessId: string,
  ): Promise<Map<string, string>> {
    const balances =
      await this.outstandingRepository.listPartyBalances(businessId);
    return new Map(balances.map((row) => [row.party_id, row.balance]));
  }

  async getProfileMediaAssetId(
    businessId: string,
    partyId: string,
  ): Promise<string | null> {
    const [row] = await this.db
      .select({ profileMediaAssetId: parties.profileMediaAssetId })
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    return row?.profileMediaAssetId ?? null;
  }

  async bindProfileImage(
    businessId: string,
    partyId: string,
    assetId: string,
    url: string,
  ): Promise<void> {
    await this.db
      .update(parties)
      .set({
        profileMediaAssetId: assetId,
        profileImageUrl: url,
        updatedAt: new Date(),
        syncVersion: sql`${parties.syncVersion} + 1`,
      })
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      );
  }

  async clearProfileImage(businessId: string, partyId: string): Promise<void> {
    await this.db
      .update(parties)
      .set({
        profileMediaAssetId: null,
        profileImageUrl: null,
        updatedAt: new Date(),
        syncVersion: sql`${parties.syncVersion} + 1`,
      })
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      );
  }

  private toRecord(
    row: PartyRow,
    balance?: string,
    options?: {
      includeHiddenLedgerBalance?: boolean;
      additionalPhones?: string[];
    },
  ): PartyRecord {
    const openingBalance = row.openingBalance ?? '0';
    const ledgerBalance = balance ?? openingBalance;

    const record: PartyRecord = {
      id: row.id,
      name: row.name,
      legal_name: row.legalName,
      alias: row.alias,
      mobile: row.mobile,
      email: row.email,
      party_type: row.partyType,
      party_category: row.partyCategory,
      party_group: row.partyGroup,
      area_code: row.areaCode,
      pricing_tier: row.pricingTier,
      default_price_tier: row.pricingTier,
      gstin: row.gstin,
      state_code: row.stateCode,
      state: row.stateCode ? resolveStateName(row.stateCode) : null,
      area_id: row.areaId,
      credit_limit: row.creditLimit,
      opening_balance: openingBalance,
      balance: ledgerBalance,
      is_active: row.isActive,
      notes: row.notes,
      profile_image_url: row.profileImageUrl,
      profile_media_asset_id: row.profileMediaAssetId,
      additional_phones: options?.additionalPhones ?? [],
      created_at: row.createdAt.toISOString(),
      updated_at: row.updatedAt.toISOString(),
    };

    if (options?.includeHiddenLedgerBalance) {
      record.hidden_ledger_balance = row.hiddenLedgerBalance;
    }

    return record;
  }
}
