import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createItemController } from './item.controller';

export const createItemRoutes = (config: AppConfig): FastifyPluginAsync => {
  const controller = createItemController(config);

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.create);

    app.get('/:id/images', { preHandler }, controller.listImages);
    app.post('/:id/images', { preHandler }, controller.addImage);
    app.put('/:id/images/reorder', { preHandler }, controller.reorderImages);
    app.patch('/:id/images/:imageId', { preHandler }, controller.updateImage);
    app.delete('/:id/images/:imageId', { preHandler }, controller.deleteImage);
    app.get('/:id/tier-prices', { preHandler }, controller.getTierPrices);
    app.put('/:id/tier-prices', { preHandler }, controller.putTierPrices);
    app.delete(
      '/:id/tier-prices/:tier',
      { preHandler },
      controller.deleteTierPrice,
    );
    app.get('/:id/price-history', { preHandler }, controller.getPriceHistory);

    app.get('/:id', { preHandler }, controller.getById);
    app.patch('/:id', { preHandler }, controller.update);
    app.delete('/:id', { preHandler }, controller.delete);
  };
};
