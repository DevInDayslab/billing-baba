import { and, asc, count, desc, eq, ilike, ne, sql, sum } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  incomeItems,
  otherIncomes,
} from '../../db/schema/other-income/tables';
import { toIncomeItemRecord } from './income-item.mapper';
import type {
  IncomeItemInsertValues,
  IncomeItemRecord,
  IncomeItemRow,
  IncomeItemUpdateValues,
  ListIncomeItemsParams,
} from './income-item.types';

export class IncomeItemRepository {
  constructor(private readonly db: Database) {}

  private incomeCountSubquery() {
    return this.db
      .select({ total: count() })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.incomeItemId, incomeItems.id),
          eq(otherIncomes.businessId, incomeItems.businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );
  }

  private incomeTotalSubquery() {
    return this.db
      .select({ total: sum(otherIncomes.amount) })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.incomeItemId, incomeItems.id),
          eq(otherIncomes.businessId, incomeItems.businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );
  }

  async list(params: ListIncomeItemsParams): Promise<{
    rows: IncomeItemRecord[];
    total: number;
  }> {
    const filters = [
      eq(incomeItems.businessId, params.businessId),
      eq(incomeItems.isDeleted, false),
    ];

    if (params.q) {
      filters.push(ilike(incomeItems.name, `%${params.q}%`));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(incomeItems)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? incomeItems.createdAt
        : params.sort === 'price'
          ? incomeItems.price
          : incomeItems.name;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: incomeItems.id,
        name: incomeItems.name,
        hsnSac: incomeItems.hsnSac,
        price: incomeItems.price,
        priceIsTaxInclusive: incomeItems.priceIsTaxInclusive,
        taxRate: incomeItems.taxRate,
        incomeCount: sql<number>`(${this.incomeCountSubquery()})`.mapWith(
          Number,
        ),
        totalAmount: sql<string>`coalesce((${this.incomeTotalSubquery()}), '0')`,
        createdAt: incomeItems.createdAt,
        updatedAt: incomeItems.updatedAt,
      })
      .from(incomeItems)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toIncomeItemRecord(row as IncomeItemRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    itemId: string,
  ): Promise<IncomeItemRecord | null> {
    const [row] = await this.db
      .select({
        id: incomeItems.id,
        name: incomeItems.name,
        hsnSac: incomeItems.hsnSac,
        price: incomeItems.price,
        priceIsTaxInclusive: incomeItems.priceIsTaxInclusive,
        taxRate: incomeItems.taxRate,
        incomeCount: sql<number>`(${this.incomeCountSubquery()})`.mapWith(
          Number,
        ),
        totalAmount: sql<string>`coalesce((${this.incomeTotalSubquery()}), '0')`,
        createdAt: incomeItems.createdAt,
        updatedAt: incomeItems.updatedAt,
      })
      .from(incomeItems)
      .where(
        and(
          eq(incomeItems.id, itemId),
          eq(incomeItems.businessId, businessId),
          eq(incomeItems.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toIncomeItemRecord(row as IncomeItemRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeItemId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(incomeItems.businessId, businessId),
      eq(incomeItems.isDeleted, false),
      sql`lower(${incomeItems.name}) = lower(${name})`,
    ];
    if (excludeItemId) {
      conditions.push(ne(incomeItems.id, excludeItemId));
    }

    const [row] = await this.db
      .select({ id: incomeItems.id })
      .from(incomeItems)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async create(values: IncomeItemInsertValues): Promise<IncomeItemRecord> {
    const [row] = await this.db
      .insert(incomeItems)
      .values({
        businessId: values.businessId,
        name: values.name,
        hsnSac: values.hsnSac ?? null,
        price: values.price ?? '0',
        priceIsTaxInclusive: values.priceIsTaxInclusive ?? false,
        taxRate: values.taxRate ?? '0',
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: incomeItems.id,
        name: incomeItems.name,
        hsnSac: incomeItems.hsnSac,
        price: incomeItems.price,
        priceIsTaxInclusive: incomeItems.priceIsTaxInclusive,
        taxRate: incomeItems.taxRate,
        createdAt: incomeItems.createdAt,
        updatedAt: incomeItems.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create income item');
    }

    return toIncomeItemRecord({
      ...row,
      incomeCount: 0,
      totalAmount: '0',
    });
  }

  async update(
    businessId: string,
    itemId: string,
    values: IncomeItemUpdateValues,
  ): Promise<IncomeItemRecord | null> {
    const [row] = await this.db
      .update(incomeItems)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.hsnSac !== undefined ? { hsnSac: values.hsnSac } : {}),
        ...(values.price !== undefined ? { price: values.price } : {}),
        ...(values.priceIsTaxInclusive !== undefined
          ? { priceIsTaxInclusive: values.priceIsTaxInclusive }
          : {}),
        ...(values.taxRate !== undefined ? { taxRate: values.taxRate } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${incomeItems.syncVersion} + 1`,
      })
      .where(
        and(
          eq(incomeItems.id, itemId),
          eq(incomeItems.businessId, businessId),
          eq(incomeItems.isDeleted, false),
        ),
      )
      .returning({
        id: incomeItems.id,
        name: incomeItems.name,
        hsnSac: incomeItems.hsnSac,
        price: incomeItems.price,
        priceIsTaxInclusive: incomeItems.priceIsTaxInclusive,
        taxRate: incomeItems.taxRate,
        createdAt: incomeItems.createdAt,
        updatedAt: incomeItems.updatedAt,
      });

    if (!row) return null;

    const incomeCount = await this.countLinkedIncomes(businessId, itemId);
    const [totalRow] = await this.db
      .select({ total: sum(otherIncomes.amount) })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.incomeItemId, itemId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );

    return toIncomeItemRecord({
      ...row,
      incomeCount,
      totalAmount: totalRow?.total ?? '0',
    });
  }

  async countLinkedIncomes(
    businessId: string,
    itemId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({ total: count() })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.incomeItemId, itemId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );
    return Number(row?.total ?? 0);
  }

  async softDelete(
    businessId: string,
    itemId: string,
    userId: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(incomeItems)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${incomeItems.syncVersion} + 1`,
      })
      .where(
        and(
          eq(incomeItems.id, itemId),
          eq(incomeItems.businessId, businessId),
          eq(incomeItems.isDeleted, false),
        ),
      )
      .returning({ id: incomeItems.id });

    return Boolean(row);
  }
}
