import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { processedIdempotencyKeys } from '../../shared/http/idempotency';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  convertPurchaseDocumentBodySchema,
  createPurchaseDocumentBodySchema,
  createPurchaseLineBodySchema,
  finalizePurchaseDocumentBodySchema,
  listPurchaseDocumentsQuerySchema,
  purchaseDocumentIdParamSchema,
  purchaseLineIdParamSchema,
  updatePurchaseDocumentBodySchema,
  updatePurchaseLineBodySchema,
} from './purchase-document.schema';
import { PurchaseDocumentService } from './purchase-document.service';

export function createPurchaseDocumentController() {
  const service = new PurchaseDocumentService();

  return {
    listDocuments: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listPurchaseDocumentsQuerySchema.parse(request.query);
        const result = await service.listDocuments(
          businessId,
          accountId,
          query,
        );
        return sendPaginated(reply, result.data, result.meta);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid query parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    createDocument: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const body = createPurchaseDocumentBodySchema.parse(request.body);
        const data = await service.createDocument(
          businessId,
          accountId,
          userId,
          body,
        );
        return sendData(reply, data, 201);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getDocument: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        const data = await service.getDocument(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid document ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    updateDocument: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        const body = updatePurchaseDocumentBodySchema.parse(request.body);
        const data = await service.updateDocument(
          businessId,
          accountId,
          userId,
          id,
          body,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    deleteDocument: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        await service.deleteDocument(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid document ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    finalizeDocument: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const idempotencyKey = request.headers['idempotency-key'];
        const key =
          idempotencyKey && typeof idempotencyKey === 'string'
            ? idempotencyKey
            : undefined;

        if (key && processedIdempotencyKeys.has(key)) {
          throw new AppError(
            'IDEMPOTENCY_CONFLICT',
            'Request already processed',
            409,
          );
        }

        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        const body = finalizePurchaseDocumentBodySchema.parse(
          request.body ?? {},
        );
        const data = await service.finalizeDocument(
          businessId,
          accountId,
          userId,
          id,
          body,
        );

        if (key) {
          processedIdempotencyKeys.add(key);
        }

        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    cancelDocument: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        const data = await service.cancelDocument(
          businessId,
          accountId,
          userId,
          id,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid document ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    convertDocument: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        const body = convertPurchaseDocumentBodySchema.parse(request.body);
        const data = await service.convertDocument(
          businessId,
          accountId,
          userId,
          id,
          body,
        );
        return sendData(reply, data, 201);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getPaymentHistory: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        const result = await service.getPaymentHistory(
          businessId,
          accountId,
          id,
        );
        return sendData(reply, result.data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid document ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    listLines: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        const data = await service.listLines(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid document ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    addLine: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = purchaseDocumentIdParamSchema.parse(request.params);
        const body = createPurchaseLineBodySchema.parse(request.body);
        const data = await service.addLine(
          businessId,
          accountId,
          userId,
          id,
          body,
        );
        return sendData(reply, data, 201);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    updateLine: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id, lineId } = purchaseLineIdParamSchema.parse(request.params);
        const body = updatePurchaseLineBodySchema.parse(request.body);
        const data = await service.updateLine(
          businessId,
          accountId,
          userId,
          id,
          lineId,
          body,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    deleteLine: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id, lineId } = purchaseLineIdParamSchema.parse(request.params);
        await service.deleteLine(businessId, accountId, userId, id, lineId);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid line ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
