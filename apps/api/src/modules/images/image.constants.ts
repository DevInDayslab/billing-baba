export const IMAGE_VARIANTS = [
  'thumbnail',
  'small',
  'medium',
  'large',
] as const;

export type ImageVariant = (typeof IMAGE_VARIANTS)[number];

/** Max edge length in pixels for each responsive variant. */
export const IMAGE_VARIANT_MAX_EDGE: Record<ImageVariant, number> = {
  thumbnail: 150,
  small: 320,
  medium: 768,
  large: 1280,
};

export const IMAGE_OUTPUT_MIME = 'image/webp' as const;

export const IMAGE_WEBP_QUALITY = 82;

/** Reject sources larger than this on either axis. */
export const IMAGE_MAX_EDGE_PIXELS = 8000;

/** Reject sources whose width × height exceeds this (40 MP). */
export const IMAGE_MAX_PIXEL_COUNT = 40_000_000;

export const IMAGE_MIN_EDGE_PIXELS = 1;

export const SOURCE_IMAGE_MIME_TYPES = [
  'image/png',
  'image/jpeg',
  'image/webp',
] as const;

export type SourceImageMimeType = (typeof SOURCE_IMAGE_MIME_TYPES)[number];

export function isSourceImageMimeType(
  mimeType: string,
): mimeType is SourceImageMimeType {
  return (SOURCE_IMAGE_MIME_TYPES as readonly string[]).includes(mimeType);
}
