import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createBusinessController } from './business.controller';

export const createBusinessProfileRoutes = (): FastifyPluginAsync => {
  const controller = createBusinessController();

  return async (app) => {
    app.get(
      '/profile',
      { preHandler: [authenticate, requireBusiness] },
      controller.getProfile,
    );
    app.put(
      '/profile',
      { preHandler: [authenticate, requireBusiness] },
      controller.updateProfile,
    );
  };
};
