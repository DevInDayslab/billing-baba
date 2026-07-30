import { and, asc, count, desc, eq, ilike, ne, or, sql } from 'drizzle-orm';
import { alias } from 'drizzle-orm/pg-core';
import type { Database } from '../../db/client';
import {
  items,
  unitConversions,
  unitDefinitions,
} from '../../db/schema/inventory/tables';
import { toUnitListRecord, toUnitRecord } from './unit.mapper';
import type {
  ListUnitsParams,
  UnitConversionRow,
  UnitInsertValues,
  UnitListRecord,
  UnitRecord,
  UnitRow,
  UnitUpdateValues,
} from './unit.types';

export class UnitRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListUnitsParams): Promise<{
    rows: UnitListRecord[];
    total: number;
  }> {
    const filters = [
      eq(unitDefinitions.businessId, params.businessId),
      eq(unitDefinitions.isDeleted, false),
    ];

    if (params.isActive !== undefined) {
      filters.push(eq(unitDefinitions.isActive, params.isActive));
    }

    if (params.q) {
      const pattern = `%${params.q}%`;
      const search = or(
        ilike(unitDefinitions.name, pattern),
        ilike(unitDefinitions.shortName, pattern),
        ilike(unitDefinitions.symbol, pattern),
      );
      if (search) filters.push(search);
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(unitDefinitions)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? unitDefinitions.createdAt
        : params.sort === 'short_name'
          ? unitDefinitions.shortName
          : unitDefinitions.name;

    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);

    const offset = (params.page - 1) * params.limit;

    const conversionCountSubquery = this.db
      .select({ total: count() })
      .from(unitConversions)
      .where(
        and(
          eq(unitConversions.businessId, params.businessId),
          eq(unitConversions.isDeleted, false),
          or(
            eq(unitConversions.fromUnitId, unitDefinitions.id),
            eq(unitConversions.toUnitId, unitDefinitions.id),
          ),
        ),
      );

    const rows = await this.db
      .select({
        id: unitDefinitions.id,
        name: unitDefinitions.name,
        shortName: unitDefinitions.shortName,
        symbol: unitDefinitions.symbol,
        decimalPlaces: unitDefinitions.decimalPlaces,
        isSystem: unitDefinitions.isSystem,
        isActive: unitDefinitions.isActive,
        conversionCount: sql<number>`(${conversionCountSubquery})`.mapWith(
          Number,
        ),
        createdAt: unitDefinitions.createdAt,
        updatedAt: unitDefinitions.updatedAt,
      })
      .from(unitDefinitions)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toUnitListRecord(row as UnitRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    unitId: string,
  ): Promise<UnitRecord | null> {
    const row = await this.findRowById(businessId, unitId);
    if (!row) return null;

    const conversions = await this.loadConversionsForFromUnit(
      businessId,
      unitId,
    );
    return toUnitRecord(row, conversions);
  }

  async findRowById(
    businessId: string,
    unitId: string,
  ): Promise<UnitRow | null> {
    const conversionCountSubquery = this.db
      .select({ total: count() })
      .from(unitConversions)
      .where(
        and(
          eq(unitConversions.businessId, businessId),
          eq(unitConversions.isDeleted, false),
          or(
            eq(unitConversions.fromUnitId, unitDefinitions.id),
            eq(unitConversions.toUnitId, unitDefinitions.id),
          ),
        ),
      );

    const [row] = await this.db
      .select({
        id: unitDefinitions.id,
        name: unitDefinitions.name,
        shortName: unitDefinitions.shortName,
        symbol: unitDefinitions.symbol,
        decimalPlaces: unitDefinitions.decimalPlaces,
        isSystem: unitDefinitions.isSystem,
        isActive: unitDefinitions.isActive,
        conversionCount: sql<number>`(${conversionCountSubquery})`.mapWith(
          Number,
        ),
        createdAt: unitDefinitions.createdAt,
        updatedAt: unitDefinitions.updatedAt,
      })
      .from(unitDefinitions)
      .where(
        and(
          eq(unitDefinitions.id, unitId),
          eq(unitDefinitions.businessId, businessId),
          eq(unitDefinitions.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? (row as UnitRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeUnitId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(unitDefinitions.businessId, businessId),
      eq(unitDefinitions.isDeleted, false),
      sql`lower(${unitDefinitions.name}) = lower(${name})`,
    ];
    if (excludeUnitId) conditions.push(ne(unitDefinitions.id, excludeUnitId));

    const [row] = await this.db
      .select({ id: unitDefinitions.id })
      .from(unitDefinitions)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async findActiveShortNameConflict(
    businessId: string,
    shortName: string,
    excludeUnitId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(unitDefinitions.businessId, businessId),
      eq(unitDefinitions.isDeleted, false),
      sql`lower(${unitDefinitions.shortName}) = lower(${shortName})`,
    ];
    if (excludeUnitId) conditions.push(ne(unitDefinitions.id, excludeUnitId));

    const [row] = await this.db
      .select({ id: unitDefinitions.id })
      .from(unitDefinitions)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async create(values: UnitInsertValues): Promise<UnitRecord> {
    const [row] = await this.db
      .insert(unitDefinitions)
      .values({
        businessId: values.businessId,
        name: values.name,
        shortName: values.shortName,
        symbol: values.symbol ?? null,
        decimalPlaces: values.decimalPlaces,
        isSystem: values.isSystem,
        isActive: values.isActive,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: unitDefinitions.id,
        name: unitDefinitions.name,
        shortName: unitDefinitions.shortName,
        symbol: unitDefinitions.symbol,
        decimalPlaces: unitDefinitions.decimalPlaces,
        isSystem: unitDefinitions.isSystem,
        isActive: unitDefinitions.isActive,
        createdAt: unitDefinitions.createdAt,
        updatedAt: unitDefinitions.updatedAt,
      });

    if (!row) throw new Error('Failed to create unit');

    const created = await this.findById(values.businessId, row.id);
    if (!created) throw new Error('Failed to load created unit');

    return created;
  }

  async update(
    businessId: string,
    unitId: string,
    values: UnitUpdateValues,
  ): Promise<UnitRecord | null> {
    const [row] = await this.db
      .update(unitDefinitions)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.shortName !== undefined
          ? { shortName: values.shortName }
          : {}),
        ...(values.symbol !== undefined ? { symbol: values.symbol } : {}),
        ...(values.decimalPlaces !== undefined
          ? { decimalPlaces: values.decimalPlaces }
          : {}),
        ...(values.isSystem !== undefined ? { isSystem: values.isSystem } : {}),
        ...(values.isActive !== undefined ? { isActive: values.isActive } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${unitDefinitions.syncVersion} + 1`,
      })
      .where(
        and(
          eq(unitDefinitions.id, unitId),
          eq(unitDefinitions.businessId, businessId),
          eq(unitDefinitions.isDeleted, false),
        ),
      )
      .returning({
        id: unitDefinitions.id,
        name: unitDefinitions.name,
        shortName: unitDefinitions.shortName,
        symbol: unitDefinitions.symbol,
        decimalPlaces: unitDefinitions.decimalPlaces,
        isSystem: unitDefinitions.isSystem,
        isActive: unitDefinitions.isActive,
        createdAt: unitDefinitions.createdAt,
        updatedAt: unitDefinitions.updatedAt,
      });

    if (!row) return null;

    const conversions = await this.loadConversionsForFromUnit(
      businessId,
      unitId,
    );
    return toUnitRecord(row as UnitRow, conversions);
  }

  async softDelete(
    businessId: string,
    unitId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(unitDefinitions)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${unitDefinitions.syncVersion} + 1`,
      })
      .where(
        and(
          eq(unitDefinitions.id, unitId),
          eq(unitDefinitions.businessId, businessId),
          eq(unitDefinitions.isDeleted, false),
        ),
      )
      .returning({ id: unitDefinitions.id });

    return Boolean(row);
  }

  async countActiveConversionReferences(
    businessId: string,
    unitId: string,
  ): Promise<number> {
    const [result] = await this.db
      .select({ total: count() })
      .from(unitConversions)
      .where(
        and(
          eq(unitConversions.businessId, businessId),
          eq(unitConversions.isDeleted, false),
          or(
            eq(unitConversions.fromUnitId, unitId),
            eq(unitConversions.toUnitId, unitId),
          ),
        ),
      );

    return Number(result?.total ?? 0);
  }

  async countActiveItemReferences(
    businessId: string,
    shortName: string,
  ): Promise<number> {
    const [result] = await this.db
      .select({ total: count() })
      .from(items)
      .where(
        and(
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
          sql`lower(${items.baseUnit}) = lower(${shortName})`,
        ),
      );

    return Number(result?.total ?? 0);
  }

  async loadConversionsForFromUnit(
    businessId: string,
    fromUnitId: string,
  ): Promise<UnitConversionRow[]> {
    const fromUnit = alias(unitDefinitions, 'from_unit');
    const toUnit = alias(unitDefinitions, 'to_unit');

    const rows = await this.db
      .select({
        id: unitConversions.id,
        fromUnitId: unitConversions.fromUnitId,
        toUnitId: unitConversions.toUnitId,
        conversionFactor: unitConversions.conversionFactor,
        fromUnitName: fromUnit.name,
        toUnitName: toUnit.name,
        createdAt: unitConversions.createdAt,
        updatedAt: unitConversions.updatedAt,
      })
      .from(unitConversions)
      .innerJoin(fromUnit, eq(unitConversions.fromUnitId, fromUnit.id))
      .innerJoin(toUnit, eq(unitConversions.toUnitId, toUnit.id))
      .where(
        and(
          eq(unitConversions.businessId, businessId),
          eq(unitConversions.fromUnitId, fromUnitId),
          eq(unitConversions.isDeleted, false),
        ),
      );

    return rows as UnitConversionRow[];
  }
}
