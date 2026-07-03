import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import { processedIdempotencyKeys } from '../../shared/http/idempotency';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import { SalesDocumentService } from './sales-document.service';
import {
  brandSwapBodySchema,
  convertSalesDocumentBodySchema,
  createPosSessionBodySchema,
  createSalesDocumentBodySchema,
  createSalesLineBodySchema,
  documentSequenceIdParamSchema,
  finalizeSalesDocumentBodySchema,
  listPosSessionsQuerySchema,
  listSalesDocumentsQuerySchema,
  posSessionIdParamSchema,
  salesDocumentIdParamSchema,
  salesLineIdParamSchema,
  updatePosSessionBodySchema,
  updateDocumentSequenceBodySchema,
  updateSalesDocumentBodySchema,
  updateSalesLineBodySchema,
} from './sales-document.schema';

export function createSalesDocumentController() {
  const service = new SalesDocumentService();

  return {
    listDocuments: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listSalesDocumentsQuerySchema.parse(request.query);
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
        const body = createSalesDocumentBodySchema.parse(request.body);
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
        const { id } = salesDocumentIdParamSchema.parse(request.params);
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
        const { id } = salesDocumentIdParamSchema.parse(request.params);
        const body = updateSalesDocumentBodySchema.parse(request.body);
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
        const { id } = salesDocumentIdParamSchema.parse(request.params);
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
        const { id } = salesDocumentIdParamSchema.parse(request.params);
        const body = finalizeSalesDocumentBodySchema.parse(request.body ?? {});
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
        const { id } = salesDocumentIdParamSchema.parse(request.params);
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
        const { id } = salesDocumentIdParamSchema.parse(request.params);
        const body = convertSalesDocumentBodySchema.parse(request.body);
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

    brandSwap: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = salesDocumentIdParamSchema.parse(request.params);
        const body = brandSwapBodySchema.parse(request.body);
        const data = await service.brandSwap(
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

    listLines: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = salesDocumentIdParamSchema.parse(request.params);
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
        const { id } = salesDocumentIdParamSchema.parse(request.params);
        const body = createSalesLineBodySchema.parse(request.body);
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
        const { id, lineId } = salesLineIdParamSchema.parse(request.params);
        const body = updateSalesLineBodySchema.parse(request.body);
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
        const { id, lineId } = salesLineIdParamSchema.parse(request.params);
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

    listPosSessions: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listPosSessionsQuerySchema.parse(request.query);
        const result = await service.listPosSessions(
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

    createPosSession: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const body = createPosSessionBodySchema.parse(request.body ?? {});
        const data = await service.createPosSession(
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

    getPosSession: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = posSessionIdParamSchema.parse(request.params);
        const data = await service.getPosSession(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid session ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    updatePosSession: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = posSessionIdParamSchema.parse(request.params);
        const body = updatePosSessionBodySchema.parse(request.body);
        const data = await service.updatePosSession(
          businessId,
          accountId,
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

    listPosSessionDocuments: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = posSessionIdParamSchema.parse(request.params);
        const query = listSalesDocumentsQuerySchema.parse(request.query);
        const result = await service.listPosSessionDocuments(
          businessId,
          accountId,
          id,
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

    listDocumentSequences: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      const { accountId, businessId } = requireAuthContext(request);
      const result = await service.listDocumentSequences(businessId, accountId);
      return sendData(reply, result.data);
    },

    updateDocumentSequence: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = documentSequenceIdParamSchema.parse(request.params);
        const body = updateDocumentSequenceBodySchema.parse(request.body);
        const data = await service.updateDocumentSequence(
          businessId,
          accountId,
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
  };
}
