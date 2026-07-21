import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createStorageController } from './storage.controller';
import { StorageService } from './storage.service';

export function createStorageRoutes(config: AppConfig): FastifyPluginAsync {
  return async (app) => {
    const service = new StorageService({
      config,
      logger: {
        info: (obj, msg) => app.log.info(obj, msg),
        warn: (obj, msg) => app.log.warn(obj, msg),
        error: (obj, msg) => app.log.error(obj, msg),
      },
    });
    const controller = createStorageController(config, service);
    const preHandler = [authenticate, requireBusiness];

    app.post('/uploads', { preHandler }, controller.createUploadIntent);
    app.post('/uploads/complete', { preHandler }, controller.completeUpload);
    app.get('/files/:id', { preHandler }, controller.getFile);
    app.get('/files/:id/url', { preHandler }, controller.getFileUrl);
    app.delete('/files/:id', { preHandler }, controller.deleteFile);
  };
}
