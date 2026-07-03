import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  createGodownBodySchema,
  godownIdParamSchema,
  listGodownsQuerySchema,
  updateGodownBodySchema,
} from './godown.schema';
import { GodownService } from './godown.service';
import type { PaginatedGodownsResponse } from './godown.types';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';

export function createGodownController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedGodownsResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listGodownsQuerySchema.parse(request.query);
        const service = new GodownService();
        const result = await service.listGodowns(businessId, accountId, query);
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

    create: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const body = createGodownBodySchema.parse(request.body);
        const service = new GodownService();
        const data = await service.createGodown(
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

    getById: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = godownIdParamSchema.parse(request.params);
        const service = new GodownService();
        const data = await service.getGodown(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid godown ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    update: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = godownIdParamSchema.parse(request.params);
        const body = updateGodownBodySchema.parse(request.body);
        const service = new GodownService();
        const data = await service.updateGodown(
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

    delete: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = godownIdParamSchema.parse(request.params);
        const service = new GodownService();
        await service.deleteGodown(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid godown ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
