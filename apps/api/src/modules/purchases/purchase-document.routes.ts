import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createPurchaseDocumentController } from './purchase-document.controller';

export const createPurchaseDocumentRoutes = (): FastifyPluginAsync => {
  const controller = createPurchaseDocumentController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.listDocuments);
    app.post('/', { preHandler }, controller.createDocument);
    app.get('/:id', { preHandler }, controller.getDocument);
    app.patch('/:id', { preHandler }, controller.updateDocument);
    app.delete('/:id', { preHandler }, controller.deleteDocument);
    app.post('/:id/finalize', { preHandler }, controller.finalizeDocument);
    app.post('/:id/cancel', { preHandler }, controller.cancelDocument);
    app.post('/:id/convert', { preHandler }, controller.convertDocument);
    app.get('/:id/payment-history', { preHandler }, controller.getPaymentHistory);

    app.get('/:id/lines', { preHandler }, controller.listLines);
    app.post('/:id/lines', { preHandler }, controller.addLine);
    app.patch('/:id/lines/:lineId', { preHandler }, controller.updateLine);
    app.delete('/:id/lines/:lineId', { preHandler }, controller.deleteLine);
  };
};
