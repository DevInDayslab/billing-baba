import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createSalesDocumentController } from './sales-document.controller';

export const createSalesDocumentRoutes = (): FastifyPluginAsync => {
  const controller = createSalesDocumentController();

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
    app.post('/:id/brand-swap', { preHandler }, controller.brandSwap);

    app.get('/:id/lines', { preHandler }, controller.listLines);
    app.post('/:id/lines', { preHandler }, controller.addLine);
    app.patch('/:id/lines/:lineId', { preHandler }, controller.updateLine);
    app.delete('/:id/lines/:lineId', { preHandler }, controller.deleteLine);
  };
};

export const createPosSessionRoutes = (): FastifyPluginAsync => {
  const controller = createSalesDocumentController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/', { preHandler }, controller.listPosSessions);
    app.post('/', { preHandler }, controller.createPosSession);
    app.get('/:id', { preHandler }, controller.getPosSession);
    app.patch('/:id', { preHandler }, controller.updatePosSession);
    app.get(
      '/:id/sales-documents',
      { preHandler },
      controller.listPosSessionDocuments,
    );
  };
};
