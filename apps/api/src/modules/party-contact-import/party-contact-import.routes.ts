import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createPartyContactImportController } from './party-contact-import.controller';

export const createPartyContactImportRoutes = (
  config: AppConfig,
): FastifyPluginAsync => {
  const controller = createPartyContactImportController(config);

  return async (app) => {
    const auth = [authenticate];
    const authBusiness = [authenticate, requireBusiness];

    app.post(
      '/contact-import-sessions',
      { preHandler: authBusiness },
      controller.createSession,
    );
    app.get(
      '/contact-import-sessions/by-token/:token',
      { preHandler: auth },
      controller.getSessionByToken,
    );
    app.put(
      '/contact-import-sessions/by-token/:token/staging',
      { preHandler: auth },
      controller.replaceStagingByToken,
    );
    app.get(
      '/contact-import-sessions/:id',
      { preHandler: authBusiness },
      controller.getSessionById,
    );
    app.delete(
      '/contact-import-sessions/:id',
      { preHandler: authBusiness },
      controller.cancelSession,
    );
    app.post(
      '/contact-import-sessions/:id/commit',
      { preHandler: authBusiness },
      controller.commitSession,
    );
  };
};

export const createPublicPartyContactImportRoutes = (
  config: AppConfig,
): FastifyPluginAsync => {
  const controller = createPartyContactImportController(config);

  return async (app) => {
    app.get('/:token', controller.getPublicByToken);
  };
};
