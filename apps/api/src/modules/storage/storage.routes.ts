import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { resolveStorageProvider } from '../../providers/storage';
import { LocalFilesystemProvider } from '../../providers/storage/local-filesystem-provider';
import { createDevStorageRoutes } from './dev-storage.routes';
import { createStorageController } from './storage.controller';
import { StorageService } from './storage.service';

export function createStorageRoutes(config: AppConfig): FastifyPluginAsync {
  return async (app) => {
    const provider = resolveStorageProvider(config);
    const service = new StorageService({
      config,
      provider: provider ?? undefined,
      logger: {
        info: (obj, msg) => app.log.info(obj, msg),
        warn: (obj, msg) => app.log.warn(obj, msg),
        error: (obj, msg) => app.log.error(obj, msg),
      },
    });
    const controller = createStorageController(config, service);
    const preHandler = [authenticate, requireBusiness];

    if (provider instanceof LocalFilesystemProvider) {
      await app.register(createDevStorageRoutes(provider), {
        prefix: '/_dev',
      });
      app.log.info(
        'Local filesystem storage enabled for development (.local-storage/)',
      );
    }

    app.post('/uploads', { preHandler }, controller.createUploadIntent);
    app.post('/uploads/complete', { preHandler }, controller.completeUpload);
    app.get('/files/:id', { preHandler }, controller.getFile);
    app.get('/files/:id/url', { preHandler }, controller.getFileUrl);
    app.delete('/files/:id', { preHandler }, controller.deleteFile);
  };
}
