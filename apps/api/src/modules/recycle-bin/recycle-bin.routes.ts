import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createRecycleBinController } from './recycle-bin.controller';

export const createRecycleBinRoutes = (): FastifyPluginAsync => {
  const controller = createRecycleBinController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post(
      '/:entityType/:entityId/restore',
      { preHandler },
      controller.restore,
    );
    app.delete(
      '/:entityType/:entityId',
      { preHandler },
      controller.purge,
    );
  };
};
