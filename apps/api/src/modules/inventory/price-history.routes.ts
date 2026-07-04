import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createPriceHistoryController } from './price-history.controller';

export const createPriceHistoryRoutes = (): FastifyPluginAsync => {
  const controller = createPriceHistoryController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.get('/:id', { preHandler }, controller.getById);
  };
};
