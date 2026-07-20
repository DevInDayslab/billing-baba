import type { ImagePolicy } from '../media-processing.constants';
import {
  IMAGE_VARIANT_MAX_EDGE,
  IMAGE_VARIANTS,
  type ImageVariant,
} from '../image/image.constants';
import type {
  EncodedImage,
  ImagePipelineResult,
  ProcessedVariantOutput,
} from '../media-processing.types';
import { rejectAnimatedImage, readImageMetadata, validateImageDimensions } from './steps/read-metadata.step';
import { validateBinarySignature, validateMimeType } from './steps/validate-mime.step';
import { encodeImageBuffer } from './steps/encode-image.step';

export type RunImagePipelineInput = {
  buffer: Buffer;
  mimeType: string;
  policy: ImagePolicy;
};

function variantsForPolicy(policy: ImagePolicy): ImageVariant[] {
  if (!policy.generateVariants) {
    return ['original'];
  }
  return [...IMAGE_VARIANTS];
}

export async function runImagePipeline(
  input: RunImagePipelineInput,
): Promise<ImagePipelineResult> {
  const started = Date.now();

  validateMimeType(input.mimeType);
  validateBinarySignature(input.buffer, input.mimeType);

  const metadata = await readImageMetadata(input.buffer);
  validateImageDimensions(metadata.dimensions);
  rejectAnimatedImage(metadata.isAnimated);

  const variantsToGenerate = variantsForPolicy(input.policy);
  const outputs: ProcessedVariantOutput[] = [];

  for (const variant of variantsToGenerate) {
    let effectiveMaxEdge: number | null = null;
    let shouldResize = false;

    if (input.policy.resize) {
      shouldResize = true;
      effectiveMaxEdge =
        variant === 'original'
          ? (input.policy.maxEdge ?? IMAGE_VARIANT_MAX_EDGE.original)
          : IMAGE_VARIANT_MAX_EDGE[variant];
    }

    const encoded: EncodedImage = await encodeImageBuffer(input.buffer, {
      maxEdge: effectiveMaxEdge,
      resize: shouldResize,
      hasAlpha: metadata.hasAlpha,
      preserveTransparency: input.policy.preserveTransparency,
    });

    outputs.push({ variant, encoded });
  }

  const original =
    outputs.find((item) => item.variant === 'original')?.encoded ??
    outputs[outputs.length - 1]!.encoded;

  return {
    original,
    variants: outputs,
    hasAlpha: metadata.hasAlpha,
    durationMs: Date.now() - started,
  };
}
