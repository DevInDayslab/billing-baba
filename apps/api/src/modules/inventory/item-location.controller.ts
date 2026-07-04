import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import {
  createItemLocationBodySchema,
  itemLocationIdParamSchema,
  listItemLocationsQuerySchema,
  updateItemLocationBodySchema,
} from './item-location.schema';
import { ItemLocationService } from './item-location.service';
import type { PaginatedItemLocationsResponse } from './item-location.types';

export function createItemLocationController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedItemLocationsResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listItemLocationsQuerySchema.parse(request.query);
        const service = new ItemLocationService();
        const result = await service.listItemLocations(
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

    create: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const body = createItemLocationBodySchema.parse(request.body);
        const service = new ItemLocationService();
        const data = await service.createItemLocation(
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
        const { id } = itemLocationIdParamSchema.parse(request.params);
        const service = new ItemLocationService();
        const data = await service.getItemLocation(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item location ID',
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
        const { id } = itemLocationIdParamSchema.parse(request.params);
        const body = updateItemLocationBodySchema.parse(request.body);
        const service = new ItemLocationService();
        const data = await service.updateItemLocation(
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
        const { id } = itemLocationIdParamSchema.parse(request.params);
        const service = new ItemLocationService();
        await service.deleteItemLocation(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item location ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
