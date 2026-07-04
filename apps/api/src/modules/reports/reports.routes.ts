import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createReportsController } from './reports.controller';

export const createReportsRoutes = (): FastifyPluginAsync => {
  const controller = createReportsController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/sales', { preHandler }, controller.getSaleReport);
    app.get('/purchases', { preHandler }, controller.getPurchaseReport);
    app.get('/stock-summary', { preHandler }, controller.getStockSummary);
    app.get('/low-stock', { preHandler }, controller.getLowStock);
    app.get('/party-outstanding', { preHandler }, controller.getPartyOutstanding);
    app.get('/party-statement', { preHandler }, controller.getPartyStatement);
    app.get('/day-book', { preHandler }, controller.getDayBook);
    app.get('/all-transactions', { preHandler }, controller.getAllTransactions);
    app.get('/profit-loss', { preHandler }, controller.getProfitLoss);
    app.get('/gstr-1', { preHandler }, controller.getGstr1);
    app.get('/gstr-2', { preHandler }, controller.getGstr2);
    app.get('/gstr-3b', { preHandler }, controller.getGstr3b);
  };
};
