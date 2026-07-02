import type { FastifyPluginAsync } from 'fastify';
import { createBusinessRoutes } from './business.routes';

export const businessModule: FastifyPluginAsync = async (app) => {
  await app.register(createBusinessRoutes());
};
