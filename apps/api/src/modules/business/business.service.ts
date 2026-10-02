import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { formatDatabaseError } from '../../shared/errors/database-error';
import { AuthService } from '../auth/auth.service';
import type { AuthSessionResponse } from '../auth/auth.types';
import { BusinessRepository } from './business.repository';
import type {
  CreateBusinessBody,
  UpdateBusinessProfileBody,
} from './business.schema';
import type {
  BusinessDetail,
  BusinessListItem,
  BusinessProfile,
  CommerceSettings,
  CreateBusinessResponse,
} from './business.types';
import { BusinessBrandingService } from './business-branding.service';
import type { UpdateCommerceSettingsBody } from './business-commerce-settings.schema';

function mapCreateBusinessError(error: unknown): AppError | unknown {
  if (error instanceof AppError) {
    return error;
  }

  if (error instanceof Error) {
    if (error.message === 'GSTIN_ALREADY_EXISTS') {
      return new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        gstin: ['This GSTIN is already registered to another business'],
      });
    }
    if (error.message === 'BUSINESS_NAME_ALREADY_EXISTS') {
      return new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        name: [
          'You already have a business with this name. Use a different name or open the existing one from your company list.',
        ],
      });
    }
  }

  const databaseError = formatDatabaseError(error);
  if (databaseError?.includes('uq_businesses_gstin')) {
    return new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
      gstin: ['This GSTIN is already registered to another business'],
    });
  }

  return error;
}

export class BusinessService {
  private readonly repository: BusinessRepository;
  private readonly branding: BusinessBrandingService | null;
  private readonly config: AppConfig | undefined;

  constructor(config?: AppConfig) {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.config = config;
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
    options?: {
      refreshToken?: string;
      app?: FastifyInstance;
    },
  ): Promise<CreateBusinessResponse> {
    try {
      const business = await this.repository.createWithBootstrap(
        accountId,
        input,
        accountPhone,
      );

      let auth: AuthSessionResponse | undefined;
      const refreshToken = options?.refreshToken?.trim();
      if (refreshToken && options?.app && this.config) {
        try {
          const authService = new AuthService(options.app, this.config);
          auth = await authService.refresh(refreshToken, business.id);
        } catch (error) {
          options.app.log.warn(
            { err: error, businessId: business.id },
            'Business created but session refresh failed',
          );
        }
      }

      return auth ? { ...business, auth } : business;
    } catch (error) {
      throw mapCreateBusinessError(error);
    }
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

  async scheduleBusinessDeletion(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const scheduled = await this.repository.scheduleDeletion(
      businessId,
      accountId,
    );
    if (!scheduled) {
      throw new AppError(
        'BUSINESS_NOT_FOUND',
        'Business not found or you do not have access',
        404,
      );
    }
  }

  async cancelScheduledBusinessDeletion(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const restored = await this.repository.cancelScheduledDeletion(
      businessId,
      accountId,
    );
    if (!restored) {
      throw new AppError(
        'BUSINESS_NOT_FOUND',
        'Business not found or you do not have access',
        404,
      );
    }
  }
}
