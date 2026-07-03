import type { FastifyPluginAsync } from 'fastify';
import { createBusinessRoutes } from './business.routes';
import { createBusinessProfileRoutes } from './business-profile.routes';

export const businessModule: FastifyPluginAsync = async (app) => {
  await app.register(createBusinessRoutes());
};

export const businessProfileModule: FastifyPluginAsync = async (app) => {
  await app.register(createBusinessProfileRoutes());
};
