import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createGeneratedDocumentController } from './generated-document.controller';

export function createGeneratedDocumentRoutes(
  config: AppConfig,
): FastifyPluginAsync {
  const controller = createGeneratedDocumentController(config);

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/lookup', { preHandler }, controller.lookup);
    app.post('/ensure', { preHandler }, controller.ensure);
    app.get('/:id/url', { preHandler }, controller.getSignedUrl);
    app.post('/:id/regenerate', { preHandler }, controller.regenerate);
  };
}

export function createPublicGeneratedDocumentRoutes(
  config: AppConfig,
): FastifyPluginAsync {
  const controller = createGeneratedDocumentController(config);

  return async (app) => {
    app.get('/:token', controller.getPublicMetadata);
    app.get('/:token/file', controller.getPublicFile);
  };
}
