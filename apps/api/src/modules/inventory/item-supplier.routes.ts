import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createItemSupplierController } from './item-supplier.controller';

export const createItemSupplierRoutes = (): FastifyPluginAsync => {
  const controller = createItemSupplierController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/:itemId/suppliers', { preHandler }, controller.list);
    app.put('/:itemId/suppliers', { preHandler }, controller.replace);
  };
};
