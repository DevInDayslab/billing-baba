import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { StorageNotFoundError } from '../storage/storage.errors';
import { StorageService } from '../storage/storage.service';
import type { UploadIntent } from '../storage/storage.types';
import {
  PARTY_PROFILE_IMAGE_POLICY,
  PARTY_PROFILE_OWNER_TYPE,
} from './party-profile-image.constants';
import { PartyRepository } from './party.repository';
import type { PartyRecord } from './party.types';

export type PartyProfileImageResponse = {
  media_asset_id: string;
  url: string;
  mime_type: string;
  file_size: number;
};

export type PartyProfileImageServiceDeps = {
  config: AppConfig;
  repository?: PartyRepository;
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

export class PartyProfileImageService {
  private readonly repository: PartyRepository;
  private readonly storage: StorageService;

  constructor(deps: PartyProfileImageServiceDeps) {
    this.repository = deps.repository ?? new PartyRepository(requireDb());
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });
  }

  async createUploadIntent(
    businessId: string,
    accountId: string,
    partyId: string,
    mimeType: string,
    fileSize: number,
    checksum?: string | null,
  ): Promise<UploadIntent> {
    await this.assertPartyExists(businessId, partyId);

    return this.storage.createUploadIntent(
      businessId,
      accountId,
      {
        purpose: 'parties',
        visibility: 'authenticated',
        mimeType,
        fileSize,
        ownerType: PARTY_PROFILE_OWNER_TYPE,
        ownerId: partyId,
        checksum,
      },
      PARTY_PROFILE_IMAGE_POLICY,
    );
  }

  async completeUpload(
    businessId: string,
    accountId: string,
    partyId: string,
    intentId: string,
  ): Promise<PartyProfileImageResponse> {
    await this.assertPartyExists(businessId, partyId);

    const asset = await this.storage.completeUpload(
      businessId,
      accountId,
      intentId,
    );

    if (
      asset.purpose !== 'parties' ||
      asset.ownerType !== PARTY_PROFILE_OWNER_TYPE ||
      asset.ownerId !== partyId
    ) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Upload intent does not match the party profile image',
        400,
      );
    }

    const previousAssetId =
      await this.repository.getProfileMediaAssetId(businessId, partyId);

    const url = await this.storage.resolveBusinessAssetUrl(
      businessId,
      accountId,
      asset.id,
    );

    await this.repository.bindProfileImage(businessId, partyId, asset.id, url);

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

  async deleteProfileImage(
    businessId: string,
    accountId: string,
    partyId: string,
  ): Promise<void> {
    await this.assertPartyExists(businessId, partyId);

    const assetId = await this.repository.getProfileMediaAssetId(
      businessId,
      partyId,
    );
    if (!assetId) {
      throw new AppError('NOT_FOUND', 'Party profile image not found', 404);
    }

    await this.repository.clearProfileImage(businessId, partyId);

    try {
      await this.storage.deleteAsset(businessId, accountId, assetId);
    } catch (error) {
      if (!(error instanceof StorageNotFoundError)) {
        throw error;
      }
    }
  }

  async resolveProfileImageUrl(
    businessId: string,
    accountId: string,
    profileMediaAssetId: string | null,
    fallbackUrl: string | null,
  ): Promise<string | null> {
    if (!profileMediaAssetId) return fallbackUrl;
    try {
      return await this.storage.resolveBusinessAssetUrl(
        businessId,
        accountId,
        profileMediaAssetId,
      );
    } catch {
      return fallbackUrl;
    }
  }

  async enrichParty(
    businessId: string,
    accountId: string,
    party: PartyRecord,
  ): Promise<PartyRecord> {
    const profileImageUrl = await this.resolveProfileImageUrl(
      businessId,
      accountId,
      party.profile_media_asset_id,
      party.profile_image_url,
    );
    return {
      ...party,
      profile_image_url: profileImageUrl,
    };
  }

  async enrichParties(
    businessId: string,
    accountId: string,
    parties: PartyRecord[],
  ): Promise<PartyRecord[]> {
    return Promise.all(
      parties.map((party) => this.enrichParty(businessId, accountId, party)),
    );
  }

  private async assertPartyExists(
    businessId: string,
    partyId: string,
  ): Promise<void> {
    const party = await this.repository.findById(businessId, partyId);
    if (!party) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }
  }
}
