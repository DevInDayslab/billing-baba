import type { FastifyInstance } from 'fastify';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { BusinessRepository } from './business.repository';
import type { BusinessDetail, BusinessListItem } from './business.types';
import type { CreateBusinessBody } from './business.schema';

export class BusinessService {
  private readonly repository: BusinessRepository;

  constructor(private readonly app: FastifyInstance) {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new BusinessRepository(db);
  }

  async listBusinesses(accountId: string): Promise<BusinessListItem[]> {
    return this.repository.listByAccountId(accountId);
  }

  async createBusiness(
    accountId: string,
    accountPhone: string,
    input: CreateBusinessBody,
  ): Promise<BusinessDetail> {
    const business = await this.repository.createWithBootstrap(
      accountId,
      input,
      accountPhone,
    );

    return business;
  }
}
