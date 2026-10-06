import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createImageController } from './image.controller';
import { ImageService } from './image.service';

export function createImageRoutes(config: AppConfig): FastifyPluginAsync {
  return async (app) => {
    const service = new ImageService({ config });
    const controller = createImageController(config, service);
    const preHandler = [authenticate, requireBusiness];

    app.post(
      '/:sourceAssetId/process',
      { preHandler },
      controller.processSource,
    );
    app.get(
      '/:sourceAssetId/variants',
      { preHandler },
      controller.listVariants,
    );
    app.get(
      '/:sourceAssetId/variants/:variant/url',
      { preHandler },
      controller.getVariantUrl,
    );
  };
}

export function createImagesModule(config: AppConfig): FastifyPluginAsync {
  return createImageRoutes(config);
}

export {
  IMAGE_VARIANT_MAX_EDGE,
  IMAGE_VARIANTS,
  type ImageVariant,
} from './image.constants';
export { ImageService } from './image.service';
export { buildImageVariantStoragePath } from './image-path.builder';
