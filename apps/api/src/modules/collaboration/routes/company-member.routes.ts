import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../../middleware/auth.middleware';
import { requireBusiness } from '../../../middleware/require-business.middleware';
import { createCompanyMemberController } from '../company-member.controller';

export function createCompanyMemberRoutes(): FastifyPluginAsync {
  const controller = createCompanyMemberController();

  return async (app) => {
    app.get(
      '/',
      { preHandler: [authenticate, requireBusiness] },
      controller.list,
    );
    app.patch(
      '/:id',
      { preHandler: [authenticate, requireBusiness] },
      controller.update,
    );
    app.delete(
      '/:id',
      { preHandler: [authenticate, requireBusiness] },
      controller.remove,
    );
    app.post('/:id/leave', { preHandler: [authenticate] }, controller.leave);
  };
}
