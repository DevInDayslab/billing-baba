import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createPurchaseDocumentParseController } from './purchase-document-parse.controller';

export const createPurchaseDocumentParseRoutes = (): FastifyPluginAsync => {
  const controller = createPurchaseDocumentParseController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.post('/parse-document', { preHandler }, controller.parseDocument);
  };
};
