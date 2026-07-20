export { buildProcessedImagePath } from '../media-processing/image/image-path.builder';

/** @deprecated Use buildProcessedImagePath — legacy derivative key builder */
export function buildImageVariantStoragePath(params: {
  environment: string;
  businessId: string;
  sourceAssetId: string;
  variant: string;
}): string {
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
