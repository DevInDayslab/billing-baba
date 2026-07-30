import type { FastifyPluginAsync } from 'fastify';
import { createReportsRoutes } from './reports.routes';

export const reportsModule: FastifyPluginAsync = async (app) => {
  await app.register(createReportsRoutes());
};
