import {
  REJECTED_IMAGE_MIME_TYPES,
  SOURCE_IMAGE_MIME_TYPES,
} from '../../image/image.constants';
import { ImageValidationError } from '../../../images/image.errors';

const PNG_SIGNATURE = Buffer.from([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
]);
const JPEG_SIGNATURE = Buffer.from([0xff, 0xd8, 0xff]);
const WEBP_RIFF = Buffer.from([0x52, 0x49, 0x46, 0x46]);
const WEBP_MAGIC = Buffer.from([0x57, 0x45, 0x42, 0x50]);

export function validateMimeType(mimeType: string): void {
  const normalized = mimeType.split(';')[0]?.trim().toLowerCase() ?? mimeType;

  if ((REJECTED_IMAGE_MIME_TYPES as readonly string[]).includes(normalized)) {
    throw new ImageValidationError(`Image type not supported: ${normalized}`, {
      mime_type: ['BMP, TIFF, GIF, HEIC, and SVG uploads are not supported'],
    });
  }

  if (!(SOURCE_IMAGE_MIME_TYPES as readonly string[]).includes(normalized)) {
    throw new ImageValidationError(
      `Unsupported image MIME type: ${normalized}`,
      {
        mime_type: ['Only PNG, JPEG, and WEBP are supported'],
      },
    );
  }
}

export function validateBinarySignature(
  buffer: Buffer,
  mimeType: string,
): void {
  if (buffer.length < 12) {
    throw new ImageValidationError('Image file is too small or corrupted', {
      file: ['Invalid or truncated image data'],
    });
  }

  const normalized = mimeType.split(';')[0]?.trim().toLowerCase() ?? mimeType;

  if (normalized === 'image/png') {
    if (!buffer.subarray(0, 8).equals(PNG_SIGNATURE)) {
      throw new ImageValidationError('PNG signature mismatch', {
        file: ['File content does not match declared PNG type'],
      });
    }
    return;
  }

  if (normalized === 'image/jpeg') {
    if (!buffer.subarray(0, 3).equals(JPEG_SIGNATURE)) {
      throw new ImageValidationError('JPEG signature mismatch', {
        file: ['File content does not match declared JPEG type'],
      });
    }
    return;
  }

  if (normalized === 'image/webp') {
    const riff = buffer.subarray(0, 4);
    const webp = buffer.subarray(8, 12);
    if (!riff.equals(WEBP_RIFF) || !webp.equals(WEBP_MAGIC)) {
      throw new ImageValidationError('WEBP signature mismatch', {
        file: ['File content does not match declared WEBP type'],
      });
    }
  }
}
