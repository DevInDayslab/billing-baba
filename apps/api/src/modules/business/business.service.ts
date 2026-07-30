import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { BusinessBrandingService } from './business-branding.service';
import { BusinessRepository } from './business.repository';
import type {
  CreateBusinessBody,
  UpdateBusinessProfileBody,
} from './business.schema';
import type { UpdateCommerceSettingsBody } from './business-commerce-settings.schema';
import type {
  BusinessDetail,
  BusinessListItem,
  BusinessProfile,
  CommerceSettings,
} from './business.types';

export class BusinessService {
  private readonly repository: BusinessRepository;
  private readonly branding: BusinessBrandingService | null;

  constructor(config?: AppConfig) {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new BusinessRepository(db);
    this.branding = config ? new BusinessBrandingService({ config }) : null;
  }

  async listBusinesses(accountId: string): Promise<BusinessListItem[]> {
    const items = await this.repository.listByAccountId(accountId);
    if (!this.branding) {
      return items.map(({ logoMediaAssetId: _ignored, ...item }) => item);
    }
    return this.branding.enrichListItemsWithBrandingUrls(accountId, items);
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
    if (!this.branding) {
      return profile;
    }
    return this.branding.enrichProfileWithBrandingUrls(
      businessId,
      accountId,
      profile,
    );
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
      if (!this.branding) {
        return profile;
      }
      return this.branding.enrichProfileWithBrandingUrls(
        businessId,
        accountId,
        profile,
      );
    } catch (error) {
      if (error instanceof Error && error.message === 'GSTIN_ALREADY_EXISTS') {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          gstin: ['This GSTIN is already registered to another business'],
        });
      }
      throw error;
    }
  }

  async getCommerceSettings(
    businessId: string,
    accountId: string,
  ): Promise<CommerceSettings> {
    const settings = await this.repository.getCommerceSettings(
      businessId,
      accountId,
    );
    if (!settings) {
      throw new AppError(
        'BUSINESS_NOT_FOUND',
        'Business not found or you do not have access',
        404,
      );
    }
    return settings;
  }

  async updateCommerceSettings(
    businessId: string,
    accountId: string,
    input: UpdateCommerceSettingsBody,
  ): Promise<CommerceSettings> {
    const settings = await this.repository.updateCommerceSettings(
      businessId,
      accountId,
      input,
    );
    if (!settings) {
      throw new AppError(
        'BUSINESS_NOT_FOUND',
        'Business not found or you do not have access',
        404,
      );
    }
    return settings;
  }

  async deleteBusiness(businessId: string, accountId: string): Promise<void> {
    const deleted = await this.repository.softDelete(businessId, accountId);
    if (!deleted) {
      throw new AppError(
        'BUSINESS_NOT_FOUND',
        'Business not found or you do not have access',
        404,
      );
    }
  }
}
