import { and, asc, eq, ne, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { itemAlternatives } from '../../db/schema/inventory/item-alternatives.table';
import {
  brands,
  categories,
  items,
  stockLevels,
} from '../../db/schema/inventory/tables';

export type AlternativeRecord = {
  id: string;
  itemId: string;
  alternativeItemId: string;
  sortOrder: number;
  alternativeItem: {
    id: string;
    name: string;
    barcode: string | null;
    brandName: string | null;
    categoryName: string | null;
    salePrice: string;
    stockQuantity: number;
  };
};

export class ItemAlternativesRepository {
  constructor(private readonly db: Database) {}

  async listByItemId(
    businessId: string,
    itemId: string,
  ): Promise<AlternativeRecord[]> {
    let rows;
    try {
      rows = await this.db
        .select({
          id: itemAlternatives.id,
          itemId: itemAlternatives.itemId,
          alternativeItemId: itemAlternatives.alternativeItemId,
          sortOrder: itemAlternatives.sortOrder,
          alternativeItemName: items.name,
          alternativeItemBarcode: items.barcode,
          alternativeItemSalePrice: items.salePrice,
          brandId: items.brandId,
          categoryId: items.categoryId,
        })
        .from(itemAlternatives)
        .innerJoin(
          items,
          and(
            eq(itemAlternatives.alternativeItemId, items.id),
            eq(items.isDeleted, false),
          ),
        )
        .where(
          and(
            eq(itemAlternatives.businessId, businessId),
            eq(itemAlternatives.itemId, itemId),
            eq(itemAlternatives.isDeleted, false),
          ),
        )
        .orderBy(asc(itemAlternatives.sortOrder));
    } catch (error: any) {
      console.error('RAW DB ERROR:', {
        message: error.message,
        cause: error.cause,
        detail: error.detail,
        code: error.code,
        hint: error.hint,
      });
      throw error;
    }

    const results = await Promise.all(
      rows.map(async (row) => {
        const [stockResult, brand, category] = await Promise.all([
          this.db
            .select({
              total: sql<string>`COALESCE(SUM(${stockLevels.quantity}::numeric), 0)`,
            })
            .from(stockLevels)
            .where(
              and(
                eq(stockLevels.itemId, row.alternativeItemId),
                eq(stockLevels.businessId, businessId),
                eq(stockLevels.isDeleted, false),
              ),
            )
            .then((result) => result[0]),
          row.brandId
            ? this.db
                .select({ name: brands.name })
                .from(brands)
                .where(and(eq(brands.id, row.brandId), eq(brands.isDeleted, false)))
                .limit(1)
                .then((result) => result[0])
            : Promise.resolve(undefined),
          row.categoryId
            ? this.db
                .select({ name: categories.name })
                .from(categories)
                .where(
                  and(eq(categories.id, row.categoryId), eq(categories.isDeleted, false)),
                )
                .limit(1)
                .then((result) => result[0])
            : Promise.resolve(undefined),
        ]);

        return {
          id: row.id,
          itemId: row.itemId,
          alternativeItemId: row.alternativeItemId,
          sortOrder: row.sortOrder,
          alternativeItem: {
            id: row.alternativeItemId,
            name: row.alternativeItemName,
            barcode: row.alternativeItemBarcode,
            brandName: brand?.name ?? null,
            categoryName: category?.name ?? null,
            salePrice: row.alternativeItemSalePrice,
            stockQuantity: Number(stockResult?.total ?? 0),
          },
        };
      }),
    );

    return results;
  }

  async create(params: {
    businessId: string;
    itemId: string;
    alternativeItemId: string;
    createdBy: string | null;
  }): Promise<{ id: string }> {
    const [row] = await this.db
      .insert(itemAlternatives)
      .values({
        businessId: params.businessId,
        itemId: params.itemId,
        alternativeItemId: params.alternativeItemId,
        createdBy: params.createdBy,
        updatedBy: params.createdBy,
      })
      .returning({ id: itemAlternatives.id });

    if (!row) {
      throw new Error('Failed to create item alternative');
    }

    return row;
  }

  async findPair(
    businessId: string,
    itemId: string,
    alternativeItemId: string,
  ): Promise<{ id: string } | null> {
    const [row] = await this.db
      .select({ id: itemAlternatives.id })
      .from(itemAlternatives)
      .where(
        and(
          eq(itemAlternatives.businessId, businessId),
          eq(itemAlternatives.itemId, itemId),
          eq(itemAlternatives.alternativeItemId, alternativeItemId),
          eq(itemAlternatives.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async softDelete(
    businessId: string,
    itemId: string,
    alternativeItemId: string,
    userId: string | null,
  ): Promise<void> {
    await this.db
      .update(itemAlternatives)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: userId,
        syncVersion: sql`${itemAlternatives.syncVersion} + 1`,
      })
      .where(
        and(
          eq(itemAlternatives.businessId, businessId),
          eq(itemAlternatives.itemId, itemId),
          eq(itemAlternatives.alternativeItemId, alternativeItemId),
          eq(itemAlternatives.isDeleted, false),
        ),
      );
  }

  async reorder(
    businessId: string,
    itemId: string,
    orderedAlternativeItemIds: string[],
  ): Promise<void> {
    await this.db.transaction(async (tx) => {
      for (let i = 0; i < orderedAlternativeItemIds.length; i++) {
        const alternativeItemId = orderedAlternativeItemIds[i];
        if (!alternativeItemId) continue;

        await tx
          .update(itemAlternatives)
          .set({
            sortOrder: i,
            updatedAt: new Date(),
            syncVersion: sql`${itemAlternatives.syncVersion} + 1`,
          })
          .where(
            and(
              eq(itemAlternatives.businessId, businessId),
              eq(itemAlternatives.itemId, itemId),
              eq(itemAlternatives.alternativeItemId, alternativeItemId),
              eq(itemAlternatives.isDeleted, false),
            ),
          );
      }
    });
  }
}
