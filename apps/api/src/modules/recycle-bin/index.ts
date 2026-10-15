import type { FastifyPluginAsync } from 'fastify';
import { createRecycleBinRoutes } from './recycle-bin.routes';

export const recycleBinModule: FastifyPluginAsync = async (app) => {
  await app.register(createRecycleBinRoutes());
};
