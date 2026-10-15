import type { FastifyPluginAsync } from 'fastify';
import { createGstReportsRoutes } from './gst-reports.routes';

export const gstReportsModule: FastifyPluginAsync = async (app) => {
  await app.register(createGstReportsRoutes());
};
