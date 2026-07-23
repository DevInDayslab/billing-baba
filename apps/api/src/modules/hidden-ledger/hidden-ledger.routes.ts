import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createHiddenLedgerController } from './hidden-ledger.controller';

export const createHiddenLedgerRoutes = (): FastifyPluginAsync => {
  const controller = createHiddenLedgerController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/entries', { preHandler }, controller.listEntries);
    app.get('/entries/:id', { preHandler }, controller.getEntry);
    app.get('/entries/:id/recoveries', { preHandler }, controller.listRecoveries);
    app.get('/parties/:partyId/summary', { preHandler }, controller.getPartySummary);
    app.post(
      '/parties/:partyId/recover-from-sale',
      { preHandler },
      controller.recoverFromSale,
    );
  };
};
