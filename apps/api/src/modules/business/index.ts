import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createBusinessRoutes } from './business.routes';
import { createBusinessBrandingRoutes } from './business-branding.routes';
import { createBusinessProfileRoutes } from './business-profile.routes';

export const businessModule =
  (config: AppConfig): FastifyPluginAsync =>
  async (app) => {
    await app.register(createBusinessRoutes(config));
  };

export const businessProfileModule =
  (config: AppConfig): FastifyPluginAsync =>
  async (app) => {
    await app.register(createBusinessProfileRoutes(config));
    await app.register(createBusinessBrandingRoutes(config));
  };
