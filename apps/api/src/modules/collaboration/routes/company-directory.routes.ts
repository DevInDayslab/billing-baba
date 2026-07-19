import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../../middleware/auth.middleware';
import { createCompanyDirectoryController } from '../company-directory.controller';

export function createCompanyDirectoryRoutes(): FastifyPluginAsync {
  const controller = createCompanyDirectoryController();

  return async (app) => {
    app.get('/shared', { preHandler: [authenticate] }, controller.listShared);
    app.get(
      '/invitations',
      { preHandler: [authenticate] },
      controller.listInvitations,
    );
  };
}
