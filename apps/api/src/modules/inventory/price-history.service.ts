import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import { PriceHistoryRepository } from './price-history.repository';
import type { ListPriceHistoryQuery } from './price-history.schema';
import type { PriceHistoryRecord } from './price-history.types';

export class PriceHistoryService extends InventoryServiceBase {
  private readonly repository: PriceHistoryRepository;

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
    this.repository = new PriceHistoryRepository(db);
  }

  async listPriceHistory(
    businessId: string,
    accountId: string,
    query: ListPriceHistoryQuery,
  ): Promise<{
    data: PriceHistoryRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      itemId: query.item_id,
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

  async getPriceHistory(
    businessId: string,
    accountId: string,
    historyId: string,
  ): Promise<PriceHistoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const record = await this.repository.findById(businessId, historyId);
    if (!record) {
      throw new AppError('NOT_FOUND', 'Price history record not found', 404);
    }

    return record;
  }
}
