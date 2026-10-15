import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createGstReportsController } from './gst-reports.controller';

export const createGstReportsRoutes = (): FastifyPluginAsync => {
  const controller = createGstReportsController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/hsn-summary', { preHandler }, controller.getHsnSummary);
    app.get('/sac-report', { preHandler }, controller.getSacReport);
    app.get('/gstr1', { preHandler }, controller.getGstr1);
    app.get('/gstr2', { preHandler }, controller.getGstr2);
    app.get('/gstr3b', { preHandler }, controller.getGstr3b);
    app.get('/gstr9', { preHandler }, controller.getGstr9);
  };
};
