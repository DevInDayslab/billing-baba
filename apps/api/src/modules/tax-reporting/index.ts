import type { FastifyPluginAsync } from 'fastify';
import { withholdingTaxModule } from '../withholding-tax';
import { createTaxReportingRoutes } from './tax-reporting.routes';

export const taxReportingModule: FastifyPluginAsync = async (app) => {
  await app.register(createTaxReportingRoutes());
  await app.register(withholdingTaxModule);
};
