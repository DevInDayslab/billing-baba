import type { FastifyPluginAsync } from 'fastify';
import { createDashboardRoutes } from './dashboard.routes';

export const dashboardModule: FastifyPluginAsync = async (app) => {
  await app.register(createDashboardRoutes());
};
