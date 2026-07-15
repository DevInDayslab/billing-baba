import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../../middleware/auth.middleware';
import { requireBusiness } from '../../../middleware/require-business.middleware';
import { createContactController } from '../contact.controller';

export const createContactRoutes = (): FastifyPluginAsync => {
  const controller = createContactController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.create);
    app.get('/:id', { preHandler }, controller.getById);
    app.patch('/:id', { preHandler }, controller.update);
    app.delete('/:id', { preHandler }, controller.delete);
    app.post('/:id/activities', { preHandler }, controller.addActivity);
  };
};
