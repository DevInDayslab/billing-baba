export const IMAGE_VARIANTS = ['thumbnail', 'medium', 'original'] as const;

export type ImageVariant = (typeof IMAGE_VARIANTS)[number];

/** Max edge length in pixels for each responsive variant. */
export const IMAGE_VARIANT_MAX_EDGE: Record<ImageVariant, number> = {
  thumbnail: 256,
  medium: 800,
  original: 1600,
};

export const IMAGE_WEBP_QUALITY = 82;
export const IMAGE_JPEG_QUALITY = 84;

export const OUTPUT_FORMATS = ['webp', 'jpeg', 'png'] as const;
export type OutputImageFormat = (typeof OUTPUT_FORMATS)[number];

export const IMAGE_MAX_EDGE_PIXELS = 8000;
export const IMAGE_MAX_PIXEL_COUNT = 64_000_000;
export const IMAGE_MIN_EDGE_PIXELS = 1;

export const SOURCE_IMAGE_MIME_TYPES = [
  'image/png',
  'image/jpeg',
  'image/webp',
] as const;

export type SourceImageMimeType = (typeof SOURCE_IMAGE_MIME_TYPES)[number];

export const REJECTED_IMAGE_MIME_TYPES = [
  'image/bmp',
  'image/tiff',
  'image/gif',
  'image/heic',
  'image/heif',
  'image/svg+xml',
] as const;

export function isSourceImageMimeType(
  mimeType: string,
): mimeType is SourceImageMimeType {
  return (SOURCE_IMAGE_MIME_TYPES as readonly string[]).includes(mimeType);
}

export function mimeForFormat(format: OutputImageFormat): string {
  switch (format) {
    case 'webp':
      return 'image/webp';
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
  }
}

export function extensionForFormat(format: OutputImageFormat): string {
  switch (format) {
    case 'webp':
      return 'webp';
    case 'jpeg':
      return 'jpg';
    case 'png':
      return 'png';
  }
}

export function variantFileSuffix(variant: ImageVariant): string {
  switch (variant) {
    case 'thumbnail':
      return 'thumb';
    case 'medium':
      return 'medium';
    case 'original':
      return 'original';
  }
}
