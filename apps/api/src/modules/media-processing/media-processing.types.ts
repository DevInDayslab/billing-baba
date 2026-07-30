import type { StoragePurpose } from '../storage/storage.constants';
import type { StorageAsset, MediaAssetRow } from '../storage/storage.types';
import type { ImagePolicyKey } from './media-processing.constants';
import type { ImageVariant, OutputImageFormat } from './image/image.constants';

export type ProcessingStatus =
  | 'pending'
  | 'processing'
  | 'ready'
  | 'failed'
  | 'skipped';

export type MediaProcessingContext = {
  businessId: string | null;
  accountId: string;
  asset: StorageAsset;
  assetRow: MediaAssetRow;
  policyKey: ImagePolicyKey;
  stagingStorageKey: string;
  sourceBuffer: Buffer;
  originalSize: number;
};

export type EncodedImage = {
  buffer: Buffer;
  width: number;
  height: number;
  format: OutputImageFormat;
  mimeType: string;
  fileSize: number;
};

export type ProcessedVariantOutput = {
  variant: ImageVariant;
  encoded: EncodedImage;
};

export type ImagePipelineResult = {
  original: EncodedImage;
  variants: ProcessedVariantOutput[];
  hasAlpha: boolean;
  durationMs: number;
};

export type MediaProcessResult = {
  sourceAssetId: string;
  originalStorageKey: string;
  originalMimeType: string;
  originalSize: number;
  optimizedSize: number;
  compressionRatio: number;
  width: number;
  height: number;
  format: OutputImageFormat;
  variants: ProcessedVariantOutput[];
  durationMs: number;
};

export type ResolvePolicyInput = {
  purpose: StoragePurpose;
  mimeType: string;
  ownerType: string | null;
  businessId: string | null;
};
