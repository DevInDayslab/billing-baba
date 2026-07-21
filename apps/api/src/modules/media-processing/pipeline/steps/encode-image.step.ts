import sharp from 'sharp';
import {
  IMAGE_JPEG_QUALITY,
  IMAGE_WEBP_QUALITY,
  type OutputImageFormat,
  mimeForFormat,
} from '../../image/image.constants';
import type { EncodedImage } from '../../media-processing.types';
import { ImageProcessingError } from '../../../images/image.errors';
import { createSharpInstance } from './read-metadata.step';

export type EncodeOptions = {
  maxEdge: number | null;
  resize: boolean;
  hasAlpha: boolean;
  preserveTransparency?: boolean;
};

async function encodeWebp(
  pipeline: sharp.Sharp,
  lossless: boolean,
): Promise<Buffer> {
  return pipeline
    .webp({ quality: IMAGE_WEBP_QUALITY, effort: 4, lossless })
    .toBuffer();
}

async function encodeJpeg(pipeline: sharp.Sharp): Promise<Buffer> {
  return pipeline
    .flatten({ background: { r: 255, g: 255, b: 255 } })
    .jpeg({ quality: IMAGE_JPEG_QUALITY, mozjpeg: true })
    .toBuffer();
}

async function encodePng(pipeline: sharp.Sharp): Promise<Buffer> {
  return pipeline.png({ compressionLevel: 9 }).toBuffer();
}

export async function encodeImageBuffer(
  buffer: Buffer,
  options: EncodeOptions,
): Promise<EncodedImage> {
  let pipeline = createSharpInstance(buffer).rotate();

  if (options.resize && options.maxEdge !== null) {
    pipeline = pipeline.resize(options.maxEdge, options.maxEdge, {
      fit: 'inside',
      withoutEnlargement: true,
    });
  }

  const useTransparency =
    options.hasAlpha && (options.preserveTransparency ?? options.hasAlpha);

  let format: OutputImageFormat;
  let outputBuffer: Buffer;

  if (useTransparency) {
    try {
      outputBuffer = await encodeWebp(pipeline.clone(), true);
      format = 'webp';
    } catch {
      outputBuffer = await encodePng(pipeline.clone());
      format = 'png';
    }
  } else {
    try {
      outputBuffer = await encodeWebp(pipeline.clone(), false);
      format = 'webp';
    } catch {
      outputBuffer = await encodeJpeg(pipeline.clone());
      format = 'jpeg';
    }
  }

  const info = await sharp(outputBuffer).metadata();
  const width = info.width ?? 0;
  const height = info.height ?? 0;

  if (width === 0 || height === 0) {
    throw new ImageProcessingError('Encoded image has invalid dimensions');
  }

  return {
    buffer: outputBuffer,
    width,
    height,
    format,
    mimeType: mimeForFormat(format),
    fileSize: outputBuffer.length,
  };
}
