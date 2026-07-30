import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createStockLevelController } from './stock-level.controller';

export const createStockLevelRoutes = (): FastifyPluginAsync => {
  const controller = createStockLevelController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.get('/:id', { preHandler }, controller.getById);
  };
};
