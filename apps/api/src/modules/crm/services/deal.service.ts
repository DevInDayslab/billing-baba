import { getDb } from '../../../db/client';
import { AppError } from '../../../shared/errors/app-error';
import { DealRepository } from '../db/deal.repository';
import type {
  CreateDealBody,
  ListDealsQuery,
  UpdateDealBody,
} from '../deal.schema';
import type { DealRecord } from '../deal.types';

export class DealService {
  private readonly repository: DealRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new DealRepository(db);
  }

  async listDeals(
    businessId: string,
    accountId: string,
    query: ListDealsQuery,
  ): Promise<{
    data: DealRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      accountName: query.account_name,
      assignedTo: query.assigned_to,
      stage: query.stage,
      from: query.from ? new Date(query.from) : undefined,
      to: query.to ? new Date(query.to) : undefined,
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

  async getDeal(
    businessId: string,
    accountId: string,
    dealId: string,
  ): Promise<DealRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const deal = await this.repository.findById(businessId, dealId);
    if (!deal) {
      throw new AppError('NOT_FOUND', 'Deal not found', 404);
    }

    return deal;
  }

  async createDeal(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateDealBody,
  ): Promise<DealRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    return this.repository.create({
      id: input.id,
      businessId,
      name: input.name,
      stage: input.stage,
      accountName: input.account_name ?? null,
      assignedTo: input.assigned_to ?? null,
      amount: input.amount !== undefined ? String(input.amount) : undefined,
      expectedCloseDate: input.expected_close_date ?? null,
      description: input.description ?? null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateDeal(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    dealId: string,
    input: UpdateDealBody,
  ): Promise<DealRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const updated = await this.repository.update(businessId, dealId, {
      name: input.name,
      stage: input.stage,
      accountName: input.account_name,
      assignedTo: input.assigned_to,
      amount: input.amount !== undefined ? String(input.amount) : undefined,
      expectedCloseDate: input.expected_close_date,
      description: input.description,
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Deal not found', 404);
    }

    return updated;
  }

  async deleteDeal(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    dealId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const deleted = await this.repository.softDelete(
      businessId,
      dealId,
      userId,
    );
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Deal not found', 404);
    }
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const allowed = await this.repository.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!allowed) {
      throw new AppError('FORBIDDEN', 'Access denied for this business', 403);
    }
  }
}
