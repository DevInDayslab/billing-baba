import type { FastifyPluginAsync } from 'fastify';
import { createLoyaltyRulesRoutes } from '../loyalty/loyalty-rules.routes';

export const settingsModule: FastifyPluginAsync = async (app) => {
  await app.register(createLoyaltyRulesRoutes(), { prefix: '/loyalty-rules' });
};
