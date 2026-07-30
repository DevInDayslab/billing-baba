import type { FastifyPluginAsync } from 'fastify';
import { createContactRoutes } from './routes/contact.routes';
import { createDealRoutes } from './routes/deal.routes';
import { createLeadRoutes } from './routes/lead.routes';

export const crmModule: FastifyPluginAsync = async (app) => {
  await app.register(createLeadRoutes(), { prefix: '/leads' });
  await app.register(createContactRoutes(), { prefix: '/contacts' });
  await app.register(createDealRoutes(), { prefix: '/deals' });
};
