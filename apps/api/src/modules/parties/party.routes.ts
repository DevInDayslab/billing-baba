import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createLoyaltyController } from '../loyalty/loyalty.controller';
import { createPartyController } from './party.controller';

export const createPartyRoutes = (): FastifyPluginAsync => {
  const controller = createPartyController();
  const loyaltyController = createLoyaltyController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.create);
    app.get('/:id/delete-status', { preHandler }, controller.getDeleteStatus);
    app.get('/:id/ledger', { preHandler }, controller.getLedger);
    app.get('/:id/loyalty', { preHandler }, loyaltyController.getPartyBalance);
    app.get(
      '/:id/loyalty/transactions',
      { preHandler },
      loyaltyController.listPartyTransactions,
    );
    app.get('/:id', { preHandler }, controller.getById);
    app.patch('/:id', { preHandler }, controller.update);
    app.delete('/:id', { preHandler }, controller.delete);
  };
};
