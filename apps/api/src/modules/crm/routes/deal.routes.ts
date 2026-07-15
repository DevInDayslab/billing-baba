import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../../middleware/auth.middleware';
import { requireBusiness } from '../../../middleware/require-business.middleware';
import { createDealController } from '../deal.controller';

export const createDealRoutes = (): FastifyPluginAsync => {
  const controller = createDealController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.create);
    app.get('/:id', { preHandler }, controller.getById);
    app.patch('/:id', { preHandler }, controller.update);
    app.delete('/:id', { preHandler }, controller.delete);
  };
};
