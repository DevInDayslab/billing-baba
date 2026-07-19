import sharp from 'sharp';
import {
  IMAGE_MAX_EDGE_PIXELS,
  IMAGE_MAX_PIXEL_COUNT,
  IMAGE_MIN_EDGE_PIXELS,
  IMAGE_VARIANT_MAX_EDGE,
  IMAGE_VARIANTS,
} from './image.constants';
import { ImageProcessingError, ImageValidationError } from './image.errors';
import type { ImageDimensions, ProcessedImageVariant } from './image.types';

export type ImageProcessorOptions = {
  webpQuality?: number;
};

export async function readImageDimensions(
  buffer: Buffer,
): Promise<ImageDimensions> {
  try {
    const metadata = await sharp(buffer).metadata();
    const width = metadata.width ?? 0;
    const height = metadata.height ?? 0;
    return { width, height };
  } catch {
    throw new ImageProcessingError('Unable to read image metadata');
  }
}

export function validateImageDimensions(dimensions: ImageDimensions): void {
  const { width, height } = dimensions;

  if (
    width < IMAGE_MIN_EDGE_PIXELS ||
    height < IMAGE_MIN_EDGE_PIXELS ||
    !Number.isFinite(width) ||
    !Number.isFinite(height)
  ) {
    throw new ImageValidationError('Image dimensions are invalid', {
      dimensions: ['Width and height must be positive integers'],
    });
  }

  if (width > IMAGE_MAX_EDGE_PIXELS || height > IMAGE_MAX_EDGE_PIXELS) {
    throw new ImageValidationError(
      `Image exceeds the ${IMAGE_MAX_EDGE_PIXELS}px edge limit`,
      {
        dimensions: [`Maximum edge length is ${IMAGE_MAX_EDGE_PIXELS}px`],
      },
    );
  }

  if (width * height > IMAGE_MAX_PIXEL_COUNT) {
    throw new ImageValidationError(
      `Image exceeds the ${IMAGE_MAX_PIXEL_COUNT} pixel limit`,
      {
        dimensions: [`Maximum pixel count is ${IMAGE_MAX_PIXEL_COUNT}`],
      },
    );
  }
}

export async function generateImageVariants(
  buffer: Buffer,
  options: ImageProcessorOptions = {},
): Promise<ProcessedImageVariant[]> {
  const quality = options.webpQuality ?? 82;
  const results: ProcessedImageVariant[] = [];

  for (const variant of IMAGE_VARIANTS) {
    const maxEdge = IMAGE_VARIANT_MAX_EDGE[variant];
    const output = await sharp(buffer)
      .rotate()
      .resize(maxEdge, maxEdge, {
        fit: 'inside',
        withoutEnlargement: true,
      })
      .webp({ quality, effort: 4 })
      .toBuffer({ resolveWithObject: true });

    results.push({
      variant,
      width: output.info.width,
      height: output.info.height,
      fileSize: output.data.length,
      buffer: output.data,
    });
  }

  return results;
}
