import type { FastifyPluginAsync } from 'fastify';
import { createPaymentRoutes } from './payment.routes';

export { OutstandingRepository } from './outstanding.repository';
export type {
  OutstandingSummary,
  PartyOutstandingBalance,
} from './outstanding.types';

export const accountingModule: FastifyPluginAsync = async (app) => {
  await app.register(createPaymentRoutes(), { prefix: '/payments' });
};
