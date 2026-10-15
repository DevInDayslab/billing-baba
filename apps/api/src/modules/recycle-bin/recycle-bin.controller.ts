import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  recycleBinEntityParamsSchema,
  recycleBinListQuerySchema,
} from './recycle-bin.schema';
import { RecycleBinService } from './recycle-bin.service';

export function createRecycleBinController() {
  const service = new RecycleBinService();

  return {
    list: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const query = recycleBinListQuerySchema.parse(request.query);
        const result = await service.list(businessId, accountId, query);
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

    restore: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const params = recycleBinEntityParamsSchema.parse(request.params);
        await service.restore(
          businessId,
          accountId,
          userId,
          params.entityType,
          params.entityId,
        );
        return sendData(reply, { success: true });
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    purge: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const params = recycleBinEntityParamsSchema.parse(request.params);
        await service.purge(
          businessId,
          accountId,
          userId,
          params.entityType,
          params.entityId,
        );
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
