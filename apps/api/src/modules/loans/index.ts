import type { FastifyPluginAsync } from 'fastify';
import { createLoanAccountRoutes } from './loan-account.routes';
import { createLoanTransactionRoutes } from './loan-transaction.routes';

export const loansModule: FastifyPluginAsync = async (app) => {
  await app.register(createLoanAccountRoutes(), { prefix: '/loan-accounts' });
  await app.register(createLoanTransactionRoutes(), {
    prefix: '/loan-transactions',
  });
};
