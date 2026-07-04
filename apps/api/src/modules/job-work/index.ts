import type { FastifyPluginAsync } from 'fastify';
import { createJobWorkOrderRoutes } from './job-work-order.routes';

export const jobWorkModule: FastifyPluginAsync = async (app) => {
  await app.register(createJobWorkOrderRoutes(), {
    prefix: '/job-work-orders',
  });
};
