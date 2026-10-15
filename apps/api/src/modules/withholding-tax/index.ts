import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createTaxDepositController } from './tax-deposit.controller';

export const withholdingTaxModule: FastifyPluginAsync = async (app) => {
  const controller = createTaxDepositController();
  const preHandler = [authenticate, requireBusiness];

  app.get('/deposits', { preHandler }, controller.list);
  app.post('/deposits', { preHandler }, controller.create);
  app.delete('/deposits/:id', { preHandler }, controller.delete);
};

export { seedWithholdingTaxSections } from './withholding-tax-section-seed.service';
export { WithholdingTaxEntryService } from './withholding-tax-entry.service';
