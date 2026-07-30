import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createDocumentAttachmentController } from './document-attachment.controller';

export function createDocumentAttachmentRoutes(
  config: AppConfig,
): FastifyPluginAsync {
  const controller = createDocumentAttachmentController(config);

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.list);
    app.post('/', { preHandler }, controller.upload);
    app.get('/:id/url', { preHandler }, controller.getDownloadUrl);
    app.patch('/:id', { preHandler }, controller.update);
    app.delete('/:id', { preHandler }, controller.delete);
  };
}
