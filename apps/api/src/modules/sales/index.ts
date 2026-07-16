import type { FastifyPluginAsync } from 'fastify';
import { createSaleFaRoutes } from './sale-fa.routes';
import {
  createDocumentSequenceRoutes,
  createPosSessionRoutes,
  createSalesDocumentRoutes,
} from './sales-document.routes';

export const salesModule: FastifyPluginAsync = async (app) => {
  await app.register(createSalesDocumentRoutes(), {
    prefix: '/sales-documents',
  });
  await app.register(createPosSessionRoutes(), { prefix: '/pos-sessions' });
  await app.register(createDocumentSequenceRoutes(), {
    prefix: '/document-sequences',
  });
  await app.register(createSaleFaRoutes(), {
    prefix: '/fixed-asset-sales',
  });
};
