import type { FastifyPluginAsync } from 'fastify';
import { createHiddenLedgerRoutes } from './hidden-ledger.routes';

export const hiddenLedgerModule: FastifyPluginAsync = async (app) => {
  await app.register(createHiddenLedgerRoutes());
};
