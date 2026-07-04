import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createPaymentController } from './payment.controller';

export const createPaymentRoutes = (): FastifyPluginAsync => {
  const controller = createPaymentController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.create);
    app.get('/:id', { preHandler }, controller.getById);
    app.patch('/:id', { preHandler }, controller.update);
    app.delete('/:id', { preHandler }, controller.delete);
    app.get('/:id/allocations', { preHandler }, controller.listAllocations);
    app.post('/:id/allocations', { preHandler }, controller.addAllocation);
    app.delete(
      '/:id/allocations/:allocationId',
      { preHandler },
      controller.deleteAllocation,
    );
  };
};
