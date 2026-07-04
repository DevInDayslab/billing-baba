import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import { StockLevelRepository } from './stock-level.repository';
import type { ListStockLevelsQuery } from './stock-level.schema';
import type { StockLevelRecord } from './stock-level.types';

export class StockLevelService extends InventoryServiceBase {
  private readonly repository: StockLevelRepository;

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
    this.repository = new StockLevelRepository(db);
  }

  async listStockLevels(
    businessId: string,
    accountId: string,
    query: ListStockLevelsQuery,
  ): Promise<{
    data: StockLevelRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      itemId: query.item_id,
      godownId: query.godown_id,
      lowStock: query.low_stock,
      q: query.q,
      sort: query.sort,
      order: query.order,
    });

    return {
      data: result.rows,
      meta: {
        page: query.page,
        limit: query.limit,
        total: result.total,
      },
    };
  }

  async getStockLevel(
    businessId: string,
    accountId: string,
    stockLevelId: string,
  ): Promise<StockLevelRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const stockLevel = await this.repository.findById(businessId, stockLevelId);
    if (!stockLevel) {
      throw new AppError('NOT_FOUND', 'Stock level not found', 404);
    }

    return stockLevel;
  }
}
