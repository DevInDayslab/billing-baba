import type { ImageVariant } from './image.constants';

export type ImageVariantRecord = {
  id: string;
  businessId: string;
  sourceMediaAssetId: string;
  variant: ImageVariant;
  mediaAssetId: string;
  width: number;
  height: number;
  fileSize: number;
  mimeType: string;
  storageKey: string;
  createdAt: Date;
  updatedAt: Date;
};

export type ProcessedImageVariant = {
  variant: ImageVariant;
  width: number;
  height: number;
  fileSize: number;
  buffer: Buffer;
};

export type ImageVariantResponse = {
  variant: ImageVariant;
  media_asset_id: string;
  width: number;
  height: number;
  file_size: number;
  mime_type: string;
  url: string;
  cdn_url: string | null;
  expires_at: string | null;
};

export type ImageVariantsResponse = {
  source_media_asset_id: string;
  variants: ImageVariantResponse[];
};

export type ImageDimensions = {
  width: number;
  height: number;
};
