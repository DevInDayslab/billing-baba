import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createPaymentController } from './payment.controller';
import { createPaymentNotifyHandler } from './payment-notify.routes';

export function createPaymentRoutes(config: AppConfig): FastifyPluginAsync {
  const controller = createPaymentController();
  const notifyHandler = createPaymentNotifyHandler(config);

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.create);
    app.get('/:id', { preHandler }, controller.getById);
    app.patch('/:id', { preHandler }, controller.update);
    app.delete('/:id', { preHandler }, controller.delete);
    app.post('/:id/notify', { preHandler }, notifyHandler);
    app.get('/:id/allocations', { preHandler }, controller.listAllocations);
    app.post('/:id/allocations', { preHandler }, controller.addAllocation);
    app.delete(
      '/:id/allocations/:allocationId',
      { preHandler },
      controller.deleteAllocation,
    );
  };
}
