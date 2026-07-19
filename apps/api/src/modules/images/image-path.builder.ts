import type { AppConfig } from '../../config/app_config';
import type { ImageVariant } from './image.constants';

export type BuildImageVariantPathParams = {
  environment: AppConfig['environment'];
  businessId: string;
  sourceAssetId: string;
  variant: ImageVariant;
};

/**
 * Stable derivative keys for CDN cache invalidation.
 * {env}/businesses/{businessId}/derivatives/{sourceAssetId}/{variant}.webp
 */
export function buildImageVariantStoragePath(
  params: BuildImageVariantPathParams,
): string {
  const { environment, businessId, sourceAssetId, variant } = params;
  return [
    environment,
    'businesses',
    businessId,
    'derivatives',
    sourceAssetId,
    `${variant}.webp`,
  ].join('/');
}
