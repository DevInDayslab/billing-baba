import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createGstinRoutes } from './gstin.routes';

export const gstinModule =
  (config: AppConfig): FastifyPluginAsync =>
  async (app) => {
    await app.register(createGstinRoutes(config));
  };
