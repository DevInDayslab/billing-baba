import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createItemBomController } from './item-bom.controller';

export const createItemBomRoutes = (): FastifyPluginAsync => {
  const controller = createItemBomController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/:itemId/bom', { preHandler }, controller.get);
    app.put('/:itemId/bom', { preHandler }, controller.replace);
  };
};
