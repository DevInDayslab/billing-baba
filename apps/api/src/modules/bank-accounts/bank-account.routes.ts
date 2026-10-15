import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createBankAccountController } from './bank-account.controller';

export function createBankAccountRoutes(): FastifyPluginAsync {
  const controller = createBankAccountController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/bank-accounts', { preHandler }, controller.list);
    app.get('/bank-accounts/balances', { preHandler }, controller.balances);
    app.post('/bank-accounts', { preHandler }, controller.create);
    app.patch(
      '/bank-accounts/cash/opening',
      { preHandler },
      controller.updateCashOpening,
    );
    app.patch('/bank-accounts/:id', { preHandler }, controller.update);
    app.delete('/bank-accounts/:id', { preHandler }, controller.delete);

    app.post('/account-transfers', { preHandler }, controller.createTransfer);
    app.delete(
      '/account-transfers/:id',
      { preHandler },
      controller.deleteTransfer,
    );

    app.post(
      '/account-adjustments',
      { preHandler },
      controller.createAdjustment,
    );
    app.delete(
      '/account-adjustments/:id',
      { preHandler },
      controller.deleteAdjustment,
    );
  };
}
