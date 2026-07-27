import type { FastifyPluginAsync } from 'fastify';
import { createSyncRoutes } from './sync.routes';

export const syncModule: FastifyPluginAsync = async (app) => {
  await app.register(createSyncRoutes());
};
