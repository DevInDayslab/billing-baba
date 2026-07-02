import type { FastifyPluginAsync } from 'fastify';
import { createBusinessProfileRoutes } from './business-profile.routes';
import { createBusinessRoutes } from './business.routes';

export const businessModule: FastifyPluginAsync = async (app) => {
  await app.register(createBusinessRoutes());
};

export const businessProfileModule: FastifyPluginAsync = async (app) => {
  await app.register(createBusinessProfileRoutes());
};
