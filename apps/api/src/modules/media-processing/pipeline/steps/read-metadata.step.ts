import sharp from 'sharp';
import {
  ImageProcessingError,
  ImageValidationError,
} from '../../../images/image.errors';
import type { ImageDimensions } from '../../../images/image.types';
import {
  IMAGE_MAX_EDGE_PIXELS,
  IMAGE_MAX_PIXEL_COUNT,
  IMAGE_MIN_EDGE_PIXELS,
} from '../../image/image.constants';

export function createSharpInstance(buffer: Buffer): sharp.Sharp {
  return sharp(buffer, {
    failOn: 'error',
    limitInputPixels: IMAGE_MAX_PIXEL_COUNT,
  });
}

export async function readImageMetadata(buffer: Buffer): Promise<{
  dimensions: ImageDimensions;
  hasAlpha: boolean;
  isAnimated: boolean;
  orientation: number | undefined;
}> {
  try {
    const metadata = await createSharpInstance(buffer).metadata();
    const width = metadata.width ?? 0;
    const height = metadata.height ?? 0;
    const pages = metadata.pages ?? 1;
    const isAnimated =
      pages > 1 ||
      metadata.format === 'gif' ||
      (metadata.format === 'webp' && pages > 1);

    return {
      dimensions: { width, height },
      hasAlpha: metadata.hasAlpha ?? false,
      isAnimated,
      orientation: metadata.orientation,
    };
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

export function rejectAnimatedImage(isAnimated: boolean): void {
  if (isAnimated) {
    throw new ImageValidationError('Animated images are not supported', {
      animation: ['Only static images are allowed'],
    });
  }
}
