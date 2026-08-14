import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createPaymentGatewayRoutes } from './payment-gateway.routes';

export const createPaymentGatewayModule =
  (config: AppConfig): FastifyPluginAsync =>
  async (app) => {
    await app.register(createPaymentGatewayRoutes(config));
  };
