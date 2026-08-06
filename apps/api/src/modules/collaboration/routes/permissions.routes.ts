import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../../middleware/auth.middleware';
import { requireBusiness } from '../../../middleware/require-business.middleware';
import { createPermissionsController } from '../permissions.controller';

export function createPermissionsRoutes(): FastifyPluginAsync {
  const controller = createPermissionsController();

  return async (app) => {
    app.get(
      '/me',
      { preHandler: [authenticate, requireBusiness] },
      controller.current,
    );
  };
}
