import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createSubscriptionRoutes } from './subscription.routes';

export const createSubscriptionModule =
  (config: AppConfig): FastifyPluginAsync =>
  async (app) => {
    await app.register(createSubscriptionRoutes(config));
  };
