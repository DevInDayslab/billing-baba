import { describe, expect, test } from 'bun:test';
import sharp from 'sharp';
import {
  resolveImagePolicy,
  shouldProcessAsset,
} from '../../../src/modules/media-processing/media-processing.constants';
import {
  validateBinarySignature,
  validateMimeType,
} from '../../../src/modules/media-processing/pipeline/steps/validate-mime.step';
import { runImagePipeline } from '../../../src/modules/media-processing/pipeline/image-pipeline';
import { IMAGE_POLICIES } from '../../../src/modules/media-processing/media-processing.constants';
import { ImageValidationError } from '../../../src/modules/images/image.errors';

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

describe('media-processing.constants', () => {
  test('shouldProcessAsset returns false for PDF', () => {
    expect(
      shouldProcessAsset({
        purpose: 'documents',
        mimeType: 'application/pdf',
        ownerType: null,
        businessId: '11111111-1111-1111-1111-111111111111',
      }),
    ).toBe(false);
  });

  test('resolveImagePolicy maps attachments to optimize-only policy', () => {
    const policy = resolveImagePolicy({
      purpose: 'sales',
      mimeType: 'image/jpeg',
      ownerType: 'sale',
      businessId: '11111111-1111-1111-1111-111111111111',
    });
    expect(policy.key).toBe('ATTACHMENT');
    expect(policy.resize).toBe(false);
    expect(policy.generateVariants).toBe(false);
  });

  test('resolveImagePolicy maps branding to LOGO', () => {
    const policy = resolveImagePolicy({
      purpose: 'branding',
      mimeType: 'image/png',
      ownerType: null,
      businessId: '11111111-1111-1111-1111-111111111111',
    });
    expect(policy.key).toBe('LOGO');
    expect(policy.maxEdge).toBe(1024);
  });

  test('resolveImagePolicy maps party profile photos to AVATAR', () => {
    const policy = resolveImagePolicy({
      purpose: 'parties',
      mimeType: 'image/jpeg',
      ownerType: 'party',
      businessId: '11111111-1111-1111-1111-111111111111',
    });
    expect(policy.key).toBe('AVATAR');
    expect(policy.generateVariants).toBe(true);
    expect(policy.maxEdge).toBe(512);
  });

  test('resolveImagePolicy maps other party uploads to ATTACHMENT', () => {
    const policy = resolveImagePolicy({
      purpose: 'parties',
      mimeType: 'image/jpeg',
      ownerType: 'kyc',
      businessId: '11111111-1111-1111-1111-111111111111',
    });
    expect(policy.key).toBe('ATTACHMENT');
  });
});

describe('media-processing pipeline validation', () => {
  test('rejects unsupported MIME types', () => {
    expect(() => validateMimeType('image/gif')).toThrow(ImageValidationError);
  });

  test('rejects binary signature mismatch', async () => {
    const buffer = Buffer.from('not-an-image');
    expect(() => validateBinarySignature(buffer, 'image/jpeg')).toThrow(
      ImageValidationError,
    );
  });

  test('attachment policy optimizes without generating extra variants', async () => {
    const buffer = await createTestJpeg(1200, 900);
    const result = await runImagePipeline({
      buffer,
      mimeType: 'image/jpeg',
      policy: IMAGE_POLICIES.ATTACHMENT,
    });

    expect(result.variants).toHaveLength(1);
    expect(result.variants[0]?.variant).toBe('original');
    expect(result.variants[0]?.encoded.width).toBe(1200);
  });

  test('item image policy generates thumbnail, medium, and original variants', async () => {
    const buffer = await createTestJpeg(2400, 1800);
    const result = await runImagePipeline({
      buffer,
      mimeType: 'image/jpeg',
      policy: IMAGE_POLICIES.ITEM_IMAGE,
    });

    expect(result.variants.map((item) => item.variant)).toEqual([
      'thumbnail',
      'medium',
      'original',
    ]);
    expect(result.original.width).toBeLessThanOrEqual(1600);
  });

  test('transparent PNG uses webp or png output', async () => {
    const buffer = await sharp({
      create: {
        width: 200,
        height: 200,
        channels: 4,
        background: { r: 0, g: 0, b: 0, alpha: 0 },
      },
    })
      .png()
      .toBuffer();

    const result = await runImagePipeline({
      buffer,
      mimeType: 'image/png',
      policy: IMAGE_POLICIES.LOGO,
    });

    expect(['webp', 'png']).toContain(result.original.format);
  });
});

describe('media-processing compression ratio', () => {
  test('optimized output is smaller than large JPEG source', async () => {
    const buffer = await createTestJpeg(2000, 1500);
    const result = await runImagePipeline({
      buffer,
      mimeType: 'image/jpeg',
      policy: IMAGE_POLICIES.ITEM_IMAGE,
    });

    expect(result.original.fileSize).toBeLessThan(buffer.length);
  });
});
