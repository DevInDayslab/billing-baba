import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createPaymentRoutes } from './payment.routes';

export { OutstandingRepository } from './outstanding.repository';
export type {
  OutstandingSummary,
  PartyOutstandingBalance,
} from './outstanding.types';

export function createAccountingModule(config: AppConfig): FastifyPluginAsync {
  return async (app) => {
    await app.register(createPaymentRoutes(config), { prefix: '/payments' });
  };
}
