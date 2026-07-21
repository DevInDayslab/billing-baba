import { IMAGE_POLICIES } from '../media-processing/media-processing.constants';
import { runImagePipeline } from '../media-processing/pipeline/image-pipeline';
import {
  readImageMetadata,
  validateImageDimensions,
} from '../media-processing/pipeline/steps/read-metadata.step';
import type { ProcessedImageVariant } from './image.types';

export type ImageProcessorOptions = {
  webpQuality?: number;
};

export async function readImageDimensions(
  buffer: Buffer,
): Promise<{ width: number; height: number }> {
  const metadata = await readImageMetadata(buffer);
  return metadata.dimensions;
}

export { validateImageDimensions };

export async function generateImageVariants(
  buffer: Buffer,
  _options: ImageProcessorOptions = {},
): Promise<ProcessedImageVariant[]> {
  const pipelineResult = await runImagePipeline({
    buffer,
    mimeType: detectMimeFromBuffer(buffer),
    policy: IMAGE_POLICIES.ITEM_IMAGE,
  });

  return pipelineResult.variants.map((item) => ({
    variant: item.variant,
    width: item.encoded.width,
    height: item.encoded.height,
    fileSize: item.encoded.fileSize,
    buffer: item.encoded.buffer,
  }));
}

function detectMimeFromBuffer(buffer: Buffer): string {
  if (
    buffer.length >= 8 &&
    buffer
      .subarray(0, 8)
      .equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))
  ) {
    return 'image/png';
  }
  if (
    buffer.length >= 3 &&
    buffer.subarray(0, 3).equals(Buffer.from([0xff, 0xd8, 0xff]))
  ) {
    return 'image/jpeg';
  }
  return 'image/webp';
}
