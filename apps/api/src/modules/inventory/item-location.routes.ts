import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createItemLocationController } from './item-location.controller';

export const createItemLocationRoutes = (
  config: AppConfig,
): FastifyPluginAsync => {
  const controller = createItemLocationController(config);

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.create);
    app.post('/:id/photo', { preHandler }, controller.uploadPhoto);
    app.delete('/:id/photo', { preHandler }, controller.deletePhoto);
    app.get('/:id/history', { preHandler }, controller.listHistory);
    app.get('/:id', { preHandler }, controller.getById);
    app.patch('/:id', { preHandler }, controller.update);
    app.delete('/:id', { preHandler }, controller.delete);
  };
};
