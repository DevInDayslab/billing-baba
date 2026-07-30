import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createDashboardController } from './dashboard.controller';

export const createDashboardRoutes = (): FastifyPluginAsync => {
  const controller = createDashboardController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];
    app.get('/', { preHandler }, controller.getDashboard);
  };
};
