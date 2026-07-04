import { and, count, eq, ne, or, sql } from 'drizzle-orm';
import { alias } from 'drizzle-orm/pg-core';
import type { Database } from '../../db/client';
import {
  unitConversions,
  unitDefinitions,
} from '../../db/schema/inventory/tables';
import { toUnitConversionRecordDto } from './unit.mapper';
import type {
  ListUnitConversionsParams,
  UnitConversionInsertValues,
  UnitConversionRecordDto,
  UnitConversionUpdateValues,
} from './unit.types';

export class UnitConversionRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListUnitConversionsParams): Promise<{
    rows: UnitConversionRecordDto[];
    total: number;
  }> {
    const filters = [
      eq(unitConversions.businessId, params.businessId),
      eq(unitConversions.isDeleted, false),
    ];

    if (params.fromUnitId) {
      filters.push(eq(unitConversions.fromUnitId, params.fromUnitId));
    }
    if (params.toUnitId) {
      filters.push(eq(unitConversions.toUnitId, params.toUnitId));
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(unitConversions)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.selectConversionRows(whereClause)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toUnitConversionRecordDto(row)),
      total,
    };
  }

  async findById(
    businessId: string,
    conversionId: string,
  ): Promise<UnitConversionRecordDto | null> {
    const [row] = await this.selectConversionRows(
      and(
        eq(unitConversions.id, conversionId),
        eq(unitConversions.businessId, businessId),
        eq(unitConversions.isDeleted, false),
      ),
    ).limit(1);

    return row ? toUnitConversionRecordDto(row) : null;
  }

  async findActivePairConflict(
    businessId: string,
    fromUnitId: string,
    toUnitId: string,
    excludeConversionId?: string,
  ): Promise<string | null> {
    const forward = and(
      eq(unitConversions.businessId, businessId),
      eq(unitConversions.isDeleted, false),
      eq(unitConversions.fromUnitId, fromUnitId),
      eq(unitConversions.toUnitId, toUnitId),
    );

    const reverse = and(
      eq(unitConversions.businessId, businessId),
      eq(unitConversions.isDeleted, false),
      eq(unitConversions.fromUnitId, toUnitId),
      eq(unitConversions.toUnitId, fromUnitId),
    );

    const conditions = [or(forward, reverse)];
    if (excludeConversionId) {
      conditions.push(ne(unitConversions.id, excludeConversionId));
    }

    const [row] = await this.db
      .select({ id: unitConversions.id })
      .from(unitConversions)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async create(
    values: UnitConversionInsertValues,
  ): Promise<UnitConversionRecordDto> {
    const [row] = await this.db
      .insert(unitConversions)
      .values({
        businessId: values.businessId,
        fromUnitId: values.fromUnitId,
        toUnitId: values.toUnitId,
        conversionFactor: values.conversionFactor,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({ id: unitConversions.id });

    if (!row) throw new Error('Failed to create unit conversion');

    const created = await this.findById(values.businessId, row.id);
    if (!created) throw new Error('Failed to load created unit conversion');

    return created;
  }

  async update(
    businessId: string,
    conversionId: string,
    values: UnitConversionUpdateValues,
  ): Promise<UnitConversionRecordDto | null> {
    const [row] = await this.db
      .update(unitConversions)
      .set({
        ...(values.fromUnitId !== undefined
          ? { fromUnitId: values.fromUnitId }
          : {}),
        ...(values.toUnitId !== undefined ? { toUnitId: values.toUnitId } : {}),
        ...(values.conversionFactor !== undefined
          ? { conversionFactor: values.conversionFactor }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${unitConversions.syncVersion} + 1`,
      })
      .where(
        and(
          eq(unitConversions.id, conversionId),
          eq(unitConversions.businessId, businessId),
          eq(unitConversions.isDeleted, false),
        ),
      )
      .returning({ id: unitConversions.id });

    if (!row) return null;

    return this.findById(businessId, conversionId);
  }

  async softDelete(
    businessId: string,
    conversionId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(unitConversions)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${unitConversions.syncVersion} + 1`,
      })
      .where(
        and(
          eq(unitConversions.id, conversionId),
          eq(unitConversions.businessId, businessId),
          eq(unitConversions.isDeleted, false),
        ),
      )
      .returning({ id: unitConversions.id });

    return Boolean(row);
  }

  private selectConversionRows(
    whereClause: ReturnType<typeof and> | undefined,
  ) {
    const fromUnit = alias(unitDefinitions, 'from_unit');
    const toUnit = alias(unitDefinitions, 'to_unit');

    return this.db
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
          eq(fromUnit.isDeleted, false),
          eq(toUnit.isDeleted, false),
          whereClause,
        ),
      );
  }
}
