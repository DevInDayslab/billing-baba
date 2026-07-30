import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createLoyaltyRulesController } from './loyalty.controller';

export const createLoyaltyRulesRoutes = (): FastifyPluginAsync => {
  const controller = createLoyaltyRulesController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.getRules);
    app.patch('/', { preHandler }, controller.updateRules);
  };
};
