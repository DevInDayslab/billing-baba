import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createAuthRoutes } from './auth.routes';

export function createAuthModule(config: AppConfig): FastifyPluginAsync {
  return async (app) => {
    await app.register(createAuthRoutes(config));
  };
}
