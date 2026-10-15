import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { PurchasesServiceBase } from '../purchases/purchases.base-service';
import { IncomeItemRepository } from './income-item.repository';
import type {
  CreateIncomeItemBody,
  ListIncomeItemsQuery,
  UpdateIncomeItemBody,
} from './income-item.schema';
import type { IncomeItemRecord } from './income-item.types';

export class IncomeItemService extends PurchasesServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: IncomeItemRepository;

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
    this.repository = new IncomeItemRepository(db);
  }

  async listItems(
    businessId: string,
    accountId: string,
    query: ListIncomeItemsQuery,
  ): Promise<{
    data: IncomeItemRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      sort: query.sort,
      order: query.order,
    });
    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getItem(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<IncomeItemRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const item = await this.repository.findById(businessId, itemId);
    if (!item) {
      throw new AppError('NOT_FOUND', 'Income item not found', 404);
    }
    return item;
  }

  async createItem(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateIncomeItemBody,
  ): Promise<IncomeItemRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const name = input.name.trim();
    await this.assertNameAvailable(businessId, name);
    return this.repository.create({
      businessId,
      name,
      hsnSac: input.hsn_sac?.trim() || null,
      price: input.price ?? '0',
      priceIsTaxInclusive: input.price_is_tax_inclusive ?? false,
      taxRate: input.tax_rate ?? '0',
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateItem(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    input: UpdateIncomeItemBody,
  ): Promise<IncomeItemRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    if (input.name !== undefined) {
      await this.assertNameAvailable(businessId, input.name.trim(), itemId);
    }

    const updated = await this.repository.update(businessId, itemId, {
      ...(input.name !== undefined ? { name: input.name.trim() } : {}),
      ...(input.hsn_sac !== undefined
        ? { hsnSac: input.hsn_sac?.trim() || null }
        : {}),
      ...(input.price !== undefined ? { price: input.price } : {}),
      ...(input.price_is_tax_inclusive !== undefined
        ? { priceIsTaxInclusive: input.price_is_tax_inclusive }
        : {}),
      ...(input.tax_rate !== undefined ? { taxRate: input.tax_rate } : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Income item not found', 404);
    }
    return updated;
  }

  async deleteItem(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    const deleted = await this.repository.softDelete(
      businessId,
      itemId,
      userId ?? null,
    );
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Income item not found', 404);
    }
  }

  private async assertNameAvailable(
    businessId: string,
    name: string,
    excludeItemId?: string,
  ): Promise<void> {
    const conflict = await this.repository.findActiveNameConflict(
      businessId,
      name,
      excludeItemId,
    );
    if (conflict) {
      throw new AppError(
        'CONFLICT',
        'An income item with this name already exists',
        409,
      );
    }
  }
}
