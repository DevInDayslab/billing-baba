import type { FastifyPluginAsync } from 'fastify';
import {
  createPosSessionRoutes,
  createSalesDocumentRoutes,
} from './sales-document.routes';

export const salesModule: FastifyPluginAsync = async (app) => {
  await app.register(createSalesDocumentRoutes(), {
    prefix: '/sales-documents',
  });
  await app.register(createPosSessionRoutes(), { prefix: '/pos-sessions' });
};
