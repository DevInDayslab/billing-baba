import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createSyncController } from './sync.controller';

export const createSyncRoutes = (): FastifyPluginAsync => {
  const controller = createSyncController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.post('/devices', { preHandler }, controller.registerDevice);
    app.get('/devices', { preHandler }, controller.listDevices);
    app.get('/status', { preHandler }, controller.getStatus);

    app.post('/bootstrap', { preHandler }, controller.startBootstrap);
    app.get(
      '/bootstrap/:bootstrap_id/chunks/:chunk_index',
      { preHandler },
      controller.getBootstrapChunk,
    );

    app.post('/push', { preHandler }, controller.push);
    app.get('/pull', { preHandler }, controller.pull);

    app.post('/media/uploads', { preHandler }, controller.mediaUploadIntent);
    app.post(
      '/media/uploads/complete',
      { preHandler },
      controller.mediaUploadComplete,
    );
    app.get(
      '/media/:asset_id/url',
      { preHandler },
      controller.mediaDownloadUrl,
    );
  };
};
