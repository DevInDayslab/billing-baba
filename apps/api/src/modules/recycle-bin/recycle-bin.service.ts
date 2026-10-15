import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import type { RecycleBinEntityType } from './recycle-bin.constants';
import { RecycleBinLifecycleService } from './recycle-bin-lifecycle.service';
import { RecycleBinRepository } from './recycle-bin.repository';
import type { RecycleBinListQuery } from './recycle-bin.schema';
import type { RecycleBinItemRecord } from './recycle-bin.types';

export class RecycleBinService {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: RecycleBinRepository;
  private readonly lifecycle: RecycleBinLifecycleService;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = db;
    this.repository = new RecycleBinRepository(db);
    this.lifecycle = new RecycleBinLifecycleService();
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.repository.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!hasAccess) {
      throw new AppError(
        'FORBIDDEN',
        'You do not have access to this business',
        403,
      );
    }
  }

  async list(
    businessId: string,
    accountId: string,
    query: RecycleBinListQuery,
  ): Promise<{ data: RecycleBinItemRecord[]; meta: { page: number; limit: number; total: number } }> {
    await this.assertBusinessAccess(businessId, accountId);
    const result = await this.repository.list(businessId, {
      page: query.page,
      limit: query.limit,
      entityType: query.entity_type,
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

  async restore(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    entityType: RecycleBinEntityType,
    entityId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.lifecycle.restoreEntity(entityType, {
      businessId,
      accountId,
      userId,
    }, entityId);
  }

  async purge(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    entityType: RecycleBinEntityType,
    entityId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.lifecycle.purgeEntity(entityType, {
      businessId,
      accountId,
      userId,
    }, entityId);
  }

  async deleteEntity(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    entityType: RecycleBinEntityType,
    entityId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.lifecycle.deleteEntity(entityType, {
      businessId,
      accountId,
      userId,
    }, entityId);
  }
}
