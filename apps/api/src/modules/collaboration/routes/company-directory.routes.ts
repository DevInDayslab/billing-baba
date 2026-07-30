import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../../config/app_config';
import { authenticate } from '../../../middleware/auth.middleware';
import { createCompanyDirectoryController } from '../company-directory.controller';

export function createCompanyDirectoryRoutes(
  config: AppConfig,
): FastifyPluginAsync {
  const controller = createCompanyDirectoryController(config);

  return async (app) => {
    app.get('/shared', { preHandler: [authenticate] }, controller.listShared);
    app.get(
      '/invitations',
      { preHandler: [authenticate] },
      controller.listInvitations,
    );
  };
}
