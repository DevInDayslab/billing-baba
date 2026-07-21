import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createPartyRoutes } from './party.routes';

export const partiesModule =
  (config: AppConfig): FastifyPluginAsync =>
  async (app) => {
    await app.register(createPartyRoutes(config));
  };
