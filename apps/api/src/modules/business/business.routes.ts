import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { createBusinessController } from './business.controller';

export const createBusinessRoutes = (): FastifyPluginAsync => {
  const controller = createBusinessController();

  return async (app) => {
    app.get('/', { preHandler: authenticate }, controller.list);
    app.post('/', { preHandler: authenticate }, controller.create);
    app.delete('/:id', { preHandler: authenticate }, controller.delete);
  };
};
