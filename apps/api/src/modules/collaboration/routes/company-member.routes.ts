import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../../middleware/auth.middleware';
import { createCompanyMemberController } from '../company-member.controller';

export function createCompanyMemberRoutes(): FastifyPluginAsync {
  const controller = createCompanyMemberController();

  return async (app) => {
    app.post('/:id/leave', { preHandler: [authenticate] }, controller.leave);
  };
}
