import { z } from 'zod';
import { IMAGE_VARIANTS } from './image.constants';

export const sourceAssetParamSchema = z.object({
  sourceAssetId: z.uuid(),
});

export const variantParamSchema = z.object({
  sourceAssetId: z.uuid(),
  variant: z.enum(IMAGE_VARIANTS),
});

export type SourceAssetParams = z.infer<typeof sourceAssetParamSchema>;
export type VariantParams = z.infer<typeof variantParamSchema>;
