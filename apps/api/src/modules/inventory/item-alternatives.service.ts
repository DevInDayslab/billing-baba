import { and, eq, ne, notInArray, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { getDb } from '../../db/client';
import {
  brands,
  categories,
  items,
  stockLevels,
} from '../../db/schema/inventory/tables';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import {
  type AlternativeRecord,
  ItemAlternativesRepository,
} from './item-alternatives.repository';

type RecommendedItem = {
  id: string;
  name: string;
  barcode: string | null;
  brandName: string | null;
  categoryName: string | null;
  salePrice: string;
  stockQuantity: number;
};

export class ItemAlternativesService extends InventoryServiceBase {
  private readonly repository: ItemAlternativesRepository;
  private readonly db: Database;

  constructor() {
    super();
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = db;
    this.repository = new ItemAlternativesRepository(db);
  }

  async listAlternatives(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<AlternativeRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
    return this.repository.listByItemId(businessId, itemId);
  }

  async addAlternative(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    alternativeItemId: string,
  ): Promise<AlternativeRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);

    if (itemId === alternativeItemId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        alternative_item_id: ['Item cannot be an alternative to itself'],
      });
    }

    await this.assertItemExists(businessId, itemId);
    await this.assertItemExists(businessId, alternativeItemId);

    const existing = await this.repository.findPair(
      businessId,
      itemId,
      alternativeItemId,
    );
    if (existing) {
      throw new AppError(
        'DUPLICATE_ALTERNATIVE',
        'This alternative already exists',
        422,
      );
    }

    const circular = await this.repository.findPair(
      businessId,
      alternativeItemId,
      itemId,
    );
    if (circular) {
      throw new AppError(
        'CIRCULAR_ALTERNATIVE_MAPPING',
        'Circular alternative mapping detected',
        422,
      );
    }

    await this.repository.create({
      businessId,
      itemId,
      alternativeItemId,
      createdBy: userId ?? null,
    });

    return this.repository.listByItemId(businessId, itemId);
  }

  async removeAlternative(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    alternativeItemId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.repository.softDelete(
      businessId,
      itemId,
      alternativeItemId,
      userId ?? null,
    );
  }

  async reorderAlternatives(
    businessId: string,
    accountId: string,
    itemId: string,
    orderedIds: string[],
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.repository.reorder(businessId, itemId, orderedIds);
  }

  async getRecommendations(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<{
    manuallyConfigured: AlternativeRecord[];
    sameBrandCategory: RecommendedItem[];
    sameCategory: RecommendedItem[];
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const [sourceItem] = await this.db
      .select({
        id: items.id,
        brandId: items.brandId,
        categoryId: items.categoryId,
      })
      .from(items)
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .limit(1);

    if (!sourceItem) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }

    const manuallyConfigured = await this.repository.listByItemId(
      businessId,
      itemId,
    );
    const manuallyConfiguredIds = manuallyConfigured.map(
      (alt) => alt.alternativeItemId,
    );

    let sameBrandCategory: RecommendedItem[] = [];
    let sameCategory: RecommendedItem[] = [];

    if (sourceItem.brandId && sourceItem.categoryId) {
      const sameBrandCategoryRows = await this.db
        .select({
          id: items.id,
          name: items.name,
          barcode: items.barcode,
          salePrice: items.salePrice,
          brandName: brands.name,
          categoryName: categories.name,
          stockQuantity: sql<string>`COALESCE(SUM(${stockLevels.quantity}::numeric), 0)`,
        })
        .from(items)
        .leftJoin(
          brands,
          and(eq(items.brandId, brands.id), eq(brands.isDeleted, false)),
        )
        .leftJoin(
          categories,
          and(
            eq(items.categoryId, categories.id),
            eq(categories.isDeleted, false),
          ),
        )
        .leftJoin(
          stockLevels,
          and(
            eq(stockLevels.itemId, items.id),
            eq(stockLevels.businessId, businessId),
            eq(stockLevels.isDeleted, false),
          ),
        )
        .where(
          and(
            eq(items.businessId, businessId),
            eq(items.brandId, sourceItem.brandId),
            eq(items.categoryId, sourceItem.categoryId),
            ne(items.id, itemId),
            eq(items.isDeleted, false),
          ),
        )
        .groupBy(
          items.id,
          items.name,
          items.barcode,
          items.salePrice,
          brands.name,
          categories.name,
        )
        .limit(10);

      sameBrandCategory = sameBrandCategoryRows.map((row) => ({
        id: row.id,
        name: row.name,
        barcode: row.barcode,
        brandName: row.brandName,
        categoryName: row.categoryName,
        salePrice: row.salePrice,
        stockQuantity: Number(row.stockQuantity),
      }));
    }

    const sameBrandCategoryIds = sameBrandCategory.map((item) => item.id);
    const excludeIds = [
      ...manuallyConfiguredIds,
      ...sameBrandCategoryIds,
      itemId,
    ];

    if (sourceItem.categoryId) {
      const sameCategoryRows = await this.db
        .select({
          id: items.id,
          name: items.name,
          barcode: items.barcode,
          salePrice: items.salePrice,
          brandName: brands.name,
          categoryName: categories.name,
          stockQuantity: sql<string>`COALESCE(SUM(${stockLevels.quantity}::numeric), 0)`,
        })
        .from(items)
        .leftJoin(
          brands,
          and(eq(items.brandId, brands.id), eq(brands.isDeleted, false)),
        )
        .leftJoin(
          categories,
          and(
            eq(items.categoryId, categories.id),
            eq(categories.isDeleted, false),
          ),
        )
        .leftJoin(
          stockLevels,
          and(
            eq(stockLevels.itemId, items.id),
            eq(stockLevels.businessId, businessId),
            eq(stockLevels.isDeleted, false),
          ),
        )
        .where(
          and(
            eq(items.businessId, businessId),
            eq(items.categoryId, sourceItem.categoryId),
            notInArray(items.id, excludeIds),
            eq(items.isDeleted, false),
          ),
        )
        .groupBy(
          items.id,
          items.name,
          items.barcode,
          items.salePrice,
          brands.name,
          categories.name,
        )
        .limit(10);

      sameCategory = sameCategoryRows.map((row) => ({
        id: row.id,
        name: row.name,
        barcode: row.barcode,
        brandName: row.brandName,
        categoryName: row.categoryName,
        salePrice: row.salePrice,
        stockQuantity: Number(row.stockQuantity),
      }));
    }

    return {
      manuallyConfigured,
      sameBrandCategory,
      sameCategory,
    };
  }

  private async assertItemExists(
    businessId: string,
    itemId: string,
  ): Promise<void> {
    const [item] = await this.db
      .select({ id: items.id })
      .from(items)
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .limit(1);

    if (!item) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }
  }
}
