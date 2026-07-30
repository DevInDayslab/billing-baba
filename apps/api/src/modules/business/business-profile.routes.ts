import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createBusinessController } from './business.controller';

export const createBusinessProfileRoutes = (
  config: AppConfig,
): FastifyPluginAsync => {
  const controller = createBusinessController(config);

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
    app.get(
      '/commerce-settings',
      { preHandler: [authenticate, requireBusiness] },
      controller.getCommerceSettings,
    );
    app.patch(
      '/commerce-settings',
      { preHandler: [authenticate, requireBusiness] },
      controller.updateCommerceSettings,
    );
  };
};
