import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createGstinController } from './gstin.controller';

export const createGstinRoutes = (config: AppConfig): FastifyPluginAsync => {
  const controller = createGstinController(config);

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.post('/verify', { preHandler }, controller.verify);
  };
};
