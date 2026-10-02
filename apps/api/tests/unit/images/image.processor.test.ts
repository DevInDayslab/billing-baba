import { describe, expect, test } from 'bun:test';
import sharp from 'sharp';
import { IMAGE_VARIANT_MAX_EDGE } from '../../../src/modules/images/image.constants';
import { ImageValidationError } from '../../../src/modules/images/image.errors';
import {
  generateImageVariants,
  readImageDimensions,
  validateImageDimensions,
} from '../../../src/modules/images/image.processor';
import { buildProcessedImagePath } from '../../../src/modules/media-processing/image/image-path.builder';

async function createTestJpeg(width: number, height: number): Promise<Buffer> {
  return sharp({
    create: {
      width,
      height,
      channels: 3,
      background: { r: 10, g: 120, b: 200 },
    },
  })
    .jpeg()
    .toBuffer();
}

describe('buildProcessedImagePath', () => {
  test('builds UUID-based processed image key', () => {
    expect(
      buildProcessedImagePath({
        environment: 'test',
        businessId: '11111111-1111-1111-1111-111111111111',
        purpose: 'items',
        assetId: '22222222-2222-2222-2222-222222222222',
        variant: 'medium',
        format: 'webp',
      }),
    ).toBe(
      'test/businesses/11111111-1111-1111-1111-111111111111/items/22222222-2222-2222-2222-222222222222-medium.webp',
    );
  });
});

describe('image.processor', () => {
  test('validateImageDimensions rejects oversized edges', () => {
    expect(() =>
      validateImageDimensions({ width: 9000, height: 1000 }),
    ).toThrow(ImageValidationError);
  });

  test('readImageDimensions returns metadata for valid image', async () => {
    const buffer = await createTestJpeg(640, 480);
    const dimensions = await readImageDimensions(buffer);
    expect(dimensions.width).toBe(640);
    expect(dimensions.height).toBe(480);
  });

  test('generateImageVariants produces webp outputs for thumbnail, medium, original', async () => {
    const buffer = await createTestJpeg(2000, 1500);
    const variants = await generateImageVariants(buffer);

    expect(variants).toHaveLength(3);
    for (const item of variants) {
      expect(item.fileSize).toBeGreaterThan(0);
      expect(item.width).toBeLessThanOrEqual(
        IMAGE_VARIANT_MAX_EDGE[item.variant],
      );
      expect(item.height).toBeLessThanOrEqual(
        IMAGE_VARIANT_MAX_EDGE[item.variant],
      );

      const metadata = await sharp(item.buffer).metadata();
      expect(metadata.format).toBe('webp');
      expect(metadata.exif).toBeUndefined();
    }
  });

  test('generateImageVariants does not upscale small images', async () => {
    const buffer = await createTestJpeg(100, 80);
    const variants = await generateImageVariants(buffer);
    const original = variants.find((item) => item.variant === 'original');
    expect(original?.width).toBe(100);
    expect(original?.height).toBe(80);
  });
});
