import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../../config/app_config';
import { authenticate } from '../../../middleware/auth.middleware';
import { requireBusiness } from '../../../middleware/require-business.middleware';
import { createInvitationController } from '../invitation.controller';

export function createInvitationRoutes(config: AppConfig): FastifyPluginAsync {
  const controller = createInvitationController(config);

  return async (app) => {
    app.post(
      '/',
      { preHandler: [authenticate, requireBusiness] },
      controller.create,
    );
    app.get(
      '/',
      { preHandler: [authenticate, requireBusiness] },
      controller.list,
    );
    app.post(
      '/reinvite/:id',
      { preHandler: [authenticate, requireBusiness] },
      controller.reinvite,
    );
    app.post(
      '/:id/cancel',
      { preHandler: [authenticate, requireBusiness] },
      controller.cancel,
    );
    app.get('/:token', controller.getByToken);
    app.post('/:token/accept', controller.accept);
    app.post('/:token/reject', controller.reject);
  };
}
