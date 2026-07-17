import type { FastifyReply, FastifyRequest } from 'fastify';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { requireAuthContext } from '../inventory/inventory.controller-helpers';
import { PurchaseDocumentParseService } from './purchase-document-parse.service';

export function createPurchaseDocumentParseController() {
  const service = new PurchaseDocumentParseService();

  return {
    parseDocument: async (request: FastifyRequest, reply: FastifyReply) => {
      const { accountId, businessId } = requireAuthContext(request);
      const file = await request.file();

      if (!file) {
        throw new AppError(
          'VALIDATION_ERROR',
          'A document file is required',
          400,
        );
      }

      const buffer = await file.toBuffer();
      const data = await service.parseDocument(businessId, accountId, {
        buffer,
        filename: file.filename,
        mimeType: file.mimetype,
      });

      return sendData(reply, data);
    },
  };
}
