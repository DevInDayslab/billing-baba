import {
  IMAGE_POLICIES,
  type ImagePolicyKey,
} from '../media-processing.constants';
import type {
  MediaProcessingContext,
  MediaProcessResult,
} from '../media-processing.types';
import { runImagePipeline } from '../pipeline/image-pipeline';

export type MediaProcessor = {
  process(ctx: MediaProcessingContext): Promise<MediaProcessResult>;
};

export class ImageMediaProcessor implements MediaProcessor {
  async process(ctx: MediaProcessingContext): Promise<MediaProcessResult> {
    const policyKey = ctx.policyKey as Exclude<ImagePolicyKey, 'SKIP'>;
    const policy = IMAGE_POLICIES[policyKey];

    const pipelineResult = await runImagePipeline({
      buffer: ctx.sourceBuffer,
      mimeType: ctx.asset.mimeType,
      policy,
    });

    const originalSize = ctx.originalSize;
    const optimizedSize = pipelineResult.original.fileSize;
    const compressionRatio =
      originalSize > 0 ? optimizedSize / originalSize : 1;

    return {
      sourceAssetId: ctx.asset.id,
      originalStorageKey: '',
      originalMimeType: pipelineResult.original.mimeType,
      originalSize,
      optimizedSize,
      compressionRatio,
      width: pipelineResult.original.width,
      height: pipelineResult.original.height,
      format: pipelineResult.original.format,
      variants: pipelineResult.variants,
      durationMs: pipelineResult.durationMs,
    };
  }
}
