export {
  IMAGE_VARIANTS,
  IMAGE_VARIANT_MAX_EDGE,
  IMAGE_WEBP_QUALITY,
  IMAGE_JPEG_QUALITY,
  isSourceImageMimeType,
  mimeForFormat as imageMimeForFormat,
  type ImageVariant,
  type SourceImageMimeType,
} from '../media-processing/image/image.constants';

export const IMAGE_OUTPUT_MIME = 'image/webp' as const;

export const IMAGE_MAX_EDGE_PIXELS = 8000;
export const IMAGE_MAX_PIXEL_COUNT = 64_000_000;
export const IMAGE_MIN_EDGE_PIXELS = 1;

export const SOURCE_IMAGE_MIME_TYPES = [
  'image/png',
  'image/jpeg',
  'image/webp',
] as const;
