import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { BusinessRepository } from './business.repository';
import type {
  CreateBusinessBody,
  UpdateBusinessProfileBody,
} from './business.schema';
import type {
  BusinessDetail,
  BusinessListItem,
  BusinessProfile,
} from './business.types';

export class BusinessService {
  private readonly repository: BusinessRepository;

  constructor() {
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

  async getProfile(
    businessId: string,
    accountId: string,
  ): Promise<BusinessProfile> {
    const profile = await this.repository.getProfile(businessId, accountId);
    if (!profile) {
      throw new AppError(
        'BUSINESS_NOT_FOUND',
        'Business not found or you do not have access',
        404,
      );
    }
    return profile;
  }

  async updateProfile(
    businessId: string,
    accountId: string,
    input: UpdateBusinessProfileBody,
  ): Promise<BusinessProfile> {
    try {
      const profile = await this.repository.updateProfile(
        businessId,
        accountId,
        input,
      );
      if (!profile) {
        throw new AppError(
          'BUSINESS_NOT_FOUND',
          'Business not found or you do not have access',
          404,
        );
      }
      return profile;
    } catch (error) {
      if (error instanceof Error && error.message === 'GSTIN_ALREADY_EXISTS') {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          gstin: ['This GSTIN is already registered to another business'],
        });
      }
      throw error;
    }
  }
}
