import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createSaleFaController } from './sale-fa.controller';

export const createSaleFaRoutes = (): FastifyPluginAsync => {
  const controller = createSaleFaController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.create);
    app.get('/:batchId', { preHandler }, controller.getById);
    app.patch('/:batchId', { preHandler }, controller.update);
    app.delete('/:batchId', { preHandler }, controller.delete);
  };
};
