import type { FastifyPluginAsync } from 'fastify';
import { createPaymentRoutes } from './payment.routes';

export const accountingModule: FastifyPluginAsync = async (app) => {
  await app.register(createPaymentRoutes(), { prefix: '/payments' });
};
