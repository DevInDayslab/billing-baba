import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createTaxReportingController } from './tax-reporting.controller';

export const createTaxReportingRoutes = (): FastifyPluginAsync => {
  const controller = createTaxReportingController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/gst-register', { preHandler }, controller.getGstRegister);
    app.get('/gst-rate-summary', { preHandler }, controller.getGstRateSummary);
    app.get('/tds-payable', { preHandler }, controller.getTdsPayable);
    app.get('/tds-receivable', { preHandler }, controller.getTdsReceivable);
    app.get('/tcs-receivable', { preHandler }, controller.getTcsReceivable);
    app.get('/form-27eq', { preHandler }, controller.getForm27eq);
  };
};
