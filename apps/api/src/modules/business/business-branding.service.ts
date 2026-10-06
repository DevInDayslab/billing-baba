import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { AuthRepository } from '../auth/auth.repository';
import type { UserRole } from '../auth/auth.types';
import { StorageNotFoundError } from '../storage/storage.errors';
import { StorageService } from '../storage/storage.service';
import type { UploadIntent } from '../storage/storage.types';
import { BusinessRepository } from './business.repository';
import type { BusinessListItem, BusinessProfile } from './business.types';
import {
  AVATAR_POLICY,
  BRANDING_POLICIES,
  BRANDING_WRITE_ROLES,
  type BrandingKind,
} from './business-branding.constants';

export type BusinessListItemRow = BusinessListItem & {
  logoMediaAssetId: string | null;
};

export type BrandingAssetResponse = {
  media_asset_id: string;
  url: string;
  mime_type: string;
  file_size: number;
};

export type BusinessBrandingServiceDeps = {
  config: AppConfig;
  repository?: BusinessRepository;
  storage?: StorageService;
};

function requireDb() {
  const db = getDb();
  if (!db) {
    throw new AppError(
      'DATABASE_NOT_CONFIGURED',
      'Database is not configured',
      503,
    );
  }
  return db;
}

export class BusinessBrandingService {
  private readonly repository: BusinessRepository;
  private readonly storage: StorageService;

  constructor(deps: BusinessBrandingServiceDeps) {
    this.repository = deps.repository ?? new BusinessRepository(requireDb());
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });
  }

  assertCanWriteBranding(role: UserRole | undefined): void {
    if (
      !role ||
      !(BRANDING_WRITE_ROLES as readonly UserRole[]).includes(role)
    ) {
      throw new AppError(
        'FORBIDDEN',
        'You do not have permission to manage business branding',
        403,
      );
    }
  }

  async createBrandingUploadIntent(
    businessId: string,
    accountId: string,
    kind: BrandingKind,
    mimeType: string,
    fileSize: number,
    checksum?: string | null,
  ): Promise<UploadIntent> {
    const policy = BRANDING_POLICIES[kind];

    return this.storage.createUploadIntent(
      businessId,
      accountId,
      {
        purpose: 'branding',
        visibility: 'authenticated',
        mimeType,
        fileSize,
        ownerType: kind,
        ownerId: businessId,
        checksum,
      },
      policy,
    );
  }

  async completeBrandingUpload(
    businessId: string,
    accountId: string,
    kind: BrandingKind,
    intentId: string,
  ): Promise<BrandingAssetResponse> {
    const asset = await this.storage.completeUpload(
      businessId,
      accountId,
      intentId,
    );

    if (asset.purpose !== 'branding' || asset.ownerType !== kind) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Upload intent does not match the requested branding asset',
        400,
      );
    }

    const previousAssetId = await this.repository.getBrandingMediaAssetId(
      businessId,
      kind,
    );

    const url = await this.storage.resolveBusinessAssetUrl(
      businessId,
      accountId,
      asset.id,
    );

    await this.repository.bindBrandingAsset(businessId, kind, asset.id, url);

    if (previousAssetId && previousAssetId !== asset.id) {
      try {
        await this.storage.deleteAsset(businessId, accountId, previousAssetId);
      } catch (error) {
        if (!(error instanceof StorageNotFoundError)) {
          throw error;
        }
      }
    }

    return {
      media_asset_id: asset.id,
      url,
      mime_type: asset.mimeType,
      file_size: asset.fileSize,
    };
  }

  async deleteBranding(
    businessId: string,
    accountId: string,
    kind: BrandingKind,
  ): Promise<void> {
    const assetId = await this.repository.getBrandingMediaAssetId(
      businessId,
      kind,
    );
    if (!assetId) {
      throw new AppError('NOT_FOUND', 'Branding asset not found', 404);
    }

    await this.repository.clearBrandingAsset(businessId, kind);

    try {
      await this.storage.deleteAsset(businessId, accountId, assetId);
    } catch (error) {
      if (!(error instanceof StorageNotFoundError)) {
        throw error;
      }
    }
  }

  async resolveLogoUrl(
    businessId: string,
    accountId: string,
    fallbackLogoUrl: string | null,
    logoMediaAssetId: string | null,
  ): Promise<string | null> {
    if (!logoMediaAssetId) return fallbackLogoUrl;
    try {
      return await this.storage.resolveBusinessAssetUrl(
        businessId,
        accountId,
        logoMediaAssetId,
      );
    } catch {
      return fallbackLogoUrl;
    }
  }

  async enrichListItemsWithBrandingUrls(
    accountId: string,
    items: BusinessListItemRow[],
  ): Promise<BusinessListItem[]> {
    return Promise.all(
      items.map(async (item) => {
        const { logoMediaAssetId, ...rest } = item;
        const logoUrl = await this.resolveLogoUrl(
          item.id,
          accountId,
          item.logo_url,
          logoMediaAssetId,
        );
        return { ...rest, logo_url: logoUrl };
      }),
    );
  }

  async enrichProfileWithBrandingUrls(
    businessId: string,
    accountId: string,
    profile: BusinessProfile,
  ): Promise<BusinessProfile> {
    const bindings = await this.repository.getBrandingBindings(businessId);

    const resolve = async (
      assetId: string | null,
      fallback: string | null,
    ): Promise<string | null> => {
      if (!assetId) return fallback;
      try {
        return await this.storage.resolveBusinessAssetUrl(
          businessId,
          accountId,
          assetId,
        );
      } catch {
        return fallback;
      }
    };

    const [logoUrl, signatureUrl, stampUrl, upiQrUrl] = await Promise.all([
      resolve(bindings.logoMediaAssetId, profile.logo_url),
      resolve(bindings.signatureMediaAssetId, profile.signature_url),
      resolve(bindings.stampMediaAssetId, profile.stamp_url),
      resolve(bindings.upiQrMediaAssetId, profile.upi_qr_url),
    ]);

    return {
      ...profile,
      logo_url: logoUrl,
      signature_url: signatureUrl,
      stamp_url: stampUrl,
      upi_qr_url: upiQrUrl,
    };
  }
}

export type AccountAvatarServiceDeps = {
  config: AppConfig;
  authRepository?: AuthRepository;
  storage?: StorageService;
};

export class AccountAvatarService {
  private readonly authRepository: AuthRepository;
  private readonly storage: StorageService;

  constructor(deps: AccountAvatarServiceDeps) {
    this.authRepository =
      deps.authRepository ?? new AuthRepository(requireDb());
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });
  }

  async createAvatarUploadIntent(
    accountId: string,
    mimeType: string,
    fileSize: number,
    checksum?: string | null,
  ): Promise<UploadIntent> {
    return this.storage.createAccountUploadIntent(
      accountId,
      { mimeType, fileSize, checksum },
      AVATAR_POLICY,
    );
  }

  async completeAvatarUpload(
    accountId: string,
    intentId: string,
  ): Promise<BrandingAssetResponse> {
    const asset = await this.storage.completeAccountUpload(accountId, intentId);

    if (asset.ownerType !== 'avatar') {
      throw new AppError(
        'VALIDATION_ERROR',
        'Upload intent does not match avatar',
        400,
      );
    }

    const previousAssetId =
      await this.authRepository.getAvatarMediaAssetId(accountId);

    const url = await this.storage.resolveAccountAssetUrl(accountId, asset.id);
    await this.authRepository.bindAvatarAsset(accountId, asset.id, url);

    if (previousAssetId && previousAssetId !== asset.id) {
      try {
        await this.storage.deleteAccountAsset(accountId, previousAssetId);
      } catch (error) {
        if (!(error instanceof StorageNotFoundError)) {
          throw error;
        }
      }
    }

    return {
      media_asset_id: asset.id,
      url,
      mime_type: asset.mimeType,
      file_size: asset.fileSize,
    };
  }

  async deleteAvatar(accountId: string): Promise<void> {
    const assetId = await this.authRepository.getAvatarMediaAssetId(accountId);
    if (!assetId) {
      throw new AppError('NOT_FOUND', 'Avatar not found', 404);
    }

    await this.authRepository.clearAvatarAsset(accountId);

    try {
      await this.storage.deleteAccountAsset(accountId, assetId);
    } catch (error) {
      if (!(error instanceof StorageNotFoundError)) {
        throw error;
      }
    }
  }

  async resolveAvatarUrl(
    accountId: string,
    avatarMediaAssetId: string | null,
    fallbackUrl: string | null,
  ): Promise<string | null> {
    if (!avatarMediaAssetId) return fallbackUrl;
    try {
      return await this.storage.resolveAccountAssetUrl(
        accountId,
        avatarMediaAssetId,
      );
    } catch {
      return fallbackUrl;
    }
  }
}
