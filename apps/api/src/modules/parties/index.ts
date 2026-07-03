import type { FastifyPluginAsync } from 'fastify';
import { createPartyRoutes } from './party.routes';

export const partiesModule: FastifyPluginAsync = async (app) => {
  await app.register(createPartyRoutes());
};
