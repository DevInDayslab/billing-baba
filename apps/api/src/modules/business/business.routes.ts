import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { createBusinessController } from './business.controller';

export const createBusinessRoutes = (config: AppConfig): FastifyPluginAsync => {
  const controller = createBusinessController(config);

  return async (app) => {
    app.get('/', { preHandler: authenticate }, controller.list);
    app.post('/', { preHandler: authenticate }, controller.create);
    app.delete('/:id', { preHandler: authenticate }, controller.delete);
    app.post(
      '/:id/cancel-deletion',
      { preHandler: authenticate },
      controller.cancelDeletion,
    );
  };
};
