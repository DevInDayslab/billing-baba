import type { FastifyPluginAsync } from 'fastify';
import { createPurchaseDocumentRoutes } from './purchase-document.routes';

export const purchasesModule: FastifyPluginAsync = async (app) => {
  await app.register(createPurchaseDocumentRoutes(), {
    prefix: '/purchase-documents',
  });
};
