import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createPartyContactImportRoutes } from '../party-contact-import';
import { createPartyRoutes } from './party.routes';

export const partiesModule =
  (config: AppConfig): FastifyPluginAsync =>
  async (app) => {
    await app.register(createPartyContactImportRoutes(config));
    await app.register(createPartyRoutes(config));
  };
